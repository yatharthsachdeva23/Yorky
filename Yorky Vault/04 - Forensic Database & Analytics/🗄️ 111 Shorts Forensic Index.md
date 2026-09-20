---
tags: [database, shorts, forensic, analytics]
created: 2026-09-20
---

# 🗄️ 111 Shorts Forensic Master Index

> [!INFO] Audit Status
> 100% of all 111 Shorts uploaded to `@YatharthSachdeva` have been forensically extracted from YouTube Studio via Pure CDP and ingested into normalized PostgreSQL tables.

---

## 📊 Milestone Highlights

* **Short #1 (`5goNjmztwqg`)**: Oldest Short (Published Jan 22, 2024). Verified end-to-end Pure CDP pipeline.
* **Short #41 (`pszcrf0uTbQ`)**: Top engagement short with **107 comments**, 29 question threads.
* **Short #62 (`j4CtPMW-1Q4`)**: Date correction applied: fixed placeholder date (`2024-10-15`) to ground-truth published date (`2024-05-25`).
* **Short #111 (`8Hq1h-LhO1k`)**: Newest Short analyzed.

---

## 🔍 Key SQL Verification Queries

```sql
-- Check total coverage of Shorts with complete metadata:
SELECT COUNT(*) as total_shorts,
       COUNT(published_at) as with_published_date,
       COUNT(related_video_id) as with_related_video
FROM shorts;

-- Inspect Top 5 Shorts by Retention %:
SELECT s.short_id, s.title, pm.views, pm.retention_pct
FROM shorts s
JOIN performance_metrics pm ON s.video_id = pm.video_id
ORDER BY pm.retention_pct DESC
LIMIT 5;
```

See also: [[🔬 Pure CDP Pipeline Architecture]] • [[📊 Channel KPI & Status]]
