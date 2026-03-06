terraform {
  backend "s3" {
    bucket         = "nestor-terraform-state"
    key            = "qr-code/terraform.tfstate"
    region         = "us-east-1"
  }
}
