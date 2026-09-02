# BlueEagle Multi-Tenant Platform — Infrastructure Remediation

> Terraform-based remediation of a legacy AWS multi-tenant platform supporting Retail, Logistics, and Partners.

![Architecture Diagram](architecture/blueeagle-legacy-platform-infra.png)

## Table of Contents

- [Overview](#overview)
- [What Changed](#what-changed)
- [Architecture](#architecture)
- [CI/CD](#cicd)
- [Security](#security)
- [Operational Improvements](#operational-improvements)
- [Repository Structure](#repository-structure)
- [Documentation](#documentation)
- [Getting Started](#getting-started)
- [Branch and Commit Convention](#branch-and-commit-convention)
- [Outcome](#outcome)

## Overview

BlueEagle is a shared AWS platform supporting three tenants:

- Retail
- Logistics
- Partners

The legacy platform had accumulated infrastructure and operational debt over
time, including limited automation, inconsistent tenant configuration,
security gaps, and insufficient operational controls.

The objective of this remediation is **not to rebuild the platform**, but to
make it safer, more consistent, and supportable for the next five years.

## What Changed

The remediation introduces:

- Reusable Terraform modules for shared infrastructure
- Consistent configuration across all three tenants
- Isolated per-tenant Terraform state
- Explicit S3 security controls
- Customer-managed KMS encryption
- KMS key policies and rotation
- Consistent resource tagging
- Automated Terraform validation
- Infrastructure security scanning with Checkov
- Security posture scanning with tfsec
- Infrastructure cost analysis with Infracost
- Terraform drift detection
- Controlled manual infrastructure deployment
- Documented operational and recovery procedures

## Architecture

Each tenant consumes the same shared Terraform modules while maintaining its
own configuration and state.

```text
                    ┌──────────────────────────┐
                    │       GitLab CI/CD        │
                    │                          │
                    │ Format / Validate        │
                    │ Checkov / Plan           │
                    │ Cost / Security          │
                    │ Drift / Manual Apply     │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
          ┌────────┐         ┌────────┐         ┌────────┐
          │ Retail │         │Logistics│        │Partners│
          └────┬───┘         └────┬───┘         └────┬───┘
               │                  │                  │
               └──────────────────┼──────────────────┘
                                  ▼
                    ┌──────────────────────────┐
                    │   Shared Terraform       │
                    │        Modules            │
                    │                          │
                    │     VPC   IAM   S3       │
                    └──────────────────────────┘
```

## CI/CD

```
The GitLab pipeline provides quality gates before infrastructure deployment.

| Stage             | Purpose                                       |
| ----------------- | --------------------------------------------- |
| Functional Static | Terraform formatting, validation, and Checkov |
| Functional Plan   | Generate Terraform plans for review           |
| Non-Functional    | Cost and security checks                      |
| Operational       | Scheduled drift detection                     |
| Apply             | Controlled manual deployment                  |

```

The pipeline uses a tenant matrix so the same controls are applied consistently
to Retail, Logistics, and Partners.

Terraform plans are stored as pipeline artifacts and must pass the required
checks before deployment.

Infrastructure deployment is intentionally manual on the main branch.

Security

Security controls were made explicit rather than relying on undocumented
account-level defaults.

Key improvements include:

S3 public access blocking
S3 versioning
S3 lifecycle management
Customer-managed KMS encryption
KMS key rotation
Explicit KMS key policy
Automated Checkov scanning
Automated tfsec scanning
Security checks before infrastructure deployment

The pipeline prevents known security issues from progressing to deployment.

Operational Improvements

The remediation also addresses operational debt.

The platform now includes:

Scheduled Terraform drift detection
Defined escalation procedures
Documented recovery expectations
Tenant-specific operational procedures
Incident-to-technical-debt feedback
Owned remediation actions

See the Support Runbook for the detailed operating
model.

## Repository Structure

```
├── bootstrap/
├── docs/
│   ├── technical-debt-register.md
│   ├── support-runbook.md
│   └── presentation-outline.md
│
├── reference-solution/
│   ├── modules/
│   │   ├── iam/
│   │   ├── s3/
│   │   └── vpc/
│   │
│   ├── tenants/
│   │   ├── retail/
│   │   ├── logistics/
│   │   └── partners/
│   │
│   └── .github/workflows/multi-tenant-ci.yml
│
├── scripts/
├── blueeagle-legacy-platform-infra.png
└── README.md

```
## Documentation

Detailed project information is intentionally kept in docs/ rather than
making the root README unnecessarily large.
| Document                                                   | Purpose                                       |
| ---------------------------------------------------------- | --------------------------------------------- |
| [Technical Debt Register](reference-solution/docs/technical-debt-register.md) | Findings, risks, priorities, and remediation  |
| [Support Runbook](reference-solution/docs/support-runbook.md)                 | Support, escalation, monitoring, and recovery |
| [Presentation Outline](reference-solution/docs/presentation-outline.md)       | Executive presentation and Q&A preparation    |


## Getting Started

Prerequisites

- Terraform
- AWS credentials
- AWS remote state backend
- Git
- GitLab access
- Infracost API key

Install Git Hooks

- bash scripts/install-hooks.sh

Initialize a Tenant

- cd reference-solution/tenants/retail
- terraform init

Validate

- terraform fmt -check -recursive
- terraform validate

Planning and applying infrastructure should normally be performed through the
CI/CD pipeline rather than individual developer machines.

## Branch and Commit Convention

* Changes should reference the associated ClickUp work item.

1. Branch
feature/WANP-11XX-short-description

2. Commit
WANP-11XX: imperative description

3. Merge Request
WANP-11XX: Title

* Local Git hooks provide an early check, while CI/CD provides the authoritative
quality gate.

## Outcome

The remediation transforms the legacy platform from a largely manual and
inconsistent infrastructure workflow into a more controlled and repeatable
multi-tenant platform.

The resulting approach provides:

- Consistent tenant architecture
- Better tenant isolation
- Stronger security controls
- Automated infrastructure testing
- Cost visibility
- Drift detection
- Controlled deployments
- Documented operational procedures


The goal is not simply to make Terraform pass.

The goal is to make the platform safer to change, easier to operate, and
defensible to the business.