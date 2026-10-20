bucket       = "mysite-tfstate-111111111111" # output of bootstrap/state-backend
key          = "website/dev/terraform.tfstate"
region       = "ap-southeast-1"
encrypt      = true
use_lockfile = true # S3-native locking (Terraform/OpenTofu >= 1.10), no DynamoDB needed
