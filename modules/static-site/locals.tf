data "aws_caller_identity" "current" {}

locals {
  name              = "${var.project}-${var.environment}"
  account_id        = data.aws_caller_identity.current.account_id
  use_custom_domain = var.domain_name != null
  aliases           = local.use_custom_domain ? concat([var.domain_name], var.additional_aliases) : []
  use_rewrite       = var.rewrite_directory_index && !var.single_page_app

  # Single place to decide how CloudFront answers 403/404 from S3.
  error_page = (
    var.single_page_app ? { path = "/index.html", code = 200 } :
    var.error_page_path != null ? { path = var.error_page_path, code = 404 } :
    null
  )

  managed_rule_groups = {
    AWSManagedRulesCommonRuleSet          = 10
    AWSManagedRulesKnownBadInputsRuleSet  = 20
    AWSManagedRulesAmazonIpReputationList = 30
  }
}
