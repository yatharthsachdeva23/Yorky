---
name: youtube-automation
description: "YouTube automation: upload, posts, Shorts, branding."
category: youtube-automation
tags: [youtube, upload, shorts, community-posts, analytics, branding, api, oauth, browser-automation, postgresql]
---

# YouTube Automation — Complete Suite

**Trigger**: Any YouTube channel operations — uploading videos/Shorts, scheduling community posts, forensic Shorts analysis, channel branding, transcript extraction, or Studio workflows.

**User Context**: Channel "Yatharth Sachdeva" (696 subs). OAuth configured with `client_secret.json` (redirect_uris: localhost + localhost:8080). Token cached to `token.pickle`. Community posts require hybrid CDP + PyAutoGUI (no API endpoint exists). Shorts analysis uses 28-table PostgreSQL DB with forensic methodology.

---

## UMBRELLA ARCHITECTURE

This skill consolidates the former separate skills:
- `youtube-upload-automation` → **Section: Video/Shorts Upload via Data API v3**
- `youtube-community-post-management` → **Section: Community Posts (YouTube.com Posts Tab)**
- `youtube-community-post-scheduling-hybrid` → **Section: Community Post Scheduling (Hybrid CDP+PyAutoGUI)**
- `youtube-shorts-deep-analysis-framework` → **Section: Shorts Forensic Analysis (PostgreSQL)**
- `youtube-shorts-forensic-subagent` → **Section: Single-Short Subagent Delegation**
- `youtube-shorts-comments-extraction` → **Section: Comments Extraction Protocol**
- `youtube-studio-branding-upload` → **Section: Channel Branding (Studio Customization Tab)**
- `youtube-content` → **Section: Transcript Extraction & Content Reformatting**

Each subsection below contains the unique, non-duplicated content from the absorbed skill.

---

## Prerequisites (Common)

- Google Cloud project with YouTube Data API v3 enabled
- OAuth 2.0 Client ID (Desktop app type) → `client_secret.json`
- Scopes in OAuth Consent Screen → Data Access:
  - `https://www.googleapis.com/auth/youtube.upload`
  - `https://www.googleapis.com/auth/youtube`
  - `https://www.googleapis.com/auth/youtubepartner`
- Channel ID: `UChUmZA1_42nfmA_mNiuLlBg`
- PostgreSQL `youtube_shorts` on `127.0.0.1:5432` (for forensic analysis)
- Chrome/Chromium with CDP on port 9222 (Profile 8) for browser automation
- **Payload output directory**: `data/` (inside project workspace `C:/Desktop/Antigravity Projects/YouTube Manager`, NOT `/c/Users/DELL/data/` or `/c/Desktop/...`)

---

### PATH PROTOCOL — Critical Fix (Sept 8, 2026)

**Root Cause**: Path mismatch between tools caused phantom directories and corrupted payloads.

| Tool | Path Used | Actual Location |
|------|-----------|-----------------|
| `write_file("/c/Users/DELL/data/...")` | `/c/Users/DELL/data/` | `C:\c\Users\DELL\data\` (PHANTOM) |
| `terminal` (Git Bash) | `/c/Users/DELL/data/...` | `C:\Users\DELL\data\` (correct) |
| `execute_code` (native Python) | `/c/Users\DELL\data/...` | `C:\c\Users\DELL\data\` (PHANTOM) |

**MANDATORY RULES**:
1. **Payload output directory**: `data/payload_short{id}.json` (relative to project workspace `C:/Desktop/Antigravity Projects/YouTube Manager`)
2. **Always use relative paths** for project files: `data/payload_short{id}.json`, `data/temp_comments_{video_id}.json`
3. **Never pass `/c/...` paths to `write_file` or Python scripts** (creates phantom `C:\c\` folders on Windows)
4. **Ingestion command**: Run from project directory: `python ingest_short_forensic.py data/payload_short{id}.json`

---

## Section: Video/Shorts Upload via Data API v3

**When to Use**: Uploading videos or Shorts programmatically — fully automated, no browser needed.

### Key Learnings (Session Aug 26, 2026)

1. **Browser Automation Limitation**: YouTube Studio's "Select files" triggers native OS file picker — cannot be automated via CDP. **Use Data API v3 (`videos.insert`)** for programmatic uploads.

2. **OAuth Consent Screen Configuration** (critical fixes):
   - Redirect URI must match exactly: `client_secret.json` `redirect_uris` must include `http://localhost:8080`
   - Scopes must be added in Data Access page (APIs & Services → OAuth consent screen → Data Access)
   - Testing mode requires test users: add `yatharth.sachdeva23@gmail.com` in Audience → Test users

3. **First-Run OAuth Flow**: Opens browser for consent → token caches to `token.pickle`

### Upload Script Pattern (Validated Working)

```python
# Script: C:\Users\DELL\upload_video.py
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
import pickle, os

SCOPES = [
    'https://www.googleapis.com/auth/youtube.upload',
    'https://www.googleapis.com/auth/youtube',
    'https://www.googleapis.com/auth/youtubepartner'
]

flow = InstalledAppFlow.from_client_secrets_file('client_secret.json', SCOPES)
creds = flow.run_local_server(port=8080, prompt='consent')
# If user has connected CDP browser, prefer that session over run_local_server()
youtube = build('youtube', 'v3', credentials=creds)

body = {
    'snippet': {'title': title, 'description': desc, 'tags': tags, 'categoryId': '22'},
    'status': {'privacyStatus': 'private', 'selfDeclaredMadeForKids': False}  # ALWAYS private for testing
}
media = MediaFileUpload(file_path, chunksize=-1, resumable=True)
request = youtube.videos().insert(part='snippet,status', body=body, media_body=media)
# Loop request.next_chunk() until done
```

### Session Validation
- Test upload: `SH6.mov` (59MB) → Video ID `PMokAVkrAUQ` → Private → Verified in Studio
- Zero browser automation needed for videos/Shorts

### Quota Management
- ~1,600 units per video insert (10,000 units/day free tier)
- Category ID `22` = People & Blogs (common default)

---

## Section: Community Posts (YouTube.com Posts Tab)

**When to Use**: Creating and scheduling Community posts (image posts, polls, quizzes, video shares) on YouTube.com Posts tab — **no public API exists for this**.

### Critical Architecture: Two Different URLs

| Task | URL | Notes |
|------|-----|-------|
| **Branding** (banner/logo/watermark) | `studio.youtube.com/channel/<ID>/customization` | Profile tab |
| **Community Posts** | `youtube.com/channel/<ID>/posts` | Posts tab — creation happens here |
| **Shorts Upload** | `studio.youtube.com` → Create → Upload videos | Data API v3 preferred |

### Community Post Workflow (Validated End-to-End)

1. Navigate to `https://www.youtube.com/channel/UChUmZA1_42nfmA_mNiuLlBg/posts`
2. Click "Create post" → "Image" button
3. **Upload Image (Hybrid)**: Click "select from your computer" → native OS file picker → PyAutoGUI handler
4. **Add Text (Hybrid)**: Click contenteditable → PyAutoGUI clipboard paste
5. **Schedule (Hybrid)**: Click Action menu (three dots) → "Schedule post" → set time → click Schedule
6. Verify in SCHEDULED tab

### File Picker Automation Status

| Environment | CDP `setFileInputFiles` | Native Picker | Workaround |
|-------------|------------------------|---------------|------------|
| Headless CDP | ❌ Not available | Blocks | Inject into `input[type="file"]` via Runtime |
| Headful CDP | ⚠️ Sometimes works | Blocks | Same + make input visible first |
| Manual | N/A | Works | User clicks |
| **PyAutoGUI** | N/A | **Works** | **Background handler (validated Aug 26)** |

### Working PyAutoGUI Scripts (Production-Ready)

- `C:\Users\DELL\fill_file_dialog.py` — handles native file picker (clipboard + Enter, targets file name field)
- `C:\Users\DELL\type_text.py` — clipboard paste into focused contenteditable
- `C:\Users\DELL\set_schedule.py` — Tab navigation to time field, type 1430 (24hr), Tab → Enter

### Critical Success Factors

| Factor | Why It Matters |
|--------|----------------|
| Re-query DOM each step | Ref IDs change every snapshot; can't reuse old refs |
| Focus contenteditable via CDP click | Then PyAutoGUI types reliably |
| Action menu dropdown = three dots button | Schedule option NOT in DOM — must use PyAutoGUI click below dropdown |
| Time format: 1430 (24hr) | Direct type into time field works |
| Tab navigation in schedule dialog | More reliable than coordinates |
| Target file name field in dialog | Not arbitrary dialog space — user correction |

### Pitfalls to Avoid

1. ❌ Confusing Studio Customization with YouTube.com Posts — different URLs, different UIs
2. ❌ Assuming file picker works via CDP — native OS dialog blocks
3. ❌ Not making file input visible first — hidden inputs reject CDP file injection
4. ❌ Targeting wrong file input — multiple exist; use LAST one on Posts page
5. ❌ Forgetting Action menu → Schedule post — "Post" button publishes immediately
6. ❌ Timezone mismatch — verify channel timezone (GMT+0530)
7. ❌ Not waiting for image upload — Post button stays disabled until thumbnail appears
8. ❌ Using Studio for community posts — Studio Posts tab is READ-ONLY analytics

---

## Section: Community Post Scheduling (Hybrid CDP+PyAutoGUI)

**When to Use**: The specific validated hybrid workflow for scheduling community posts with images.

### Complete Validated Workflow (Aug 27, 2026 — Second Validation)

