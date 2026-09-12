# Verification Checklist — 10-Level Database Verification

**Run after EVERY short ingestion** (or at batch milestones). Never assume DB state — always query directly.

---

## Level 1: Core Tables (Must Have Data)
```sql
SELECT s.short_id, s.video_id, s.title, pm.views, pm.retention_pct
FROM shorts s
LEFT JOIN performance_metrics pm ON s.video_id = pm.video_id
WHERE s.short_id = {SHORT_ID};
```
- ✅ `shorts` row exists
- ✅ `performance_metrics` row exists (views, retention, avg_view_duration_seconds)

---

## Level 2: Traffic Sources (Must Have 5-6 Rows)
```sql
SELECT source_name, source_category, views, percentage
FROM traffic_sources
WHERE video_id = '{VIDEO_ID}'
ORDER BY percentage DESC;
```
- ✅ 5-6 sources per short
- ✅ Percentages sum to ~100%
- ✅ Categories: feed, search, browse, channel, suggested, other, notifications

---

## Level 3: Search Terms (Must Have Quality Data)
```sql
SELECT search_term, views, percentage_of_search, percentage_of_total, intent_category, relevance_score
FROM search_terms
WHERE video_id = '{VIDEO_ID}'
ORDER BY views DESC;
```
- ✅ 3-8 terms per short
- ✅ `intent_category` ∈ {specific, related, noise}
- ✅ `relevance_score` 1-5
- ✅ Check for noise patterns (bbose, bhojpuri, instrumental, cinderella gown)

---

## Level 4: Retention Curve (Must Have 3+ Points)
```sql
SELECT timestamp_seconds, retention_pct, is_key_moment, moment_type, moment_note
FROM retention_curve
WHERE video_id = '{VIDEO_ID}'
ORDER BY timestamp_seconds;
```
- ✅ At least 3 points (start, spike, end)
- ✅ `is_key_moment` = true for spike point
- ✅ `moment_type` ∈ {hook, spike, mid, end}

---

## Level 5: Audience Demographics (All 6 Tables)
```sql
-- Device
SELECT mobile_pct, desktop_pct, tv_pct, tablet_pct, desktop_intent_proxy FROM audience_device WHERE video_id = '{VIDEO_ID}';
-- Gender
SELECT male_pct, female_pct, unknown_pct, has_data FROM audience_gender WHERE video_id = '{VIDEO_ID}';
-- Age
SELECT age_13_17_pct, age_18_24_pct, age_25_34_pct, target_audience_pct, non_target_pct, has_data FROM audience_age WHERE video_id = '{VIDEO_ID}';
-- Geography
SELECT country_code, country_name, views, percentage, is_target_country FROM audience_geography WHERE video_id = '{VIDEO_ID}' ORDER BY percentage DESC;
-- Subscriber status
SELECT subscribed_pct, not_subscribed_pct, sub_viewer_retention_pct, non_sub_viewer_retention_pct FROM audience_subscriber_status WHERE video_id = '{VIDEO_ID}';
-- Subtitles
SELECT none_pct, hindi_pct, english_pct, other_pct, has_cc_data FROM audience_subtitles WHERE video_id = '{VIDEO_ID}';
```

---

## Level 6: Comments (Must Match Extracted)
```sql
SELECT total_comments, comments_per_1k_views, top_level_comments, total_replies, creator_replies, creator_reply_rate
FROM comments_analysis WHERE video_id = '{VIDEO_ID}';

SELECT comment_id, author_name, is_creator, depth, parent_comment_id, intent_category, sentiment
FROM individual_comments WHERE video_id = '{VIDEO_ID}' ORDER BY depth, comment_id;
```
- ✅ `comments_analysis` matches extraction
- ✅ `individual_comments` has thread hierarchy (parent_comment_id, depth)
- ✅ `intent_category` ∈ {query, gratitude, creator_reply, creator_promo, spam, other}

---

## Level 7: Classification & Templates
```sql
SELECT primary_type, secondary_type, confidence_score FROM short_content_classification WHERE video_id = '{VIDEO_ID}';
SELECT template_id, title_length, word_count, hashtag_count, emoji_count, char_before_pipe, char_after_pipe FROM short_title_template WHERE video_id = '{VIDEO_ID}';
```
- ✅ Classification exists with confidence 8-9
- ✅ Title template exists for all analyzed shorts

---

