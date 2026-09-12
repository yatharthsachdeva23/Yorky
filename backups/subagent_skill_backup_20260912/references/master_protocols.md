# Master Protocols — YouTube Shorts Forensic Analysis

**Single source of truth** for the 4 core protocols governing the forensic pipeline.

---

## Protocol 1: Navigation & Pagination (Studio Virtualized Tables)

### Target: Shorts List (`/channel/.../videos/short`)

**Container**: `<main>` (NOT `ytcp-video-section-content`)

```python
# Scroll loop
for step in range(50):
    main = document.querySelector('main')
    before = main.scrollTop
    main.scrollTop = before + 500
    await new Promise(r => setTimeout(r, 500))
    # Extract rows: document.querySelectorAll('ytcp-video-row')
    if main.scrollTop + main.clientHeight >= main.scrollHeight - 100:
        break
```

**Extraction**: `ytcp-video-row` → links with `/video/{id}/edit` → video_id from URL, title from link text, duration from row text

---

### Target: Analytics Tabs

**URL**: `https://studio.youtube.com/video/{video_id}/analytics/tab-overview/period-default`

**Tab Clicking**:
```javascript
const tabs = document.querySelectorAll('[role="tab"]');
for (const tab of tabs) {
    if (tab.textContent.trim().toLowerCase() === 'overview') { tab.click(); return {clicked: true}; }
}
return {clicked: false};
```

**Wait**: 5s after click for data render + Retry button check (see Protocol 5)

**Extraction**: Use `browser_snapshot()` (NOT `browser_console` with `document.body.innerText` — returns empty from CDP supervisor). Extract from snapshot's text content.

**Tabs**: Overview → Reach → Engagement → Audience (in order)

---

### Critical: Left Sidebar Navigation (Analytics, Comments, Details/Edit)

**Selector**: `a.menu-item-link` (NOT `[role="tab"]` — those are Analytics sub-tabs only)

**CRITICAL: Ref IDs are NOT stable across snapshots**. After ANY navigation or click, you MUST re-query the DOM by TEXT CONTENT, not use cached ref IDs.

```javascript
// CORRECT: Find by text content each time
const links = document.querySelectorAll('a.menu-item-link');
for (const link of links) {
    const text = link.textContent.trim().toLowerCase();
    if (text === 'analytics' || text === 'comments' || text === 'details' || text === 'edit') {
        link.click();
        return {clicked: true, target: text};
    }
}
return {clicked: false, reason: 'not_found'};
```

**Pitfall**: In Session 2026-09-09, subagent used stale ref ID `e19` after Analytics navigation — it pointed to "Clips & Shorts" instead of "Comments". Always re-query by text after every page transition.

**Wait**: 5s after click for page render + Retry button check (see Protocol 5)

---

### Iteration Budget Management (CRITICAL)

**50-iteration limit = ~1 short max per delegation**. Budget per tab:
- Navigation + Analytics click: 5 iterations
- Each Analytics tab (Overview/Reach/Engagement/Audience): 5 iterations each = 20
- Comments tab + filter + scroll + extraction: 10 iterations
- Details/Edit tab: 5 iterations
- Payload build + save + ingest + verify: 10 iterations
- **Total: ~50 iterations** — NO MARGIN FOR ERROR

**MANDATORY**: If you hit iteration 40 without completing all 6 tabs, you WILL fail. Use iteration budget wisely:
- Don't retry failed clicks more than 2×
- Use `browser_snapshot()` for extraction (not `browser_console`)
- Build payload incrementally as you extract each tab
- Run ingestion + verification in final 10 iterations

---

## Protocol 2: Comments Extraction (Studio Comments Tab)

### URL
`https://studio.youtube.com/video/{video_id}/comments`

### Step 1: Remove Unresponded Filter (MANDATORY)

```javascript
const chips = document.querySelectorAll('ytcp-chip-bar ytcp-chip, .filter-chip, [role="button"]');
for (const chip of chips) {
    const text = (chip.innerText || chip.textContent || '').toLowerCase();
    if (text.includes('unresponded') || text.includes('response status')) {
        // CRITICAL: Click the X/CLOSE button on the chip, NOT the chip itself
        // Clicking the chip opens the filter dropdown instead of removing it
        const closeBtn = chip.querySelector('button[aria-label*="remove"], button[aria-label*="close"], button[aria-label*="delete"], .close-button, .remove-button, ytcp-icon-button');
        if (closeBtn) { closeBtn.click(); return {clicked: true, action: 'closeBtn'}; }
        return {clicked: false, reason: 'no_close_button_found'};
    }
}
return {clicked: false, reason: 'no_chip_found'};
```
**CRITICAL**: Execute this via `browser_cdp` with `Runtime.evaluate` on correct `target_id`. Do NOT use `browser_type` on filter textbox. Do NOT click the chip itself. Click the X/CLOSE button (ytcp-icon-button) on the chip.

Verify toast: "Removed filter 'Response status: Unresponded'"

### Step 2: Scroll & Capture (ytcp-activity-section)

