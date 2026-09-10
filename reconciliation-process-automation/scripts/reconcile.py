"""
Reconciliation Process Automation
----------------------------------
Recreates the logic of a production pipeline that replaced a manual,
VLOOKUP-based monthly reconciliation with an automated batch process.

Original process: pull exports from SAP, an OMS (via BigQuery), POS, and
a marketplace/central-store portal into one Excel workbook, VLOOKUP them
against each other by hand, and eyeball the mismatches.

This script: drop CSV exports into an input folder, run it, get a
structured output with mismatches auto-segmented by root cause instead
of one undifferentiated list.

Usage:
    python reconcile.py

All data in sample-data/ is synthetic.
"""

import csv
from pathlib import Path
from collections import defaultdict

DATA_DIR = Path(__file__).resolve().parent.parent / "sample-data"


def load_extract(filename):
    """Load a source-system extract into a dict keyed by order_id."""
    records = {}
    with open(DATA_DIR / filename, newline="") as f:
        for row in csv.DictReader(f):
            records[row["order_id"]] = row
    return records


def reconcile(source_a, source_b, label_a="SYSTEM_A", label_b="SYSTEM_B"):
    """
    Compare two source-system extracts and segment results by
    discrepancy type, rather than returning one flat mismatch list.
    """
    ids_a, ids_b = set(source_a), set(source_b)
    both = ids_a & ids_b
    only_a = ids_a - ids_b
    only_b = ids_b - ids_a

    exact_matches = []
    price_mismatches = []

    for oid in both:
        rec_a, rec_b = source_a[oid], source_b[oid]
        if float(rec_a["amount"]) == float(rec_b["amount"]) and rec_a["sku"] == rec_b["sku"]:
            exact_matches.append(oid)
        else:
            price_mismatches.append({
                "order_id": oid,
                f"{label_a}_amount": rec_a["amount"],
                f"{label_b}_amount": rec_b["amount"],
            })

    return {
        "exact_matches": exact_matches,
        "price_mismatches": price_mismatches,
        f"{label_a}_only": sorted(only_a),
        f"{label_b}_only": sorted(only_b),
    }


def print_summary(result, label_a, label_b):
    total_checked = (
        len(result["exact_matches"])
        + len(result["price_mismatches"])
        + len(result[f"{label_a}_only"])
        + len(result[f"{label_b}_only"])
    )
    print("=" * 60)
    print("RECONCILIATION SUMMARY")
    print("=" * 60)
    print(f"Total order IDs seen across both systems : {total_checked}")
    print(f"Exact matches                            : {len(result['exact_matches'])}")
    print(f"Price/SKU mismatches                     : {len(result['price_mismatches'])}")
    print(f"{label_a}-only records                    : {len(result[f'{label_a}_only'])}")
    print(f"{label_b}-only records                    : {len(result[f'{label_b}_only'])}")
    print()

    if result["price_mismatches"]:
        print("-- Price/SKU mismatches (needs review) --")
        for m in result["price_mismatches"]:
            print(f"  {m}")
        print()

    if result[f"{label_a}_only"]:
        print(f"-- Orders only in {label_a} (not yet synced downstream) --")
        for oid in result[f"{label_a}_only"]:
            print(f"  {oid}")
        print()

    if result[f"{label_b}_only"]:
        print(f"-- Orders only in {label_b} (investigate: created outside expected flow?) --")
        for oid in result[f"{label_b}_only"]:
            print(f"  {oid}")
        print()


if __name__ == "__main__":
    sap = load_extract("sap_extract.csv")
    oms = load_extract("oms_extract.csv")

    result = reconcile(sap, oms, label_a="SAP", label_b="OMS")
    print_summary(result, "SAP", "OMS")
