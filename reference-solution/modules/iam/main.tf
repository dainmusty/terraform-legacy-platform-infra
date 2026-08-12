# reference-solution/modules/iam
#
# Direct fix for technical-debt-register item #4: every tenant used to
# attach the SAME broad policy (s3:*, ec2:*, iam:PassRole on
# Resource: "*") — see ../../shared/iam-broad-role.tf in the legacy
# repo. This module gives each tenant their OWN role with permissions
# scoped to only the resources that tenant actually owns, so a
# compromise of one tenant's application role no longer implies
# compromise of the others.

resource "aws_iam_role" "tenant" {
  name = "${var.tenant_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "tenant_scoped_access" {
  name = "${var.tenant_name}-scoped-access"
  role = aws_iam_role.tenant.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TenantOwnBucketOnly"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "tenant" {
  name = "${var.tenant_name}-app-profile"
  role = aws_iam_role.tenant.name
}