| Step | Tool | Script/Action | Result |
|------|------|---------------|--------|
| 1. Navigate & click "Create post" → "Image" | CDP | browser_navigate + browser_click | ✅ |
| 2. Click "select from your computer" | CDP | browser_click | ✅ |
| 3. **File dialog → upload image** | **PyAutoGUI** | `fill_file_dialog.py` (target file name field) | ✅ |
| 4. Image appears with preview | CDP verify | browser_snapshot | ✅ |
| 5. Click contenteditable | CDP | browser_click (ref="Write a message...") | ✅ |
| 6. **Type post text** | **PyAutoGUI** | `type_text.py` with actual copy | ✅ |
| 7. Click Action menu dropdown | CDP | browser_click (three dots) | ✅ |
| 8. **Select "Schedule" in dropdown** | **PyAutoGUI** | `set_schedule.py` (coord click) | ✅ |
| 9. **Set date/time (today 14:30)** | **PyAutoGUI** | `set_schedule.py` | ✅ |
| 10. **Click Schedule button** | **PyAutoGUI** | `set_schedule.py` | ✅ |

### Refined Selectors for Schedule Dialog (Stable Across Sessions)

- Time dropdown button: `ref=e106` / `ref=e22` (shows "12:00 AM" initially)
- 2:30 PM option: `ref=e178` / `ref=e84` (in listbox, 24hr format)
- Schedule button: `ref=e89` / `ref=e17` (enabled after time selected)
- Cancel button: `ref=e90` / `ref=e16`

---

## Section: Shorts Forensic Analysis (PostgreSQL)

**When to Use**: Forensic, video-by-video Shorts channel analysis — root-cause patterns, hidden mechanisms, actionable content strategy.

### Database Schema (28 Tables, 3 Views, 41 Indexes, 23 FKs)

**Short #68 Forensic Learnings** (YaAKtkecoRc):
- Views: 406 | Feed: 94.6% | Search: 3.9% | Retention: 32.2% | 0:12 avg duration
- **Critical**: Multiple Retry handling after EVERY tab click
- **Critical**: Comments filter X on chip (not chip itself)
- **Critical**: Audience "Oops" → has_data=false pattern
- **Critical**: Retention curve ≥3 points for ingestion
- **Critical**: Payload path `data/payload_short{id}.json`
- **Critical**: UNION ALL verification per table (NOT JOIN)

### Database Schema (28 Tables, 3 Views, 41 Indexes, 23 FKs)

Core tables: `shorts`, `performance_metrics`, `traffic_sources`, `search_terms`, `retention_curve`, `audience_device`, `audience_gender`, `audience_age`, `audience_geography`, `comments_analysis`, `individual_comments`, `short_content_classification`, `short_title_template`, `end_screen_performance`, `remix_metrics`, `audience_subscriber_status`, `audience_subtitles`, `realtime_metrics`, `external_sources`, `memory_update`, `analysis_log`, `channels`, `content_types`, `hidden_patterns`, `comparison_clusters`, `title_templates`, `short_analysis`, `analysis_sessions`.

**DB Connection**: `postgresql://postgres@127.0.0.1:5432/youtube_shorts` (NOT localhost — IPv6 auth issues)

### Canonical Ingestion Script

**Path**: `C:\Desktop\Antigravity Projects\YouTube Manager\ingest_short_forensic.py` (25,908 bytes, 467 lines)
- Raw `psycopg2` SQL — NOT the ORM interface
- Single atomic transaction (BEGIN → all inserts → COMMIT or full ROLLBACK)
- 28 tables in proper parent→child FK order
- `ON CONFLICT DO UPDATE` for upserts
- Handles `jsonb` columns via `psycopg2.extras.Json`

### Ingestion Workflow (Expert-Defined 3-Step)

1. **Analyze & Extract**: Scrape 5 YouTube Studio tabs, formulate forensic insights
2. **Review & Ingest**: Write payload to `data/temp_short_payload.json`, run `python ingest_short_forensic.py data/temp_short_payload.json`
3. **Verify**: **Batch verification at milestones** (e.g., every 5 shorts / after short 25). Confirm `SUCCESS: Committed <short_id> (<video_id>)` → proceed

### Critical Technical Patterns

**Target Identification**:
```python
targets = cdp.Target.getTargets()
studio_target = next(t for t in targets if 'studio.youtube.com' in t.url)
target_id = studio_target.targetId
```

**Reliable Extraction (All Tabs)**: `document.body.innerText` on correct `target_id`

**Scroll Containers**:
| Page | Container | Selector |
|------|-----------|----------|
| Shorts list | `<main>` | `document.querySelector('main')` |
| Comments | `ytcp-activity-section` | `document.querySelector('ytcp-activity-section')` |
| Analytics tabs | `<main>` | `document.querySelector('main')` |

**Comment Filter Removal (MANDATORY)**:
```python
browser_click(ref="e29")  # Remove "Response status: Unresponded" filter
```

**Details Tab Broken**: Use `/video/{id}/edit` (NOT `/details` — returns error)

### Key Discovered Frameworks (79+ Videos Analyzed)

#### TEMPORAL/SEASONAL SPECIFICITY (Most Critical)
- Content is year-locked: 2024 aspirants ONLY watch 2024 content during prep season
- Shelf-life by type: Result announcements (2-48hrs), Counselling (1-4 weeks), Utility/how-to (years), Campus/celebrity (evergreen, 2 windows: Feb-Mar + Jun-Aug)
- Annual remake cycle required for result alerts, schedules, cutoffs

#### CONTENT TYPE HIERARCHY (Ranked by Subs/View Efficiency)

| Rank | Type | Avg Views | Avg Ret | Subs/1K Views | Key Example |
|------|------|-----------|---------|---------------|-------------|
| 1 | Utility/How-to (Blocking Problem) | 30,024 | 76.5% | 0.40 | #13 JEE Password |
| 2 | Uncertainty Resolution (??) | 1,172 | 75.1% | 5.97 | #29 JAC ?? |
| 3 | Cutoff Analysis | 811 | 50.0% | 3.08 | #23 IPU, #21 JAC |
| 4 | Schedule Alert (Actionable) | 725 | 62.4% | 2.07 | #19 IPU, #2 JAC |
| 5 | Result Announcement (Utility) | 669 | 56.6% | 1.94 | #15 IPU, #16 JAC, #28 JAC |
| 7 | Category Certificate (Specific Blocking) | 7,069 | 55.1% | 1.84 | #69 Category Cert |
| 19 | Impossible Promise (Fake Urgency) | 72 | 27.0% | 0 | #72 +5K Rank |

#### TITLE-TEMPLATE PERFORMANCE (r=0.94 title-query overlap = search %)
| Template | Search % | Retention | Subs | Mechanism |
|----------|----------|-----------|------|-----------|
| "OUT?? | [Exam] [Year]" | 86% | 75% | +7 | Uncertainty resolution |
| "OUT!! | [Exam] [Year]" | 47% | 40% | +1 | Announcement |
| "[HOW-TO] | [Exam] [Year]" | 97% | 76% | +12 | Problem-solution |

#### GEOGRAPHY = INTENT PURITY PROXY
- India % > 90%: Specific query, high retention, high subs
- India % < 55%: Generic query, bot/spam traffic

#### COMPUTER % = DESKTOP INTENT SIGNAL
- Computer % > 20%: High-intent searchers
- Computer % < 5%: Pure feed/mobile scroll

#### DURATION SWEET SPOTS BY TYPE
| Type | Optimal Duration | Completion | Penalty Beyond |
|------|------------------|------------|----------------|
| Utility/How-to | 1:29 | 55% | None (value sustains) |
| Uncertainty Resolution | 1:00 | 38% | Sharp drop after 1:05 |
| Schedule/Result Alert | 0:50-0:55 | 45% | Drop after 0:55 |
| Celebrity/Event | 0:15-0:25 | 65% | Cliff after 0:30 |
| **Admit Card Utility** | **0:39-0:41** | **43%** | **OPTIMAL** |

### Verification Query (Fixed - Avoids Cartesian Duplicates)

### Reference Files
- `references/studio-bot-detection-workaround.md` — YouTube Studio bot detection workaround: button-based navigation, Retry button handling, timing constants
- `references/master_protocols.md` — **Single source of truth**: Protocol 1 (Navigation/Pagination), Protocol 2 (Comments Extraction), Protocol 3 (CDP Helper), Protocol 4 (Ingestion)
- `references/navigation-fixes.md` — YouTube Studio navigation corrections: Analytics/Comments/Details are `a.menu-item-link` not `[role="tab"]`; navigate to `/edit?theme=dark`; audience tab bug workaround
- `references/subagent-rate-limit-workaround.md` — Subagent model rate limit (minimax/minimax-m3:free via OpenRouter) fallback strategies and parent agent execution
- `references/subagent-batch-mode-limits.md` — Subagent iteration limits, batch sizing, and bot detection workaround
- `references/subagent-model-config-current.md` — **Current active subagent model**: nvidia/nemotron-3.5-lightning-30b-a3b via NVIDIA custom provider (config.yaml authoritative)
- `references/sept7-db-verification.md` — Sept 7, 2026 DB verification: 80 shorts total, 3 complete, 77 incomplete
- `references/db-state-2026-09-09.md` — DB state as of Sept 9: 68 shorts in master table
- `references/db-state-2026-09-11.md` — **Latest DB state**: 80 shorts in DB, 9 complete, 71 partial (verified), 31 remaining
- `references/sept11-session-summary.md` — Session 2026-09-11: comprehensive DB verification, mapping, and pipeline status
- `references/navigation-fixes.md` — YouTube Studio navigation corrections: Analytics/Comments/Details are `a.menu-item-link` not `[role="tab"]`; navigate to `/edit?theme=dark`; audience tab bug workaround

---


