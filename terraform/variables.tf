variable "profile" {
  type        = string
  description = "Name of the AWS CLI profile that will run these actions."
}
variable "region" {
  type        = string
  description = "Name of the AWS region where to deploy these resources."
}
variable "ec2_key_name" {
  type        = string
  description = "Name of the EC2 key pair (must already exist) that will be used to log in to instances."
}
variable "project_name" {
  type        = string
  description = "Name of the project."
}

data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}
