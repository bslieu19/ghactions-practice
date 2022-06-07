terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.5"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  cloud {
    organization = "Tempest-Cor"

    workspaces {
      name = "AWS"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = $AWS_ACCESS_KEY_ID
  secret_key = $AWS_SECRET_ACCESS_KEY
}