# Sept 7, 2026 — Database Verification Results

## Direct Query Results (psql/psycopg2)

| Metric | Count |
|--------|-------|
| Total shorts in `shorts` table | 80 |
| Completely ingested (all 20 core tables) | 3 |
| Incomplete (missing ≥1 table) | 77 |

## Incomplete Shorts Breakdown

Most common missing tables across the 77 incomplete shorts:

| Missing Table | Frequency | Notes |
|--------------|-----------|-------|
| `individual_comments` | ~70+ | Comments extraction failed or skipped |
| `external_sources` | ~70+ | External referrer data not extracted |
| `short_title_template` | ~30+ | Title metadata from Edit page missing |
| `realtime_metrics` | ~25+ | 48h velocity data missing |
| `search_terms` | ~15+ | Search traffic terms missing |
| `retention_curve` | ~10+ | Engagement tab retention graph not parsed |

## Fully Complete Shorts (3)

Only 3 shorts have all 20 core tables populated. These are the gold-standard references for verification.

## Query Used

```python
import psycopg2

tables = [
    'performance_metrics', 'traffic_sources', 'search_terms', 'retention_curve',
    'audience_device', 'audience_gender', 'audience_age', 'audience_geography',
    'audience_subscriber_status', 'audience_subtitles', 'comments_analysis',
    'individual_comments', 'short_content_classification', 'short_title_template',
    'end_screen_performance', 'remix_metrics', 'realtime_metrics', 'external_sources',
    'memory_updates', 'analysis_log'
]

# For each video_id, check all 20 tables
# Complete = all 20 return COUNT(*) >= 1
```

## Action Required

1. **Re-ingest 77 incomplete shorts** with complete payloads (focus on missing tables)
2. **Ingest shorts 81-111** (31 never ingested)
3. **Run verification after every batch** — UNION ALL query across all 20 tables

## Next Verification

Run after each batch of 3-5 shorts:
```sql
SELECT 'performance_metrics' as table_name, COUNT(*) FROM performance_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = 'VID'
-- ... repeat for all 20 tables
ORDER BY table_name;
```
Every table must return ≥1.