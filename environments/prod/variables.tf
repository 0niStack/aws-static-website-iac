variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  description = "Region for the S3 buckets (CloudFront/WAF/ACM always use us-east-1)."
  type        = string
  default     = "ap-southeast-1"
}

variable "allowed_account_ids" {
  description = "If set, Terraform aborts unless the credentials belong to one of these accounts."
  type        = list(string)
  default     = null
}

variable "assume_role_arn" {
  description = "Optional role to assume (e.g. a per-account deployer role)."
  type        = string
  default     = null
}

variable "domain_name" {
  type    = string
  default = null
}

variable "additional_aliases" {
  type    = list(string)
  default = []
}

variable "hosted_zone_id" {
  type    = string
  default = null
}

variable "single_page_app" {
  type    = bool
  default = false
}

variable "error_page_path" {
  type    = string
  default = null
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "content_security_policy" {
  type    = string
  default = null
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "waf_rate_limit" {
  type    = number
  default = 2000
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "enable_access_logs" {
  type    = bool
  default = true
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "github_repository" {
  type    = string
  default = null
}

variable "create_github_oidc_provider" {
  type    = bool
  default = false
}

variable "github_oidc_provider_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
