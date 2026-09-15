#!/usr/bin/env python3
"""
track_subagents.py - Real-Time Multi-Subagent Monitor for Hermes / Yorky

Monitors concurrent subagents dispatched by Hermes during batch delegations.
Parses live transcripts and manifests from:
  AppData/Local/hermes/profiles/youtube/cache/delegation/live/<delegation_id>/

Usage:
  python scripts/track_subagents.py            # Show latest delegation snapshot
  python scripts/track_subagents.py --watch    # Live auto-refreshing dashboard (1s)
  python scripts/track_subagents.py --task 2   # Detailed log tail for a specific subagent
  python scripts/track_subagents.py --id ID    # Inspect specific delegation ID
"""

import os
import sys
import time
import json
import glob
import re
import argparse
from pathlib import Path
from datetime import datetime

# Enforce UTF-8 on Windows stdout
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

LIVE_DIR = Path(os.environ.get("LOCALAPPDATA", "C:/Users/DELL/AppData/Local")) / "hermes/profiles/youtube/cache/delegation/live"

STATUS_ICONS = {
    "completed": "[OK] DONE",
    "running":   "[>>] RUNNING",
    "failed":    "[XX] FAILED",
    "pending":   "[--] QUEUED",
    "unknown":   "[--] PENDING"
}

def get_latest_delegation_dir(target_id=None):
    if target_id:
        p = LIVE_DIR / target_id
        if p.exists():
            return p
        matches = list(LIVE_DIR.glob(f"*{target_id}*"))
        if matches:
            return matches[0]
        return None

    if not LIVE_DIR.exists():
        return None

    dirs = [d for d in LIVE_DIR.iterdir() if d.is_dir() and d.name.startswith("deleg_")]
    if not dirs:
        return None
    dirs.sort(key=lambda d: d.stat().st_mtime, reverse=True)
    return dirs[0]

def parse_task_log(log_path):
    if not os.path.exists(log_path):
        return {"status": "pending", "duration": "-", "last_action": "Waiting to start..."}

    try:
        with open(log_path, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
    except Exception as e:
        return {"status": "unknown", "duration": "-", "last_action": f"Read error: {e}"}

    if not lines:
        return {"status": "pending", "duration": "-", "last_action": "Log created, awaiting kickoff"}

    status = "running"
    duration = "-"
    last_action = ""
    goal = ""

    for line in lines:
        line_clean = line.strip()
        if line_clean.startswith("goal:"):
            goal = line_clean.replace("goal:", "").strip()
        if "status=completed" in line_clean:
            status = "completed"
        elif "status=failed" in line_clean or "exit_reason=failed" in line_clean:
            status = "failed"
        
        m_dur = re.search(r"duration=([\d\.]+s)", line_clean)
        if m_dur:
            duration = m_dur.group(1)

        if "|" in line_clean and not line_clean.startswith("==="):
            parts = line_clean.split("|", 2)
            if len(parts) >= 2:
                stage = parts[1].strip()
                details = parts[2].strip() if len(parts) > 2 else ""
                last_action = f"[{stage.upper()}] {details}"

    if not last_action and lines:
        last_action = lines[-1].strip()

    if len(last_action) > 60:
        last_action = last_action[:57] + "..."

    return {
        "status": status,
        "duration": duration,
        "last_action": last_action,
        "goal": goal
    }

def display_dashboard(deleg_dir):
    manifest_file = deleg_dir / "manifest.json"
    manifest = {}
    if manifest_file.exists():
        try:
            with open(manifest_file, "r", encoding="utf-8") as f:
                manifest = json.load(f)
        except Exception:
            pass

    deleg_id = deleg_dir.name
    started = manifest.get("started", "Unknown")
    completed = manifest.get("completed")
    task_count = manifest.get("task_count", 5)

    now_str = datetime.now().strftime("%H:%M:%S")
    header = f"=== Hermes Multi-Subagent Tracker [{now_str}] ==="
    print(header)
    print(f"Delegation ID: {deleg_id} | Started: {started} | Status: " + ("Finished" if completed else "Active"))
    print("-" * 88)
    print(f"{'Task':<6} | {'Target Short':<16} | {'Status':<12} | {'Time':<8} | Latest Subagent Action")
    print("-" * 88)

    tasks_manifest = {t.get("index"): t for t in manifest.get("tasks", [])}
    max_tasks = max(task_count, 5)
    all_done = True

    for i in range(max_tasks):
        log_file = deleg_dir / f"task-{i}.log"
        t_info = parse_task_log(log_file)
        
        m_task = tasks_manifest.get(i, {})
        m_status = m_task.get("status")
        if m_status:
            t_info["status"] = m_status

        if t_info["status"] != "completed":
            all_done = False

        goal_text = m_task.get("goal") or t_info.get("goal", "")
        short_match = re.search(r"Short\s*#?(\d+)", goal_text, re.IGNORECASE)
        short_label = f"Short #{short_match.group(1)}" if short_match else f"Worker #{i}"

        status_str = STATUS_ICONS.get(t_info["status"], t_info["status"].upper())
        duration_str = t_info["duration"]
        action_str = t_info["last_action"]

        print(f"#{i:<5} | {short_label:<16} | {status_str:<12} | {duration_str:<8} | {action_str}")

    print("-" * 88)
    if completed:
        print(f"Batch complete at {completed}!")
    elif all_done:
        print("All 5 subagents have finished execution.")
    else:
        print("Subagents are currently executing in parallel...")
    print()

def tail_task(deleg_dir, task_index):
    log_file = deleg_dir / f"task-{task_index}.log"
    print(f"--- Tailing Task #{task_index} Log ({log_file}) ---")
    if not log_file.exists():
        print("Log file does not exist yet.")
        return
    with open(log_file, "r", encoding="utf-8", errors="replace") as f:
        print(f.read())

def main():
    parser = argparse.ArgumentParser(description="Hermes Multi-Subagent Tracker")
    parser.add_argument("--watch", "-w", action="store_true", help="Live auto-refresh dashboard every 1.5s")
    parser.add_argument("--id", type=str, default=None, help="Specific delegation ID")
    parser.add_argument("--task", "-t", type=int, default=None, help="Tail specific subagent task (0-4)")
    args = parser.parse_args()

    deleg_dir = get_latest_delegation_dir(args.id)
    if not deleg_dir:
        print(f"Error: No delegation directory found in {LIVE_DIR}")
        sys.exit(1)

    if args.task is not None:
        tail_task(deleg_dir, args.task)
        return

    if args.watch:
        try:
            while True:
                os.system("cls" if os.name == "nt" else "clear")
                latest_dir = get_latest_delegation_dir(args.id)
                display_dashboard(latest_dir or deleg_dir)
                time.sleep(1.5)
        except KeyboardInterrupt:
            print("\nStopped tracking.")
    else:
        display_dashboard(deleg_dir)

if __name__ == "__main__":
    main()
