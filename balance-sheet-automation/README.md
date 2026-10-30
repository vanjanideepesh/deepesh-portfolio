# Balance Sheet & P&L Automation

> **In one line:** A 7-year-old, manually maintained financial model produced recurring accuracy errors during the monthly close. I diagnosed the root causes, replaced the structure with an automated pipeline driven directly by Trial Balance postings, and planned the rollout so the real close was never put at risk.

**My role:** root-cause diagnosis, solution design, and rollout planning · **Context:** monthly financial close · **Stack:** Excel VBA, macros

---

## 1. The problem and who felt it
A Balance Sheet & P&L workbook, in continuous use for seven years, was breaking in ways nobody had fully diagnosed. Every month, whoever ran the close would post Trial Balance data and manually carry figures across a chain of linked sheets, and every so often the numbers did not add up. Once I looked for the root causes, there were three:

- **Brittle cell-based pointers** instead of structured formulas, so a single inserted row upstream could silently break a downstream reference.
- **Cross-month data bleed**: under specific conditions, a prior month's ledger balance carried into the current month's column, producing quietly wrong totals that only a manual audit would catch.
- **Inconsistent Cost Center / Profit Center classification**: the grouping logic sorted some entries into the wrong bucket, and the problem compounded as entries were added without the master lists being reconciled.

## 2. The constraint that shaped every decision
This model fed a real monthly financial close, and being wrong even once was far more costly than being slow. That meant the fix had to be trusted, not just correct.

## 3. Decisions
1. **Fix the source, not the symptoms.** I replaced the pointer-based structure with a formula-driven pipeline flowing directly from Trial Balance postings, eliminating the cross-month bleed at its source.
2. **Automate only the two steps that were manual and inconsistent.**
   - A **"Paste Special" macro** locks the current month's figures as static values while rolling live formulas forward into a new column. A later edit is traceable, because a static prior-month figure cannot silently change.
   - A **second macro** scans new General Ledger entries, auto-classifies them by Cost Center / Profit Center against the existing masters, and flags only the genuinely new entries for manual review and approval, instead of a full manual re-check every month.
3. **Run the change as a rollout, not a release** (below).

## 4. Rollout: how skeptical stakeholders came to trust it
Automating this could not be a straight code swap. I treated replacing the model as a launch problem: how do you get skeptical stakeholders to trust a new system with something they cannot afford to get wrong, without asking them to take it on faith?

The plan, in [`artifacts/rollout_strategy.md`](artifacts/rollout_strategy.md): run the old and new processes in parallel for a full close cycle, resolve every discrepancy before trusting either, and get explicit stakeholder sign-off before the legacy process was retired. The instinct to ship the fix and move on would have been faster. Managing it like a rollout is what got it adopted.

## 5. Outcome
A model that used to require a manual, error-prone monthly ritual now updates itself from source data, with the two macros handling exactly the two steps that used to be manual and inconsistent: period rollover and new-entry classification.

## 6. What I would do differently
I would add a lightweight validation check that flags when a rolled-forward total moves more than a set percentage month over month: a cheap early-warning signal for exactly the kind of silent error this project was built to catch.

## Files in this folder
- `macros/`: the VBA macro logic (recreated with synthetic data; logic and structure match the original)
- `sample-data/`: synthetic Trial Balance and GL entry examples
- `assets/`: before/after structure diagram
- `artifacts/`: the rollout strategy