**Container**: `ytcp-activity-section` (NOT `<main>`, NOT `ytcp-comment-section`)

```javascript
const el = document.querySelector('ytcp-activity-section');
if (!el) return {status: 'no_container'};
const before = el.scrollTop;
el.scrollTop = before + 500;  // Phase 1: 10×500px
// Phase 2: 300px increments until bottom
```

**At EACH position**: Extract `ytcp-comment-thread` → author, text, is_creator, depth

**Dedupe**: `seen_ids` with author+text hash

**Temp file**: `data/temp_comments_{VIDEO_ID}.json`

**CRITICAL**: Use `browser_snapshot()` to extract comments from each scroll position. `browser_console` with `document.body.innerText` returns empty from CDP supervisor. Parse snapshot text content instead.

### Step 3: Final Analysis
- Build thread hierarchy (parent_comment_id, depth)
- Compute analytics (total, top-level, replies, max_depth, creator_replies, sentiment, intent)
- Write to DB (`comments_analysis` + `individual_comments`)
- **Delete temp file**

---

### Protocol 3: CDP Helper (`studio_cdp_helper.py`)

**Path**: `C:\\Desktop\\Antigravity Projects\\YouTube Manager\\scripts\\studio_cdp_helper.py`

**Modes**:
```bash
# Shorts list extraction
python studio_cdp_helper.py --mode shorts_list --out shorts.json

# Comments extraction (auto: filter removal + scroll + dedupe + thread hierarchy)
python studio_cdp_helper.py --mode comments --video-id VIDEO_ID --out comments.json
```

**Target Discovery**:
```python
targets = requests.get(f"{CDP_ENDPOINT}/json/list").json()
studio_target = next(t for t in targets if 'studio.youtube.com' in t.get('url', ''))
target_id = studio_target['id']
```

**Evaluation**: WebSocket via CDP supervisor (`Runtime.evaluate` with `target_id`) — NOT HTTP `/json/runtime/evaluate` (returns empty from external Python)

---

### CRITICAL: CDP Data Extraction Protocol (Validated 2026-09-09)

**Problem**: `browser_console` with `document.body.innerText` returns empty string from CDP supervisor. `browser_console` evaluations on Studio pages return empty strings.

**Solution**: Use `browser_cdp` with `Runtime.evaluate` on the correct `target_id`.

```python
# 1. Find Studio target_id
targets = browser_cdp(method="Target.getTargets", params={})
studio_target = next(t for t in targets["result"]["targetInfos"] 
                     if "studio.youtube.com" in t.get("url", ""))
target_id = studio_target["targetId"]

# 2. Extract data via CDP Runtime.evaluate on correct target_id
result = browser_cdp(method="Runtime.evaluate", 
                     params={"expression": "document.body.innerText", "returnByValue": True},
                     target_id=target_id)
text = result["result"]["result"]["value"]  # This WORKS
```

**Navigation via CDP** (when ref IDs are stale):
```python
# Click by text content via CDP
browser_cdp(method="Runtime.evaluate", params={
    "expression": "Array.from(document.querySelectorAll('a.menu-item-link')).find(a => a.textContent.trim().toLowerCase() === 'analytics')?.click() || 'not_found'",
    "returnByValue": True
}, target_id=target_id)
```

**Wait**: 5s after click for page render + Retry button check

---

## Protocol 4: Ingestion (`ingest_short_forensic.py`)

**Path**: `C:\Desktop\Antigravity Projects\YouTube Manager\ingest_short_forensic.py`

**Properties**:
- Raw `psycopg2` SQL (NOT ORM interface)
- Single atomic transaction (BEGIN → all 28 tables → COMMIT or full ROLLBACK)
- Parent→child FK order
- `ON CONFLICT DO UPDATE` for upserts
- `jsonb` via `psycopg2.extras.Json`

**Invocation**:
```bash
cd "C:/Desktop/Antigravity Projects/YouTube Manager"
python ingest_short_forensic.py data/payload_short{short_id}.json
```

**Expected Output**: `SUCCESS: Ingested Short [VIDEO_ID] into all tables in a single transaction!`

---

## Critical Schema Rules (Ingestion Failures)

| Field | Required Format | Common Mistake |
|-------|----------------|----------------|
| Root `video_id` | Required at payload root (`payload['video_id']`) | Missing |
| `shorts.short_id` | Integer nested in `payload['shorts']['short_id']` | Missing from `shorts` dict → NotNullViolation |
| `search_terms` key | Key is `search_term` (NOT `term`) | Using `term` causes NotNullViolation |
| `search_terms[i].views` | Calculated: `round(total_views * pct / 100)` | Cannot be 0 or omitted (NOT NULL in DB) |
| Traffic source | `source_name`, `source_category` in `(feed, search, browse, channel, external, other)` | Wrong category names like 'Shorts feed' |
| Retention curve | `timestamp_seconds`, `retention_pct`, `is_key_moment`, `moment_type`, `moment_note` (≥3 points) | Missing required fields or <3 points |
| `analysis_log.session_id` | **bigint FK to `analysis_sessions.id`** (1, 2, 20260901) | String fails FK constraint |
| `short_title_template.template_id` | **bigint FK to `title_templates.id`** (e.g., 28, 29) | String like "jo2024_schedule_announcement" fails FK constraint |
| `end_screen_performance.vs_channel_avg_pct` | `0.0` when no impressions | `-100.0` fails numeric(6,4) constraint |
| `performance_metrics.engagement_rate` | Float ≤ 99.9999 (numeric(6,4)) | Values >99.9999 fail precision |
| `individual_comments` | Array with ≥1 item if `total_comments > 0` | Empty array when comments exist |
| All percentages | Float | String fails |
| All IDs | Integers | String fails |

