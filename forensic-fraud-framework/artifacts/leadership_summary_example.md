# From Query Output to Leadership Decision

Five independent SQL checks produce five separate result sets. None of them, on their own, tell a non-technical stakeholder what to *do*. The real work of this project was translating flagged rows into a narrative someone could act on. Below is an illustrative before/after, built on the synthetic data in this repo — not the real engagement's findings.

---

## Before: raw technical output

> `CHECK 4: Ticket-Leverage Test`
> `ticket_id: TCK-503 | replacement_orders_created: 2 | order_ids: ORD-2010, ORD-2011`

Technically correct. Useless to a VP deciding whether to escalate.

## After: leadership-facing translation

> **Finding: a support-ticket reuse pattern is generating unauthorized replacement orders.**
>
> We found a small number of cases where a single, genuine customer support ticket was used to justify creating *more than one* separate replacement order — something the current process has no automatic check for, since each order looks individually valid; the pattern only appears when tickets and orders are cross-referenced.
>
> **Why this matters:** every instance represents a replacement order with no corresponding customer complaint behind it — direct financial exposure with no legitimate business justification.
>
> **Recommended action:** require a 1:1 ticket-to-order mapping at the point of order creation (a system-level fix, not a policy reminder), and retroactively review the flagged pattern for the affected period.

---

**The translation principle:** a technical finding becomes a business decision when it answers three questions a leader actually has — *what happened, why does it matter, and what do you want me to approve* — not when it's presented with more precision.