## Level 8: End Screen & Remix
```sql
SELECT has_end_screen, element_type, element_video_id, impressions, clicks, vs_channel_avg_pct FROM end_screen_performance WHERE video_id = '{VIDEO_ID}';
SELECT remix_count, remix_views FROM remix_metrics WHERE video_id = '{VIDEO_ID}';
```
- ✅ End screen data (even if `has_end_screen=false`)
- ✅ `vs_channel_avg_pct = 0.0` when no impressions

---

## Level 9: Realtime & External
```sql
SELECT views_48h, velocity_views_per_hour FROM realtime_metrics WHERE video_id = '{VIDEO_ID}';
SELECT source_domain, views, percentage FROM external_sources WHERE video_id = '{VIDEO_ID}';
```
- ✅ May be empty (0 rows) for old shorts — that's valid
- ✅ If WhatsApp/Telegram present → external source row exists

---

## Level 10: Memory & Analysis Log
```sql
SELECT update_type, title, payload, priority, applied_to_pipeline FROM memory_updates WHERE video_id = '{VIDEO_ID}';
SELECT session_id, tab_analyzed, status, data_completeness FROM analysis_log WHERE video_id = '{VIDEO_ID}';
```
- ✅ `memory_updates` has pattern entry (priority 3)
- ✅ `analysis_log` has 6 entries (overview, reach, engagement, audience, comments, edit)
- ✅ `session_id` = bigint (1, 2, 20260901...) — NOT strings

---

## Batch Verification (All Tables at Once)
```sql
SELECT table_name, COUNT(*) FROM (
  SELECT 'performance_metrics' as table_name FROM performance_metrics WHERE video_id = 'VID'
  UNION ALL SELECT 'traffic_sources' FROM traffic_sources WHERE video_id = 'VID'
  UNION ALL SELECT 'search_terms' FROM search_terms WHERE video_id = 'VID'
  UNION ALL SELECT 'retention_curve' FROM retention_curve WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_device' FROM audience_device WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_gender' FROM audience_gender WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_age' FROM audience_age WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_geography' FROM audience_geography WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_subscriber_status' FROM audience_subscriber_status WHERE video_id = 'VID'
  UNION ALL SELECT 'audience_subtitles' FROM audience_subtitles WHERE video_id = 'VID'
  UNION ALL SELECT 'comments_analysis' FROM comments_analysis WHERE video_id = 'VID'
  UNION ALL SELECT 'individual_comments' FROM individual_comments WHERE video_id = 'VID'
  UNION ALL SELECT 'short_content_classification' FROM short_content_classification WHERE video_id = 'VID'
  UNION ALL SELECT 'short_title_template' FROM short_title_template WHERE video_id = 'VID'
  UNION ALL SELECT 'end_screen_performance' FROM end_screen_performance WHERE video_id = 'VID'
  UNION ALL SELECT 'remix_metrics' FROM remix_metrics WHERE video_id = 'VID'
  UNION ALL SELECT 'realtime_metrics' FROM realtime_metrics WHERE video_id = 'VID'
  UNION ALL SELECT 'external_sources' FROM external_sources WHERE video_id = 'VID'
  UNION ALL SELECT 'memory_updates' FROM memory_updates WHERE video_id = 'VID'
  UNION ALL SELECT 'analysis_log' FROM analysis_log WHERE video_id = 'VID'
) t GROUP BY table_name ORDER BY table_name;
```
**Expected**: 20 tables with ≥1 row (realtime, external, title_template may be 0 for older shorts — that's valid)

---

## Red Flags (Fail Fast)

| Symptom | Cause | Fix |
|---------|-------|-----|
| `SUCCESS` but 0 rows in traffic_sources | Payload missing `traffic_sources` array | Check extraction parsing |
| FK violation on `analysis_log.session_id` | String instead of bigint | Use numeric session IDs |
| `engagement_rate` > 100 | Numeric overflow | Cap at 99.9999 |
| `vs_channel_avg_pct` = -100 | Division by zero | Use 0.0 when no impressions |
| `search_terms` empty | Noise filtering too aggressive | Keep all terms, tag noise |
| `individual_comments` = 0 but `comments_analysis.total_comments` > 0 | Thread hierarchy not built | Fix parent_comment_id logic |
| Duplicate video_ids | Ingestion not upserting | Check ON CONFLICT clauses |

---

## Automation: `verify_comprehensive.py`
```bash
cd "C:/Desktop/Antigravity Projects/YouTube Manager"
python scripts/verify_comprehensive.py --short-id 52
python scripts/verify_comprehensive.py --range 52-65
```
Runs all 10 levels, outputs JSON report with pass/fail per level.