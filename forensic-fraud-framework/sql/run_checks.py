"""
Forensic Fraud-Detection Framework - Demo Runner
--------------------------------------------------
Loads the synthetic orders/tickets data into an in-memory SQLite
database and runs all five red-flag checks from redflag_queries.sql,
printing which synthetic records get flagged and why.

This proves the framework actually works end-to-end -- it is not
just illustrative SQL, it runs.

Usage:
    python run_checks.py
"""

import csv
import sqlite3
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
SAMPLE_DATA = BASE / "sample-data"
SQL_DIR = BASE / "sql"


def load_csv_to_table(conn, csv_path, table_name):
    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        cols = reader.fieldnames

    placeholders = ", ".join("?" for _ in cols)
    col_list = ", ".join(cols)
    conn.executemany(
        f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})",
        [tuple(row[c] for c in cols) for row in rows],
    )


def run_named_query(conn, title, query):
    print("=" * 70)
    print(title)
    print("=" * 70)
    cur = conn.execute(query)
    col_names = [d[0] for d in cur.description]
    rows = cur.fetchall()
    if not rows:
        print("  (no records flagged)")
    else:
        print("  " + " | ".join(col_names))
        for row in rows:
            print("  " + " | ".join(str(v) for v in row))
    print()


if __name__ == "__main__":
    conn = sqlite3.connect(":memory:")
    conn.executescript((SQL_DIR / "schema.sql").read_text())

    load_csv_to_table(conn, SAMPLE_DATA / "orders.csv", "orders")
    load_csv_to_table(conn, SAMPLE_DATA / "tickets.csv", "tickets")
    conn.commit()

    run_named_query(conn, "CHECK 1: SKU Mismatch", """
        SELECT order_id, original_order_id, sku AS replacement_sku, original_sku
        FROM orders
        WHERE is_replacement = 1 AND sku != original_sku
    """)

    run_named_query(conn, "CHECK 2: Address Change", """
        SELECT order_id, original_order_id, shipping_address, original_shipping_address
        FROM orders
        WHERE is_replacement = 1 AND shipping_address != original_shipping_address
    """)

    run_named_query(conn, "CHECK 3: Ticket Existence Validation", """
        SELECT o.order_id, o.ticket_id_entered
        FROM orders o
        WHERE o.is_replacement = 1
          AND o.ticket_id_entered IS NOT NULL
          AND o.ticket_id_entered NOT IN (SELECT ticket_id FROM tickets)
    """)

    run_named_query(conn, "CHECK 4: Ticket-Leverage Test", """
        SELECT ticket_id_entered AS ticket_id,
               COUNT(DISTINCT order_id) AS replacement_orders_created,
               GROUP_CONCAT(order_id) AS order_ids
        FROM orders
        WHERE is_replacement = 1
          AND ticket_id_entered IN (SELECT ticket_id FROM tickets)
        GROUP BY ticket_id_entered
        HAVING COUNT(DISTINCT order_id) > 1
    """)

    run_named_query(conn, "CHECK 5: Policy Compliance (>100 days, no approver)", """
        SELECT order_id, original_order_id, original_order_date, created_date, approver,
               CAST(julianday(created_date) - julianday(original_order_date) AS INTEGER) AS days_since_original
        FROM orders
        WHERE is_replacement = 1
          AND CAST(julianday(created_date) - julianday(original_order_date) AS INTEGER) > 100
          AND (approver IS NULL OR approver = '')
    """)

    conn.close()
