terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.33.0"
    }
  }

  # comment out for the first apply in a new account (no bucket yet)
  backend "s3" {}
}