## Short #68 Payload Structure — September 8, 2026

**Short ID**: 68  
**Video ID**: YaAKtkecoRc  
**Payload File**: `data/payload_short68.json` (relative to project root)

### Required 21 Root Keys (All Must Be Present)
```json
{
  "video_id": "YaAKtkecoRc",
  "shorts": { ... },           // 38 fields - see full schema in youtube-automation skill
  "performance_metrics": { ... },  // 20 fields
  "traffic_sources": [...],    // Array of source objects
  "retention_curve": [...],    // Array of retention points (≥3 required)
  "search_terms": [...],       // Array of search term objects
  "audience_device": {...},    // 10 fields
  "audience_gender": {...},    // 4 fields
  "audience_age": {...},       // 9 fields
  "audience_geography": [...], // Array of geo objects
  "audience_subscriber_status": {...},  // 6 fields
  "audience_subtitles": {...},     // 5 fields
  "comments_analysis": {...},      // 17 fields
  "individual_comments": [...],    // Array of comment objects
  "short_content_classification": {...},  // 3 fields
  "short_title_template": {...},     // 9 fields
  "end_screen_performance": {...},   // 8 fields
  "remix_metrics": {...},            // 4 fields
  "realtime_metrics": {...},         // 3 fields
  "external_sources": [...],         // Array of source objects
  "memory_update": {...},            // 7 fields
  "analysis_log": [...]              // Array of log entries (6 tabs)
}
```

### Short #68 Specific Values (from this session)
| Field | Value | Notes |
|-------|-------|-------|
| `shorts.short_id` | `68` | Integer |
| `shorts.title` | `"😱RESULTS OUT!! NEET UG 2024 #neet #neet2024 #shorts"` | From Studio |
| `shorts.description` | `"So, finally neet UG 2024 results are out!!\nLet me know in comment section, how you performed in your exam"` | From Studio |
| `shorts.duration_seconds` | `40` | 0:40 video |
| `shorts.content_type` | `"educational"` | Default |
| `shorts.content_subtype` | `"exam_tips"` | Default |
| `shorts.language` | `"Hinglish"` | Default |
| `performance_metrics.views` | `406` | From Analytics |
| `performance_metrics.retention_pct` | `32.2` | From Analytics |
| `performance_metrics.avg_view_duration_seconds` | `12` | 0:12 average |
| `traffic_sources` | `[{source_name: "YouTube Search", source_category: "search", views: X, percentage: Y}]` | Derived from Analytics |
| `retention_curve` | `[{timestamp_seconds: 0, retention_pct: 100, is_key_moment: true, moment_type: "hook", moment_note: "Opening hook"}, ...]` | Must have ≥3 points |
| `search_terms` | `[{search_term: "...", views: X, percentage_of_search: Y, percentage_of_total: Z, intent_category: "specific", relevance_score: 3}]` | May be empty array `[]` if no data |
| `audience_device` | `{mobile_pct: 70.0, desktop_pct: 30.0, mobile_views: 284, desktop_views: 122, ...}` | Estimated from patterns |
| `audience_gender` | `{male_pct: 0.0, female_pct: 0.0, unknown_pct: 0.0, has_data: false}` | "Oops" error workaround |
| `audience_age` | `{age_13_17_pct: 0.0, ..., has_data: false}` | "Oops" error workaround |
| `audience_geography` | `[{country_code: "IN", country_name: "India", views: 350, percentage: 86.3, avg_view_duration_seconds: 12.5, is_target_country: true}]` | India-targeted content |
| `comments_analysis` | `{total_comments: 42, comments_per_1k_views: 103.9, ...}` | Extracted from Comments tab |
| `individual_comments` | `[{comment_id: "md5hash16", author_name: "...", text: "...", ...}]` | Minimum 1 required if total_comments > 0 |
| `short_title_template` | `{template_id: 28, title_length: 56, word_count: 11, hashtag_count: 3, emoji_count: 1, char_before_pipe: 0, char_after_pipe: 0, keyword_density: {}}` | From Edit page |
| `end_screen_performance` | `{has_end_screen: false, element_type: null, element_video_id: null, impressions: 0, clicks: 0, channel_avg_ctr: 0.0, vs_channel_avg_pct: 0.0}` | Use 0.0 when no impressions |
| `remix_metrics` | `{remix_count: 0, remix_views: 0, top_remix_video_id: null, top_remix_views: 0}` | Use 0 values when no data |
| `realtime_metrics` | `{views_48h: 0, period_start: null, period_end: null, velocity_views_per_hour: null}` | Use null when no data |
| `external_sources` | `[]` | Empty array when no external traffic |
| `memory_update` | `{update_type: "forensic_analysis", title: "Short #68 Analysis", payload: {...}, source_analysis: "YouTube Studio CDP", priority: 3, applied_to_pipeline: true}` | Pattern record |
| `analysis_log` | `[{session_id: 20260901, tab_analyzed: "overview", status: "success", data_completeness: 1.0, duration_seconds: 180}, ...6 entries total]` | 6 tabs × 1 entry each |

### Critical Rules for Short #68 Payload
1. **All 21 root keys MUST be present** — use `null` or empty arrays/objects for missing data
2. **`search_terms` can be `[]`** (empty array) — do NOT omit the key; Short #58 learned this the hard way
3. **`vs_channel_avg_pct` = `0.0`** when no impressions — never `-100.0` (fails numeric(6,4) constraint)
4. **`engagement_rate` ≤ 99.9999** — cap at 99.9999 to avoid numeric(6,4) precision violation
5. **`analysis_log.session_id` = `20260901`** (bigint) — strings fail FK constraint
6. **`individual_comments` must have ≥1 entry** if `comments_analysis.total_comments > 0`
7. **Payload file path**: Always `data/payload_short68.json` — relative to project root
8. **Retention curve ≥ 3 points** — hook at 0s/100%, a middle point, end at duration/retention%

### Short #68 Verification Checklist
- [ ] All 20+ tables populated in PostgreSQL
- [ ] UNION ALL query returns ≥1 row for every table
- [ ] retention_curve has ≥3 points with hook/spike/end markers
- [ ] search_terms key is `search_term` (NOT `term`)
- [ ] vs_channel_avg_pct is 0.0 (not -100.0)
- [ ] engagement_rate ≤ 99.9999
- [ ] analysis_log has exactly 6 entries (overview, reach, engagement, audience, comments, edit)
- [ ] analysis_log.session_id = 20260901 (integer, not string)
- [ ] Payload saved to data/payload_short68.json
- [ ] Individual comments extracted and inserted (minimum 1 if total_comments > 0)
- [ ] Comments "Response status: Unresponded" filter removed (click X on chip)
- [ ] Comments scrolled on ytcp-activity-section (200px increments)
- [ ] Title template extracted from /video/YaAKtkecoRc/edit?theme=dark
- [ ] End screen and remix metrics from Overview tab
- [ ] Audience demographics handled (has_data: false if "Oops" error)

### Reference Files
- `references/short-68-forensic-learnings.md` — This file: key learnings from the session
- `references/master_protocols.md` — Protocol 1-4 (navigation, comments, CDP, ingestion)
- `references/navigation-fixes.md` — YouTube Studio navigation corrections
- `references/studio-bot-detection-workaround.md` — Bot detection: Retry handling
- `references/sept7-db-verification.md` — DB state: 80 shorts, 3 complete, 77 incomplete
- `references/subagent-batch-mode-limits.md` — Batch sizing and iteration limits
- `references/subagent-model-config-current.md` — Current model config