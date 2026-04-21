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

import argparse
import json
from collections import Counter
from typing import Any, Dict, List


def _safe_load_json(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _matches(data: Dict[str, Any]) -> List[Dict[str, Any]]:
    m = data.get("matches", [])
    return m if isinstance(m, list) else []


def main() -> int:
    p = argparse.ArgumentParser(
        description="Render a Grype JSON report into Markdown summary."
    )
    p.add_argument(
        "--json",
        required=True,
        help="Path to grype JSON report (from `grype -o json`).",
    )
    p.add_argument(
        "--max-top",
        type=int,
        default=10,
        help="Max number of Critical/High rows to print.",
    )
    args = p.parse_args()

    try:
        data = _safe_load_json(args.json)
    except Exception as e:
        print("")
        print("#### Grype Summary")
        print(f"Unable to parse `{args.json}`: {e}")
        return 0

    matches = _matches(data)
    sev_list: List[str] = []
    rows: List[Dict[str, str]] = []

    for m in matches:
        vuln = m.get("vulnerability") or {}
        artifact = m.get("artifact") or {}
        if not isinstance(vuln, dict) or not isinstance(artifact, dict):
            continue

        sev = vuln.get("severity") or "Unknown"
        if not isinstance(sev, str):
            sev = "Unknown"
        sev_list.append(sev)

        rows.append(
            {
                "severity": sev,
                "id": str(vuln.get("id") or ""),
                "pkg": str(artifact.get("name") or ""),
                "ver": str(artifact.get("version") or ""),
            }
        )

    cnt = Counter(sev_list)

    print("")
    print("#### Grype Summary")
    print(f"- Total matches: **{len(matches)}**")
    print(
        (
            "- Critical: **{c}**, High: **{h}**, Medium: **{m}**, "
            "Low: **{l}**"
        ).format(
            c=cnt.get("Critical", 0),
            h=cnt.get("High", 0),
            m=cnt.get("Medium", 0),
            l=cnt.get("Low", 0),
        )
    )

    top = [r for r in rows if r["severity"] in ("Critical", "High")]
    top = top[: max(args.max_top, 0)]
    if top:
        print("")
        print(f"#### Top Critical/High (first {len(top)})")
        print("")
        print("| Severity | Vulnerability | Package | Version |")
        print("|---|---|---|---|")
        for r in top:
            print(f"| {r['severity']} | {r['id']} | {r['pkg']} | {r['ver']} |")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
