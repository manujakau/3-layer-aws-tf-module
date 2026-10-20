terraform {
  required_version = ">= 1.0"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.33.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}
