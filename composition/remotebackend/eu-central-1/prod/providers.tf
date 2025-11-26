terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.22.1"
    }
  }

  # backend "s3" {} # use local backend to first create S3 bucket to store .tfstate later
}