# Subagent Verification Checklist (Sept 7, 2026)

The subagent for Short #65 reported "SUCCESS" but ingestion was incomplete. **Subagent must verify ALL before reporting complete.**

## Mandatory Verification Checks

| Check | Required | How to Verify |
|-------|----------|---------------|
| **All 20 tables populated** | YES | Run UNION ALL verification query — every table must show ≥1 row |
| **retention_curve ≥ 3 points** | YES | Must have hook (0s/100%), spike/mid, end (duration/retention%) |
| **search_terms.views > 0** | YES | Every term must have views ≥1 (NOT NULL in DB) |
| **traffic_sources.source_category NOT NULL** | YES | Must be 'feed'/'search'/'browse'/'channel'/'external'/'other' |
| **traffic_sources.views > 0** | YES | Must have actual view counts |
| **individual_comments ≥ 1** | YES | If comments_analysis.total_comments > 0 |
| **comments_analysis populated** | YES | All 17 fields filled |
| **short_title_template populated** | YES | All 9 fields from edit page |
| **end_screen_performance populated** | YES | Even if has_end_screen=false |
| **remix_metrics populated** | YES | Even if remix_count=0 |
| **realtime_metrics populated** | YES | Even if views_48h=0 |
| **external_sources populated** | YES | Even if empty array |
| **memory_updates populated** | YES | At least 1 pattern entry |
| **analysis_log = 6 entries** | YES | overview, reach, engagement, audience, comments, edit — each with session_id=20260901 |
| **audience_subscriber_status populated** | YES | All 6 fields |

**Subagent must run verification query and confirm ALL pass before calling task complete.**

## Verification Query (Run After Ingestion)

```python
import psycopg2
conn = psycopg2.connect(dbname='youtube_shorts', user='postgres', host='127.0.0.1', port=5432)
cur = conn.cursor()

tables = [
    'performance_metrics', 'traffic_sources', 'search_terms', 'retention_curve',
    'audience_device', 'audience_gender', 'audience_age', 'audience_geography',
    'audience_subscriber_status', 'audience_subtitles', 'comments_analysis',
    'individual_comments', 'short_content_classification', 'short_title_template',
    'end_screen_performance', 'remix_metrics', 'realtime_metrics', 'external_sources',
    'memory_updates', 'analysis_log'
]

for table in tables:
    cur.execute(f'SELECT COUNT(*) FROM {table} WHERE video_id = %s', (video_id,))
    count = cur.fetchone()[0]
    status = 'EMPTY' if count == 0 else f'{count} rows'
    print(f'  {table}: {status}')

cur.close()
conn.close()
```

## Common Subagent Failures (Sept 7 Session)

| Failure | Root Cause | Prevention |
|---------|------------|------------|
| Comments filter removed but no scroll/extract | Subagent clicked filter X but didn't implement scroll loop | Add explicit todo: "Scroll ytcp-activity-section Phase 1 (10×500px), Phase 2 (300px), extract at EACH position" |
| Retention curve only 1 point | Didn't parse full retention graph text | Extract from Engagement tab bodyText: parse all timestamp-retention pairs |
| Search terms views=0 | Used percentage as views | Map: `views = round(total_views * percentage_of_total / 100)` |
| Traffic sources source_category=NULL | Used source_name as category | Map: 'Shorts feed'→'feed', 'YouTube search'→'search', 'Browse features'→'browse', 'Channel pages'→'channel', 'External'→'external', 'Other'→'other' |
| Missing 5 analysis_log entries | Only logged "All" | Create 6 separate entries with tab_analyzed = overview/reach/engagement/audience/comments/edit |
| Missing audience_subscriber_status | Didn't extract from Audience tab | Extract subscribed_pct, not_subscribed_pct, subscribed_views, not_subscribed_views, sub_viewer_retention_pct, non_sub_viewer_retention_pct |
| Payload missing root keys | Flat structure vs nested | Use EXACT PAYLOAD SCHEMA above — 21 root keys with nested objects/arrays |

## Subagent Todo Template (Use This)

```json
[
  {"id": "nav_edit", "content": "Navigate to Studio edit page", "status": "in_progress"},
  {"id": "overview", "content": "Click Analytics → extract Overview + end_screen + remix", "status": "pending"},
  {"id": "reach", "content": "Click Reach tab → extract traffic_sources + search_terms", "status": "pending"},
  {"id": "engagement", "content": "Click Engagement tab → extract retention_curve (≥3 points)", "status": "pending"},
  {"id": "audience", "content": "Click Audience tab → extract all 6 audience tables (handle Oops)", "status": "pending"},
  {"id": "comments", "content": "Click Comments → remove Unresponded filter (click X) → scroll ytcp-activity-section → extract all threads → build hierarchy", "status": "pending"},
  {"id": "edit", "content": "Click Details/Edit → extract title_template metadata", "status": "pending"},
  {"id": "build_payload", "content": "Build 21-root-key payload per EXACT PAYLOAD SCHEMA", "status": "pending"},
  {"id": "save_ingest", "content": "Save to data/payload_short{id}.json → run ingest_short_forensic.py", "status": "pending"},
  {"id": "verify", "content": "Run UNION ALL verification → confirm ALL 20 tables populated correctly", "status": "pending"}
]
```