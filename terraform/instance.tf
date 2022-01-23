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
  user_data                   = <<EOF
#!/bin/bash
set -e
mkdir -p /home/ubuntu/.disk_monitor/
git -C /home/ubuntu/.disk_monitor/ clone https://github.com/pedrofbo/disk_monitor.git
apt-get update
apt-get install -y python3-pip python3-virtualenv
virtualenv /home/ubuntu/.disk_monitor/.env
source /home/ubuntu/.disk_monitor/.env/bin/activate
pip3 install -r /home/ubuntu/.disk_monitor/disk_monitor/requirements.txt
mkdir -p /home/ubuntu/.aws
echo -e "[default]\nregion = us-east-1" >> /home/ubuntu/.aws/config
echo -e \
  '{\n\t"threshold": 0.2,\n\t"sns_topic": "${aws_sns_topic.disk_monitor.arn}",\n\t"instance_name":"${var.project_name}-worker"\n}' \
  >> /home/ubuntu/.disk_monitor/disk_monitor/config.json
echo "* * * * * cd /home/ubuntu/.disk_monitor/disk_monitor/; . ../.env/bin/activate; python monitor.py -c config.json" >> /tmp/disk_monitor
sudo -u ubuntu bash -c "crontab /tmp/disk_monitor"
EOF
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
