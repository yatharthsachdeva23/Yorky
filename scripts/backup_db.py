#!/usr/bin/env python3
"""
backup_db.py - Instant Full Backup for YouTube Shorts PostgreSQL Database
Dumps all schema and data to backups/youtube_shorts_backup_<timestamp>.sql
"""

import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path

PG_BIN = Path(r"C:\Program Files\PostgreSQL\18\bin")
PG_DUMP = PG_BIN / "pg_dump.exe"
BACKUP_DIR = Path("backups")

def run_backup():
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"youtube_shorts_backup_{timestamp}.sql"

    print(f"[*] Starting full PostgreSQL backup...")
    print(f"    Target: {backup_file}")

    cmd = [
        str(PG_DUMP if PG_DUMP.exists() else "pg_dump"),
        "-h", "localhost",
        "-p", "5432",
        "-U", "postgres",
        "-d", "youtube_shorts",
        "-F", "p",  # plain SQL
        "-f", str(backup_file)
    ]

    env = os.environ.copy()
    env["PGPASSWORD"] = os.environ.get("PGPASSWORD", "postgres")

    try:
        res = subprocess.run(cmd, env=env, capture_output=True, text=True)
        if res.returncode == 0:
            size_kb = backup_file.stat().st_size / 1024
            print(f"[+] Backup completed successfully!")
            print(f"    File: {backup_file} ({size_kb:.1f} KB)")
            return str(backup_file)
        else:
            print(f"[-] pg_dump error: {res.stderr}")
            # Fallback using python psycopg2 dump if password prompt blocked
            return None
    except Exception as e:
        print(f"[-] Backup error: {e}")
        return None

if __name__ == "__main__":
    run_backup()
