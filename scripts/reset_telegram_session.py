#!/usr/bin/env python3
"""
Reset Telegram DM session to a completely fresh conversation and configure auto-reset.
"""

import os
import sys
import json
import sqlite3
import time
import uuid
import yaml
from datetime import datetime

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

PROFILE_DIR = r"C:\Users\DELL\AppData\Local\hermes\profiles\youtube"
DB_PATH = os.path.join(PROFILE_DIR, "state.db")
CONFIG_YAML = os.path.join(PROFILE_DIR, "config.yaml")
SESSIONS_JSON = os.path.join(PROFILE_DIR, "sessions", "sessions.json")
TELEGRAM_CHAT_ID = "6973066519"
TARGET_KEY = f"agent:main:telegram:dm:{TELEGRAM_CHAT_ID}"

def configure_session_reset(idle_minutes=30):
    if not os.path.exists(CONFIG_YAML):
        print(f"[!] config.yaml not found at {CONFIG_YAML}")
        return False
        
    with open(CONFIG_YAML, "r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f) or {}

    cfg["session_reset"] = {
        "mode": "idle",
        "idle_minutes": idle_minutes,
        "notify": False  # Reset silently without cluttering Telegram with notices
    }

    with open(CONFIG_YAML, "w", encoding="utf-8") as f:
        yaml.dump(cfg, f, default_flow_style=False, sort_keys=False)
        
    print(f"[+] Configured auto-reset in config.yaml: mode=idle, idle_minutes={idle_minutes}, notify=False")
    return True

def reset_current_telegram_session():
    if not os.path.exists(DB_PATH):
        print(f"[!] state.db not found at {DB_PATH}")
        return False

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    now = datetime.now()
    now_iso = now.isoformat()
    now_ts = time.time()
    new_session_id = f"{now.strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}"

    # Check existing routing
    cur.execute("SELECT entry_json FROM gateway_routing WHERE session_key = ?", (TARGET_KEY,))
    row = cur.fetchone()
    old_session_id = None
    if row:
        try:
            entry = json.loads(row[0])
            old_session_id = entry.get("session_id")
        except Exception:
            pass

    if old_session_id:
        print(f"[*] Retiring existing Telegram session: {old_session_id}")
        cur.execute("""
            UPDATE sessions 
            SET ended_at = ?, end_reason = 'session_reset' 
            WHERE id = ? AND ended_at IS NULL;
        """, (now_ts, old_session_id))

    # Create new session entry
    new_entry = {
        "session_key": TARGET_KEY,
        "session_id": new_session_id,
        "created_at": now_iso,
        "updated_at": now_iso,
        "display_name": "Yatharth",
        "platform": "telegram",
        "chat_type": "dm",
        "metadata": {},
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read_tokens": 0,
        "cache_write_tokens": 0,
        "total_tokens": 0,
        "last_prompt_tokens": 0,
        "estimated_cost_usd": 0.0,
        "cost_status": "unknown",
        "expiry_finalized": False,
        "suspended": False,
        "resume_pending": False,
        "resume_reason": None,
        "last_resume_marked_at": None,
        "active_turn_token": None,
        "active_turn_started_at": None,
        "is_fresh_reset": True,
        "was_auto_reset": False,
        "auto_reset_reason": None,
        "reset_had_activity": False,
        "prev_session_id": old_session_id,
        "origin": {
            "platform": "telegram",
            "chat_id": TELEGRAM_CHAT_ID,
            "chat_name": "Yatharth",
            "chat_type": "dm",
            "user_id": TELEGRAM_CHAT_ID,
            "user_name": "Yatharth",
            "thread_id": None,
            "chat_topic": None
        }
    }

    # Record in sessions table
    cur.execute("""
        INSERT INTO sessions (
            id, source, user_id, session_key, chat_id, chat_type, started_at, profile_name
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """, (new_session_id, 'telegram', TELEGRAM_CHAT_ID, TARGET_KEY, TELEGRAM_CHAT_ID, 'dm', now_ts, 'youtube'))

    # Update gateway_routing
    entry_json_str = json.dumps(new_entry)
    cur.execute("DELETE FROM gateway_routing WHERE session_key = ?;", (TARGET_KEY,))
    cur.execute("""
        INSERT INTO gateway_routing (scope, session_key, entry_json, updated_at)
        VALUES (?, ?, ?, ?);
    """, (os.path.join(PROFILE_DIR, "sessions"), TARGET_KEY, entry_json_str, now_ts))

    conn.commit()
    conn.close()

    # Update mirror sessions.json
    if os.path.exists(SESSIONS_JSON):
        try:
            with open(SESSIONS_JSON, "r", encoding="utf-8") as f:
                s_data = json.load(f)
            s_data[TARGET_KEY] = new_entry
            with open(SESSIONS_JSON, "w", encoding="utf-8") as f:
                json.dump(s_data, f, indent=2)
            print("[+] Updated mirror sessions.json.")
        except Exception as e:
            print(f"[-] Warning updating sessions.json: {e}")

    print(f"[+] Fresh Telegram session created: {new_session_id}")
    return True

if __name__ == "__main__":
    configure_session_reset(idle_minutes=30)
    reset_current_telegram_session()
