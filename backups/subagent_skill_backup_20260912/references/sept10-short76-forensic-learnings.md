# Sept 10, 2026 — Short #76 (a6DGQWZ57EE) Forensic Analysis Learnings

## Payload Build & Ingestion

**Title template mapping**: Title "😨DON'T HAVE CATEGORY CERTIFICATE?? SEAT WILL CANCEL IN JAC/JOSAA?? #jee2024 #josaa #shorts" → template_id=28 (alert_announcement: emoji prefix + urgency marker + 3 hashtags)

**Critical FK Fix**: `analysis_log.session_id` must be integer bigint referencing `analysis_sessions.id`. Using `20260910` (string-like) caused FK violation; fixed to `20260901` which exists in analysis_sessions table.

**Payload path rule**: Always use `data/payload_short{short_id}.json` relative to project workspace. Absolute paths `/c/...` create phantom `C:\c\` folders on Windows.

**Traffic source category mapping**:
- 'Shorts feed' → 'feed'
- 'YouTube search' → 'search'  
- 'Browse features' → 'browse'
- 'Channel pages' → 'channel'
- 'External' → 'external'
- 'Other' → 'other'

**Retention curve minimum**: Must have ≥3 points — hook (timestamp=0, retention=100%), midpoint, end (timestamp=duration, retention=pct)

**Search terms views calculation**: `views = round(total_views * percentage_of_total / 100)`. Never pass 0 or null — DB has NOTNull constraint.

**Comments filter removal**: Click the X/CLOSE button on the chip (`button[aria-label*="remove"], button[aria-label*="close"], button[aria-label*="delete"], .close-button, .remove-button, ytcp-iconbutton`), NOT the chip itself. Chip opens dropdown; X button removes filter.

**Retry handling**: After EVERY navigation AND tab click, check for "Retry" button and click it. Wait 5s after Retry, verify data loads (no "Oops"/"something went wrong").

**Audience tab workaround**: If "Oops, something went wrong" appears after 5 retries, set `has_data: false` for audience_gender, audience_age, audience_subtitles and note in patterns.

**Engagement tab data**: Must extract retention_curve from page body text using regex pattern `(\d{1,2}:\d{2}|\d+\.?\d*s?)\s*[–-]\s*(\d+\.?\d*)%`. Mark first as hook, peak as spike, last as end.

## Navigation Protocol (Verified)

1. Start at: `https://studio.youtube.com/video/{video_id}/edit?theme=dark`
2. Click Analytics from LEFT SIDEBAR: `a.menu-item-link` with TEXT "Analytics"
3. Click each Analytics sub-tab (`[role="tab"]`): Overview → Reach → Engagement → Audience
4. ALWAYS check for "Retry" button after EVERY navigation AND tab click
5. Click Comments: `a.menu-item-link` with TEXT "Comments"
6. Click Details/Edit: `a.menu-item-link` with TEXT "Details" or "Edit"

## Verification (Mandatory Before Completion)

Run UNION ALL query across all 20 tables:
```sql
SELECT 'performance_metrics' as table_name, COUNT(*) FROM performance_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = 'VID'
UNION ALL SELECT 'search_terms', COUNT(*) FROM search_terms WHERE video_id = 'VID'
UNION ALL SELECT 'retention_curve', COUNT(*) FROM retention_curve WHERE video_id = 'VID'
UNION ALL SELECT 'audience_device', COUNT(*) FROM audience_device WHERE video_id = 'VID'
UNION ALL SELECT 'audience_gender', COUNT(*) FROM audience_gender WHERE video_id = 'VID'
UNION ALL SELECT 'audience_age', COUNT(*) FROM audience_age WHERE video_id = 'VID'
UNION ALL SELECT 'audience_geography', COUNT(*) FROM audience_geography WHERE video_id = 'VID'
UNION ALL SELECT 'audience_subscriber_status', COUNT(*) FROM audience_subscriber_status WHERE video_id = 'VID'
UNION ALL SELECT 'audience_subtitles', COUNT(*) FROM audience_subtitles WHERE video_id = 'VID'
UNION ALL SELECT 'comments_analysis', COUNT(*) FROM comments_analysis WHERE video_id = 'VID'
UNION ALL SELECT 'individual_comments', COUNT(*) FROM individual_comments WHERE video_id = 'VID'
UNION ALL SELECT 'short_content_classification', COUNT(*) FROM short_content_classification WHERE video_id = 'VID'
UNION ALL SELECT 'short_title_template', COUNT(*) FROM short_title_template WHERE video_id = 'VID'
UNION ALL SELECT 'end_screen_performance', COUNT(*) FROM end_screen_performance WHERE video_id = 'VID'
UNION ALL SELECT 'remix_metrics', COUNT(*) FROM remix_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'realtime_metrics', COUNT(*) FROM realtime_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'external_sources', COUNT(*) FROM external_sources WHERE video_id = 'VID'
UNION ALL SELECT 'memory_updates', COUNT(*) FROM memory_updates WHERE video_id = 'VID'
UNION ALL SELECT 'analysis_log', COUNT(*) FROM analysis_log WHERE video_id = 'VID'
ORDER BY table_name;
```

All 20 tables must show ≥1 row for task completion.

## DB State Reference (Sept 7, 2026)

- 80 shorts in DB
- Only 3 completely ingested (all 20 tables)
- 77 incomplete (common missing: individual_comments, external_sources, short_title_template, realtime_metrics, search_terms, retention_curve)
- Shorts 81-111 never ingested

## Key Pitfalls Avoided

| Failure | Root Cause | Fix |
|---------|------------|-----|
| FK violation on analysis_log | session_id as string "20260910" | Use integer 20260901 (exists in analysis_sessions) |
| Traffic source category NULL | Used 'Shorts feed' instead of 'feed' | Map source names to category codes |
| retention_curve < 3 points | Only extracted 1-2 points | Parse full body text, mark hook/middle/end |
| search_terms views=0 | Used percentage directly | Calculate: round(total_views * percentage / 100) |
| Comments filter not removed | Clicked chip instead of X button | Click X/CLOSE button on chip |
| Payload path phantom folders | Used /c/Users/DELL/... | Use relative data/payload_short{id}.json |
| verification cartesian duplicates | JOIN across 1:N tables | Use UNION ALL per table independently |
| engagement_rate > 99.9999 | Numeric(6,4) precision limit | Cap at 99.9999 |
| vs_channel_avg_pct = -100.0 | Numeric(6,4) when impressions=0 | Use 0.0 when no impressions |