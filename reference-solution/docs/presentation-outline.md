# Stakeholder Presentation — Reference Outline

For the 7-minute presentation + 3-minute Q&A described in the exercise
document. This is a structure to adapt, not a script to read —
presenting to a C-officer-level audience means leading with outcomes
and risk, not with Terraform syntax.

## Suggested structure (7 minutes)

**0:00-1:00 — The situation, in business terms**
- One shared platform, three tenants, ten years old, no single team
  has ever owned all of it end to end
- Frame the ask precisely: not "modernise everything," but "make this
  supportable for another 5 years" — a narrower, achievable mandate
- One sentence on why this matters to them specifically: unmanaged
  technical debt is deferred cost and unbounded risk, and right now
  nobody can quantify either

**1:00-2:30 — What we found (the debt register, summarised)**
- Don't read all 10 findings — group them into 3 themes an executive
  can hold in their head:
  1. No safety net (no CI/CD, no tests, no state locking) — changes
     are made on faith
  2. No isolation (shared IAM policy, hardcoded cross-tenant
     references) — one tenant's incident can become three tenants'
     incident
  3. No visibility (no tagging, no monitoring, no documented recovery
     objectives) — we can't say what anything costs, or how fast we
     could recover it, today
- Lead with the ONE finding most likely to resonate with this specific
  audience (usually the blast-radius/shared-IAM one — it's the
  easiest to translate into "one breach becomes three")

**2:30-5:00 — The process for addressing it**
- Sequenced, not all-at-once: static analysis and CI/CD first (the
  safety net has to exist before you touch anything risky), then
  per-tenant isolation, then the security/access fixes, then
  monitoring and documented recovery objectives last (because you need
  the earlier steps to safely test them)
- Explicitly call out that tenants keep running throughout — this is a
  live migration onto shared modules, not a rebuild, and say so plainly
- Name the one or two riskiest steps (e.g. splitting the shared IAM
  policy) and what you'd do to de-risk them specifically (staged
  rollout per tenant, rollback plan, a defined verification step before
  calling it done)

**5:00-6:30 — Service continuity: what we put in place**
- The support runbook: monitoring, escalation tiers, and — the detail
  that actually reassures this audience — documented, tested RTO/RPO
  per tenant, not just aspirational numbers
- The postmortem-to-debt-register feedback loop, framed as "we don't
  just fix incidents, we track why they happened so the same class of
  problem doesn't recur"

**6:30-7:00 — The ask**
- State plainly what you need from this audience: time, a defined
  maintenance window per tenant, or sign-off on the sequencing —
  whatever is actually true for your remediation plan. Don't end on a
  summary slide; end on a decision you need them to make.

## Anticipate these questions (you have 3 minutes)

- "What's the actual cost of doing this vs. not doing it?" — have a
  real answer, even a rough one; "unquantified risk" is not an answer
  a C-level audience will accept twice
- "What if a tenant owner pushes back on the timeline?" — have an
  answer that isn't "escalate to their manager" as the first move
- "How do we know this won't happen again in another 10 years?" — this
  is the postmortem feedback loop question; answer with the mechanism
  (register plus owned action items plus due dates), not a promise
