terraform {
  required_version = ">= 1.1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
