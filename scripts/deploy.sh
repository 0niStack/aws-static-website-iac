#!/usr/bin/env bash
# Publish a built site to an environment: scripts/deploy.sh <dev|staging|prod> <site_dir>
set -euo pipefail

ENV="${1:?usage: deploy.sh <dev|staging|prod> <site_dir>}"
SITE_DIR="${2:?usage: deploy.sh <dev|staging|prod> <site_dir>}"
TF="${TF:-$(command -v tofu || command -v terraform)}"
DIR="environments/${ENV}"

[ -d "$SITE_DIR" ] || { echo "site dir not found: $SITE_DIR" >&2; exit 1; }

BUCKET="$("$TF" -chdir="$DIR" output -raw site_bucket_name)"
DIST_ID="$("$TF" -chdir="$DIR" output -raw distribution_id)"

echo "Deploying $SITE_DIR -> s3://$BUCKET ($ENV)"

# 1) Assets: long-lived cache (use fingerprinted filenames!). HTML excluded here.
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete \
  --exclude "*.html" \
  --cache-control "public,max-age=31536000,immutable"

# 2) HTML: always revalidate so a deploy is visible immediately.
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete \
  --exclude "*" --include "*.html" \
  --cache-control "no-cache"

aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*" >/dev/null
echo "Done: $("$TF" -chdir="$DIR" output -raw website_url)"
