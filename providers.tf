locals {
  private_key_path = "Test.pem"
  ssh_user = "ubuntu"
  key_name = "Test"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

provider "aws" {}