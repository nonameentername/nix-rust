remote_state {
  backend = "s3"
  config = {
    region            = "us-east-1"
    endpoint          = "http://s3.localhost.localstack.cloud:4566"
    sts_endpoint      = "http://localhost:4566"
    dynamodb_endpoint = "http://localhost:4566"
    iam_endpoint      = "http://localhost:4566"
    bucket            = "my-terraform-state"
    key               = "${path_relative_to_include()}/terraform.tfstate"
    encrypt           = true
    dynamodb_table    = "my-lock-table"
    profile           = "default"

    skip_bucket_ssencryption    = true
    skip_bucket_root_access     = true
    skip_bucket_enforced_tls    = true
    skip_bucket_public_access_blocking = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
