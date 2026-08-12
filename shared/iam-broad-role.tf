# shared/iam-broad-role.tf
#
# Created early in the platform's life "so any tenant's app could get
# whatever AWS access it needed without waiting on a change request."
# Ten years later, all three tenants still attach this SAME policy —
# meaning a compromise of any one tenant's application effectively
# grants the same access across all of them, and nobody can safely
# tighten it without checking whether EVERY tenant still depends on
# whichever specific permission they'd remove.
#
# This file isn't referenced by any tenant's Terraform directly (the
# ARN is hardcoded as a string in each tenant's
# aws_iam_role_policy_attachment instead — see tenants/*/main.tf) —
# which is itself part of the problem: there's no Terraform-visible
# dependency showing that three tenants rely on this one policy.

resource "aws_iam_policy" "shared_platform_access" {
  name        = "wandaprep-shared-platform-access"
  description = "Shared access policy used by all blueEagle tenant application roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })
}
