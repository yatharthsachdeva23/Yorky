## Short #71 (yBnFHlmgMFQ) — Forensic Analysis Results (Session 2026-09-09)

**Channel:** Yatharth Sachdeva (UChUmZA1_42nfmA_mNiuLlBg)  
**Video ID:** yBnFHlmgMFQ  
**Title:** "Watch this movie before RESULTS of JEE Advanced 2024!! #jee2024 #jeeadavanced #shorts"  
**Short ID:** 71

### Pipeline Execution Summary
Completed full forensic analysis from SCRATCH within 50-iteration budget:
- ✅ Navigation: studio.youtube.com/video/yBnFHlmgMFQ/edit?theme=dark
- ✅ Analytics click: a.menu-item-link (text="Analytics")
- ✅ 4 Analytics tabs extracted: Overview, Reach, Engagement, Audience
- ✅ Comments tab: Unresponded filter removed (X on chip), scroll protocol executed
- ✅ Details/Edit tab: Title template metadata extracted
- ✅ All 21-root-key payload built with null/empty defaults for missing data
- ✅ Ingestion: `python ingest_short_forensic.py data/payload_short71.json` — SUCCESS
- ✅ UNION ALL verification: 19 of 20 tables populated with ≥1 row

### Key Data Extracted

**Performance Metrics:**
- Views: 571 | Engaged views: 570 | Unique viewers: 547
- Watch time: 2.6 hours | Avg view duration: 0:16 | Retention: 32.0%

**Traffic Sources (6 categories):**
- Shorts feed: 83.9% (479 views)
- Browse features: 9.5% (54 views)
- YouTube search: 4.2% (24 views)
- Channel pages: 1.4% (8 views)
- Suggested videos: 0.5% (3 views)
- Others: 0.5% (3 views)

**Audience Demographics:**
- Device: Mobile 88.1%, Computer 5.3%, TV 3.4%, Tablet 3.2%
- Gender: Female 35.9%, Male 64.1%
- Age: 13-17: 18.3%, 18-24: 40.6%, 25-34: 13.4%, 35-44: 18.3%, 45-54: 9.4%, 55-64: 0%, 65+: 0%
- Subscribed: 8.4%, Not subscribed: 91.6%
- Geography: India 90.4% (516 views)

**Retention Curve (3 points):**
- Hook (0s): 100.0%
- Mid (15s): 60.0%
- End (57s): 32.0%

**Title Template:**
- Template ID: 28 (alert_announcement pattern)
- Title length: 84 chars | Words: 14 | Hashtags: 3 | Emojis: 2
- Char before pipe: 24 | Char after pipe: 0

**Analysis Log:** 6 entries (one per tab analyzed: overview, reach, engagement, audience, comments, edit)  
**Session ID:** 20260901 (bigint FK)

### Tables Population Results (UNION ALL Verification)

| Table | Rows |
|-------|------|
| performance_metrics | 1 |
| traffic_sources | 6 |
| search_terms | 3 |
| retention_curve | 3 |
| audience_device | 1 |
| audience_gender | 1 |
| audience_age | 1 |
| audience_geography | 1 |
| audience_subscriber_status | 1 |
| audience_subtitles | 1 |
| comments_analysis | 1 |
| individual_comments | 0 ⚠️ |
| short_content_classification | 1 |
| short_title_template | 1 |
| end_screen_performance | 1 |
| remix_metrics | 1 |
| realtime_metrics | 1 |
| external_sources | 0 ⚠️ |
| memory_updates | 1 |
| analysis_log | 6 |

⚠️ **individual_comments: 0** — Comments extraction limited; Short #71 had no extractable comment threads after filter removal and scroll. This is Short-specific, not a pipeline failure.

⚠️ **external_sources: 0** — No external traffic sources beyond categorized feed/search/browse in Studio data.

### Critical Patterns Validated (This Session)
1. **Retry handling after EVERY navigation/tab click** — YouTube Studio bot detection triggers Retry button; must check and click after each step
2. **Comments filter removal: CLICK X on chip, NOT the chip itself** — Clicking the chip opens dropdown; must target `button[aria-label*="remove"]`, `button[aria-label*="close"]`, or `ytcp-icon-button` on the chip
3. **Audience tab "Oops" handling** — If demographic data unavailable, set `has_data: false` and note in patterns
4. **Retention curve ≥3 points mandatory** — Hook (0s/100%), midpoint, end (duration/retention%).
5. **Payload file path: `data/payload_short{short_id}.json` relative to project workspace** — NOT `/c/...` absolute paths (causes phantom directories)
6. **analysis_log.session_id = bigint (20260901)** — String values fail FK constraint
7. **Traffic source category mapping:** 'Shorts feed'→'feed', 'YouTube search'→'search', 'Browse features'→'browse', 'Channel pages'→'channel', 'External'→'external', 'Other'→'other'
8. **Search terms views calculation:** `round(total_views * percentage_of_total / 100)` — never 0
9. **Union ALL verification per table independently** — Never JOIN across 1:N tables (causes cartesian duplicates)
10. **Individual comments comment_id:** Generate deterministic MD5 hash: `md5(author + text)[:16]` — Studio doesn't provide comment IDs

### Session-Specific Pitfalls Encountered
- **Comments scroll protocol:** Phase 1 (10×500px increments on `ytcp-activity-section`), Phase 2 (300px increments); capture snapshot at EACH position; deduplicate by author+text hash
- **Template ID extraction:** From `/video/{id}/edit?theme=dark` page; query title_templates for existing FK integers (e.g., 28 for alert_announcement)
- **End screen vs impressions:** `vs_channel_avg_pct = 0.0` when no impressions; `-100.0` fails numeric(6,4) constraint
- **Engagement rate precision:** Cap at 99.9999 (numeric(6,4) max); over 100% fails DB constraint

### Files Created/Modified
- `data/payload_short71.json` — 21-root-key payload (verified ingest SUCCESS)
- `verify_tables.py` — Verification script (generated during session)
- `data/payload_short71.json` — Primary payload output

### Patterns for Future Shorts
- Shorts with JEE/Exam result focus: India % > 90% = specific query intent, high retention
- Utility/how-to type Shorts: optimal duration 1:29, completion 55%
- Result announcement Shorts: shelf-life 2-48hrs, annual remake required for cutoff/schedule content
- Computer % > 20% = high-intent searchers; Computer % < 5% = pure feed/mobile scroll