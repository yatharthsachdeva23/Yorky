# Path Handling Lessons — YouTube Shorts Forensic Pipeline

## The Phantom Path Problem (Sept 8, 2026)

### Root Cause
Different tools interpret `/c/Users/DELL/data/` differently on Windows:

| Tool | Runtime | Path `/c/Users/DELL/data/` resolves to |
|------|---------|----------------------------------------|
| `write_file` | Hermes internal | `C:\c\Users\DELL\data\` (PHANTOM) |
| `terminal` (Git Bash) | MSYS/bash | `C:\Users\DELL\data\` (CORRECT) |
| `execute_code` (native Python) | Windows Python | `C:\c\Users\DELL\data\` (PHANTOM) |

### Result
Two different physical files created:
- `C:\c\Users\DELL\data\payload_short68.json` (from `write_file`/`execute_code`)
- `C:\Users\DELL\data\payload_short68.json` (from `terminal`)

Subagent reads from one, ingestion reads from the other → "file keeps reverting" confusion.

## Solution: Use Relative Paths from Project Directory

### Correct Convention
```
Project Directory: C:/Desktop/Antigravity Projects/YouTube Manager/
Working Directory: C:/Desktop/Antigravity Projects/YouTube Manager/ (config.yaml cwd)

Payload Output: data/payload_short{id}.json
Temp Comments: data/temp_comments_{VIDEO_ID}.json
Ingestion Command: python ingest_short_forensic.py data/payload_short{id}.json
```

### Tool-Specific Rules
- **write_file**: Use relative path `data/payload_short68.json` (resolves from working dir)
- **terminal**: Use relative path `data/payload_short68.json` (Git Bash, cwd = project dir)
- **execute_code**: Use relative path `data/payload_short68.json` (Python, cwd = project dir)
- **Config.yaml**: `cwd: "C:/Desktop/Antigravity Projects/YouTube Manager"` (forward slashes!)

## YAML Path Syntax (Critical)

**WRONG** (breaks YAML parsing):
```yaml
cwd: "C:\Desktop\Antigravity Projects\YouTube Manager"
```
Backslashes `\D` and `\Y` are invalid YAML escape sequences.

**CORRECT**:
```yaml
cwd: "C:/Desktop/Antigravity Projects/YouTube Manager"
```
Forward slashes work natively on Windows and avoid all escaping issues.

## Payload Path Convention (Updated)

| Artifact | Path (Relative to Project Dir) |
|----------|--------------------------------|
| Payload JSON | `data/payload_short{short_id}.json` |
| Comments temp | `data/temp_comments_{VIDEO_ID}.json` |
| Ingestion command | `python ingest_short_forensic.py data/payload_short{short_id}.json` |

**NEVER use**: `/c/Users/DELL/data/`, `/c/Desktop/...`, `C:\Users\DELL\data\`

## Config.yaml Fix Applied (Sept 8, 2026)

**File**: `C:\Users\DELL\AppData\Local\hermes\profiles\youtube\config.yaml`

**Line 93** - Fixed:
```yaml
# Before (broken):
cwd: "C:\Desktop\Antigravity Projects\YouTube Manager"

# After (fixed):
cwd: "C:/Desktop/Antigravity Projects/YouTube Manager"
```

## Skill Updates Applied (Sept 8, 2026)

### SKILL.md (youtube-automation)
- All payload path references updated from `/c/Users/DELL/data/` to `data/`
- Ingestion commands updated to use `data/payload_short{id}.json`
- Python path simplified to `python` (uses venv from cwd)

### master_protocols.md (references/)
- Temp comments path: `/c/Users/DELL/data/temp_comments_...` → `data/temp_comments_...`
- Payload path: `/c/Users/DELL/data/payload_short...` → `data/payload_short...`
- Workspace rule: `/c/Users/DELL/` → project directory `C:/Desktop/Antigravity Projects/YouTube Manager/`
- CD command: `/c/Desktop/...` → `C:/Desktop/...`

## Verification Checklist for Future Sessions

- [ ] `config.yaml` terminal.cwd uses forward slashes
- [ ] All skill references use `data/payload_short{id}.json`
- [ ] No `/c/Users/DELL/data/` in instructional text (only in warning tables)
- [ ] Ingestion command uses relative path from project directory
- [ ] Subagent context includes working directory and path rules