output "ec2_public_ip" {
  description = "Public IP from EC2"
  value = aws_instance.ec2.public_ip
}

output "ecr_api_url" {
  description = "ECR API URL"
  value = aws_ecr_repository.ecr_api.repository_url
}

output "ecr_frontend_url" {
  description = "ECR Frontend URL"
  value = aws_ecr_repository.ecr_frontend.repository_url
}

output "s3_name" {
  description = "S3 Bucket Name"
  value = aws_s3_bucket.s3_qr.bucket
}

