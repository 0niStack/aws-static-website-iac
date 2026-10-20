terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Values come from backend.hcl:  tofu init -backend-config=backend.hcl
  backend "s3" {}
}
