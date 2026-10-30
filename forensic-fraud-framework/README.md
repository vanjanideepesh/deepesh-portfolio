# Forensic Audit: Manual Order Fraud Detection

> **In one line:** Manually created replacement orders were an invisible place for abuse. I designed a layered detection approach and the leadership narrative that turns flagged rows into a decision someone can act on. This repo demonstrates the method on fully synthetic data.

**My role:** detection design and stakeholder communication · **Context:** internal audit of manually created replacement and return orders · **Stack:** SQL, data forensics

> [!IMPORTANT]
> This framework is based on a real forensic audit I led professionally. That engagement involved an internal investigation, so this repository intentionally shows the detection methodology only, not the real data, findings, or figures. Everything below runs on synthetic data generated to have the same shape as the real problem, with illustrative (not real) numbers.

---

## 1. The problem and who is exposed
When part of a process depends on humans manually creating exception records (for example, a replacement order raised without a fully automated trigger), it becomes a natural place for abuse to hide. A single support ticket can be reused to justify several orders, or a required field can be filled with a placeholder instead of real data. Neither shows up unless someone is looking across systems rather than inside any one of them.

## 2. Approach: independent checks, accumulated
Rather than one rule, I designed a **layered set of independent red-flag checks**, so a transaction failing several of them is a much stronger signal than any single check alone.

| # | Check | The question it asks |
|---|---|---|
| 1 | SKU mismatch | Does the replacement item match what was actually purchased? |
| 2 | Address change | Was the shipping address altered between the original order and the replacement? |
| 3 | Ticket-existence validation | Does the cited support ticket actually exist, or is it a placeholder or fabricated reference? |
| 4 | **Ticket-leverage test** (the novel part) | Does a single genuine ticket get reused to justify more than one replacement order? This pattern is invisible if you look only at tickets or only at orders; it appears when you join the two datasets and count. |
| 5 | Policy compliance | Were replacements requested outside a defined window that should require manager approval, and is an approver even on record? |

Each check runs as an independent SQL query across the joined dataset. A transaction accumulates flags rather than being judged by any single rule, which keeps false positives low while surfacing genuinely unusual patterns.

## 3. Decision framing: from flagged rows to an action
Five independent checks each produce a technically correct result set, but none of them alone tells a VP what to approve. The skill this project really tested was not the SQL. It was **translating flagged rows into a decision a non-technical person could act on**: what happened, why it matters financially, and what specific action is being requested.

See [`artifacts/leadership_summary_example.md`](artifacts/leadership_summary_example.md) for an illustrative before and after: the raw query output versus the leadership-facing narrative it became. A finding only has value once it is translated for the audience that has to act on it.

## 4. What I would do differently
I would formalize the "accumulated flags" scoring into an explicit weighted model rather than an implicit count, so the threshold for escalation is a documented, defensible number rather than a judgment call.

## Files in this folder
- `sql/`: the red-flag detection queries, runnable against the synthetic dataset included here
- `sample-data/`: fully synthetic order, ticket, and support-record data (no real company data)
- `assets/`: example output visualization showing flagged transactions (synthetic)
- `artifacts/`: the illustrative leadership summary
