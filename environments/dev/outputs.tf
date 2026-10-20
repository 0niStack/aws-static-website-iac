output "website_url" {
  value = module.site.website_url
}

output "site_bucket_name" {
  value = module.site.site_bucket_name
}

output "distribution_id" {
  value = module.site.distribution_id
}

output "distribution_domain_name" {
  value = module.site.distribution_domain_name
}

output "deploy_role_arn" {
  value = module.site.deploy_role_arn
}
