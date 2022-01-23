# Create an IAM role for Airflow server to assume
resource "aws_iam_role" "disk_monitor" {
  name                 = "sns-disk_monitor"
  description          = "sns-disk_monitor IAM role for Airflow server"
  max_session_duration = 3600
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  inline_policy {
    name = "sns-disk_monitor"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "sns:Publish"
          Resource = [
            aws_sns_topic.disk_monitor.arn,
          ]
        },
      ]
    })
  }
}
resource "aws_iam_instance_profile" "disk_monitor" {
  name = aws_iam_role.disk_monitor.name
  role = aws_iam_role.disk_monitor.name
}

# Fetch ID of the latest official Ubuntu Focal AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
# Create Airflow server instance
resource "aws_instance" "disk_monitor" {
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_airflow_webserver.id]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.medium"
  key_name                    = var.ec2_key_name
  iam_instance_profile        = aws_iam_instance_profile.disk_monitor.id
  associate_public_ip_address = true
  user_data                   = templatefile(
    "${path.module}/scripts/setup.sh",
    {
      sns_topic = aws_sns_topic.disk_monitor.arn,
      project_name = "${var.project_name}-worker"
    }
  )
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    tags = {
      "Name" = "sns-disk_monitor"
    }
  }
  tags = {
    "Name" = "sns-disk_monitor"
  }
  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
      instance_state,
      instance_type
    ]
  }
}
