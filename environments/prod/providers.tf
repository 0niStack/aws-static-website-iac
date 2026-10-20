locals {
  default_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = var.allowed_account_ids # guard: refuse to run against the wrong account

  dynamic "assume_role" {
    for_each = var.assume_role_arn == null ? [] : [var.assume_role_arn]
    content {
      role_arn     = assume_role.value
      session_name = "tf-${var.project}-${var.environment}"
    }
  }

  default_tags {
    tags = local.default_tags
  }
}

# CloudFront certificates and WAF (scope CLOUDFRONT) are global resources that live in us-east-1.
provider "aws" {
  alias               = "us_east_1"
  region              = "us-east-1"
  allowed_account_ids = var.allowed_account_ids

  dynamic "assume_role" {
    for_each = var.assume_role_arn == null ? [] : [var.assume_role_arn]
    content {
      role_arn     = assume_role.value
      session_name = "tf-${var.project}-${var.environment}"
    }
  }

  default_tags {
    tags = local.default_tags
  }
}
