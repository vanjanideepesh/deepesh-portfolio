-- Schema for the forensic fraud-detection framework demo.
-- All data loaded against this schema is synthetic (see sample-data/).

CREATE TABLE orders (
    order_id                TEXT PRIMARY KEY,
    original_order_id       TEXT,           -- NULL if this is an original order, not a replacement
    is_replacement          INTEGER,        -- 0 = original order, 1 = replacement/return order
    sku                     TEXT,
    original_sku            TEXT,
    shipping_address        TEXT,
    original_shipping_address TEXT,
    ticket_id_entered       TEXT,           -- the support ticket ID entered when creating a replacement
    created_by              TEXT,
    created_date            TEXT,
    original_order_date     TEXT,
    approver                TEXT            -- manager who approved, if applicable; NULL if none recorded
);

CREATE TABLE tickets (
    ticket_id       TEXT PRIMARY KEY,
    status          TEXT,
    created_date    TEXT,
    linked_order_id TEXT
);
