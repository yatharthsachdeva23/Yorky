# Short #75 (Mkx7Qp8nCys) — Forensic Analysis Complete (Sept 10, 2026)

## Status
✅ **COMPLETE** — 20/20 tables populated, all schema validations passed.

## Short Details
- **Short #75**: `Mkx7Qp8nCys` | **Title**: `🚨JOSAA 2024 STARTED!! #jee2024 #josaa #shorts`
- **template_id**: 28 (emoji + `!!` + 3 hashtags → `alert_announcement` template)
- **Title pattern**: `[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]`
- **Duration**: 60s | **Views**: 73 | **Retention**: 45% at end | **Top geo**: India (91.2%)
- **Traffic**: 61.6% Shorts feed, 20.5% Browse, 10.9% Search

## Critical Compliance — Must Embed in Future Payloads

| Field | Rule | This Session Compliance |
|-------|------|------------------------|
| `shorts.short_id` | MUST be integer (e.g., 75, not "short75") | ✅ 75 |
| `traffic_sources[].views` | MUST be integer, never null. Calculate: `round(total_views * percentage / 100)` | ✅ All 6 entries integer |
| `short_title_template.template_id` | MUST be integer from valid title_templates mapping (28=emoji+!!+3 hashtags) | ✅ 28 |
| `analysis_log[].data_completeness` | MUST be float 1.0, never string "full" | ✅ All 6 entries 1.0 |
| `analysis_log.session_id` | bigint FK to analysis_sessions.id (integers: 1, 2, 20260901) — strings fail | ✅ 20260901 |
| Payload path | `data/payload_short{short_id}.json` (relative to project workspace) | ✅ `data/payload_short75.json` |

## Payload Construction Steps (Validated)

1. Navigate to `https://studio.youtube.com/video/Mkx7Qp8nCys/edit?theme=dark`
2. Click Analytics from LEFT SIDEBAR (`a.menu-item-link` with TEXT "Analytics")
3. Click each Analytics sub-tab in order: **Overview → Reach → Engagement → Audience → Comments → Details/Edit**
4. Check for "Retry" button after **EVERY** navigation AND tab click (5 retries max)
5. Extract all tab data per the EXACT PAYLOAD SCHEMA (21 root keys)
6. Map title pattern to template_id: emoji+!!+3 hashtags → 28
7. Build payload with **ALL 21 root keys** (null/empty for missing data — do NOT omit keys)
8. Save to `data/payload_short75.json`
9. Run: `python ingest_short_forensic.py data/payload_short75.json`
10. Verify: `python verify_short.py 75` → must show `20/20 tables populated`

## Title Template ID Mapping Reference

| template_id | template_name | pattern |
|-------------|---------------|---------|
| 28 | alert_announcement | `[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]` |
| 29 | urgent_download_warning | `[EMOI] [TOPIC] [URGENCY] | [ACTION] #[HASHTAG1] #[HASHTAG2]` |
| 24,26,27 | series_part_format | `MOST IMP TIPS for JEE (Part-{N}) #iit #jee #part{N} #jee2024` |
| 1,2,6,7,12 | educational_series_part | `{topic} (Part-{part}) #{hashtags}` |

## Selection Logic

- Title starts with emoji + has `!!` + 3 hashtags → template_id = 28
- Title has pipe `|` + emoji prefix + 2 hashtags → template_id = 29
- Title contains `(Part-` → template_id = 24/26/27
- Title contains `(Part-` + simple hashtags → template_id = 1/2/6,7,12

## 77 Incomplete Shorts Remediation Priority

Re-ingest shorts 55-80 (missing ≥1 table each, most commonly `individual_comments`, `external_sources`, `short_title_template`, `realtime_metrics`, `search_terms`, `retention_curve`). Then ingest shorts 81-111 (31 never ingested). After each batch, run `python verify_short.py {short_id}` and confirm `20/20 tables populated`.

## Verification Query (Must Run Before Task Completion)

```sql
-- UNION ALL per table — NEVER JOIN across 1:N tables
SELECT 'analysis_log' as table_name, COUNT(*) FROM analysis_log WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_device', COUNT(*) FROM audience_device WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_gender', COUNT(*) FROM audience_gender WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_age', COUNT(*) FROM audience_age WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_geography', COUNT(*) FROM audience_geography WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_subscriber_status', COUNT(*) FROM audience_subscriber_status WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'audience_subtitles', COUNT(*) FROM audience_subtitles WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'comments_analysis', COUNT(*) FROM comments_analysis WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'individual_comments', COUNT(*) FROM individual_comments WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'end_screen_performance', COUNT(*) FROM end_screen_performance WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'external_sources', COUNT(*) FROM external_sources WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'memory_updates', COUNT(*) FROM memory_updates WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'performance_metrics', COUNT(*) FROM performance_metrics WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'realtime_metrics', COUNT(*) FROM realtime_metrics WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'remix_metrics', COUNT(*) FROM remix_metrics WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'retention_curve', COUNT(*) FROM retention_curve WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'search_terms', COUNT(*) FROM search_terms WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'short_content_classification', COUNT(*) FROM short_content_classification WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'short_title_template', COUNT(*) FROM short_title_template WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = 'Mkx7Qp8nCys'
UNION ALL SELECT 'video_id' FROM shorts WHERE short_id = 75
ORDER BY table_name;
```

## Critical Fixes Confirmed This Session

1. ✅ `analysis_log.session_id` must be bigint FK integer (20260901), NOT string — FK constraint violation otherwise
2. ✅ Payload root `video_id` + nested `shorts.short_id` both required — NotNullViolation on `shorts` table if either missing
3. ✅ All `traffic_sources[].views` must be integer > 0 — calculate: `round(total_views * percentage / 100)` if not directly provided
4. ✅ `short_title_template.template_id` must be integer FK from valid mapping — string or short-number fails
5. ✅ `analysis_log[].data_completeness` must be float 1.0, not string "full"
6. ✅ Retention curve must have ≥3 points: hook (0s/100%), midpoint, end (duration/retention%)
7. ✅ Payload file MUST be `data/payload_short{short_id}.json` relative to workspace — absolute paths `/c/...` create phantom folders
8. ✅ Comments filter "Response status: Unresponded" must be removed by clicking X button on chip, NOT the chip itself
9. ✅ Audience tab "Oops" after 5 retries → set `has_data: false` for gender/age/subtitles, note in patterns

## See Also
- `references/sept7-db-verification.md`
- `references/navigation-fixes.md`
- `references/studio-bot-detection-workaround.md`
- `references/template_id_fk_fix.md`
- `references/subagent-batch-mode-limits.md`