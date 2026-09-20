---
tags: [analytics, database, kpi, status]
created: 2026-09-20
---

# 📊 Channel KPI & Forensic Database Status

> [!INFO] Ground Truth Source
> All metrics below are backed by the 28-table PostgreSQL database running on `127.0.0.1:5432/youtube_shorts`.

---

## 📈 High-Level Metrics Summary

* **Total Shorts in Library**: `111`
* **Database Audit Completion**: `100%` (All 111 Shorts ingested across 20 active normalized tables)
* **Total Extracted Comments**: `356` comments across `63` active threads
* **Median Comment Count**: `1` (Heavily anchored by viral Short #41 with 107 comments)
* **Zero-Comment Shorts**: `48` (Verified legitimate zero-comment state)
* **Traffic Dominance**: YouTube Search + Shorts Feed account for >90% of total lifetime impressions

---

## 🗄️ Active PostgreSQL Architecture (20 Normalized Tables)

1. `shorts`: Master video metadata, visibility, `published_at`
2. `performance_metrics`: Views, retention %, watch time, engagement rate
3. `traffic_sources`: Feed, search, browse, channel, external breakdown
4. `search_terms`: Search keywords driving impressions
5. `retention_curve`: Second-by-second retention drop-off curve
6. `audience_device`: Mobile, desktop, tablet, TV
7. `audience_gender`: Gender demographics
8. `audience_age`: Age cohorts (13-17, 18-24, etc.)
9. `audience_geography`: Country of origin (India >90%)
10. `audience_subscriber_status`: Subscribed vs. non-subscribed views
11. `audience_subtitles`: Top subtitle/CC languages
12. `comments_analysis`: Sentiment percentages, pinned comments, query categories
13. `individual_comments`: Deduped raw comments with author and intent
14. `short_content_classification`: Educational intent and topic categorization
15. `short_title_template`: Emoji density, title structure
16. `end_screen_performance`: End screen element clicks and CTR
17. `remix_metrics`: Sound and video remixes
18. `realtime_metrics`: 48h and 60m velocity
19. `external_sources`: WhatsApp, Google Search, and external referrals
20. `memory_updates`: Cross-video algorithmic learnings

See also: [[🗄️ 111 Shorts Forensic Index]] • [[🔬 Pure CDP Pipeline Architecture]]
