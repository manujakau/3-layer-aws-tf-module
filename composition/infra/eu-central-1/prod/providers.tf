terraform {
  required_version = ">= 1.0"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.22.1"
      configuration_aliases = [aws.XXX_old]
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}

provider "aws" {
  alias = "XXX_old"
}
