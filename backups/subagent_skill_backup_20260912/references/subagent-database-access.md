# Subagent Database Access Pattern — Session 2026-09-09

## Problem
Subagent tried to use `execute_code` with `psycopg2` for database queries:
```python
execute_code(import psycopg2; conn = psycopg2.connect(...))
```
**Failed**: `ModuleNotFoundError: No module named 'psycopg2'` in the execute_code sandbox.

But `terminal` with the same command worked:
```bash
terminal(python -c "import psycopg2; conn = psycopg2.connect(...); ...")
```
**Succeeded**: `psycopg2 available`

## Root Cause
- `execute_code` runs in an isolated sandbox without project dependencies
- `terminal` runs in the project venv where `psycopg2` is installed

## Correct Pattern for Subagents
**Always use `terminal` for database operations**, never `execute_code`.

```bash
# Schema inspection
terminal(python -c "import psycopg2; conn = psycopg2.connect(host='127.0.0.1', database='youtube_shorts', user='postgres'); cur = conn.cursor(); cur.execute(\"SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'short_title_template'\"); print(cur.fetchall()); conn.close()")

# UNION ALL verification
terminal(python -c "
import psycopg2
conn = psycopg2.connect(host='127.0.0.1', database='youtube_shorts', user='postgres')
cur = conn.cursor()
tables = ['performance_metrics', 'traffic_sources', 'search_terms', 'retention_curve', 'audience_device', 'audience_gender', 'audience_age', 'audience_geography', 'audience_subscriber_status', 'audience_subtitles', 'comments_analysis', 'individual_comments', 'short_content_classification', 'short_title_template', 'end_screen_performance', 'remix_metrics', 'realtime_metrics', 'external_sources', 'memory_updates', 'analysis_log']
for t in tables:
    cur.execute(f'SELECT COUNT(*) FROM {t} WHERE video_id = %s', ('Mp1WHa-CXfw',))
    print(f'{t}: {cur.fetchone()[0]}')
cur.close()
conn.close()
")
```

## Ingestion Script Execution
```bash
terminal(command="cd \"C:/Desktop/Antigravity Projects/YouTube Manager\" && python ingest_short_forensic.py data/payload_short69.json")
```

## Verification Script
```bash
terminal(command="cd \"C:/Desktop/Antigravity Projects/YouTube Manager\" && python scripts/verify_comprehensive.py --short-id 69 --video-id Mp1WHa-CXfw")
```

## Rule for Subagent Instructions
> **DATABASE OPERATIONS**: Use `terminal` tool ONLY. Do NOT use `execute_code` for psycopg2 — the sandbox lacks project dependencies. The project venv at `C:/Desktop/Antigravity Projects/YouTube Manager/venv` has all required packages.