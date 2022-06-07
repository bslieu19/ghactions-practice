terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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