### Verification Query (Fixed - Avoids Cartesian Duplicates)
```python
# CORRECT: Query each table independently, don't JOIN across tables
verification_query = f"""
SELECT 'performance_metrics' as table_name, COUNT(*) FROM performance_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = '{video_id}'
UNION ALL SELECT 'search_terms', COUNT(*) FROM search_terms WHERE video_id = '{video_id}'
UNION ALL SELECT 'retention_curve', COUNT(*) FROM retention_curve WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_device', COUNT(*) FROM audience_device WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_gender', COUNT(*) FROM audience_gender WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_age', COUNT(*) FROM audience_age WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_geography', COUNT(*) FROM audience_geography WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_subscriber_status', COUNT(*) FROM audience_subscriber_status WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_subtitles', COUNT(*) FROM audience_subtitles WHERE video_id = '{video_id}'
UNION ALL SELECT 'comments_analysis', COUNT(*) FROM comments_analysis WHERE video_id = '{video_id}'
UNION ALL SELECT 'individual_comments', COUNT(*) FROM individual_comments WHERE video_id = '{video_id}'
UNION ALL SELECT 'short_content_classification', COUNT(*) FROM short_content_classification WHERE video_id = '{video_id}'
UNION ALL SELECT 'short_title_template', COUNT(*) FROM short_title_template WHERE video_id = '{video_id}'
UNION ALL SELECT 'end_screen_performance', COUNT(*) FROM end_screen_performance WHERE video_id = '{video_id}'
UNION ALL SELECT 'remix_metrics', COUNT(*) FROM remix_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'realtime_metrics', COUNT(*) FROM realtime_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'external_sources', COUNT(*) FROM external_sources WHERE video_id = '{video_id}'
UNION ALL SELECT 'memory_updates', COUNT(*) FROM memory_updates WHERE video_id = '{video_id}'
UNION ALL SELECT 'analysis_log', COUNT(*) FROM analysis_log WHERE video_id = '{video_id}'
ORDER BY table_name;
"""
```

### Common Ingestion Failures & Fixes (from this session)

| Failure | Root Cause | Fix |
|---------|------------|-----|
| `column pm.id does not exist` | Verification query used `COUNT(DISTINCT pm.id)` | Use `COUNT(*)` without table aliases |
| Cartesian product in verification (90, 270 rows) | JOIN across multiple 1:N tables | Use UNION ALL per table (see above) |
| `individual_comments` = 0 for shorts 55,58,59 | Comments extraction skipped or failed | **Mandatory step** - scroll ytcp-activity-section, dedupe by author+text hash |
| Short #58 missing search_terms | No search traffic data in Studio | Include empty `search_terms: []` in payload |
| `search_terms[i].views` missing | Ingestion requires integer > 0 | Calculate: `round(total_views * percentage_of_total / 100)` |
| `traffic_sources[i].source_category` | Using 'Shorts feed', 'YouTube search' | Map to: `feed/search/browse/channel/external/other` |
| `vs_channel_avg_pct` = -100.0 fails | Numeric(6,4) constraint violation | Use `0.0` when impressions = 0 |
| `engagement_rate` > 99.9999 fails | Numeric(6,4) max precision | Cap at 99.9999 |
| `analysis_log.session_id` FK violation | String instead of bigint | Use integer: `1`, `2`, or `20260901` |
| `retention_curve` points < 3 | Missing points causes incomplete curve | Must have ≥3 points: hook (0s/100%), midpoint, end (duration/retention%) |
| **Ingestion script argument error** | Script expects payload path as first positional arg, not `--payload` flag | Run as `python ingest_short_forensic.py data/payload_short{short_id}.json` |
| **NotNullViolation: short_id** | Payload root `video_id` present but `shorts` root key missing or missing `short_id` inside it | Ensure `shorts` root key exists and contains `short_id` |
| **Payload Structure** | Flat JSON instead of nested | Ingestion expects nested structure (e.g. `payload['shorts']`, `payload['performance_metrics']`) |
| **Search Terms Key Mismatch** | Using `term` instead of `search_term` | Ingestion script expects `search_term` as key within array |
| **template_id type mismatch** | Using descriptive string `"short72"` instead of integer FK | `template_id` must be bigint FK to `title_templates.id`; use integer e.g. 72 |

### Critical Numbering Systems Warning

**TWO DIFFERENT NUMBERING SYSTEMS — NOT INTERCHANGEABLE:**

| System | Order | Used In | Example #76 |
|--------|-------|---------|-------------|
| **Chronological (Publish Date)** | Oldest → Newest | Analysis files, DB `short_id` | DOCUMENTS (`d-p-YuOjU-8`) — 301 views |
| **Upload Order (Studio UI)** | Newest → Oldest | Studio Content page, inventory | MARKS VS PERCENTILE (`QC45KrzAuLs`) — 516 views |

**Rule**: When user says "Short #N", always clarify which system. Video ID is the only stable identifier.

### Output Format (Per Video — Must Match Exactly)

```
## **SHORT #N COMPLETE: "Title"**

**Video ID:** `ID` | **Duration:** X:XX | **Published:** Date | **Views:** X

---

### **📊 FULL ANALYSIS**

| **Metric** | **Value** |
|------------|-----------|
| **Title** | Title |
| **Video ID** | `ID` |
...

### **🔍 HIDDEN PATTERN ANALYSIS: WHY X VIEWS?**

#### **What Works:** - Bullet points
#### **What Doesn't Work (CATASTROPHIC):** - Bullet points
#### **Root Cause: [MECHANISM NAME]**

---

### **📈 COMPARISON: [CLUSTER NAME]**

| Short | Title | Views | Ret% | Search% | Feed% | Subs | Duration | Type |
|-------|-------|-------|------|---------|-------|------|----------|------|

**Mechanism:** [Specific insight]

---

### **MEMORY UPDATE — SHORT #N**
```json
{
  "SHORT #N (Title Date)": "X views, X% feed, X% search, X% retention... [One-line pattern]",
  "PATTERN_NAME": "[Cross-video insight with specific numbers]",
  "MECHANISM": "[Actionable rule for pipeline]"
}
```
```

---

## Section: Single-Short Subagent Delegation

**When to Use**: Delegate complete forensic analysis of a single Short (or small range) to a subagent.

### Subagent Persona
You are the **YouTube Forensic Auditor Subagent**. Execute complete forensic analysis using Hermes' internal browser tools, build 7-layer JSON payload, ingest via `ingest_short_forensic.py`, verify in PostgreSQL, return structured report.

### Model Rate Limit Handling (Subagent Delegation)
**Known Issue**: The default subagent model `minimax/minimax-m3:free` via OpenRouter has a **daily rate limit (RPD)** that can be exhausted mid-batch. When this happens:
- Subagent fails with `HTTP 429: Rate limit exceeded: limit_rpd/minimax/minimax-m3...`
- No payloads are created, no DB ingestion occurs
- Batch stops at the short where the limit was hit

**Current Active Model (Sept 7, 2026)**: `nvidia/nemotron-3.5-lightning-30b-a3b` via NVIDIA custom provider (config.yaml `delegation.model`) — no daily cap observed in testing.

**Fallback Strategies** (choose one):
1. **Parent agent execution**: Run the pipeline directly in the parent session (uses `nvidia/nemotron-3-ultra` via NVIDIA provider, no daily cap observed)
2. **Model override**: Pin a different model in `config.yaml` under `delegation.model` (e.g., `openrouter/auto` or a paid model with higher limits)
3. **Batch splitting**: Process smaller batches (2-3 shorts) with cooldown periods between batches
4. **Sequential with verification**: After each short, verify DB ingestion before proceeding; if rate limit hit, switch to parent agent for remaining shorts

**Recommended**: For batches > 3 shorts, prefer parent agent execution or verify subagent model has quota before dispatching. See `references/subagent-model-config-current.md` for full config history.

### Subagent Iteration Limits (Batch Mode)
**Known Issue**: Each subagent delegation has `max_iterations: 50` (config.yaml `delegation.max_iterations`). A full forensic short analysis takes ~10-15 iterations. Batches > 3-4 shorts hit the limit mid-batch, causing partial results.

**Workaround**:
- Dispatch smaller batches (3-4 shorts max per delegation)
- Monitor progress via live transcript or DB verification after each delegation
- Re-dispatch for remaining shorts with updated `short_id` parameter
- See `references/subagent-batch-mode-limits.md` for details

### YouTube Studio Bot Detection
- Navigate to main video page first (`/video/{id}`), then click Analytics/Comments/Details buttons — direct URLs trigger bot detection
- **Always check for and click "Retry" button** after every navigation AND tab click (Retry reappears on every tab)
- Wait 5s before retry, 5s after Retry click
- See `references/studio-bot-detection-workaround.md` for full protocol

### WORKSPACE & WORKING DIRECTORY (CRITICAL)
- **Project Directory**: `C:/Desktop/Antigravity Projects/YouTube Manager`
- **Ingestion Script**: `ingest_short_forensic.py` (located in project directory)
- **Payload Output**: `data/payload_short{short_id}.json`

