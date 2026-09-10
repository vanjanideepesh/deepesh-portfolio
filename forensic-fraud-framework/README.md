# Forensic Fraud-Detection Framework

**A multi-signal framework for detecting process abuse in manually-created transaction records, demonstrated here on fully synthetic data.**

> **A note before you read further:** this framework is based on a real forensic audit I led professionally, investigating manually-created replacement/return orders. That engagement involved an internal investigation, so **this repository intentionally shows the detection methodology only — not the real data, findings, or figures** from that work. Everything below runs on synthetic data generated to have the same shape as the real problem, with illustrative (not real) numbers.

---

## The problem

When part of a process depends on humans manually creating exception records (e.g., a replacement order raised without a fully automated trigger), it becomes a natural place for abuse to hide — a single support ticket can be reused to justify multiple orders, or a required field can be filled with a placeholder instead of real data, and neither shows up unless someone is specifically looking across systems rather than within any one of them.

## The approach

Rather than one rule, I designed a **layered set of independent red-flag checks**, so that a transaction failing multiple checks is a much stronger signal than any single check alone:

1. **SKU-mismatch check** — does the replacement item match what was actually purchased?
2. **Address-change detection** — was the shipping address altered between the original order and the replacement?
3. **Ticket-existence validation** — does the support ticket cited actually exist in the support system, or is it a placeholder/fabricated reference?
4. **"Ticket-leverage" test** *(the novel part)* — does a single, genuine support ticket get reused to justify more than one separate replacement order? This is the pattern that's invisible if you only look at tickets *or* only look at orders — it only appears when you join the two datasets and count.
5. **Policy-compliance checks** — e.g., flagging replacements requested outside a defined time window that should require manager-level approval, and checking whether an approver is even on record.

Each check runs as an independent SQL query across the joined dataset; a transaction accumulates flags rather than being judged by any single rule, which keeps false positives low while surfacing genuinely unusual patterns.

## Why this matters for product thinking, not just SQL

This project is as much about **framing a fuzzy, ambiguous problem into a testable structure** as it is about the queries themselves — "is this fraud" isn't a single query, it's a set of hypotheses that each need their own evidence, and then a way to combine that evidence into a confidence signal a non-technical stakeholder can act on.

## Files in this folder

- `sql/` — the red-flag detection queries, runnable against the synthetic dataset included here
- `sample-data/` — fully synthetic order, ticket, and support-record data (no real company data)
- `assets/` — example output visualization showing flagged transactions (synthetic)

## What I'd do differently

I'd formalize the "accumulated flags" scoring into an explicit weighted model rather than an implicit count, so the threshold for escalation is a documented, defensible number rather than a judgment call.
