#!/usr/bin/env python3
"""
Sync Telegram DM session directly to the active Hermes CLI session.
Bridges context, transcript, and memory so chatting on Telegram is 100%
identical to chatting with Yorky in the CLI terminal.
"""

import os
import json
import sqlite3
import sys
import time
from datetime import datetime

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

PROFILE_DIR = r"C:\Users\DELL\AppData\Local\hermes\profiles\youtube"
DB_PATH = os.path.join(PROFILE_DIR, "state.db")
SESSIONS_JSON = os.path.join(PROFILE_DIR, "sessions", "sessions.json")
TELEGRAM_CHAT_ID = "6973066519"
TARGET_KEY = f"agent:main:telegram:dm:{TELEGRAM_CHAT_ID}"

def sync_session():
    if not os.path.exists(DB_PATH):
        print(f"[!] state.db not found at {DB_PATH}")
        return False

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # 1. Find the active CLI session
    cur.execute("""
        SELECT id, started_at, last_activity_at, message_count
        FROM sessions
        WHERE source = 'cli' AND ended_at IS NULL
        ORDER BY last_activity_at DESC
        LIMIT 1;
    """)
    cli_row = cur.fetchone()
    if not cli_row:
        # Fallback to latest CLI session even if ended
        cur.execute("""
            SELECT id, started_at, last_activity_at, message_count
            FROM sessions
            WHERE source = 'cli'
            ORDER BY last_activity_at DESC
            LIMIT 1;
        """)
        cli_row = cur.fetchone()

    if not cli_row:
        print("[!] No CLI session found in state.db.")
        conn.close()
        return False

    cli_session_id = cli_row[0]
    cli_msgs = cli_row[3]
    print(f"[*] Found Active CLI Session: {cli_session_id} ({cli_msgs} messages)")

    # 2. Inspect current Telegram routing
    cur.execute("SELECT entry_json FROM gateway_routing WHERE session_key = ?", (TARGET_KEY,))
    row = cur.fetchone()
    now_iso = datetime.now().isoformat()
    now_ts = time.time()

    if row:
        entry = json.loads(row[0])
        old_session_id = entry.get("session_id")
        print(f"[*] Current Telegram Session ID: {old_session_id}")
        if old_session_id == cli_session_id:
            print("[+] Telegram is ALREADY synced to this CLI session!")
            conn.close()
            return True

        # Close old session if still open
        cur.execute("""
            UPDATE sessions
            SET ended_at = ?, end_reason = 'session_switch'
            WHERE id = ? AND ended_at IS NULL;
        """, (now_ts, old_session_id))

        entry["session_id"] = cli_session_id
        entry["updated_at"] = now_iso
        new_entry_json = json.dumps(entry)

        cur.execute("""
            UPDATE gateway_routing
            SET entry_json = ?, updated_at = ?
            WHERE session_key = ?;
        """, (new_entry_json, now_ts, TARGET_KEY))
    else:
        print(f"[*] No existing gateway_routing entry for {TARGET_KEY}. Creating one...")
        entry = {
            "session_key": TARGET_KEY,
            "session_id": cli_session_id,
            "created_at": now_iso,
            "updated_at": now_iso,
            "display_name": "Yatharth",
            "platform": "telegram",
            "chat_type": "dm",
            "metadata": {},
            "origin": {
                "platform": "telegram",
                "chat_id": TELEGRAM_CHAT_ID,
                "chat_name": "Yatharth",
                "chat_type": "dm",
                "user_id": TELEGRAM_CHAT_ID,
                "user_name": "Yatharth"
            }
        }
        new_entry_json = json.dumps(entry)
        cur.execute("""
            INSERT INTO gateway_routing (scope, session_key, entry_json, updated_at)
            VALUES (?, ?, ?, ?);
        """, (os.path.join(PROFILE_DIR, "sessions"), TARGET_KEY, new_entry_json, now_ts))

    conn.commit()
    conn.close()

    # 3. Update sessions.json mirror
    if os.path.exists(SESSIONS_JSON):
        try:
            with open(SESSIONS_JSON, "r", encoding="utf-8") as f:
                sessions_data = json.load(f)
            if TARGET_KEY in sessions_data:
                sessions_data[TARGET_KEY]["session_id"] = cli_session_id
                sessions_data[TARGET_KEY]["updated_at"] = now_iso
            else:
                sessions_data[TARGET_KEY] = entry
            with open(SESSIONS_JSON, "w", encoding="utf-8") as f:
                json.dump(sessions_data, f, indent=2)
            print("[+] Updated sessions.json mirror successfully.")
        except Exception as e:
            print(f"[-] Warning: Failed to update sessions.json mirror: {e}")

    print(f"\n🎉 [SUCCESS] Telegram DM ({TELEGRAM_CHAT_ID}) successfully bound to CLI session '{cli_session_id}'!")
    print("    Any message sent on Telegram will now directly continue the active CLI chat with all 400+ messages and recent work.")
    return True

if __name__ == "__main__":
    sync_session()
