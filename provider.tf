terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.16.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-roboshop-rahul"   # Replace with your S3 bucket name
    key            = "terraform-module-test"          # Replace with your desired key/path
    region         = "us-east-1"                  # Replace with your AWS region
    encrypt        = true                         # Optional: Enable server-side encryption
    use_lockfile   = true                         # Optional: For state locking 
  }
}

provider "aws" {
  # Configuration options
}