# Balance Sheet & P&L Automation

**Diagnosed and fixed recurring accuracy errors in a 7-year-old, manually maintained financial model — replacing it with an automated pipeline driven directly by Trial Balance postings.**

---

## The problem

A Balance Sheet & P&L workbook, in continuous use for seven years, was breaking in ways nobody had fully diagnosed. Every month, whoever ran the close would post Trial Balance data and then manually carry figures across a chain of linked sheets — and every so often, numbers just didn't add up. The root causes, once I actually looked for them:

- **Brittle cell-based pointers** instead of structured formulas — so figures referenced specific cell addresses rather than named ranges or lookups, meaning a single inserted row anywhere upstream could silently break a downstream reference.
- **Cross-month data bleed** — under specific conditions, a prior month's ledger balance would carry into the current month's column instead of the new period's data, producing quietly wrong totals that only a manual audit would catch.
- **Inconsistent Cost Center / Profit Center classification** — the grouping logic sorted some entries into the wrong bucket, which compounded over time as more entries were added without the master lists being reconciled.

## The approach

- Replaced the pointer-based structure with a formula-driven pipeline flowing directly from Trial Balance postings — eliminating the cross-month bleed at the source rather than patching its symptoms.
- Built a **"Paste Special" macro** that locks the current month's figures as static values while rolling live formulas forward into a new column — automating a step the previous process handled manually (specifically so any later edit is traceable, since a static prior-month figure can't silently change).
- Built a second macro that scans new General Ledger entries, auto-classifies them by Cost Center / Profit Center against the existing masters, and flags **only the genuinely new entries** for manual review and approval — instead of requiring a full manual re-check every month.

## Outcome

A model that used to require a manual, error-prone monthly ritual now updates itself from source data, with the two macros handling exactly the two steps that used to be manual and inconsistent: period rollover and new-entry classification.

## What I'd do differently

I'd add a lightweight validation check that flags if a rolled-forward total moves more than a threshold percentage month-over-month — a cheap early-warning signal for exactly the kind of silent error this project was built to catch in the first place.

## Rollout strategy behind this project

Automating this couldn't be a straight code swap — this model fed a real monthly financial close, and being wrong even once was far more costly than being slow. I treated replacing it as a **launch problem**: how do you get skeptical stakeholders to trust a new system with something they can't afford to get wrong, without just asking them to take it on faith?

See [`artifacts/rollout_strategy.md`](./artifacts/rollout_strategy.md) for the full phased plan — parallel-running the old and new processes for a full close cycle, resolving every discrepancy before trusting either, and getting explicit stakeholder sign-off before the legacy process was retired. The instinct to just ship the fix and move on would have been faster; the instinct to manage it like a rollout, not a release, is what actually got it adopted.

## Files in this folder

- `macros/` — the VBA macro logic (recreated with synthetic data; logic and structure match the original)
- `sample-data/` — synthetic Trial Balance and GL entry examples
- `assets/` — before/after structure diagram
