resource "aws_s3_bucket" "s3_qr" {
  bucket = var.qr_bucket_name
  force_destroy = true

  tags = {
    Name        = var.qr_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "qr_bucket" {
  bucket = aws_s3_bucket.s3_qr.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "qr_bucket" {
  bucket = aws_s3_bucket.s3_qr.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_ecr_repository" "ecr_api" {
  name                 = var.ecr_api_name
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "aws_ecr_repository" "ecr_frontend" {
  name                 = var.ecr_frontend_name
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "qr-code-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "qr-code-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.vpc.id
  tags = {
  Name = "qr-code-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "qr-code-rt"
  }

}

resource "aws_route_table_association" "rt_attach" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
  
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Blocks for 22 (SSH)"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Blocks for 80 (HTTP)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Blocks for 3000 (frontend)"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Blocks for 8000 (API)"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "qr-code-sg"
  }
}

resource "aws_instance" "ec2" {
  ami           = var.ec2_ami
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = var.ssh_ec2
  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y docker git aws-cli
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  mkdir -p /usr/local/lib/docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
EOF

  tags = {
    Name = "qr-code-ec2"
  }
}