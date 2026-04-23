#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Aggregate multiple Grype JSON reports into a consolidated markdown table.

Expects the input directory to contain one subdirectory per downloaded
artifact (as produced by `actions/download-artifact@v4` with a pattern),
each holding a `grype-results.json` file. Subdirectory name is assumed
to follow `grype-<service>[-<run-id>-<run-attempt>]`; that convention
is what `security-container-scan` produces and what callers should use
for artifact names.
"""

import argparse
import glob
import json
import os
import re
import sys
from collections import Counter


def _load_matches(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as exc:
        print(f"WARN: failed to parse {path}: {exc}", file=sys.stderr)
        return None
    matches = data.get("matches", [])
    return matches if isinstance(matches, list) else []


def _service_from_dirname(dirname):
    name = os.path.basename(dirname)
    name = re.sub(r"^grype-", "", name, count=1)
    # Strip trailing `-<run_id>-<run_attempt>` that security-container-scan
    # callers use to keep artifact names unique across reruns.
    name = re.sub(r"-\d+-\d+$", "", name)
    return name or os.path.basename(dirname)


def _counts(matches):
    counter = Counter()
    for m in matches:
        vuln = m.get("vulnerability") or {}
        sev = vuln.get("severity") or "Unknown"
        if not isinstance(sev, str):
            sev = "Unknown"
        counter[sev] += 1
    return counter


def _render(rows):
    lines = ["## 🔍 Container Scan Summary", ""]
    if not rows:
        lines.append("_No Grype artifacts were found to aggregate._")
        lines.append("")
        return "\n".join(lines)

    lines.append("| Service | Total | Critical | High | Medium | Low | Other |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|")
    totals = [0] * 6
    for name, total, crit, high, med, low, other in rows:
        lines.append(
            f"| {name} | {total} | {crit} | {high} | {med} | {low} | {other} |"
        )
        for i, v in enumerate((total, crit, high, med, low, other)):
            totals[i] += v

    lines.append(
        "| **TOTAL** | **{0}** | **{1}** | **{2}** | **{3}** | **{4}** | **{5}** |".format(
            *totals
        )
    )
    lines.append("")
    lines.append(
        "_Per-CVE detail lives in the per-service `grype-*` artifacts "
        "(JSON + SARIF). Severity counts only — no CVE IDs published here._"
    )
    lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dir",
        required=True,
        help="Root directory containing `grype-*/grype-results.json` subtrees.",
    )
    args = parser.parse_args()

    pattern = os.path.join(args.dir, "*", "grype-results.json")
    report_paths = sorted(glob.glob(pattern))

    rows = []
    for path in report_paths:
        matches = _load_matches(path)
        if matches is None:
            continue
        name = _service_from_dirname(os.path.dirname(path))
        counter = _counts(matches)
        rows.append(
            (
                name,
                len(matches),
                counter.get("Critical", 0),
                counter.get("High", 0),
                counter.get("Medium", 0),
                counter.get("Low", 0),
                counter.get("Negligible", 0) + counter.get("Unknown", 0),
            )
        )

    rows.sort(key=lambda r: r[0])
    sys.stdout.write(_render(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
