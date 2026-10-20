project     = "mysite"
environment = "prod"

# allowed_account_ids = ["333333333333"]   # prod AWS account

domain_name        = "www.example.com"
additional_aliases = ["example.com"]
hosted_zone_id     = "Z0000000000000000000"

price_class        = "PriceClass_All"
enable_waf         = true
waf_rate_limit    = 2000

# Tighten for your real asset origins before go-live.
content_security_policy = "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; frame-ancestors 'none'"

enable_versioning  = true
enable_access_logs = true
log_retention_days = 365
force_destroy      = false

# github_repository        = "your-org/your-site"
# github_oidc_provider_arn = "arn:aws:iam::333333333333:oidc-provider/token.actions.githubusercontent.com"
