data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = local.name
  description                       = "OAC for ${local.name} site bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "index_rewrite" {
  count   = local.use_rewrite ? 1 : 0
  name    = "${local.name}-index-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/functions/index-rewrite.js")
}

resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${local.name}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = var.hsts_max_age
      include_subdomains         = true
      preload                    = false
      override                   = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    dynamic "content_security_policy" {
      for_each = var.content_security_policy == null ? [] : [var.content_security_policy]
      content {
        content_security_policy = content_security_policy.value
        override                = true
      }
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "camera=(), microphone=(), geolocation=()"
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  comment             = "${local.name} website"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = local.aliases
  web_acl_id          = var.enable_waf ? aws_wafv2_web_acl.this[0].arn : null

  origin {
    origin_id                = "s3-site"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-site"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id

    dynamic "function_association" {
      for_each = local.use_rewrite ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.index_rewrite[0].arn
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = local.error_page == null ? [] : [403, 404]
    content {
      error_code            = custom_error_response.value
      response_code         = local.error_page.code
      response_page_path    = local.error_page.path
      error_caching_min_ttl = 10
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_type == "none" ? [] : var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_domain ? null : true
    acm_certificate_arn            = one(aws_acm_certificate_validation.this[*].certificate_arn)
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
  }

  dynamic "logging_config" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket          = aws_s3_bucket.logs[0].bucket_domain_name
      prefix          = "cloudfront/"
      include_cookies = false
    }
  }

  depends_on = [
    aws_s3_bucket_ownership_controls.logs,
    aws_s3_bucket_public_access_block.logs,
  ]
}
