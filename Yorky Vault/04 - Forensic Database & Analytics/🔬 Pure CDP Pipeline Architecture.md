---
tags: [cdp, chrome, pipeline, database]
created: 2026-09-20
---

# 🔬 Pure CDP Forensic Pipeline Architecture

> [!IMPORTANT] Single Location Rule
> All pipeline scripts live strictly in `scripts/`. No duplicate scripts in project root.

---

## 🚀 The 3-Stage Pure CDP Execution Commands

```bash
# Step 1: Pure CDP WebSocket Extraction (~25s)
python scripts/extract_short_pure_cdp.py <video_id> <short_id>

# Step 2: Forensic Payload Normalization (<1s)
python scripts/build_payload.py <video_id> <short_id>

# Step 3: Atomic PostgreSQL Ingestion (<1s)
python scripts/ingest_short_forensic.py <short_id>
```

---

## 🛡️ Mandatory Payload Assertions

In `scripts/ingest_short_forensic.py`:
* `assert video_id`: Non-empty 11-char string
* `assert title`: Valid non-empty string
* `assert published_at`: Non-null ISO 8601 timestamp (resolved from Overview date chip)

See also: [[🗄️ 111 Shorts Forensic Index]] • [[🤖 Subagent Delegation Protocol]]
