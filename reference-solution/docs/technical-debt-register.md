# Technical Debt Register — blueEagle Multi-Tenant Platform

This is the reference assessment of `tenants/`, `shared/`, and the
repository as a whole, as it existed before remediation. Your own
register (see the exercise document) should be in this shape — a
findable list a stakeholder could read without opening any Terraform
— not prose.

| # | Finding | Where | Risk | Remediation |
|---|---|---|---|---|
| 1 | No remote state, no locking — state lives on whichever engineer's laptop last ran `apply` | All three tenants | Concurrent applies can corrupt state; no shared history; a laptop failure is a disaster-recovery event | Per-tenant S3 backend + DynamoDB lock table |
| 2 | `partners` has no VPC of its own — hardcodes `retail`'s VPC/subnet IDs as local values | `tenants/partners/main.tf` | Recreating `retail`'s VPC silently breaks `partners`, or worse, points it at whatever resource reuses that ID | Give `partners` its own VPC via the shared module; remove the hardcoded IDs entirely |
| 3 | Admin security group allows SSH/RDP from `0.0.0.0/0`, added as a "temporary" incident fix and never narrowed | `tenants/retail/main.tf` | Internet-exposed administrative access to production infrastructure | Restrict to named CIDR ranges via a variable; omit the security group entirely where no admin access is needed |
| 4 | All three tenants attach the same broad IAM policy (`s3:*`, `ec2:*`, `iam:PassRole` on `Resource: "*"`) | `shared/iam-broad-role.tf`, referenced by ARN string in each tenant | Compromise of any one tenant's application role is effectively compromise of all three | Per-tenant IAM role scoped to only that tenant's own bucket and resources |
| 5 | No consistent Terraform/provider version pinning — `retail` and `partners` have none at all, `logistics` pins a different major version | All three tenants | Unreviewed upstream provider changes can silently alter behaviour; the three tenants can't safely share modules until this is fixed | One pinned `required_version` and provider version constraint, applied identically everywhere |
| 6 | No CI/CD of any kind — changes are applied manually, from individual laptops, with no review or audit trail | Entire repository | Unreviewed changes reach production; no record of who changed what, when, or why | GitLab CI/CD: static analysis → plan (reviewed on the MR) → manual apply, matching every other Terraform repo in this series |
| 7 | No automated testing or validation of any kind | Entire repository | Regressions and misconfigurations ship unnoticed until they cause an incident | Static analysis (`checkov`, `tfsec`) as functional/non-functional gates; scheduled drift detection as an operational gate — see `docs/support-runbook.md` |
| 8 | No tagging standard — no `Owner`, `CostCentre`, or consistent `Tenant` tag anywhere | All three tenants | Cost allocation across tenants is not possible; ownership during an incident has to be established by asking around | A mandatory common tag set (`Tenant`, `Owner`, `ManagedBy`, `CostCentre`) applied via `default_tags` on every tenant's provider block |
| 9 | Copy-pasted, drifted per-tenant networking/storage/IAM code — no shared modules | All three tenants | A fix applied to one tenant (e.g. the SG issue in finding #3) doesn't propagate to the others; security posture is inconsistent by accident, not by design | Extract `modules/vpc`, `modules/iam`, `modules/s3`; every tenant consumes the same module |
| 10 | No documented or tested disaster-recovery / backup strategy | Entire repository | RTO/RPO are unknown; recovery capability is unverified, not just undocumented | `docs/support-runbook.md`'s recovery procedures, plus a periodic recovery drill (see the exercise document's Operational Test requirement) |

## How this register should be used going forward

This is a living document, not a one-time audit. Every incident
postmortem (see `docs/support-runbook.md`'s template) that identifies
a contributing cause not already listed here should add a new row —
closing the loop between "we had an incident" and "we now have a
tracked, owned action to stop it recurring," which is the direct
answer to the support-model interview question this exercise is built
around.
