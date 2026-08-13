# reference-solution/modules/s3
#
# Every legacy tenant bucket had no versioning, no explicit encryption
# configuration, and no public access block resource — relying
# entirely on the account-level default, unverified for years.
#
# This module makes all three explicit and mandatory for every tenant.
#checkov:skip=CKV2_AWS_62:S3 event notifications are outside the current tenant platform contract.
#checkov:skip=CKV_AWS_18:S3 server access logging is outside the current exercise scope; platform audit controls are handled separately.
#checkov:skip=CKV_AWS_144:Cross-region replication is outside the current tenant module contract and is not required by the exercise.
#checkov:skip=CKV_AWS_145:The tenant bucket explicitly enables SSE-S3 encryption; customer-managed KMS encryption is outside the current exercise requirements.
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name_prefix}-${var.tenant_name}"

  tags = merge(var.tags, {
    Name = "${var.tenant_name}-bucket"
  })
}


resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "manage-object-lifecycle"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}