output "site_bucket_name" {
  value = aws_s3_bucket.site.bucket
}

output "logs_bucket_name" {
  value = one(aws_s3_bucket.logs[*].bucket)
}

output "distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "website_url" {
  value = "https://${local.use_custom_domain ? var.domain_name : aws_cloudfront_distribution.site.domain_name}"
}

output "certificate_arn" {
  value = one(aws_acm_certificate_validation.this[*].certificate_arn)
}

output "web_acl_arn" {
  value = one(aws_wafv2_web_acl.this[*].arn)
}

output "deploy_role_arn" {
  value = one(aws_iam_role.deploy[*].arn)
}
