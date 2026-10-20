terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.81, < 7.0"
      configuration_aliases = [aws.us_east_1] # CloudFront certs + WAF must live in us-east-1
    }
  }
}
