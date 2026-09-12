# Path Protocol for Subagents — Session 2026-09-08 (Updated 2026-09-09)

## Critical Rule: NEVER Use `/c/` Paths

**Why**: On Windows, `/c/Users/...` in Python/write_file creates phantom `C:\c\Users\...` directories. Native Windows tools (Python, Chrome, write_file) do NOT interpret `/c/` as `C:`.

| Tool | Path Used | Actual Location |
|------|-----------|-----------------|
| `write_file("/c/Users/DELL/data/...")` | `/c/Users/DELL/data/` | `C:\c\Users\DELL\data\` (PHANTOM) |
| `terminal` (Git Bash) | `/c/Users/DELL/data/...` | `C:\Users\DELL\data\` (correct) |
| `execute_code` (native Python) | `/c/Users/DELL/data/...` | `C:\c\Users\DELL\data\` (PHANTOM) |

## Mandatory Rules for Subagents

### 1. Payload Output Path
```python
# CORRECT - use write_file with relative path
write_file(path="data/payload_short69.json", content=json_string)

# WRONG - creates phantom directory
execute_code(with open('C:/Desktop/Antigravity Projects/YouTube Manager/data/payload_short69.json', 'w') as f: ...)
```

### 2. Ingestion Command
```bash
# CORRECT - from project directory with relative path
terminal(command="cd \"C:/Desktop/Antigravity Projects/YouTube Manager\" && python ingest_short_forensic.py data/payload_short69.json")

# WRONG - absolute path with /c/
terminal(command="python /c/Desktop/Antigravity Projects/YouTube Manager/ingest_short_forensic.py /c/Desktop/Antigravity Projects/YouTube Manager/data/payload_short69.json")
```

### 3. Working Directory
All operations relative to: `C:/Desktop/Antigravity Projects/YouTube Manager/` (project workspace)

### 4. Verification
```bash
# Check file landed correctly
terminal(command="ls -la \"C:/Desktop/Antigravity Projects/YouTube Manager/data/payload_short69.json\"")
```

## Subagent Instruction Template
> **PATH PROTOCOL (MANDATORY)**:
> - Save payload: `write_file(path="data/payload_short{id}.json", content=...)` — RELATIVE PATH ONLY
> - Run ingestion: `terminal(command="cd \"C:/Desktop/Antigravity Projects/YouTube Manager\" && python ingest_short_forensic.py data/payload_short{id}.json")`
> - NEVER use `/c/` paths in any tool, `execute_code`, terminal, or file operations
> - NEVER use absolute paths in Python file I/O
> - Verify: `terminal(command="ls -la \"C:/Desktop/Antigravity Projects/YouTube Manager/data/payload_short{id}.json\"")`