**Common Ingestion Failures**: See `references/ingestion_failure_patterns.md` for detailed patterns and fixes.

### Two Numbering Systems (NOT Interchangeable)
- **Chronological**: Oldest → Newest = DB `short_id`. Short #68 = 68th video published.
- **Upload Order**: Newest → Oldest = Studio UI markings. Short #76 ≠ Short #68 chronological.
- **Rule**: Video ID is the only stable identifier.

---

## File Path Conventions (Workspace-Aware)

| Artifact | Path |
|----------|------|
| Payload JSON | `data/payload_short{short_id}.json` |
| Comments temp | `data/temp_comments_{VIDEO_ID}.json` |
| Ingestion script | `ingest_short_forensic.py` (or `C:/Desktop/Antigravity Projects/YouTube Manager/ingest_short_forensic.py`) |
| CDP helper | `scripts/studio_cdp_helper.py` (or `C:/Desktop/Antigravity Projects/YouTube Manager/scripts/studio_cdp_helper.py`) |

**Rule**: All working files operate relative to project directory `C:/Desktop/Antigravity Projects/YouTube Manager/` (project workspace). Never use `/c/...` paths in Python or `write_file` (creates phantom `C:\c\` directories on Windows).

---

## Verification Queries (Always Run)

```sql
-- Per-short table coverage
SELECT 'performance_metrics' t, COUNT(*) FROM performance_metrics WHERE video_id = 'VID'
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
UNION ALL SELECT 'analysis_log', COUNT(*) FROM analysis_log WHERE video_id = 'VID';
```

---

## EXACT PAYLOAD SCHEMA — Must Match ingest_short_forensic.py (All 21 Root Keys)

The subagent MUST build payload matching this EXACT structure. Reference: `data/payload_short68.json` (working example).

**Critical Reference Files:**
- `references/title_template_mappings.md` — Valid template_id values and selection rules
- `references/ingestion_failure_patterns.md` — Common ingestion failures and fixes

```json
{
  "video_id": "STRING (required at root)",
  "shorts": {
    "short_id": INTEGER,
    "title": "STRING",
    "title_raw": "STRING (optional, defaults to title)",
    "description": "STRING",
    "description_length": INTEGER,
    "description_has_cta": BOOLEAN,
    "description_has_links": BOOLEAN,
    "published_at": "ISO8601 STRING",
    "duration_seconds": INTEGER,
    "duration_bucket": "STRING (e.g., '15-60s')",
    "visibility": "STRING (e.g., 'public')",
    "playlist_id": "STRING or null",
    "playlist_title": "STRING or null",
    "end_screen_type": "STRING or null",
    "end_screen_video_id": "STRING or null",
    "has_subtitles": BOOLEAN,
    "subtitle_languages": "ARRAY of STRINGS",
    "related_video_id": "STRING or null",
    "tags_title": "ARRAY of STRINGS",
    "tags_description": "ARRAY of STRINGS",
    "emoji_in_title": BOOLEAN,
    "emoji_list": "ARRAY of STRINGS",
    "red_alert_emoji": BOOLEAN,
    "content_year": INTEGER,
    "content_type": "STRING",
    "content_subtype": "STRING",
    "thumbnail_style": "OBJECT (JSON)",
    "hook_type": "STRING or null",
    "value_type": "STRING or null",
    "language": "STRING (e.g., 'Hinglish')",
    "cta_placement": "STRING (e.g., 'none')"
  },
  "performance_metrics": {
    "video_id": "STRING (FK)",
    "views": INTEGER,
    "engaged_views": INTEGER,
    "unique_viewers": INTEGER,
    "watch_time_hours": FLOAT,
    "avg_view_duration_seconds": FLOAT,
    "retention_pct": FLOAT,
    "completion_pct": FLOAT,
    "swipe_away_pct": FLOAT,
    "subscribers_gained": INTEGER,
    "subscribers_lost": INTEGER,
    "net_subscribers": INTEGER,
    "likes": INTEGER,
    "comments_count": INTEGER,
    "shares": INTEGER,
    "hype_points": INTEGER,
    "engagement_rate": FLOAT,
    "sub_conversion_rate": FLOAT,
    "engaged_view_rate": FLOAT,
    "views_vs_channel_avg_pct": FLOAT or null,
    "retention_vs_channel_avg": FLOAT or null,
    "period_start": "ISO8601 STRING or null",
    "period_end": "ISO8601 STRING or null"
  },
  "traffic_sources": [
      {
        "source_name": "STRING",
        "source_category": "STRING (MUST be: 'feed'/'search'/'browse'/'channel'/'external'/'other' — NOT 'Shorts feed', 'YouTube search', etc.)",
        "views": "INTEGER (required, NOT NULL — calculate: round(total_views * percentage / 100))",
        "percentage": "FLOAT",
        "avg_view_duration_seconds": "FLOAT or null",
        "retention_pct": "FLOAT or null"
      }
    ],
  "retention_curve": [
    {
      "timestamp_seconds": FLOAT,
      "retention_pct": FLOAT,
      "is_key_moment": BOOLEAN,
      "moment_type": "STRING (hook|spike|mid|end)",
      "moment_note": "STRING"
    }
  ],
  "search_terms": [
      {
        "search_term": "STRING",
        "views": "INTEGER (required, NOT NULL — calculate: round(total_views * percentage_of_total / 100))",
        "percentage_of_search": "FLOAT",
        "percentage_of_total": "FLOAT",
        "intent_category": "STRING (MUST be: 'specific'/'related'/'noise'/'brand')",
        "relevance_score": "INTEGER (1-5)"
      }
    ],
  "audience_device": {
    "mobile_pct": FLOAT,
    "desktop_pct": FLOAT,
    "tv_pct": FLOAT,
    "tablet_pct": FLOAT,
    "mobile_views": INTEGER,
    "desktop_views": INTEGER,
    "tv_views": INTEGER,
    "tablet_views": INTEGER,
    "desktop_intent_proxy": FLOAT
  },
  "audience_gender": {
    "male_pct": FLOAT,
    "female_pct": FLOAT,
    "unknown_pct": FLOAT,
    "has_data": BOOLEAN
  },
  "audience_age": {
    "age_13_17_pct": FLOAT,
    "age_18_24_pct": FLOAT,
    "age_25_34_pct": FLOAT,
    "age_35_44_pct": FLOAT,
    "age_45_54_pct": FLOAT,
    "age_55_64_pct": FLOAT,
    "age_65_plus_pct": FLOAT,
    "target_audience_pct": FLOAT,
    "non_target_pct": FLOAT,
    "has_data": BOOLEAN
  },
  "audience_geography": [
    {
      "country_code": "STRING (e.g., 'IN')",
      "country_name": "STRING (e.g., 'India')",
      "views": INTEGER,
      "percentage": FLOAT,
      "avg_view_duration_seconds": FLOAT or null,
      "is_target_country": BOOLEAN
    }
  ],
  "audience_subscriber_status": {
    "subscribed_pct": FLOAT,
    "not_subscribed_pct": FLOAT,
    "subscribed_views": INTEGER,
    "not_subscribed_views": INTEGER,
    "sub_viewer_retention_pct": FLOAT,
    "non_sub_viewer_retention_pct": FLOAT
  },
  "audience_subtitles": {
    "none_pct": FLOAT,
    "hindi_pct": FLOAT,
    "english_pct": FLOAT,
    "other_pct": FLOAT,
    "has_cc_data": BOOLEAN
  },
  "comments_analysis": {
    "total_comments": INTEGER,
    "comments_per_1k_views": FLOAT,
    "top_level_comments": INTEGER,
    "total_replies": INTEGER,
    "max_thread_depth": INTEGER,
    "avg_thread_depth": FLOAT or null,
    "creator_replies": INTEGER,
    "creator_reply_rate": FLOAT,
    "positive_sentiment_pct": FLOAT,
    "negative_sentiment_pct": FLOAT,
    "neutral_sentiment_pct": FLOAT,
    "query_comments": INTEGER,
    "gratitude_comments": INTEGER,
    "gratitude_with_likes": INTEGER,
    "spam_irrelevant_comments": INTEGER,
    "unanswered_high_intent_queries": INTEGER
  },
  "individual_comments": [
    {
      "comment_id": "STRING (md5 hash of author+text, 16 chars)",
      "author_name": "STRING",
      "author_channel_id": "STRING or null",
      "is_creator": BOOLEAN,
      "is_pinned": BOOLEAN,
      "is_hearted": BOOLEAN,
      "text": "STRING",
      "text_clean": "STRING",
      "like_count": INTEGER,
      "reply_count": INTEGER,
      "parent_comment_id": "STRING or null",
      "depth": INTEGER,
      "published_at": "ISO8601 STRING",
      "updated_at": "ISO8601 STRING",
      "sentiment": "STRING (positive|negative|neutral)",
      "intent_category": "STRING (query|gratitude|creator_reply|creator_promo|spam|other)",
      "query_subtype": "STRING or null",
      "is_actionable": BOOLEAN,
      "has_contact_info": BOOLEAN
    }
  ],
  "short_content_classification": {
    "primary_type": "STRING",
    "secondary_type": "STRING",
    "confidence_score": INTEGER (8-9)
  },
  "short_title_template": {
      "template_id": "BIGINT (FK to title_templates.id — must be integer, e.g., 28, 29)",
      "title_length": "INTEGER",
      "word_count": "INTEGER",
      "hashtag_count": "INTEGER",
      "emoji_count": "INTEGER",
      "char_before_pipe": "INTEGER",
      "char_after_pipe": "INTEGER",
      "keyword_density": "OBJECT (JSON)"
    },
  "end_screen_performance": {
    "has_end_screen": BOOLEAN,
    "element_type": "STRING or null",
    "element_video_id": "STRING or null",
    "impressions": INTEGER,
    "clicks": INTEGER,
    "channel_avg_ctr": FLOAT or null,
    "vs_channel_avg_pct": FLOAT (0.0 if no impressions)
  },
  "remix_metrics": {
    "remix_count": INTEGER,
    "remix_views": INTEGER,
    "top_remix_video_id": "STRING or null",
    "top_remix_views": INTEGER
  },
  "realtime_metrics": {
    "views_48h": INTEGER,
    "period_start": "ISO8601 STRING or null",
    "period_end": "ISO8601 STRING or null",
    "velocity_views_per_hour": FLOAT or null
  },
  "external_sources": [
    {
      "source_domain": "STRING",
      "source_type": "STRING",
      "views": INTEGER,
      "percentage": FLOAT
    }
  ],
  "memory_update": {
    "update_type": "STRING",
    "title": "STRING",
    "payload": "OBJECT (JSON)",
    "source_analysis": "STRING",
    "priority": INTEGER (1-5),
    "applied_to_pipeline": BOOLEAN
  },
  "analysis_log": [
    {
      "session_id": INTEGER (bigint: 1, 2, 20260901),
      "tab_analyzed": "STRING (overview|reach|engagement|audience|comments|edit)",
      "status": "STRING (success|partial|failed)",
      "error_message": "STRING or null",
      "data_completeness": FLOAT (0.0-1.0),
      "duration_seconds": INTEGER
    }
  ]
}
```

**CRITICAL**: Every key shown above MUST be present in payload (use null/empty arrays/empty objects for missing data — do NOT omit keys). The ingestion script uses `.get()` with defaults but some fields like `search_terms[i].views` are required (NOT NULL in DB).

---

## Wait Times (Mandatory)

| Operation | Wait |
|-----------|------|
| Navigation (analytics) | 5s |
| Tab click (Overview/Reach/Engagement/Audience) | 5s |
| Comments page load | 5s |
| Filter removal | 2s |
| Edit page load | 5s |
| Scroll step (comments) | 0.4s |

---

## Video ID Mapping (Chronological = DB short_id)

```python
VIDEO_IDS_BY_SHORT_ID = {
    1: "5goNjmztwqg", 2: "0jstRcQmAro", 3: "XWFbqR_9fqc", 4: "Pwp0zPAY6Y4", 5: "s_PoEssiuPo",
    6: "UTeogxHwnPw", 7: "zdOSsbqouKE", 8: "12BKLbv0Eso", 9: "XM1AzgVMeqk", 10: "nJNR60Ms1BE",
    11: "_A5Idj7SddI", 12: "BJ5lJob_sDU", 13: "OkWbChCIb04", 14: "2jcdStwq2yY", 15: "yDKB-xCaMB8",
    16: "rg5iPj-249o", 17: "waW201cvfl8", 18: "Ay9K30yrg8Y", 19: "lmbndk-Db-Q", 20: "cSapjDf5CHY",
    21: "JmSdjrAxNFM", 22: "MpQ-K2D9Ao4", 23: "bXetyvX2Mu8", 24: "pHfj5VVN0Ew", 25: "dpTHfuBYClo",
    26: "sHwtsGShqjE", 27: "Wyt0zC-zadM", 28: "JRrvbkvRyiI", 29: "pTiZBob0vWA", 30: "F6g5hMAUH6A",
    31: "durkT5BI9-0", 32: "-ntsqYRrjic", 33: "kQlrFbAzvro", 34: "3LCJCKfRATo", 35: "VkXC2gAxVvs",
    36: "QC45KrzAuLs", 37: "gNgwb1lmKL8", 38: "XlOAFuUr7F4", 39: "d-p-YuOjU-8", 40: "7L-wWpll_GU",
    41: "pszcrf0uTbQ", 42: "EDNdXwv7W64", 43: "DdMa3y_sImk", 44: "YFnY2guPlxg", 45: "noF6FnkgYmE",
    46: "FwuhJ23l7R4", 47: "tyxuLrd-xo4", 48: "UzWyYR6WM6U", 49: "3gSWKoBeqnw", 50: "impBBFcUinY",
    51: "kIrFARfeW5o", 52: "tO8vEcWUFXs", 53: "m1qgKExs2BY", 54: "_vTmJ79_4ho", 55: "atkvEdcPidM",
    56: "dudb29Xqo60", 57: "9jXcNZyYza8", 58: "eC_j1wlFJBw", 59: "Q-IS9K8g294", 60: "p03EyeJlM-k",
    61: "229XDzxoc4g", 62: "j4CtPMW-1Q4", 63: "iLZVyccaTJs", 64: "xBun0zPGZDA", 65: "4B4aAW76GLQ",
    66: "LQ7ttolwjJQ", 67: "zqqcLDVZxR8", 68: "YaAKtkecoRc", 69: "Mp1WHa-CXfw", 70: "D4KiNRb7UTk",
    71: "yBnFHlmgMFQ", 72: "bLwR73Y2d0w", 73: "Pnh6g6K9y8Q", 74: "DNIHqPqY3VM", 75: "Mkx7Qp8nCys",
    76: "a6DGQWZ57EE", 77: "_6qJfWvvWJo", 78: "NVbNJeWZ1Lo", 79: "wnp9gFm7ZpY", 80: "pl90QEsoKFk",
    81: "mK2nGGZFRVI", 82: "A2U9omXQ2go", 83: "fsSkI-1Opvk", 84: "pbU_sJKSfrg", 85: "W1nCo6y71R8",
    86: "rrTB_XW3pWA", 87: "kbLQ0kJ7pYQ", 88: "xj4emmUcJGE", 89: "w2UTdzsuads", 90: "SOKrC7BJ418",
    91: "PaYUzmc11E8", 92: "0KAZqj8-gFo", 93: "AwJoDsJiAoQ", 94: "ZrY0tM9yPxQ", 95: "hiP5k2gClN0",
    96: "QnjyscmnjEQ", 97: "3JdwNxhgqN8", 98: "DrhZsdeBj6k", 99: "5v6ouzwDdRQ", 100: "4yAeMwjZxoo",
    101: "muLRYXpkVWA", 102: "j7xmoRH2rzo", 103: "_gF2JDP64Yc", 104: "BMh9Xq36RrA", 105: "aFGUvq0rF8E",
    106: "e1ngJUdDFLw", 107: "SS61lwI_i5Q", 108: "7E6iXXGa_pw", 109: "A0hAJw2WWc4", 110: "dw8257FXOug",
    111: "PMokAVkrAUQ"
}
```

---

## Discovered Patterns (Validated)

| Pattern | Evidence | Actionable Rule |
|---------|----------|-----------------|
| `DOWNLOAD IMMEDIATELY` = algo poison | Short #52: 100% search noise (bbose, bhojpuri, instrumental), 26.5% ret | **Never use** |
| Admit card utility at 0:39 | Short #53: 64% search, 42.7% ret, 93.8% India, 15.3% desktop | **Optimal pattern** for utility shorts |
| Passive "Dates Changed" vs Actionable "Dates Extended" | #54: 3% search, 20.8% ret vs #19: 71% search, 63% ret | Use **actionable verbs** in schedule alerts |
| Short→Long-form end screens | Short #53, #54: 0% CTR | **Don't use** Short→Long end screens |
| Computer % > 15% = desktop intent | Short #53: 15.3% desktop → high search quality | Track as **intent proxy** |
| India % > 90% = intent purity | Short #53: 93.8% India → high retention, high search | Geography = quality proxy |

---

## Session 2026-09-09 Addendum: Subagent Verification Checklist (MANDATORY)

### Subagent MUST Verify Before Reporting Complete

The subagent for Short #69 reported "SUCCESS" but DB had: missing comments, duplicate logs, spurious sources. **Subagent must run ALL checks below before calling task complete.**

| Check | Required | How to Verify |
|-------|----------|---------------|
| **All 20 tables populated** | YES | Run UNION ALL verification query — every table must show ≥1 row |
| **retention_curve ≥ 3 points** | YES | Must have hook (0s/100%), spike/mid, end (duration/retention%) |
| **search_terms.views > 0** | YES | Every term must have views ≥1 (NOT NULL in DB) |
| **traffic_sources.source_category NOT NULL** | YES | Must be 'feed'/'search'/'browse'/'channel'/'external'/'other' |
| **traffic_sources.views > 0** | YES | Must have actual view counts |
| **individual_comments ≥ 1** | YES | If comments_analysis.total_comments > 0; optional if 0 |
| **comments_analysis populated** | YES | All 17 fields filled |
| **short_title_template populated** | YES | All 9 fields from edit page |
| **end_screen_performance populated** | YES | Even if has_end_screen=false |
| **remix_metrics populated** | YES | Even if remix_count=0 |
| **realtime_metrics populated** | YES | Even if views_48h=0 |
| **external_sources populated** | YES | If external traffic > 0; optional if 0 |
| **memory_updates populated** | YES | At least 1 pattern entry |
| **analysis_log = 6 entries** | YES | overview, reach, engagement, audience, comments, edit — each with session_id=20260901 |
| **audience_subscriber_status populated** | YES | All 6 fields |

### Comments Extraction Enforcement (Protocol 2)

**Subagent MUST implement EXACT protocol — no shortcuts:**

1. **Remove Unresponded filter**: Click X/CLOSE button on chip (button[aria-label*="remove"], ytcp-icon-button) — NOT the chip itself
2. **Scroll ytcp-activity-section** (NOT `<main>`):
   - Phase 1: 10 × 500px scrolls, capture at EACH position
   - Phase 2: 300px increments to bottom, capture at EACH position
3. **Extract at EACH scroll position**: `ytcp-comment-thread` → author, text, timestamp, likes, is_creator, depth
4. **Dedupe by author+text hash** in temp file: `data/temp_comments_{VIDEO_ID}.json`
5. **Build thread hierarchy** → compute analytics → write to DB → delete temp file

**FAILURE MODE**: If individual_comments count < comments_analysis.total_comments, extraction INCOMPLETE — must redo.

---

## Session 2026-09-09 Addendum: Subagent Verification Checklist (MANDATORY)

### Subagent MUST Verify Before Reporting Complete

The subagent for Short #69 reported "SUCCESS" but DB had: missing comments, duplicate logs, spurious sources. **Subagent must run ALL checks below before calling task complete.**

| Check | Required | How to Verify |
|-------|----------|---------------|
| **All 20 tables populated** | YES | Run UNION ALL verification query — every table must show ≥1 row |
| **retention_curve ≥ 3 points** | YES | Must have hook (0s/100%), spike/mid, end (duration/retention%) |
| **search_terms.views > 0** | YES | Every term must have views ≥1 (NOT NULL in DB) |
| **traffic_sources.source_category NOT NULL** | YES | Must be 'feed'/'search'/'browse'/'channel'/'external'/'other' |
| **traffic_sources.views > 0** | YES | Must have actual view counts |
| **individual_comments ≥ 1** | YES | If comments_analysis.total_comments > 0; optional if 0 |
| **comments_analysis populated** | YES | All 17 fields filled |
| **short_title_template populated** | YES | All 9 fields from edit page |
| **end_screen_performance populated** | YES | Even if has_end_screen=false |
| **remix_metrics populated** | YES | Even if remix_count=0 |
| **realtime_metrics populated** | YES | Even if views_48h=0 |
| **external_sources populated** | YES | If external traffic > 0; optional if 0 |
| **memory_updates populated** | YES | At least 1 pattern entry |
| **analysis_log = 6 entries** | YES | overview, reach, engagement, audience, comments, edit — each with session_id=20260901 |
| **audience_subscriber_status populated** | YES | All 6 fields |
| **NO DUPLICATES in analysis_log** | YES | Exactly 6 entries, not 12 or 18 |
| **NO DUPLICATES in memory_updates** | YES | Exactly 1 entry per short |

### Comments Extraction Enforcement (Protocol 2)

**Subagent MUST implement EXACT protocol — no shortcuts:**

1. **Remove Unresponded filter**: Click X/CLOSE button on chip (button[aria-label*="remove"], ytcp-icon-button) — NOT the chip itself
2. **Scroll ytcp-activity-section** (NOT `<main>`):
   - Phase 1: 10 × 500px scrolls, capture at EACH position
   - Phase 2: 300px increments to bottom, capture at EACH position
3. **Extract at EACH scroll position**: `ytcp-comment-thread` → author, text, timestamp, likes, is_creator, depth
4. **Dedupe by author+text hash** in temp file: `data/temp_comments_{VIDEO_ID}.json`
5. **Build thread hierarchy** → compute analytics → write to DB → delete temp file

**FAILURE MODE**: If individual_comments count < comments_analysis.total_comments, extraction INCOMPLETE — must redo.

### Single Ingestion Rule

**Subagent MUST run ingestion EXACTLY ONCE per short.** 
- If ingestion fails, fix payload and re-run ONCE.
- DO NOT re-ingest same short multiple times.
- If re-ingestion needed, DELETE all data for that video_id first, then re-ingest once.
- The UNION ALL verification query must show exactly 1 row per single-row table, N rows per array table — not 2x or 3x.

---

## MANDATORY: Subagent Operational Rules (CRITICAL - VIOLATION = TASK FAILURE)

### RULE 1: NO CONVERSATIONAL TEXT WITHOUT TOOL CALLS
**In Hermes, any turn WITHOUT a tool call is treated as TASK COMPLETION.**
- You MUST call a tool in EVERY step until ingestion + verification complete
- Do NOT emit "Now I will..." or "Let me..." or planning text
- Only tool calls and brief think annotations allowed

### RULE 2: STRICT PAYLOAD SCHEMA COMPLIANCE
**Read `data/payload_short71.json` FIRST before building payload.**
Your payload MUST match exact structure:
- `shorts.short_id`: INTEGER (e.g., 72, NOT "short72" or "72")
- `traffic_sources[].views`: INTEGER (never null). Calculate: round(total_views * pct / 100)
- `short_title_template.template_id`: INTEGER from title_templates (28, 29, 24, 26, 27, 1, 2, 6, 7, 12). NEVER short number or string.
- `analysis_log[].data_completeness`: FLOAT 1.0 (never string "full")
- All 21 root keys required - use null/[]/{} for missing data

### RULE 3: INGESTION SCRIPT IS IMMUTABLE
**FORBIDDEN: Editing `ingest_short_forensic.py`**
- If ingestion fails → FIX YOUR PAYLOAD JSON, never the Python script
- The script is a locked engine

### RULE 4: NO BASH HEREDOCS / MULTILINE PYTHON
**Windows environment - forbidden patterns:**
- `cat << 'EOF'` or heredocs
- Multiline `python -c "..."` 
- Use `write_file` for files, `python <file_path>` for scripts

### RULE 5: NO browser_vision
**Multimodal disabled** - Use CDP: `browser_snapshot`, `browser_click`, `browser_console`

### RULE 6: NO PREMATURE COMPLETION
**Do NOT report "completed" until ALL 11 steps verified:**
1. Navigate → 2. Analytics → 3. Overview → 4. Reach → 5. Engagement → 6. Audience → 7. Comments → 8. Details/Edit → 9. Build+Save Payload → 10. Ingest → 11. Verify DB

---
## NAVIGATION PROTOCOL (CRITICAL - BOT DETECTION WORKAROUND)

### ALWAYS START AT EDIT PAGE
**CORRECT:** `https://studio.youtube.com/video/{video_id}/edit?theme=dark`
**WRONG:** `https://studio.youtube.com/shorts/{video_id}/analytics?theme=dark` or any direct analytics URL

### Navigation Sequence:
1. Navigate to EDIT page: `browser_navigate("https://studio.youtube.com/video/{video_id}/edit?theme=dark")` - WAIT 5s
2. Click Analytics from LEFT SIDEBAR (a.menu-item-link with TEXT "Analytics") - WAIT 5s
3. Then click each Analytics sub-tab ([role="tab"]): Overview → Reach → Engagement → Audience

### Bot Detection:
- ALWAYS check for "Retry" button after EVERY navigation AND tab click
- If "Retry" appears, click it and WAIT 5s
- Repeat up to 3 times if needed

---
## Subagent Verification Command (MANDATORY)

**Subagent MUST run this EXACT command after ingestion:**

```bash
python "C:\Desktop\Antigravity Projects\YouTube Manager\verify_short.py" {SHORT_NUMBER}
```

**DO NOT use relative paths or different syntax.** The absolute Windows path with forward slashes is required.

**Verification Logic (verify_short.py):**
- Core 18 tables: MUST have data (exit code 0 = success)
- Optional 2 tables: `individual_comments` (only if comments_analysis.total_comments > 0), `external_sources` (only if external traffic > 0)
- If no comments/external traffic expected → treated as PASS
- Subagent should NOT investigate "empty" optional tables

**After verification passes → immediately summarize and conclude. Do NOT continue with extra steps.**

---

## MANDATORY: Completion Checklist (Subagent MUST verify ALL before reporting complete)

The subagent MUST complete ALL 11 steps and verify before calling task complete:

| Step | Must Complete | Verification |
|------|---------------|--------------|
| 1. Navigate to edit page | ✓ | Page loads |
| 2. Click Analytics | ✓ | Analytics tab visible |
| 3. Overview tab | ✓ | Snapshot captured |
| 4. Reach tab | ✓ | Snapshot captured |
| 5. Engagement tab | ✓ | Snapshot captured |
| 6. Audience tab | ✓ | Snapshot captured |
| 7. Comments tab | ✓ | Filter removed, scroll captured, comments extracted |
| 8. Details/Edit tab | ✓ | Title template extracted, template_id selected from mapping |
| 9. Build + Save Payload | ✓ | File exists at data/payload_short{id}.json |
| 10. Run Ingestion | ✓ | Terminal outputs "SUCCESS: Ingested Short [...]" |
| 11. Verify DB | ✓ | `python verify_short.py {short_id}` outputs SUCCESS |

**FAILURE = Any step incomplete. Do NOT report "completed" until ALL 11 checks pass.**

The subagent MUST run ingestion and verification in the SAME delegation. If iteration limit approaches, prioritize steps 9-11 over re-scrolling.

---

## Title Template ID Mapping (CRITICAL for Payload)

The subagent MUST choose correct `template_id` from `title_templates` table based on title pattern:

| template_id | template_name | pattern | Use For |
|-------------|---------------|---------|---------|
| 28 | alert_announcement | `[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]` | Urgent alerts with prefix emoji, triple exclamation, 3 hashtags |
| 29 | urgent_download_warning | `[EMOJI] [TOPIC] [URGENCY] | [ACTION] #[HASHTAG1] #[HASHTAG2]` | Urgent with pipe separator, 2 hashtags |
| 24,26,27 | series_part_format | `MOST IMP TIPS for JEE & other competitive exams (Part-{N}) #iit #jee #part{N} #jee2024` | Multi-part series |
| 1,2,6,7,12 | educational_series_part | `{topic} (Part-{part}) #{hashtags}` | Educational series |

**Selection Logic:**
- Title starts with emoji + has `!!` + 3 hashtags → template_id = 28
- Title has pipe `|` + emoji prefix + 2 hashtags → template_id = 29
- Title contains `(Part-` → template_id = 24/26/27
- Title contains `(Part-` + simple hashtags → template_id = 1/2/6/7/12

The subagent MUST inspect the actual title from Details/Edit page and select matching template_id.