# bootstrap
#
# Run ONCE, locally, with a local state file (there is no remote backend
# yet — that's what this creates). It provisions the S3 bucket and
# DynamoDB lock table that the root module's backend.tf will use.
#
# This is the classic Terraform "chicken and egg" bootstrap problem:
# you cannot store state remotely before the remote store exists.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Deliberately no backend block — this config keeps its (tiny) state
  # locally in bootstrap/terraform.tfstate. Do not delete that file once
  # you have real infrastructure depending on the bucket/table it manages.
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "blueeagle-tfstate-${var.trainee_name}"

  tags = {
    Project = "blueEagle"
    Purpose = "terraform-remote-state"
    Owner   = var.trainee_name
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "blueeagle-tfstate-lock-${var.trainee_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "blueEagle"
    Owner   = var.trainee_name
  }
}
