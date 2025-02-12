terraform {
  required_version = ">= 1.0"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.84.0"
      configuration_aliases = [ aws.XXX_old ]
    }
  }
}

provider "aws" {
  alias = "XXX_old"
}