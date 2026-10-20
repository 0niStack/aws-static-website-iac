module "site" {
  source = "../../modules/static-site"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project     = var.project
  environment = var.environment

  domain_name        = var.domain_name
  additional_aliases = var.additional_aliases
  hosted_zone_id     = var.hosted_zone_id

  single_page_app         = var.single_page_app
  error_page_path         = var.error_page_path
  price_class             = var.price_class
  content_security_policy = var.content_security_policy

  enable_waf     = var.enable_waf
  waf_rate_limit = var.waf_rate_limit

  enable_versioning  = var.enable_versioning
  enable_access_logs = var.enable_access_logs
  log_retention_days = var.log_retention_days
  force_destroy      = var.force_destroy

  github_repository           = var.github_repository
  create_github_oidc_provider = var.create_github_oidc_provider
  github_oidc_provider_arn    = var.github_oidc_provider_arn
}
