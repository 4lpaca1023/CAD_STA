#!/usr/bin/env python3
"""Summarize runtimes and timing metrics for a run_all invocation.

The script expects a single argument (the timestamped run directory).  It scans
well-known tool folders (OpenSTA/OpenTimer/iEDA) plus any Tatum directories,
extracts the /usr/bin/time line as well as WNS/TNS numbers when available, and
prints a human-readable report.  run_all.sh captures this output into summary.txt.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple


def load_log_lines(log_path: Path) -> List[str]:
    """Return the log as a list of lines, tolerating non-UTF8 characters."""
    try:
        return log_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except FileNotFoundError:
        return []


def parse_time_fields(lines: List[str]) -> Dict[str, str]:
    """Extract the trailing /usr/bin/time line (real/user/sys)."""
    result = {"real": "N/A", "user": "N/A", "sys": "N/A"}
    time_re = re.compile(r"TIME real=([^ ]+) user=([^ ]+) sys=([^ ]+)")
    for line in reversed(lines):
        match = time_re.search(line)
        if match:
            result["real"], result["user"], result["sys"] = match.groups()
            break
    return result


def parse_sta_like_metrics(lines: List[str]) -> Dict[str, str]:
    """Parse `tns`/`wns` lines emitted by OpenSTA or OpenTimer scripts."""
    metrics = {
        "wns_max": "N/A",
        "wns_min": "N/A",
        "tns_max": "N/A",
        "tns_min": "N/A",
    }
    sta_re = re.compile(r"^(tns|wns)\s+(min|max)\s+(-?\d+\.\d+|[-\d\.]+)")
    for line in lines:
        match = sta_re.match(line.strip())
        if match:
            kind, which, value = match.groups()
            metrics[f"{kind}_{which}"] = value
    return metrics


def parse_opentimer_metrics(lines: List[str]) -> Dict[str, str]:
    """OpenTimer prints four bare numbers: tns(max/min) then wns(max/min)."""
    metrics = {
        "wns_max": "N/A",
        "wns_min": "N/A",
        "tns_max": "N/A",
        "tns_min": "N/A",
    }
    numeric_re = re.compile(r"^-?\d+(?:\.\d+)?$")
    found: List[str] = []
    for line in reversed(lines):
        stripped = line.strip()
        if numeric_re.fullmatch(stripped):
            found.append(stripped)
            if len(found) == 4:
                break
    if len(found) == 4:
        metrics["wns_min"], metrics["wns_max"], metrics["tns_min"], metrics["tns_max"] = found
    return metrics


def parse_ieda_metrics(lines: List[str]) -> Dict[str, str]:
    """Extract WNS/TNS numbers from iEDA's tabular report."""
    metrics = {
        "wns_max": "N/A",
        "wns_min": "N/A",
        "tns_max": "N/A",
        "tns_min": "N/A",
    }
    current_table: Optional[str] = None
    for raw in lines:
        line = raw.strip("\n")
        if line.startswith("| Endpoint"):
            current_table = "paths"
            continue
        if line.startswith("| Clock"):
            current_table = "tns"
            continue
        if not line.startswith("|"):
            if not line.startswith("+"):
                current_table = None
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if current_table == "paths" and len(cells) >= 7:
            delay_type = cells[2]
            slack = cells[6]
            try:
                slack_value = float(slack)
            except ValueError:
                continue
            key = f"wns_{delay_type}"
            current = metrics.get(key)
            if current in ("N/A", None) or slack_value < float(current):
                metrics[key] = f"{slack_value:.4f}"
        elif current_table == "tns" and len(cells) >= 3:
            delay_type = cells[1]
            tns_value = cells[2]
            try:
                float(tns_value)
            except ValueError:
                continue
            metrics[f"tns_{delay_type}"] = tns_value
    return metrics


def summarize_tool(tool_name: str, folder: Path, parser) -> Optional[Dict[str, str]]:
    """Return combined runtime/metric data for a tool folder."""
    log_path = folder / "run.log"
    if not log_path.exists():
        return None
    lines = load_log_lines(log_path)
    summary = {
        "tool": tool_name,
        "log": str(log_path),
    }
    summary.update(parse_time_fields(lines))
    summary.update(parser(lines))
    return summary


def summarize_tatum(folder: Path) -> Optional[Dict[str, str]]:
    """Tatum logs only provide runtimes; use "N/A" for analysis metrics."""
    log_path = folder / "run.log"
    if not log_path.exists():
        return None
    lines = load_log_lines(log_path)
    summary = {
        "tool": folder.name,
        "log": str(log_path),
        "wns_max": "N/A",
        "wns_min": "N/A",
        "tns_max": "N/A",
        "tns_min": "N/A",
    }
    summary.update(parse_time_fields(lines))
    return summary


def format_summary(summary: Dict[str, str]) -> str:
    """Build a small text block for a single tool."""
    lines = [
        f"Tool: {summary['tool']}",
        f"  Log: {summary['log']}",
        f"  Runtime: real={summary['real']} user={summary['user']} sys={summary['sys']}",
        f"  WNS (max/min): {summary.get('wns_max', 'N/A')} / {summary.get('wns_min', 'N/A')}",
        f"  TNS (max/min): {summary.get('tns_max', 'N/A')} / {summary.get('tns_min', 'N/A')}",
    ]
    return "\n".join(lines)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: summarize_results.py <run_directory>", file=sys.stderr)
        return 1
    run_dir = Path(sys.argv[1]).resolve()
    if not run_dir.is_dir():
        print(f"Run directory not found: {run_dir}", file=sys.stderr)
        return 1

    summaries: List[Dict[str, str]] = []
    tools: List[Tuple[str, str, object]] = [
        ("OpenSTA batch", "OpenSTA_batch", parse_sta_like_metrics),
        ("OpenSTA interactive", "OpenSTA_interactive", parse_sta_like_metrics),
        ("OpenTimer batch", "OpenTimer_batch", parse_opentimer_metrics),
        ("OpenTimer interactive", "OpenTimer_interactive", parse_opentimer_metrics),
        ("iEDA iSTA", "iEDA_iSTA", parse_ieda_metrics),
    ]
    for label, folder_name, parser in tools:
        folder = run_dir / folder_name
        summary = summarize_tool(label, folder, parser)
        if summary:
            summaries.append(summary)

    # Tatum runs have dynamic names; include every folder starting with Tatum_.
    for folder in sorted(run_dir.glob("Tatum_*")):
        summary = summarize_tatum(folder)
        if summary:
            summaries.append(summary)

    if not summaries:
        print(f"No logs found under {run_dir}")
        return 0

    # Print a header showing which run directory we examined.
    print(f"Run directory: {run_dir}")
    print("=" * (len(str(run_dir)) + 15))
    for block in summaries:
        print(format_summary(block))
        print("-")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
