project     = "mysite"
environment = "dev"

# allowed_account_ids = ["111111111111"]   # dev AWS account

# No custom domain in dev: use the generated https://xxxx.cloudfront.net URL.
domain_name = null

price_class        = "PriceClass_100"
enable_waf         = false
enable_versioning  = false
enable_access_logs = true
log_retention_days = 30
force_destroy      = true # dev only: lets `destroy` empty the buckets

# github_repository           = "your-org/your-site"
# create_github_oidc_provider = true   # set true in ONE env per AWS account
