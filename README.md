# Website infrastructure (OpenTofu / Terraform) — dev · staging · prod

Production-grade static-website hosting on AWS: **S3 (private) + CloudFront (OAC) + ACM + Route53 + optional WAF**.
Works with both **OpenTofu** and **Terraform** (>= 1.10). The Makefile auto-picks `tofu`, falling back to `terraform`.

```
bootstrap/state-backend/   remote-state S3 bucket (run once per AWS account, local state)
modules/static-site/       the reusable module (all the real logic)
environments/
  dev/      thin root module + terraform.tfvars + backend.hcl
  staging/  same code, different values
  prod/     same code, different values
scripts/deploy.sh          publish site files + cache headers + invalidation
.github/workflows/         infra CI (validate/plan/apply) + example site-deploy workflow
```

Each environment has its **own state** (`website/<env>/terraform.tfstate`) and is designed to run in its **own AWS account**
(`allowed_account_ids` guards against applying to the wrong one).

## What you get

| Concern | Implementation |
|---|---|
| Origin | Private S3 bucket, all public access blocked, SSE, TLS-only policy, versioning (+ lifecycle) |
| Access | CloudFront Origin Access Control (SigV4); bucket policy scoped to this one distribution |
| TLS | ACM cert (DNS-validated, us-east-1), `TLSv1.2_2021`, HTTP/2 + HTTP/3, IPv6, redirect to HTTPS |
| DNS | Route53 A + AAAA aliases for the primary domain and extra aliases (apex etc.) |
| Headers | HSTS, nosniff, X-Frame-Options, Referrer-Policy, Permissions-Policy, optional CSP |
| WAF | Rate limit per IP + AWS managed Common / KnownBadInputs / IP-reputation rules (staging, prod) |
| Routing | `/about/` → `/about/index.html` via CloudFront Function, or SPA mode (403/404 → `/index.html`) |
| Logging | CloudFront access logs to a private, encrypted, lifecycle-managed bucket |
| CI/CD | OIDC-based deploy role per env (no long-lived AWS keys), GitHub Actions plan/apply pipeline |

Environment differences live only in `terraform.tfvars`:

| | dev | staging | prod |
|---|---|---|---|
| Domain | none (`*.cloudfront.net`) | `staging.example.com` | `www.example.com` + apex |
| WAF | off | on (limit 1000) | on (limit 2000) |
| Price class | 100 | 100 | All |
| Versioning | off | on | on |
| Log retention | 30d | 90d | 365d |
| `force_destroy` | true | false | false |

## First-time setup

1. **Edit the placeholders**: `project`, account IDs, `hosted_zone_id`, domains in each `terraform.tfvars` / `backend.hcl`.
2. **Create the state bucket** in each AWS account (once):
   ```bash
   make bootstrap          # then copy the output bucket name into environments/<env>/backend.hcl
   ```
3. **Deploy an environment**:
   ```bash
   make plan  ENV=dev
   make apply ENV=dev
   make output ENV=dev     # website_url, site_bucket_name, distribution_id
   ```
   Repeat for `staging` and `prod`. The first apply with a custom domain waits for ACM DNS validation (a few minutes).
4. **Publish your site** (`./dist` = your build output):
   ```bash
   make deploy ENV=dev SITE_DIR=./dist
   ```

## CI/CD

- `infra.yml`: on PR → fmt, validate, tflint, trivy, then `plan` for all three envs. On merge to `main` → apply
  **dev → staging → prod** sequentially. Create GitHub Environments named `dev`, `staging`, `prod` and add
  **required reviewers on `prod`** for a manual approval gate.
- Repo variables `TF_ROLE_ARN_DEV|STAGING|PROD` = the IAM role Terraform itself uses in each account
  (create these by hand or in your org-level IaC; this repo does not create them).
- Site repo: set `github_repository` in tfvars → the module creates `<project>-<env>-site-deploy`, trusted only for
  `repo:<org>/<repo>:environment:<env>`. Use `deploy-site.example.yml` as a starting point.
  Only **one** GitHub OIDC provider can exist per AWS account: set `create_github_oidc_provider = true` in one env
  per account, and pass `github_oidc_provider_arn` in the others sharing that account.

## Production notes

- **Dev domain**: leave `domain_name = null` to skip DNS/ACM entirely; you still get a working HTTPS URL.
- **CSP**: the prod example is a starting point. Test it in staging before prod, it will block anything not listed.
- **Caching**: `deploy.sh` gives non-HTML files 1-year immutable caching, so use fingerprinted filenames (Vite/Webpack/Next do).
  HTML is `no-cache` and the distribution is invalidated on each deploy.
- **Destroying prod**: buckets refuse to delete when non-empty (`force_destroy = false`). The state bucket has `prevent_destroy`.
- **Costs**: WAF adds roughly a fixed monthly charge plus per-request fees, which is why dev has it off. CloudFront/S3 cost scales with traffic.
- **Not a server**: this hosts static files. If the site needs a backend (PHP, Node, API), the origin must change to ALB/ECS/EC2.
