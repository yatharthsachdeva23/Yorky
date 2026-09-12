import sqlite3
import time
import os
import json
import re
from datetime import datetime

def parse_log_timestamp(line):
    m = re.match(r'^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}(?:,\d+)?)', line)
    if m:
        try:
            ts_str = m.group(1).replace(',', '.')
            dt = datetime.strptime(ts_str[:19], "%Y-%m-%d %H:%M:%S")
            return dt.timestamp()
        except Exception:
            pass
    return None

class HermesWatcher:
    def __init__(self, db_path=None, log_path=None):
        self.db_path = db_path or r'C:\Users\DELL\AppData\Local\hermes\profiles\youtube\state.db'
        self.agent_log_path = log_path or r'C:\Users\DELL\AppData\Local\hermes\profiles\youtube\logs\agent.log'

    def get_recent_log_events(self, max_bytes=16384):
        if not os.path.exists(self.agent_log_path):
            return []
        try:
            with open(self.agent_log_path, "r", encoding="utf-8", errors="ignore") as f:
                f.seek(0, os.SEEK_END)
                size = f.tell()
                f.seek(max(0, size - max_bytes))
                lines = [l.strip() for l in f if l.strip()]
            events = []
            for l in lines[-40:]:
                ts = parse_log_timestamp(l)
                events.append((ts, l))
            return events
        except Exception:
            return []

    def check_api_wait_or_rate_limit(self, recent_events):
        """
        Detects if Hermes (main or subagent) is currently rate limited, 
        retrying, waiting on NVIDIA provider, or waiting on slow API response.
        """
        now = time.time()
        if not recent_events:
            return None, None

        # Look backwards through recent events
        for i in range(len(recent_events) - 1, -1, -1):
            ts, line = recent_events[i]
            low = line.lower()

            # If a turn has cleanly ended, we are NOT in an active rate limit/wait
            if "turn ended" in low:
                if ts and (now - ts < 30):
                    return None, None

            # 1. Active Retry / Backoff wait
            m_retry = re.search(r'retrying api call in ([\d\.]+)s(?:\s*\(attempt (\d+)/\d+\))?', low)
            if m_retry:
                retry_wait = float(m_retry.group(1))
                attempt = m_retry.group(2) or "1"
                # If we are within the retry sleep window or within 5s after
                if ts and (now - ts < retry_wait + 6.0):
                    return "WAITING_API", f"⏳ Rate limited (attempt {attempt}) / Retrying..."
                break

            # 2. Service temporarily overloaded / 429 / 503
            if any(k in low for k in ["service temporarily overloaded", "too many requests", "streaming failed before delivery"]):
                if ts and (now - ts < 10.0):
                    return "WAITING_API", "⏳ Rate limited / Waiting on API..."
                break

            # 3. Stream stale / Reconnecting / Waiting on provider
            if any(k in low for k in ["waiting on provider", "stream stale", "reconnecting in", "reconnecting to"]):
                if ts and (now - ts < 15.0):
                    return "WAITING_API", "⏳ Waiting on NVIDIA provider..."
                break

            # 4. If a tool completed, forward progress happened
            if "tool" in low and "completed" in low:
                break

            # 5. Long API Call (Time to first token > 8s)
            if "api call #" in low or "chat_completion_stream_request" in low:
                if ts and (now - ts > 8.0) and (now - ts < 120.0):
                    return "WAITING_API", "⏳ Waiting for NVIDIA response..."
                # If it just started (< 8s ago), it's actively reflecting/thinking
                break

        return None, None

    def get_subagent_live_action(self, delegation_id, goal_text=""):
        """Extracts the live activity of a subagent from its streaming task-0.log."""
        profile_dir = os.path.dirname(self.db_path)
        log_dir = os.path.join(profile_dir, "cache", "delegation", "live", delegation_id)
        log_file = os.path.join(log_dir, "task-0.log")

        short_num = ""
        m_short = re.search(r'Short\s*#?(\d+)', goal_text, re.IGNORECASE)
        if m_short:
            short_num = f"Short #{m_short.group(1)}: "

        if not os.path.exists(log_file):
            return f"{short_num}Starting up..."

        try:
            with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()

            for line in reversed(lines[-20:]):
                low = line.lower()
                if "ingest_short" in low and ("terminal" in low or "success" in low):
                    return f"{short_num}Ingesting to DB..."
                if "verify_short" in low:
                    return f"{short_num}Verifying tables..."
                if "write_file" in low and "payload" in low:
                    return f"{short_num}Writing payload..."
                if "extract_short" in low:
                    return f"{short_num}Extracting metrics via CDP..."
                if "browser_navigate" in low:
                    return f"{short_num}Navigating Studio..."
                if "browser_click" in low or "browser_snapshot" in low:
                    if "reach" in low:
                        return f"{short_num}Scraping Reach..."
                    elif "engagement" in low:
                        return f"{short_num}Scraping Engagement..."
                    elif "audience" in low:
                        return f"{short_num}Scraping Audience..."
                    elif "comment" in low:
                        return f"{short_num}Scraping Comments..."
                    elif "detail" in low or "edit" in low:
                        return f"{short_num}Checking Details..."
                    else:
                        return f"{short_num}Browsing Studio..."
                if "terminal(" in low:
                    return f"{short_num}Running terminal..."
                if "execute_code(" in low:
                    return f"{short_num}Processing data..."
                if "think" in low:
                    return f"{short_num}Analyzing metrics..."

            return f"{short_num}Working..."
        except Exception:
            return f"{short_num}Working..."

    def get_all_active_subagents(self):
        """Returns a list of all currently running subagents with their live activity."""
        if not os.path.exists(self.db_path):
            return []
        subagents = []
        try:
            conn = sqlite3.connect(f"file:{self.db_path}?mode=ro", uri=True, timeout=1.0)
            cur = conn.cursor()
            cur.execute("""
                SELECT delegation_id, state, task_json, dispatched_at, updated_at 
                FROM async_delegations 
                WHERE state = 'running' 
                ORDER BY dispatched_at ASC
            """)
            rows = cur.fetchall()
            for row in rows:
                did = row[0]
                tdata = json.loads(row[2]) if row[2] else {}
                goal = tdata.get('goal', '') or tdata.get('description', '')
                action_text = self.get_subagent_live_action(did, goal)
                subagents.append({
                    "id": did,
                    "goal": goal,
                    "action": action_text,
                    "dispatched_at": row[3]
                })
            conn.close()
        except Exception:
            pass
        return subagents

    def get_active_subagent_info(self, conn):
        try:
            cur = conn.cursor()
            cur.execute("""
                SELECT delegation_id, state, task_json, updated_at 
                FROM async_delegations 
                WHERE state = 'running' 
                ORDER BY updated_at DESC LIMIT 1
            """)
            row = cur.fetchone()
            if row:
                tdata = json.loads(row[2]) if row[2] else {}
                goal = tdata.get('goal', '') or tdata.get('description', '')
                return row[0], goal
        except Exception:
            pass
        return None, None

    def parse_tool_details(self, tool_name, tool_calls, is_subagent=False):
        name = tool_name or ""
        command_arg = ""
        try:
            if tool_calls:
                tc = json.loads(tool_calls)
                if isinstance(tc, list) and len(tc) > 0:
                    func = tc[0].get('function', {})
                    name = func.get('name') or tc[0].get('name') or name
                    args = func.get('arguments', '')
                    if isinstance(args, str) and args:
                        try:
                            parsed = json.loads(args)
                            command_arg = parsed.get('command', '') or parsed.get('code', '') or parsed.get('path', '')
                        except Exception:
                            command_arg = args
                    elif isinstance(args, dict):
                        command_arg = args.get('command', '') or args.get('code', '') or args.get('path', '')
        except Exception:
            pass

        low_name = name.lower()
        low_cmd = str(command_arg).lower()
        prefix = "Subagent: " if is_subagent else ""

        if "delegate" in low_name or "subagent" in low_name:
            return "SUBAGENT", "Supervising subagent..."

        # Querying DB
        if any(w in low_cmd for w in ["psql", "select ", "delete from", "insert into", "update ", "psycopg2", "database"]):
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Querying DB..."

        # Running Python scripts
        if any(w in low_cmd for w in ["python", ".py", "execute_code"]) or "execute_code" in low_name:
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Running Python script..."

        # Checking skills
        if low_name in ("skills_list", "skill_view") or "skills" in low_cmd:
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Checking skills..."

        # Editing files
        if low_name in ("skill_manage", "write_file", "edit_file", "replace_file_content"):
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Editing files..."

        # Finding / Searching
        if low_name in ("find_files", "search_code", "search_files") or any(w in low_cmd for w in ["grep ", "find ", "ls "]):
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Searching files..."

        # Browser
        if low_name.startswith("browser_"):
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Browsing Studio..."

        # Terminal
        if low_name == "terminal":
            return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Executing terminal..."

        return ("SUBAGENT" if is_subagent else "WORKING"), f"{prefix}Running {name or 'command'}..."

    def get_state(self):
        if not os.path.exists(self.db_path):
            return "WAITING", "Hermes offline"

        recent_events = self.get_recent_log_events()
        now = time.time()

        conn = None
        try:
            conn = sqlite3.connect(f"file:{self.db_path}?mode=ro", uri=True, timeout=1.0)
            cur = conn.cursor()

            # Find active CLI session
            cur.execute("SELECT id FROM sessions WHERE source = 'cli' ORDER BY rowid DESC LIMIT 1")
            row = cur.fetchone()
            active_session_id = row[0] if row else None

            # Check background subagent status
            sub_id, sub_goal = self.get_active_subagent_info(conn)

            # Get recent messages in CLI session
            cur.execute("""
                SELECT id, session_id, role, tool_name, tool_calls, timestamp, content
                FROM messages
                ORDER BY id DESC LIMIT 20
            """)
            rows = cur.fetchall()

            latest_cli = None
            if active_session_id:
                for r in rows:
                    if r[1] == active_session_id:
                        latest_cli = r
                        break
            if not latest_cli and rows:
                latest_cli = rows[0]

            if not latest_cli:
                conn.close()
                return "WAITING", "Ready for command ✨"

            msg_id, sess_id, role, tool_name, tool_calls, msg_ts, content = latest_cli

            # Check whether the CLI session is IDLE (turn completed)
            is_cli_idle = (role == 'assistant' and not tool_calls)

            # Check log events for recent turn completion in CLI session
            for ts_l, line in reversed(recent_events[-10:]):
                if active_session_id and f"[{active_session_id}]" in line:
                    if "turn ended" in line.lower() or "openai client closed" in line.lower():
                        is_cli_idle = True
                        break
                    if "conversation turn" in line.lower() or "api call #" in line.lower():
                        is_cli_idle = False
                        break

            # ── 1. If CLI is IDLE (Waiting for User Prompt) ──
            if is_cli_idle:
                conn.close()
                if sub_id:
                    # CLI is waiting for user, but a subagent is running in background
                    return "DONE", "Waiting for command ⌚ (Subagent active)"
                return "DONE", "Waiting for your command ⌚"

            # ── 2. ACTIVE WORK: CHECK RATE LIMIT / API WAIT FIRST (TOPMOST LAYER) ──
            api_state, api_desc = self.check_api_wait_or_rate_limit(recent_events)
            if api_state:
                conn.close()
                return api_state, api_desc

            # ── 3. Check for Terminal Prep in Log ──
            log_act = None
            for ts_l, line in reversed(recent_events[-10:]):
                low = line.lower()
                if active_session_id and f"[{active_session_id}]" in line:
                    if "creating new local environment" in low or "local environment ready" in low:
                        log_act = "Preparing terminal..."
                        break
                    if "agent.tool_executor: tool" in low and "completed" in low:
                        if ts_l and (now - ts_l < 5.0):
                            log_act = "Processing output..."
                        break

            # ── 4. CLI ACTIVE STATE: User turn in flight ──
            if role == 'user':
                conn.close()
                return "WORKING", log_act or "Reflecting & thinking..."

            # Active tool call
            if role == 'assistant' and tool_calls:
                tool_state, tool_desc = self.parse_tool_details(tool_name, tool_calls, is_subagent=False)
                if log_act == "Preparing terminal...":
                    tool_desc = log_act
                conn.close()
                return tool_state, tool_desc

            # Tool output returned
            if role == 'tool':
                conn.close()
                return "WORKING", log_act or "Processing output..."

            conn.close()
            return "WAITING", "Ready for command ✨"

        except Exception as e:
            if conn:
                try:
                    conn.close()
                except Exception:
                    pass
            return "WAITING", f"Status: {str(e)[:20]}"

if __name__ == "__main__":
    w = HermesWatcher()
    st, act = w.get_state()
    safe_act = (act or '').encode('ascii', errors='replace').decode('ascii')
    print(f"Evaluated State: [{st}] -> {safe_act}")
