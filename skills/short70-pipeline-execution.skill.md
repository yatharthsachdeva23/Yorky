---
name: short70-pipeline-execution
description: Execute the 3-step Pure CDP pipeline for Short #70
category: youtube-automation
---

# Execute Pure CDP pipeline for Short #70

**Trigger:** When running the 3-step Pure CDP pipeline for a specific YouTube Short by video_id and short_id.

**Steps:**
1. `python scripts/extract_short_pure_cdp.py <video_id> <short_id>` — Extracts analytics, metadata, and comments from YouTube Studio via isolated CDP target
2. `python scripts/build_payload.py <video_id> <short_id>` — Builds the full payload JSON from extracted data
3. `python scripts/ingest_short_forensic.py <short_id>` — Ingests all data into PostgreSQL forensic analysis database (atomic transaction)

**Output files:**
- `data\extracted_short70.json` — Raw extracted CDP data
- `data\payload_short70.json` — Built payload with all sections
- Database record in `youtube_shorts` PostgreSQL database

**Known issue & fix:** If `ingest_short_forensic.py` fails with "Missing 'published_at' in shorts dict", add `shorts['published_at'] = '<extracted_at timestamp>'` to the payload before running step 3. The `published_at` field may be None if not captured during extraction; use the `extracted_at` timestamp from `extracted_short*.json`.

**Verification:** Check console output for `[SUCCESS]` messages and the "Differential Ingestion Summary" table.