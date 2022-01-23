# Create a VPC to run tasks and Airflow instance
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "disk_monitor"
  }
}
# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
# Create subnet in the VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "disk_monitor"
  }
}
# Create a route table and associate it to the subnet
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "disk_monitor-public_subnet"
  }
}
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
# Create a security group behind which Airflow instance will be placed
resource "aws_security_group" "allow_airflow_webserver" {
  name        = "disk_monitor-sns"
  description = "Used by disk_monitor Airflow server"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