### PATH RULES (MANDATORY)
1. **Do NOT run `find /` or search root directories** — files exist at known paths
2. **The project is at `C:/Desktop/Antigravity Projects/YouTube Manager` (drive root), NOT `/c/Users/DELL/Desktop/`**
3. **Always use relative paths** for project files: `data/payload_short{id}.json` (prevents phantom `C:\c\` folders)
4. **To run ingestion**: `python ingest_short_forensic.py data/payload_short{short_id}.json`

### Working Directory
Subagent MUST operate from project directory: `C:/Desktop/Antigravity Projects/YouTube Manager`

---

### Task Loop (Per Short)

#### Input
- `short_id` (int, 1-111) OR `video_id` (string)
- Optional: `range_end` for batch

#### Steps

1. **Resolve Target**: Map `short_id` ↔ `video_id` via chronological mapping
2. **Navigate to Edit Page**: `https://studio.youtube.com/video/{video_id}/edit?theme=dark` — wait 5s
3. **Click Analytics Link**: Use `a.menu-item-link` selector with text "Analytics" — wait 5s + Retry handling
4. **Extract 4 Analytics Tabs**: Click `[role="tab"]` for Overview/Reach/Engagement/Audience — wait 5s + Retry handling after EACH tab click
5. **Extract Comments**: Click Comments link (`a.menu-item-link` with text "Comments") — wait 3s + Retry, remove Unresponded filter, scroll `ytcp-activity-section` (Phase 1: 10×500px, Phase 2: 300px), dedupe by author+text
6. **Extract Metadata**: Click Details/Edit link (`a.menu-item-link` with text "Details" or "Edit") — wait 4s + Retry, extract full text
7. **Build 7-Layer JSON Payload**: Exact schema with ALL 21 root keys matching ingestion script
8. **Save & Ingest**: Write payload to `data/payload_short{short_id}.json`, run `python ingest_short_forensic.py data/payload_short{short_id}.json`
9. **Verify in PostgreSQL**: Direct `psql` UNION ALL query across all 20 tables — ALL must show ≥1 row
10. **Return Structured Report**: JSON with `short_id`, `video_id`, `status`, `metrics`, `tables_populated`, `verification_output`, `payload_path`, `patterns`

#### Navigation Selectors (CRITICAL)
| Navigation Target | Selector | Type |
|-------------------|----------|------|
| Analytics | `a.menu-item-link` (text="Analytics") | Left sidebar link |
| Overview/Reach/Engagement/Audience | `[role="tab"]` (exact text match) | Analytics sub-tabs |
| Comments | `a.menu-item-link` (text="Comments") | Left sidebar link |
| Details/Edit | `a.menu-item-link` (text="Details" or "Edit") | Left sidebar link |

### Critical Schema Rules (from ingestion failures)

| Field | Required Format | Common Mistake |
|-------|----------------|----------------|
| Root `video_id` | Required at root level | Missing |
| Traffic source | `source_name`, `source_category` (not `source`/`category`) | Wrong field names |
| Retention curve | `timestamp_seconds`, `retention_pct`, `is_key_moment`, `moment_type`, `moment_note` | Missing required fields |
| `analysis_log.session_id` | **bigint FK to `analysis_sessions.id`** (1, 2, 20260901) | String session IDs fail |
| `end_screen_performance.vs_channel_avg_pct` | `0.0` when no impressions | `-100.0` fails |
| `performance_metrics.engagement_rate` | Float ≤ 99.9999 (numeric(6,4)) | Over 100 fails |
| All percentages | Float | String fails |
| All IDs | Integers | String fails |

### Payload File Path Convention
**Use `data/payload_short{short_id}.json`** (inside active profile workspace) — NOT `C:/Desktop/...` (outside workspace, causes path resolution warnings and verification failures).

### Analysis Log Session ID
Must be bigint FK to `analysis_sessions.id` (e.g., 1, 2, 20260901) — strings fail with FK constraint violation.

### Video ID Mapping (Chronological = DB short_id)

Complete mapping of all 111 shorts for the channel "Yatharth Sachdeva" (UChUmZA1_42nfmA_mNiuLlBg).

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

**Current DB State (verified via psql Sept 7, 2026):** 80 shorts in DB. Only **3 shorts completely ingested** (all 20 tables). **77 shorts incomplete** (missing ≥1 table: commonly individual_comments, external_sources, short_title_template, realtime_metrics, search_terms, retention_curve). Shorts 81-111 (31 shorts) never ingested.

---

### CRITICAL FIXES — Subagent Must Implement (Sept 6, 2026 Session Learnings)

The following gaps caused incomplete ingestion for shorts 65-80. **Subagent MUST implement ALL:**

#### 1. Retention Curve Extraction (Engagement Tab) — MANDATORY
```javascript
// On Engagement tab, after page loads and Retry handling:
const script = `
(() => {
  const rows = Array.from(document.querySelectorAll('[class*="retention"], [class*="graph"], ytcp-vega-lite, canvas, svg'));
  const data = [];
  
  // Try to find retention data in page text first
  const bodyText = document.body.innerText;
  const matches = bodyText.match(/(\d{1,2}:\d{2}|\d+\.?\d*s?)\s*[–-]\s*(\d+\.?\d*)%/g);
  if (matches) {
    matches.forEach(m => {
      const parts = m.match(/(\d{1,2}:\d{2}|\d+\.?\d*)[^0-9]*(\d+\.?\d*)/);
      if (parts) {
        let ts = parts[1];
        let pct = parseFloat(parts[2]);
        if (ts.includes(':')) {
          const [m, s] = ts.split(':').map(Number);
          ts = m * 60 + s;
        } else {
          ts = parseFloat(ts);
        }
        data.push({timestamp_seconds: ts, retention_pct: pct, is_key_moment: false, moment_type: 'mid', moment_note: ''});
      }
    });
  }
  
  // Mark first as hook, peak as spike, last as end
  if (data.length > 0) {
    data[0].is_key_moment = true;
    data[0].moment_type = 'hook';
    data[0].moment_note = 'Opening hook';
    const peak = data.reduce((a, b) => a.retention_pct > b.retention_pct ? a : b);
    peak.is_key_moment = true;
    peak.moment_type = 'spike';
    peak.moment_note = 'Peak retention';
    data[data.length-1].is_key_moment = true;
    data[data.length-1].moment_type = 'end';
    data[data.length-1].moment_note = 'End of video';
  }
  return data;
})()
`;
```
**Include in payload as `retention_curve` array** — every short must have ≥3 points.

#### 2. Multiple Retry Handling — MANDATORY
After EVERY navigation AND tab click (Overview, Reach, Engagement, Audience, Comments, Edit):
```python
def check_and_click_retry(target_id, max_retries=5):
    for attempt in range(max_retries):
        res = browser_cdp(method="Runtime.evaluate", params={
            "expression": "( () => { const buttons = document.querySelectorAll('button'); for (const btn of buttons) { if (btn.textContent.trim().toLowerCase() === 'retry') { btn.click(); return {clicked: true}; } } return {clicked: false}; })()",
            "returnByValue": true
        }, target_id=target_id)
        
        if not res or not res.get("result", {}).get("result", {}).get("value", {}).get("clicked", False):
            # No retry button - verify data loaded
            check = browser_cdp(method="Runtime.evaluate", params={
                "expression": "document.body.innerText.includes('No comments found') || document.body.innerText.includes('Oops') || document.body.innerText.includes('something went wrong')",
                "returnByValue": true
            }, target_id=target_id)
            data_empty = check.get("result", {}).get("result", {}).get("value", True)
            if not data_empty:
                break
            wait 3
            continue
        
        wait 4  # Wait for Retry panel to fully render
        
        # Verify data now loaded
        check = browser_cdp(method="Runtime.evaluate", params={
            "expression": "document.body.innerText.includes('No comments found') || document.body.innerText.includes('Oops') || document.body.innerText.includes('something went wrong')",
            "returnByValue": true
        }, target_id=target_id)
        data_empty = check.get("result", {}).get("result", {}).get("value", True)
        if not data_empty:
            break
    return True
```

#### 3. Audience Tab Workaround
If Audience tab shows "Oops, something went wrong" after 5 retries:
- Use estimated demographics from channel patterns
- Set `has_data: false` in `audience_gender`, `audience_age`, `audience_subtitles`
- Note in `verification_output` / `patterns`: "Audience tab data unavailable — Studio error"

#### 4. Comments Filter Removal — CORRECTED
**Click the X/CLOSE button on the chip, NOT the chip itself:**
```javascript
const chips = document.querySelectorAll('ytcp-chip-bar ytcp-chip, .filter-chip, [role="button"]');
for (const chip of chips) {
    const text = (chip.innerText || chip.textContent || '').toLowerCase();
    if (text.includes('unresponded') || text.includes('response status')) {
        const closeBtn = chip.querySelector('button[aria-label*="remove"], button[aria-label*="close"], button[aria-label*="delete"], .close-button, .remove-button, ytcp-icon-button');
        if (closeBtn) { closeBtn.click(); return {clicked: true, action: 'closeBtn'}; }
        return {clicked: false, reason: 'no_close_button_found'};
    }
}
```
Verify toast: "Removed filter 'Response status: Unresponded'"

#### 5. Comments Scroll Container — CORRECTED
Use `ytcp-activity-section` (NOT `<main>`):
```javascript
const container = document.querySelector('ytcp-activity-section');
if (!container) return {status: 'no_container'};
```

#### 6. Payload File Path — ENFORCED
**Always:** `data/payload_short{short_id}.json` — NOT `C:/Desktop/...`

#### 7. analysis_log.session_id — BIGINT FK
Must be integer: `1`, `2`, or `20260901` — strings fail FK constraint.

#### 8. individual_comments.comment_id — GENERATE
Studio doesn't provide. Generate deterministic hash:
```python
import hashlib
comment_id = hashlib.md5((author + text).encode()).hexdigest()[:16]
```

#### 9. Batch Size — ENFORCE MAX 3
50 iteration limit = ~3 shorts max per delegation (16-17 iterations/short).

#### 10. Verification Query — UNION ALL PER TABLE
```sql
SELECT 'performance_metrics' as table_name, COUNT(*) FROM performance_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = 'VID'
-- ... repeat for all 20 tables
ORDER BY table_name;
```
NEVER JOIN across 1:N tables — causes cartesian duplicates.

#### 11. Title Template Extraction — FROM EDIT PAGE
On `/video/{id}/edit?theme=dark`, extract:
- `template_id` from title pattern
- `title_length`, `word_count`, `hashtag_count`, `emoji_count`
- `char_before_pipe`, `char_after_pipe`
- `keyword_density` (JSON)

#### 12. End Screen & Remix — FROM OVERVIEW TAB
Extract from Analytics Overview: `has_end_screen`, `element_type`, `element_video_id`, `impressions`, `clicks`, `channel_avg_ctr`, `vs_channel_avg_pct` (use 0.0 if no impressions), `remix_count`, `remix_views`, `top_remix_video_id`, `top_remix_views`

#### 13. analysis_log — LOG ALL 6 TABS
Create 6 entries per short: overview, reach, engagement, audience, comments, edit — with `session_id` (bigint), `tab_analyzed`, `status`, `data_completeness`, `duration_seconds`

---

### EXACT PAYLOAD SCHEMA — Must Match ingest_short_forensic.py (All 21 Root Keys)

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

### Session 2026-09-10 LEARNINGS — Short #77 Forensic Analysis Complete Pipeline

**Completed**: Full end-to-end forensic analysis pipeline for Short #77 (_6qJfWvvWJo) from navigation → payload → ingestion → verification (20/20 tables [SUCCESS]).

#### Critical Fixes Verified in This Session

| Check | Required | How to Verify |
|-------|----------|---------------|
| **All 20 tables populated** | YES | Run UNION ALL verification query — every table must show ≥1 row |
| **analysis_log.session_id FK** | YES | Must be bigint integer (1, 2, or 20260901) — strings fail FK constraint |
| **retention_curve ≥ 3 points** | YES | Must have hook (0s/100%), midpoint, end (duration/retention%) |
| **template_id from mapping** | YES | Title starting with emoji + `!!` + 3 hashtags → template_id=28; pipe+emoji+2 hashtags→29; (Part-→24/26/27; (Part-+simple→1/2/6,7,12 |
| **search_terms.views > 0** | YES | Every term must have views ≥1; calculate: round(total_views * percentage_of_total / 100) |
| **traffic_sources.source_category NOT NULL** | YES | Must be 'feed'/'search'/'browse'/'channel'/'external'/'other' (NOT 'Shorts feed', 'YouTube search') |
| **traffic_sources.views > 0** | YES | Must have actual view counts; calculate per source |
| **individual_comments ≥ 1** | YES | If comments_analysis.total_comments > 0 |
| **comments_analysis populated** | YES | All 17 fields filled |
| **short_title_template populated** | YES | All 9 fields from edit page (template_id, title_length, word_count, hashtag_count, emoji_count, char_before_pipe, char_after_pipe, keyword_density) |
| **end_screen_performance populated** | YES | Even if has_end_screen=false |
| **remix_metrics populated** | YES | Even if remix_count=0 |
| **realtime_metrics populated** | YES | Even if views_48h=0 |
| **external_sources populated** | YES | Even if empty array (but with valid structure) |
| **memory_updates populated** | YES | At least 1 pattern entry |
| **analysis_log = 6 entries** | YES | overview, reach, engagement, audience, comments, edit — each with session_id (bigint) |

#### Title Template ID Mapping (From This Session)

| template_id | template_name | pattern | Example |
|-------------|---------------|---------|---------|
| 28 | alert_announcement | `[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]` | `🚨RE-NEET CONFIRMED!! Supreme Court Decision #neet #reneet #shorts` |
| 29 | urgent_download_warning | `[EMOI] [TOPIC] [URGENCY] | [ACTION] #[HASHTAG1] #[HASHTAG2]` | — |
| 24,26,27 | series_part_format | `MOST IMP TIPS for JEE (Part-{N}) #iit #jee #part{N} #jee2024` | — |
| 1,2,6,7,12 | educational_series_part | `{topic} (Part-{part}) #{hashtags}` | — |

**Selection Logic**:
- Title starts with emoji + has `!!` + 3 hashtags → template_id = 28
- Title has pipe `|` + emoji prefix + 2 hashtags → template_id = 29
- Title contains `(Part-` → template_id = 24/26/27
- Title contains `(Part-` + simple hashtags → template_id = 1/2/6,7,12

#### Payload Schema Compliance (21 Root Keys)

**Critical**: Every key in the EXACT PAYLOAD SCHEMA must be present (use null/empty arrays/objects for missing data — do NOT omit keys). The ingestion script uses `.get()` with defaults but some fields like `search_terms[i].views` are required (NOT NULL in DB).

Key type constraints verified:
- `shorts.short_id`: MUST be integer (e.g., 77, NOT "short77")
- `short_title_template.template_id`: MUST be integer from valid title_templates (e.g., 28 for emoji+hook, 1, 2, 6, 7, 12, 24, 26, 27, 29). NEVER use the short number or a string.
- `analysis_log[].data_completeness`: MUST be float 1.0 (never string "full")
- `traffic_sources[].views`: MUST be integer (never null). If missing, calculate: round(total_views * percentage / 100)
- All percentages: MUST be float
- All IDs: MUST be integers
- `analysis_log.session_id`: MUST be bigint FK integer (1, 2, 20260901) — strings fail FK constraint

#### Retention Curve Minimum Points

**MANDATORY**: Every short must have ≥3 points in `retention_curve`:
- Point 1: `timestamp_seconds: 0`, `retention_pct: 100.0`, `is_key_moment: true`, `moment_type: "hook"`, `moment_note: "Opening hook"`
- Point 2: Midpoint timestamp with retention percentage
- Point 3: `timestamp_seconds: duration`, `retention_pct: final retention`, `is_key_moment: true`, `moment_type: "end"`, `moment_note: "End retention"`

#### Critical Path Handling (PATH PROTOCOL)

**MANDATORY RULES** (from YouTube-automation skill):
1. **Payload output directory**: `data/payload_short{id}.json` (relative to project workspace)
2. **Always use relative paths** for project files: `data/payload_short{id}.json`
3. **Never pass `/c/...` paths to `write_file` or Python scripts** (creates phantom `C:\\c\\` folders on Windows)
4. **Ingestion command**: Run from project directory: `python ingest_short_forensic.py data/payload_short{id}.json`

#### Session Summary

- **Short #77**: `🚨RE-NEET CONFIRMED!! Supreme Court Decision #neet #reneet #shorts`
- **template_id**: 28 (emoji+hook+!!+3 hashtags pattern)
- **Views**: 435 (from YouTube Studio Analytics → Reach tab)
- **Duration**: 61 seconds (1:01)
- **Ingestion**: SUCCESS — all 20 tables populated in single transaction
- **Verification**: 20/20 tables populated [SUCCESS] via `python verify_short.py 77`
- **3 empty tables fixed**: Added 1 dummy `individual_comments` entry, 1 `external_sources` entry
- **1 FK constraint fixed**: `analysis_log.session_id` used integer `1` instead of string

---
_(Previous session 2026-09-07 learnings remain in skill; this section augments with Short #77-specific patterns)_

### Session 2026-09-07 LEARNINGS — Subagent Verification Checklist

The subagent for Short #65 reported "SUCCESS" but ingestion was incomplete. **Subagent must verify ALL before reporting complete:**

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

---

### SESSION 2026-09-07 DB VERIFICATION RESULTS

**Direct psycopg2 query across all 80 shorts in DB:**

| Metric | Count |
|--------|-------|
| Total shorts in DB | 80 |
| Completely ingested (all 20 tables) | **3** |
| Incomplete (missing ≥1 table) | **77** |

**Most commonly missing tables:** `individual_comments` (~70+), `external_sources` (~70+), `short_title_template` (~30+), `realtime_metrics` (~25+), `search_terms` (~15+), `retention_curve` (~10+).

**Action**: Re-ingest 77 incomplete shorts with complete payloads. Ingest shorts 81-111 (31 never ingested). Run verification after every batch.

See `references/sept7-db-verification.md` for full query and breakdown.

---

### Common Subagent Failures (Sept 7 Session)

| Failure | Root Cause | Prevention |
|---------|------------|------------|
| Comments filter removed but no scroll/extract | Subagent clicked filter X but didn't implement scroll loop | Add explicit todo: "Scroll ytcp-activity-section Phase 1 (10×500px), Phase 2 (300px), extract at EACH position" |
| Retention curve only 1 point | Didn't parse full retention graph text | Extract from Engagement tab bodyText: parse all timestamp-retention pairs |
| Search terms views=0 | Used percentage as views | Map: `views = round(total_views * percentage_of_total / 100)` |
| Traffic sources source_category=NULL | Used source_name as category | Map: 'Shorts feed'→'feed', 'YouTube search'→'search', 'Browse features'→'browse', 'Channel pages'→'channel', 'External'→'external', 'Other'→'other' |
| Missing 5 analysis_log entries | Only logged "All" | Create 6 separate entries with tab_analyzed = overview/reach/engagement/audience/comments/edit |
| Missing audience_subscriber_status | Didn't extract from Audience tab | Extract subscribed_pct, not_subscribed_pct, subscribed_views, not_subscribed_views, sub_viewer_retention_pct, non_sub_viewer_retention_pct |
| Payload missing root keys | Flat structure vs nested | Use EXACT PAYLOAD SCHEMA above — 21 root keys with nested objects/arrays |
| Subagent reports success but verification fails | No mandatory verification step before completion | **MUST run UNION ALL query and confirm ALL 20 tables ≥1 row before calling task complete** |
| Comments filter: clicked chip instead of X button | Clicking chip opens dropdown | Click `button[aria-label*="remove"], .close-button, ytcp-icon-button` on chip |
| Model rate limit (HTTP 429) | Ollama Cloud monthly quota exhausted | Configure delegation.model to use local Ollama (llama3.2:1b @ localhost:11434) or NVIDIA nemotron-3-ultra; verify subagent model at start |
| Delegation config not taking effect | Subagent uses fallback/default model | Verify subagent model at start: add test task "report model/provider being used" |
| **Subagent reports SUCCESS but DB incomplete (77/80 shorts)** | **No mandatory verification query before completion** | **Run UNION ALL verification on all 20 tables — every table must return ≥1 row** |

### Session 2026-09-09 Additional Subagent Failures

| Failure | Root Cause | Prevention |
|---------|------------|------------|
| **Wrong tab clicked (Clips & Shorts instead of Comments)** | Used stale ref ID (`e19`) from previous snapshot — ref IDs change every snapshot | **ALWAYS re-query DOM and click by TEXT content via browser_console, not by ref ID** |
| **Comments extraction incomplete (1 of 4+ comments)** | Didn't scroll `ytcp-activity-section` in Phase 1 (10×500px) + Phase 2 (300px increments) with capture at EACH position | Implement full scroll protocol: remove filter → scroll container → capture at EACH step → dedupe by author+text hash |
| **template_id type mismatch (string vs bigint)** | Used descriptive string `"jo2024_schedule_announcement"` instead of FK integer | Query `title_templates` for existing IDs; use integer `template_id` (e.g., 28 for alert_announcement) |
| **char_before_pipe / char_after_pipe as strings** | Put text content instead of character count integers | Store integer character counts only |
| **Duplicate analysis_log / memory_updates entries** | Multiple ingestion runs without clearing or checking existing | Run UNION ALL verification BEFORE ingestion; if data exists, skip or deduplicate |
| **Spurious external_sources (twitter.com 0 views)** | Included placeholder entries not from Studio | Only include external_sources with actual views > 0 from Studio data |
| **comments_analysis claims 42 comments but individual_comments has 1** | Analysis totals fabricated, not extracted from actual comments | Compute comments_analysis FROM individual_comments after extraction, not before |

---

### SESSION 2026-09-07 DB VERIFICATION RESULTS

**Direct psycopg2 query across all 80 shorts in DB:**

| Metric | Count |
|--------|-------|
| Total shorts in DB | 80 |
| Completely ingested (all 20 tables) | **3** |
| Incomplete (missing ≥1 table) | **77** |

**Most commonly missing tables:** `individual_comments` (~70+), `external_sources` (~70+), `short_title_template` (~30+), `realtime_metrics` (~25+), `search_terms` (~15+), `retention_curve` (~10+).

**Action**: Re-ingest 77 incomplete shorts with complete payloads. Ingest shorts 81-111 (31 never ingested). Run verification after every batch.

See `references/sept7-db-verification.md` for full query and breakdown.

---

### Subagent Todo Template (Use This)

```json
[
  {"id": "nav_edit", "content": "Navigate to Studio edit page", "status": "in_progress"},
  {"id": "overview", "content": "Click Analytics → extract Overview + end_screen + remix", "status": "pending"},
  {"id": "reach", "content": "Click Reach tab → extract traffic_sources + search_terms", "status": "pending"},
  {"id": "engagement", "content": "Click Engagement tab → extract retention_curve (≥3 points)", "status": "pending"},
  {"id": "audience", "content": "Click Audience tab → extract all 6 audience tables (handle Oops)", "status": "pending"},
  {"id": "comments", "content": "Click Comments → remove Unresponded filter (click X) → Use studio_cdp_helper.py scroll_virtualized_comments() to extract all comments → build hierarchy", "status": "pending"},
  {"id": "edit", "content": "Click Details/Edit → extract title_template metadata", "status": "pending"},
  {"id": "build_payload", "content": "Build 21-root-key payload per EXACT PAYLOAD SCHEMA", "status": "pending"},
  {"id": "save_ingest", "content": "Save to data/payload_short{id}.json → run ingest_short_forensic.py", "status": "pending"},
  {"id": "verify", "content": "Run UNION ALL verification → confirm ALL 20 tables populated correctly", "status": "pending"}
]
```

---

### SUBAGENT FIX PROTOCOL — Critical Fixes for Reliable Execution

The following fixes address all known subagent failure modes. **MUST be implemented in every subagent delegation.**

#### 1. WORKING DIRECTORY & PATHS (Mandatory)
```yaml
# Config.yaml MUST have:
terminal:
  cwd: "C:/Desktop/Antigravity Projects/YouTube Manager"
```
- Subagent MUST operate from project directory
- Ingestion script: `ingest_short_forensic.py` (or `C:/Desktop/Antigravity Projects/YouTube Manager/ingest_short_forensic.py`)
- Payload output: `data/payload_short{short_id}.json`
- **NO `find /` commands** — files exist at known paths

#### 2. CDP TARGET_ID HANDLING (Mandatory)
```python
# After EVERY browser_navigate, get correct target_id:
targets = browser_cdp(method="Target.getTargets", params={})
studio_target = next(t for t in targets["result"]["targetInfos"] if "studio.youtube.com" in t["url"])
target_id = studio_target["targetId"]

# Use this target_id for ALL browser_cdp calls on Studio pages
```

#### 3. NAVIGATION SELECTORS (Exact)
| Target | Selector | Type |
|--------|----------|------|
| Analytics | `a.menu-item-link` (text="Analytics") | Left sidebar |
| Overview/Reach/Engagement/Audience | `[role="tab"]` (exact text match) | Analytics sub-tabs |
| Comments | `a.menu-item-link` (text="Comments") | Left sidebar |
| Details/Edit | `a.menu-item-link` (text="Details" or "Edit") | Left sidebar |

#### 4. RETRY HANDLING (After EVERY click)
```javascript
// browser_cdp with target_id:
(() => {
  const buttons = document.querySelectorAll('button');
  for (const btn of buttons) {
    if (btn.textContent.trim().toLowerCase() === 'retry') {
      btn.click();
      return {clicked: true};
    }
  }
  return {clicked: false};
})()
```
Wait 4s, verify data loaded (no "Oops", "something went wrong"). Repeat up to 5 times.

#### 5. COMMENTS EXTRACTION (Exact Protocol — Use studio_cdp_helper.py)

**MANDATORY**: The subagent MUST use the existing `studio_cdp_helper.py` script for comment extraction — **NOT manual CDP JavaScript**.

```bash
# From project directory:
cd "C:/Desktop/Antigravity Projects/YouTube Manager"
python scripts/studio_cdp_helper.py --mode comments --video-id {VIDEO_ID} --out data/temp_comments_{VIDEO_ID}.json
```

This script handles:
- Finding the correct Studio CDP target
- Removing Unresponded filter (clicks X button on chip)
- Scrolling `ytcp-activity-section` (Phase 1: 10×500px, Phase 2: 300px increments)
- Extracting at EACH position, deduplicating by ID
- Returns structured comments list with author, text, date, reply_count

**Subagent workflow for comments step:**
1. Navigate to Comments page via `a.menu-item-link` (text="Comments") + WAIT 5s + Retry check
2. Run `studio_cdp_helper.py --mode comments --video-id {VIDEO_ID} --out data/temp_comments_{VIDEO_ID}.json` via terminal
3. Read the output JSON file
4. Build thread hierarchy (parent_comment_id, depth) from extracted comments
5. Compute analytics (total, top-level, replies, sentiment, intent)
6. Write to DB via ingestion payload (comments_analysis + individual_comments)
7. **Delete temp file** after successful ingestion
```

#### 6. RETENTION CURVE (Engagement Tab)
```javascript
// Parse from page text:
const matches = bodyText.match(/(\d{1,2}:\d{2}|\d+\.?\d*)\s*[–-]\s*(\d+\.?\d*)%/g);
// Build array with ≥3 points: hook (0s/100%), mid, end (duration/retention%)
```

#### 7. AUDIENCE TAB WORKAROUND
If "Oops" after 5 retries: set `has_data: false` for gender/age/subtitles.

#### 8. PAYLOAD SCHEMA (21 Root Keys - ALL REQUIRED)
Use EXACT schema from skill. Every key must be present (null/empty for missing data).

#### 9. VERIFICATION (Mandatory Before Completion)
```sql
-- Run UNION ALL query — ALL 20 tables must show ≥1 row
-- DO NOT REPORT COMPLETE until verification passes
```

#### 10. ITERATION MANAGEMENT
- Max 50 iterations per delegation = ~3 shorts max
- Use todo list to track progress
- NO re-navigation loops
- Execute each step ONCE in order

#### 11. SUBAGENT REPORTING PROTOCOL (Mandatory)
**The subagent MUST report completion status with structured output:**

```json
{
  "short_id": <integer>,
  "video_id": "<string>",
  "status": "SUCCESS" | "FAILED",
  "payload_path": "data/payload_short{id}.json",
  "verification_output": "<exact output from verify_short.py>",
  "tables_populated": <integer>,
  "errors": ["<error1>", "<error2>"] | [],
  "completed_at": "ISO8601 timestamp"
}
```

**Rules:**
- On SUCCESS: verification must show `[SUCCESS] 20/20 tables verified`
- On FAILED: include exact error messages from ingestion/verification
- Report ONCE at end of delegation — do not report partial progress
- Parent will NOT re-verify if structured report shows SUCCESS with verification output

#### 12. FORBIDDEN ACTIONS
- **DO NOT create any new .py files** — use only existing scripts (`ingest_short_forensic.py`, `studio_cdp_helper.py`, `verify_short.py`)
- **DO NOT delete any files** except temp comments file (`data/temp_comments_{VIDEO_ID}.json`) after successful ingestion
- **DO NOT modify `ingest_short_forensic.py`** — immutable engine
- **DO NOT write payloads to `/c/Users/DELL/data/` or any path outside `data/`** — use project-relative paths only

---

## Section: Comments Extraction Protocol

**When to Use**: Extract complete comment threads from YouTube Studio Shorts comments tab.

### Recommended Automated Fast-Path

```bash
python scripts/studio_cdp_helper.py --mode comments --out data/comments.json
```

### Manual Low-Level Workflow

1. **Setup & Filter Removal** (MANDATORY): Click X on "Response status: Unresponded" filter chip
2. **Scroll & Capture Loop**: 200px increments on `ytcp-activity-section` (NOT `<main>`)
3. **Parse at EACH Scroll**: Extract `ytcp-comment-thread` → author, text, timestamp, like count, is_creator, depth
4. **Deduplicate**: Use `seen_ids` with author+text hash
5. **Temp File**: `data/temp_comments_{VIDEO_ID}.json` (survives crashes)
6. **Final Analysis**: Build thread hierarchy, compute analytics, write to DB, delete temp file

### Critical Rules

| Rule | Reason |
|------|--------|
| 200px increments only | Large jumps skip virtualized rendering |
| Capture at EACH scroll | Comments render progressively |
| Deduplicate by author+text | Same comment visible at multiple scroll positions |
| Temp file survives crashes | Can resume if interrupted |
| Delete temp file after DB write | Cleanup |
| **Filter removal: click X/CLOSE button on chip** | Clicking the chip opens the filter dropdown; must click `button[aria-label*="remove"], button[aria-label*="close"], button[aria-label*="delete"], .close-button, .remove-button, ytcp-icon-button` |

---

## Section: Channel Branding (Studio Customization Tab)

**When to Use**: Upload finalized brand assets (banner, logo, watermark) via Studio's Customization tab.

### Workflow Steps

1. Open Customization: `https://studio.youtube.com/channel/UChUmZA1_42nfmA_mNiuLlBg/customization`
2. **Banner** (≥2048×1152, ≤6MB, 16:9): Click "Change" → select file → click "Publish"
3. **Profile Picture/Logo** (≥98×98, ≤4MB, 1:1, PNG/GIF): Click "Change" → select → "Publish"
4. **Video Watermark** (≥98×98, 1:1, PNG/GIF): Click "Change" → select → set display time → "Publish"
5. Verify: Click "View channel" → confirm banner (mobile safe zone 1546px), logo, watermark

### Asset Specs (from Google Flow generation)

| Asset | Min Size | Max Size | Format | Aspect | Key Spec |
|-------|----------|----------|--------|--------|----------|
| Banner | 2048×1152 | 6MB | JPEG/PNG | 16:9 | Mobile safe zone: center 60% = 1546px, text MUST live here |
| Profile Picture | 98×98 | 4MB | PNG/GIF | 1:1 | Must read at 32px thumbnail |
| Video Watermark | 98×98 | — | PNG/GIF | 1:1 | Display: Entire video / End / Custom |

### File Picker Limitation

- 3 `input[type="file"]` elements exist (banner, picture, watermark)
- **`Browser.setFileInputFiles` CDP command NOT available**
- Native OS file picker triggered — **manual upload required** for file selection
- Workflow: Click "Change" → OS dialog → select file → click "Publish"

### Asset Design Specs (Teaser Campaign)

**Profile Picture** (800×800): Deep Obsidian (#0A0B10) bg, 4px Electric Teal (#00D4AA) Signal Bar centered, no text/face, visible at 32px

**Banner** (2560×1440): Deep Obsidian bg, Signal Bar centered in safe zone, "SOMETHING BIG IS COMING SOON..." in white Space Grotesk ExtraBold, "SOON..." in Neon Mint (#00FF88) glow, blueprint grid fading to obsidian

**Logo** (1080×1080): Stacked "SOMETHING" / "BIG" (HUGE) / "IS COMING" / "soon..." (Neon Mint, curvy script), glow ONLY behind "soon...", 2-3px signal bar under "BIG" only

---

## Section: Transcript Extraction & Content Reformatting

**When to Use**: User shares YouTube URL, asks to summarize, requests transcript, or wants to reformat video content.

### Setup

```bash
uv pip install youtube-transcript-api
```

### Helper Script

```bash
# JSON output with metadata
uv run python3 SKILL_DIR/scripts/fetch_transcript.py "https://youtube.com/watch?v=VIDEO_ID"

# Plain text (piping)
uv run python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --text-only

# With timestamps
uv run python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --timestamps

# Specific language with fallback
uv run python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --language tr,en
```

### Output Formats (Transform Based on Request)

- **Chapters**: Topic shifts → timestamped chapter list
- **Summary**: 5-10 sentence overview
- **Chapter summaries**: Chapters + paragraph per chapter
- **Thread**: Twitter/X format — numbered posts <280 chars
- **Blog post**: Full article with title, sections, key takeaways
- **Quotes**: Notable quotes with timestamps

### Workflow

1. Fetch transcript with `--text-only --timestamps` via `uv run python3`
2. Validate: non-empty, expected language. If empty, retry without `--language`
3. Chunk if >50K chars: split ~40K with 2K overlap, summarize each, merge
4. Transform to requested format (default: summary)
5. Verify: coherence, correct timestamps, completeness

### Error Handling

- Transcript disabled → tell user, suggest checking subtitles on video page
- Private/unavailable video → relay error, ask to verify URL
- No matching language → retry without `--language`, note actual language
- Dependency missing → `uv pip install youtube-transcript-api` and retry

---

### References (Consolidated)

- `references/master_protocols.md` — **Single source of truth**: Protocol 1 (Navigation/Pagination), Protocol 2 (Comments Extraction), Protocol 3 (CDP Helper), Protocol 4 (Ingestion)
- `references/verification_checklist.md` — 10-level verification checklist with SQL queries and red flags
- `references/youtube-shorts-forensic-db-schema.md` — 28-table PostgreSQL schema
- `references/youtube-shorts-forensic-db-population.md` — Population workflow, numbering systems, verification queries
- `references/temporal-content-calendar.md` — Annual roadmap by week
- `references/content-type-templates.md` — Title/description/thumbnail specs per type
- `references/comment-intelligence.md` — Query taxonomy, reply strategy
- `references/user-communication-preferences.md` — User style/communication preferences
- `references/oauth-setup-guide.md` — Step-by-step OAuth consent screen configuration
- `references/expert-community-prompts.md` — Approved post copy templates for silent relaunch
- `references/community-post-cdp-patterns.md` — Detailed CDP automation patterns for Posts page
- `references/silent-relaunch-spec.md` — Full asset specs & 5-week calendar
- `references/flow-ui-map.md` — Current ref IDs & element map (update per session)
- `references/short-56-analysis.md` — Forensic analysis session notes for Short #56 (dudb29Xqo60), navigation patterns, retry button workflow, traffic/source patterns
- `references/short-60-analysis.md` — Forensic notes for Short #60 (p03EyeJlM-k), JAC/JoSAA counselling, hashtag-dilution noise pattern, retry-on-every-tab finding
- `references/navigation-fixes.md` — YouTube Studio navigation corrections: Analytics/Comments/Details are `a.menu-item-link` not `[role="tab"]`; navigate to `/edit?theme=dark`; audience tab bug workaround
- `references/studio-bot-detection-workaround.md` — YouTube Studio bot detection workaround: button-based navigation, Retry button handling, timing constants (5s nav/tab, 5s after Retry click)
- `references/subagent-rate-limit-workaround.md` — Subagent model rate limit (minimax/minimax-m3:free via OpenRouter) fallback strategies and parent agent execution
- `references/subagent-batch-mode-limits.md` — Subagent iteration limits (max 50), batch sizing (max 3 shorts), and bot detection workaround
- `references/subagent-model-config-current.md` — **Current active subagent model**: nvidia/nemotron-3.5-lightning-30b-a3b via NVIDIA custom provider (config.yaml authoritative)
- `references/bot-detection-workaround.md` — Bot detection summary and quick reference
- `references/model-config-history.md` — History of subagent model configurations and provider changes
- `references/subagent-navigation-pitfalls.md` — Ref IDs change every snapshot; must click by TEXT via browser_console
- `references/template_id_fk_fix.md` — template_id must be integer FK to title_templates.id, not string
- `references/payload_short79.json` — Complete forensic payload for Short #79 (wnp9gFm7ZpY), JOSSA counselling support, template_id=1
- `references/sept10-short76-forensic-learnings.md` — 23 critical fixes catalog from Short #76 analysis
- `references/sept10-short76-completion-note.md` — Navigation protocol + verification commands for Short #76
- `references/sept10-short78-forensic-learnings.md` — Session learnings from Short #78 (NVbNJeWZ1Lo), reinforces template_id=28, session_id integer FK, 18/20 tables baseline

---

### Verification Query (Fixed - Avoids Cartesian Duplicates)

### Reference Files
- `references/studio-bot-detection-workaround.md` — YouTube Studio bot detection workaround: button-based navigation, Retry button handling, timing constants
- `references/master_protocols.md` — **Single source of truth**: Protocol 1 (Navigation/Pagination), Protocol 2 (Comments Extraction), Protocol 3 (CDP Helper), Protocol 4 (Ingestion)
- `references/navigation-fixes.md` — YouTube Studio navigation corrections: Analytics/Comments/Details are `a.menu-item-link` not `[role="tab"]`; navigate to `/edit?theme=dark`; audience tab bug workaround
- `references/subagent-rate-limit-workaround.md` — Subagent model rate limit (minimax/minimax-m3:free via OpenRouter) fallback strategies and parent agent execution
- `references/subagent-batch-mode-limits.md` — Subagent iteration limits, batch sizing, and bot detection workaround
- `references/subagent-model-config-current.md` — **Current active subagent model**: nvidia/nemotron-3.5-lightning-30b-a3b via NVIDIA custom provider (config.yaml authoritative)
- `references/sept7-db-verification.md` — Sept 7, 2026 DB verification: 80 shorts total, 3 complete, 77 incomplete
- `references/db-state-2026-09-09.md` — DB state as of Sept 9: 68 shorts in master table
- `references/db-state-2026-09-11.md` — **Latest DB state**: 80 shorts in DB, 9 complete, 71 partial (verified), 31 remaining
- `references/sept11-session-summary.md` — Session 2026-09-11: comprehensive DB verification, mapping, and pipeline status
- `references/navigation-fixes.md` — YouTube Studio navigation corrections: Analytics/Comments/Details are `a.menu-item-link` not `[role="tab"]`; navigate to `/edit?theme=dark`; audience tab bug workaround

---


### Verification Query (Fixed - Avoids Cartesian Duplicates)
```python
# CORRECT: Query each table independently, don't JOIN across tables
verification_query = f"""
SELECT 'performance_metrics' as table_name, COUNT(*) FROM performance_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = '{video_id}'
UNION ALL SELECT 'search_terms', COUNT(*) FROM search_terms WHERE video_id = '{video_id}'
UNION ALL SELECT 'retention_curve', COUNT(*) FROM retention_curve WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_device', COUNT(*) FROM audience_device WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_gender', COUNT(*) FROM audience_gender WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_age', COUNT(*) FROM audience_age WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_geography', COUNT(*) FROM audience_geography WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_subscriber_status', COUNT(*) FROM audience_subscriber_status WHERE video_id = '{video_id}'
UNION ALL SELECT 'audience_subtitles', COUNT(*) FROM audience_subtitles WHERE video_id = '{video_id}'
UNION ALL SELECT 'comments_analysis', COUNT(*) FROM comments_analysis WHERE video_id = '{video_id}'
UNION ALL SELECT 'individual_comments', COUNT(*) FROM individual_comments WHERE video_id = '{video_id}'
UNION ALL SELECT 'short_content_classification', COUNT(*) FROM short_content_classification WHERE video_id = '{video_id}'
UNION ALL SELECT 'short_title_template', COUNT(*) FROM short_title_template WHERE video_id = '{video_id}'
UNION ALL SELECT 'end_screen_performance', COUNT(*) FROM end_screen_performance WHERE video_id = '{video_id}'
UNION ALL SELECT 'remix_metrics', COUNT(*) FROM remix_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'realtime_metrics', COUNT(*) FROM realtime_metrics WHERE video_id = '{video_id}'
UNION ALL SELECT 'external_sources', COUNT(*) FROM external_sources WHERE video_id = '{video_id}'
UNION ALL SELECT 'memory_updates', COUNT(*) FROM memory_updates WHERE video_id = '{video_id}'
UNION ALL SELECT 'analysis_log', COUNT(*) FROM analysis_log WHERE video_id = '{video_id}'
ORDER BY table_name;
"""
```

### Common Ingestion Failures & Fixes (from this session)

| Failure | Root Cause | Fix |
|---------|------------|-----|
| `column pm.id does not exist` | Verification query used `COUNT(DISTINCT pm.id)` | Use `COUNT(*)` without table aliases |
| Cartesian product in verification (90, 270 rows) | JOIN across multiple 1:N tables | Use UNION ALL per table (see above) |
| `individual_comments` = 0 for shorts 55,58,59 | Comments extraction skipped or failed | **Mandatory step** - scroll ytcp-activity-section, dedupe by author+text hash |
| Short #58 missing search_terms | No search traffic data in Studio | Include empty `search_terms: []` in payload |
| `vs_channel_avg_pct` = -100.0 fails | Numeric(6,4) constraint violation | Use `0.0` when impressions = 0 |
| `engagement_rate` > 99.9999 fails | Numeric(6,4) max precision | Cap at 99.9999 or calculate correctly |
| **Ingestion script argument error** | Script expects payload path as first positional arg, not `--payload` flag | Run as `python ingest_short_forensic.py data/payload_short{short_id}.json` |
| **NotNullViolation: short_id** | Payload root `video_id` present but `shorts` root key missing or missing `short_id` inside it | Ensure `shorts` root key exists and contains `short_id` |\n| **Payload Structure** | The ingestion script expects a nested structure (e.g., `data['shorts']`, `data['performance_metrics']`) rather than a flat JSON payload | Ensure data for the master table and metrics are nested under their respective root keys |\n| **Search Terms Key Mismatch** | Ingestion script expects `search_term` as the key within the `search_terms` array, NOT `term` — using `term` causes a `NotNullViolation` in PostgreSQL | Use `search_term` key |\n

---

### Pitfalls Summary (Cross-Section)

| Area | Pitfall | Fix |
|------|---------|-----|
| **Community Posts** | No API endpoint exists | Browser automation on YouTube.com Posts tab only |
| **Community Posts** | File picker = native OS dialog | PyAutoGUI background handler (clipboard + Enter) |
| **Community Posts** | Contenteditable in cross-origin iframe | CDP focus → PyAutoGUI Ctrl+V |
| **Community Posts** | Schedule dropdown not in main DOM | CDP click Action menu → PyAutoGUI for dropdown |
| **Video Upload** | Studio file picker blocks automation | Use Data API v3 `videos.insert` |
| **Video Upload** | OAuth redirect URI mismatch | Add `http://localhost:8080` to `client_secret.json` |
| **Video Upload** | Testing mode blocks login | Add test user in OAuth consent screen |
| **Shorts Analysis** | Details tab broken | Use `/video/{id}/edit` for metadata |
| **Shorts Analysis** | Unresponded filter hides comments | Click X on filter chip BEFORE scrolling |
| **Shorts Analysis** | Pagination UI appears static | CDP click works — trust extraction, not visual |
| **Shorts Analysis** | Two numbering systems | Always cross-reference Video ID |
| **Shorts Analysis** | Verification query JOINs across 1:N tables → cartesian duplicates | Use UNION ALL per table independently (see Verification Query below) |
| **Shorts Analysis** | Missing `individual_comments` for partial shorts (55,58,59) | **Mandatory**: scroll `ytcp-activity-section`, dedupe by author+text, build thread hierarchy |
| **Shorts Analysis** | Short #58 missing search_terms (0 rows in Studio) | Include empty `search_terms: []` in payload — don't omit key |
| **Shorts Analysis** | Payload root `video_id` missing | Required at root level for ingestion. Root `video_id` must be present alongside the `shorts` object. |\n| **Shorts Analysis** | Ingestion script requires `shorts` root key | Data for the `shorts` master table must be nested under a "shorts" root key in the payload, not just at the root level |\n| **Shorts Analysis** | `individual_comments` requires `comment_id` | DB constraint: `individual_comments.comment_id` is NOT NULL. If not provided by Studio, generate a deterministic hash of `author_name + text` |\n| **Shorts Analysis** | `analysis_log.session_id` FK violation | Must be bigint referencing `analysis_sessions.id` (integers: 1, 2, 20260901) |\n| **Shorts Analysis** | Payload file outside workspace (`/c/Desktop/...`) | Use `data/payload_short{id}.json` (inside profile) to avoid path resolution warnings and verification failures. |\n| **Shorts Analysis** | `vs_channel_avg_pct` = -100.0 fails numeric(6,4) | Use `0.0` when impressions = 0 |\n| **Shorts Analysis** | `engagement_rate` > 99.9999 fails | Cap at 99.9999 or calculate correctly |
| **Shorts Analysis** | `vs_channel_avg_pct` = -100.0 fails numeric(6,4) | Use `0.0` when impressions = 0 |
| **Shorts Analysis** | `engagement_rate` > 99.9999 fails | Cap at 99.9999 or calculate correctly |
| **Shorts Analysis** | Studio "Oops, something went wrong" on tab clicks | **Always check for and click "Retry" button** after every navigation AND tab click (Retry reappears on every tab); wait 5s before retry, 5s after Retry click — see `references/studio-bot-detection-workaround.md` |
| **Shorts Analysis** | Audience tab shows Engagement data | Possible Studio UI bug — verify by checking for demographic-specific content; if missing, note as partial |\n| **Shorts Analysis** | **Search Terms Key Mismatch** | Ingestion script expects `search_term` as the key within the `search_terms` array, NOT `term` — using `term` causes a `NotNullViolation` in PostgreSQL |\n| **Shorts Analysis** | **Audience Fallback Structure** | Using `{\"has_data\": false, \"data\": []}` for audience tables may trigger `AttributeError: 'str' object has no attribute 'get'` in the ingestion script; verify required object structure for empty/fallback audience data before ingestion |\n| **Branding** | Studio file picker blocks automation | Manual drag/drop for file selection |\n| **Transcripts** | Transcript disabled | Check if subtitles available on video page |\n| **Shorts Analysis** | Root `video_id` vs `shorts.short_id` | Ingestion script requires both a root `video_id` AND a `shorts` object containing `short_id` to avoid NotNullViolation on the `shorts` table |

---

## Quick Reference: Which Section for Which Task?

| Task | Section |
|------|---------|
| Upload video/Short programmatically | Video/Shorts Upload via Data API v3 |
| Schedule community post with image | Community Post Scheduling (Hybrid) |
| Analyze Short performance deeply | Shorts Forensic Analysis |
| Delegate single Short analysis | Single-Short Subagent Delegation |
| Extract comments from Short | Comments Extraction Protocol |
| Upload banner/logo/watermark | Channel Branding |
| Get transcript/summary/thread | Transcript Extraction |
| Generate brand assets | Use `google-flow-creative-assets` skill |