# Support Runbook & Operational Model — blueEagle Multi-Tenant Platform

This is the reference answer to "design and run an effective support
model for a production service." It has four parts: how we detect
problems, how we respond to them, how we recover, and how we make sure
the same problem doesn't happen twice.

## 1. Monitoring & Alerting

Each tenant gets its own CloudWatch dashboard and its own SNS topic —
findings in one tenant's platform should never page someone who only
owns another tenant.

| Signal | Threshold | Routes to |
|---|---|---|
| VPC NAT Gateway error rate | > 1% over 5 min | Tenant on-call (L1) |
| S3 4xx/5xx rate on tenant bucket | > 5% over 5 min | Tenant on-call (L1) |
| IAM role AccessDenied rate | Any sustained increase over baseline | Tenant on-call (L1) + platform security channel |
| Scheduled drift-detection pipeline | Any -detailed-exitcode of 2 (drift found) | Platform team, next business day (not a page) |
| Terraform apply failure (any tenant) | Any failure | Whoever triggered the apply + platform on-call |

## 2. Escalation Tiers

- **L1 (tenant on-call)** — first responder, follows the relevant
  symptom-diagnosis-remediation path below. Escalates to L2 if
  unresolved within 30 minutes or if the fix requires a change outside
  their own tenant's Terraform.
- **L2 (platform on-call)** — owns the shared modules and any
  cross-tenant concern. Escalates to L3 if the incident involves a
  security exposure (e.g. a security-group or IAM finding) or spans
  more than one tenant simultaneously.
- **L3 (platform lead + security)** — owns the incident from here;
  authorises any emergency change that bypasses the normal MR-reviewed
  pipeline, and is responsible for ensuring that bypass is
  retroactively reviewed and documented within 24 hours.

## 3. Symptom, Diagnosis, Remediation

### "Application in a tenant is unreachable"
1. Check the tenant's target group / security group first — is the
   expected ingress rule actually present? (Findings #3 and #9 in the
   Technical Debt Register exist precisely because nobody had a fast
   way to answer this question per-tenant before.)
2. Check terraform plan for that tenant against current state — has
   something drifted from what's declared in Git?
3. If infrastructure looks correct, escalate to application-level
   diagnosis (outside this repo's scope).

### "A tenant's Terraform apply failed"
1. Read the actual error — most failures are either a state lock held
   by a stuck previous run, or a genuine plan/apply mismatch (someone
   changed something out-of-band).
2. If it's a stuck lock: confirm no other apply is genuinely in
   progress, then release it deliberately (terraform force-unlock) —
   never as a first reflex.
3. If it's drift: treat it as an operational test finding — that's
   exactly the scenario drift-detection in .gitlab-ci.yml exists to
   catch automatically going forward. Add it to the Technical Debt
   Register if the drift's root cause isn't already listed there.

### "Cost alert / unexpected spend in a tenant"
1. Check the tenant's CostCentre tag against Cost Explorer, filtered
   by that tag — this is the entire reason finding #8 mattered enough
   to fix.
2. Compare against the last cost-check (Infracost) output for that
   tenant's most recent Merge Request — did the last approved change
   already account for this, or is this drift/out-of-band spend?

## 4. Recovery Objectives

| Tenant | RTO | RPO | Notes |
|---|---|---|---|
| retail | 4 hours | 1 hour | Oldest tenant, highest transaction volume |
| logistics | 4 hours | 1 hour | |
| partners | 8 hours | 4 hours | Lower criticality; confirm with tenant owner before treating as authoritative |

These numbers did not exist anywhere before this exercise's
remediation — they were assumed, never stated, and never tested. State
them explicitly, then periodically prove them: pick a non-production
window, deliberately terminate a resource (e.g. a NAT Gateway) that a
tenant depends on, and time how long actual recovery takes against the
number above. A number nobody has ever tested is a guess, not an RTO.

## 5. Incident Postmortem Template

Every incident above a defined severity threshold gets one of these,
within 3 business days, no exceptions for "it was a small one":

```
## Incident: <short title>
Date / duration:
Tenant(s) affected:
Severity:

### Timeline
(timestamped, factual, no blame)

### Root cause

### Contributing factors
(process gaps, not just the technical trigger — e.g. "no automated
drift detection existed" is a valid contributing factor)

### Action items
| Action | Owner | Due date | Tracked in Technical Debt Register? |
|---|---|---|---|

### Did our RTO/RPO assumptions hold?
```

The last section is deliberate: an incident is also, quietly, a free
test of the Recovery Objectives table above. Use it as one.

## 6. Closing the Loop

Every postmortem's action items that represent a systemic gap (not a
one-off human error) get added as a new row in
docs/technical-debt-register.md, with an owner and a due date. A
support model that investigates incidents well but never feeds
findings back into the codebase or backlog will keep having the same
incident, with a different timestamp, forever.
