-- ============================================================
-- Red-flag detection queries
-- Each check is independent; a transaction accumulating flags
-- across multiple checks is a stronger signal than any one check
-- alone. Run against the synthetic schema in schema.sql.
-- ============================================================

-- CHECK 1: SKU mismatch
-- The replacement item doesn't match what was actually purchased.
SELECT order_id, original_order_id, sku AS replacement_sku, original_sku
FROM orders
WHERE is_replacement = 1
  AND sku != original_sku;


-- CHECK 2: Address-change detection
-- Shipping address was altered between the original order and the replacement.
SELECT order_id, original_order_id, shipping_address, original_shipping_address
FROM orders
WHERE is_replacement = 1
  AND shipping_address != original_shipping_address;


-- CHECK 3: Ticket-existence validation
-- The ticket ID entered on the replacement order doesn't actually exist.
SELECT o.order_id, o.ticket_id_entered
FROM orders o
WHERE o.is_replacement = 1
  AND o.ticket_id_entered IS NOT NULL
  AND o.ticket_id_entered NOT IN (SELECT ticket_id FROM tickets);


-- CHECK 4: Ticket-leverage test (the novel check)
-- A single, genuine ticket is reused to justify more than one
-- separate replacement order. Invisible if you only look at
-- tickets, or only look at orders -- only appears on the join.
SELECT ticket_id_entered AS ticket_id,
       COUNT(DISTINCT order_id) AS replacement_orders_created,
       GROUP_CONCAT(order_id) AS order_ids
FROM orders
WHERE is_replacement = 1
  AND ticket_id_entered IN (SELECT ticket_id FROM tickets)
GROUP BY ticket_id_entered
HAVING COUNT(DISTINCT order_id) > 1;


-- CHECK 5: Policy-compliance check
-- Replacement requested more than 100 days after the original order
-- should require manager-level approval. Flag any that don't have one.
SELECT order_id, original_order_id, original_order_date, created_date, approver,
       CAST(julianday(created_date) - julianday(original_order_date) AS INTEGER) AS days_since_original
FROM orders
WHERE is_replacement = 1
  AND CAST(julianday(created_date) - julianday(original_order_date) AS INTEGER) > 100
  AND (approver IS NULL OR approver = '');
