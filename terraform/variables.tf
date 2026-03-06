variable "aws_region" {
  description = "AWS-Region"
  type = string
  default = "us-east-1"
}

variable "qr_bucket_name" {
  description = "Bucket for QR codes"
  type = string
  default = "nestor-qr-codes-2026"
}

variable "ecr_api_name" {
  description = "ECR for my API"
  type = string
  default = "ecr-for-api"
}

variable "ecr_frontend_name" {
  description = "ECR for my Frontend"
  type = string
  default = "ecr-for-frontend"
}

variable "ec2_ami" {
  description = "AMI for my EC2"
  type = string
  default = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ssh_ec2" {
  description = "SSH for my EC2"
  type = string
  default = "ssh_standart"
}