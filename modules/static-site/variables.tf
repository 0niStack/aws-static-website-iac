variable "project" {
  description = "Short project name, used as a resource name prefix."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,24}$", var.project))
    error_message = "project must be 2-24 chars: lowercase letters, digits, hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ---------- Domain / TLS ----------
variable "domain_name" {
  description = "Primary FQDN (e.g. www.example.com). null = use the default *.cloudfront.net domain."
  type        = string
  default     = null
}

variable "additional_aliases" {
  description = "Extra FQDNs (e.g. the apex domain). Must live in the same hosted zone."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID. Required when domain_name is set."
  type        = string
  default     = null

  validation {
    condition     = var.domain_name == null || var.hosted_zone_id != null
    error_message = "hosted_zone_id is required when domain_name is set."
  }
}

# ---------- Site behaviour ----------
variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "single_page_app" {
  description = "Serve /index.html (HTTP 200) for unknown paths. For React/Vue/Angular SPAs."
  type        = bool
  default     = false
}

variable "rewrite_directory_index" {
  description = "Map /about/ and /about to /about/index.html (Hugo, Astro, Next export...). Ignored for SPAs."
  type        = bool
  default     = true
}

variable "error_page_path" {
  description = "Custom 404 page (e.g. /404.html) for non-SPA sites. null = default CloudFront error."
  type        = string
  default     = null
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be PriceClass_100, PriceClass_200 or PriceClass_All."
  }
}

# ---------- Security ----------
variable "content_security_policy" {
  description = "Value for the Content-Security-Policy header. null = header not set."
  type        = string
  default     = null
}

variable "hsts_max_age" {
  type    = number
  default = 63072000 # 2 years
}

variable "enable_waf" {
  description = "Attach an AWS WAFv2 web ACL (managed rules + rate limit) to CloudFront."
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "Max requests per 5 minutes per IP before WAF blocks."
  type        = number
  default     = 2000
}

variable "geo_restriction_type" {
  type    = string
  default = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "geo_restriction_type must be none, whitelist or blacklist."
  }
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1 alpha-2 country codes."
  type        = list(string)
  default     = []
}

# ---------- Storage / logging ----------
variable "enable_versioning" {
  type    = bool
  default = true
}

variable "noncurrent_version_expiration_days" {
  type    = number
  default = 90
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
  description = "Allow destroying non-empty buckets. Keep false for prod."
  type        = bool
  default     = false
}

# ---------- CI/CD deploy role (GitHub Actions OIDC) ----------
variable "github_repository" {
  description = "org/repo allowed to deploy the site content. null = no deploy role is created."
  type        = string
  default     = null
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Only one may exist per AWS account."
  type        = bool
  default     = false
}

variable "github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN (when create_github_oidc_provider = false)."
  type        = string
  default     = null
}
