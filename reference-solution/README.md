A worked example of a passing remediation: shared `modules/` (vpc,
iam, s3), three refactored `tenants/` consuming them with isolated
per-tenant state, a complete `.gitlab-ci.yml` implementing the
functional/non-functional/operational test strategy, and three
`docs/` deliverables (technical debt register, support runbook,
presentation outline).

**Do not push this folder's contents to the branch trainees clone
from.** The exercise is for each trainee to produce their own
assessment and remediation of the legacy repo as it ships. Use this to
validate your training AWS account setup, grade submissions, or
unblock a stuck trainee.

![Architecture Diagram](../blueeagle-legacy-platform-infra.png)

## Before handing out the exercise

1. Confirm the legacy repo (repo root — `tenants/`, `shared/`, the
   sparse README) is what trainees actually see; this folder should
   not be visible to them.
2. Set up your own Terraform remote state backend (run the
   `bootstrap/` config in this repo once, locally).
3. Set the CI/CD variables listed at the top of `.gitlab-ci.yml`,
   including an Infracost API key (free tier is enough).
4. Push to a throwaway branch and confirm the pipeline runs cleanly
   across all three tenants in the matrix, including a manual apply.
5. Revert / discard the throwaway branch.

## Grading notes

This exercise is less "did the code run" and more "did the trainee
correctly identify and prioritise the debt, and can they defend their
plan out loud." Weight accordingly:

- **The Technical Debt Register** should read like the one here in
  structure (finding, location, risk, remediation) even if the
  specific wording differs — a trainee who lists ten vague, generic
  IaC best-practice tips instead of the ten *specific* problems
  actually present in `tenants/` and `shared/` hasn't done the
  assessment.
- **The three tenants should end up structurally consistent** (same
  modules, same tagging, same version pin) — a remediation that fixes
  `retail` well but leaves `logistics` and `partners` in their
  original state hasn't addressed the systemic issue, just one
  symptom of it.
- **The presentation is a real assessment artefact, not a formality.**
  Score it on whether a non-technical, senior audience would actually
  follow it in 7 minutes, not on Terraform correctness (that's already
  covered by the pipeline).
- **The three post-interview questions (see the exercise document's
  Interview Discussion section) are meant to be asked live**, not
  answered in writing, and are your best signal for whether the
  written deliverables reflect real understanding or something
  produced without engaging with why each fix matters.

## Commit and Branch Naming Convention (what trainees should actually be told)

The trainee-facing README is deliberately sparse — that's the exercise's
premise, not an oversight. But trainees still need the real convention
to complete this exercise correctly, so it lives here instead:

This project corresponds to **Capstone Proj 11** in ClickUp, tickets
`WANP-1101` through `WANP-1106`.

- **Branch naming:** `feature/WANP-11XX-<short-description>`
- **Commit messages:** `WANP-11XX: <imperative description>`
- **Merge Request titles:** `WANP-11XX: <Title>`

Point trainees to this section (or just tell them directly) rather
than polishing the trainee README itself — see the workspace README's
full **Commit and Branch Naming Convention** section for the complete
reasoning.
## Local setup (recommended)

After cloning this repo, run once:

    bash scripts/install-hooks.sh

This installs a `pre-push` git hook that checks your branch name locally
before you push, so you catch naming mistakes before waiting on a pipeline.

> This local check is a convenience only. It can be skipped (e.g.
> `git push --no-verify`) and is not a substitute for CI enforcement,
> which is the actual policy gate and cannot be bypassed.
## Prerequisites this assumes are already running

- Your own Terraform remote state backend (run the `bootstrap/`
  config in this repo once, locally — one state bucket/table can hold
  all three tenants' state under different keys)
- An Infracost API key
- A GitLab Runner capable of running the images referenced in
  `.gitlab-ci.yml` (`checkov`, `tfsec`, `infracost/infracost`, plus the
  standard `hashicorp/terraform` image already used elsewhere in this
  series)
