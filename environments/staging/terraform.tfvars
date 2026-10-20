project     = "mysite"
environment = "staging"

# allowed_account_ids = ["222222222222"]   # staging AWS account

domain_name    = "staging.example.com"
hosted_zone_id = "Z0000000000000000000"

price_class        = "PriceClass_100"
enable_waf         = true
waf_rate_limit     = 1000
enable_versioning  = true
enable_access_logs = true
log_retention_days = 90
force_destroy      = false

# github_repository        = "your-org/your-site"
# github_oidc_provider_arn = "arn:aws:iam::222222222222:oidc-provider/token.actions.githubusercontent.com"
