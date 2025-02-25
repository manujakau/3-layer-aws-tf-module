terraform {
  required_version = ">= 1.0"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.84.0"
      configuration_aliases = [aws.XXX_old]
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.1"
    }
  }
}

provider "aws" {
  alias = "XXX_old"
}
