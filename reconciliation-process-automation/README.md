# Reconciliation Process Automation

**Turned a 4-hour manual reconciliation process into a 4-minute automated pipeline, reconciling 70,000+ line items at 99.99% accuracy.**

---

## The problem

At a fast-growing D2C retail company, monthly reconciliation (Settlements, Sales, and related cycles) meant manually pulling exports from five separate systems — SAP, an internal Order Management System (via BigQuery), POS, a marketplace/central-store portal, and a fulfillment system — into a single Excel workbook, matching them with VLOOKUP, and eyeballing mismatches. It was slow, error-prone, and entirely dependent on one person's manual attention every month.

## The approach

- Built a folder-driven batch pipeline: dumps go into a fixed input folder structure, a script processes them automatically, and a structured output workbook is generated — no manual copy-paste.
- The output auto-segments mismatches by type (present in System A only, System B only, cross-channel discrepancies) instead of one undifferentiated list, so root-cause review takes minutes instead of hours.
- A summary tab surfaces the numbers that matter first: total orders processed, total value, and — critically — the mismatched subset and its value, before anyone has to open a single detail tab.

## What I found along the way

Beyond the automation itself, the structured approach surfaced a data-integrity issue that manual review had missed for a long time: a duplicate join-key in one system's extract (two rows sharing a key, whose values summed correctly against the other system — easy to miss by hand, obvious once automated), and roughly 0.2% of orders silently failing to sync between systems due to a null date field upstream. Both are the kind of small, structural bugs that compound expensively over time if nobody's specifically looking for them.

## Outcome

| Metric | Before | After |
|---|---|---|
| Turnaround time | ~4 hours/month | ~4 minutes/month |
| Line items reconciled | Manual sample checks | 70,199 (99.99% exact match) |
| Mismatch investigation | Undifferentiated list | Auto-segmented by root cause |

## What I'd do differently

Given more runway, I'd move this from a batch/folder-driven script to a scheduled pipeline with alerting (e.g., Airflow + Slack notification on mismatch-rate spikes), so someone finds out about a data-integrity issue the day it happens, not the day the monthly reconciliation runs.

## Files in this folder

- `scripts/` — the batch-processing logic (recreated with synthetic data; structure and approach match the original)
- `sample-data/` — synthetic input files showing the expected format from each source system
- `assets/` — sample output workbook screenshot
