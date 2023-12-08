terraform {
  required_providers {
    aws = {
      version = ">4.0.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">1.0.0"
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Deployment  = "Terraform"
      Environment = "dev"
    }
  }
}
