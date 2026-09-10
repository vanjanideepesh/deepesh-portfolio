# Rollout Strategy: Replacing a 7-Year Live Financial Process

Automating a Balance Sheet & P&L model that had been in continuous monthly use for seven years isn't a problem you can solve by just shipping the new version — if the automation had a bug, it would be wrong on a real financial close, discovered after the fact. This needed a launch plan, not just a build plan.

## Phase 1 - Parallel run (1 full close cycle)

The automated pipeline ran **alongside** the existing manual process for one complete month-end close, not instead of it. Every output was diffed line-by-line against the legacy model's output before anyone trusted a single number from the new system.

## Phase 2 - Discrepancy resolution

Any mismatch between the two processes was investigated to determine which one was actually correct — in a few cases, this is exactly how the underlying cell-pointer bugs in the legacy model were confirmed rather than assumed.

## Phase 3 - Stakeholder sign-off

Formal sign-off from the VP overseeing Statutory Finance before the legacy process was retired — not because the automation wasn't working, but because trust in a financial close process has to be earned deliberately, not assumed from clean test results.

## Phase 4 - Legacy decommission

Only after Phases 1-3 were complete did the old manual process stop being used. The old workbook was archived, not deleted, in case of audit questions referencing prior periods.

---

**Why this is a GTM-style decision, not just an engineering one:** the technical build could have shipped in Phase 1. The actual risk being managed was adoption risk and trust risk — the same category of problem as launching a new product to skeptical users, just with a much lower tolerance for being wrong even once. Sequencing the rollout to build confidence incrementally, rather than optimizing for the fastest possible cutover, was the deliberate call.
