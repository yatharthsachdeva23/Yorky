# Payload Field Mapping Reference

Quick reference for mapping YouTube Studio extracted data to ingestion script expected fields.

## Master Table: `shorts`

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| short_id | Chronological mapping | Must match DB short_id |
| video_id | URL or Studio | Required at root level too |
| title | Edit page title field | |
| title_raw | Same as title | Optional, defaults to title |
| description | Edit page description | |
| description_length | len(description) | |
| description_has_cta | Check for "link in bio", "comment below" | Boolean |
| description_has_links | Check for http:// or https:// | Boolean |
| published_at | Studio video details | ISO8601 |
| duration_seconds | Studio or video file | |
| duration_bucket | '15-60s' | Fixed for Shorts |
| visibility | 'public'/'private'/'unlisted' | |
| playlist_id | Studio playlist | Optional |
| playlist_title | Studio playlist | Optional |
| end_screen_type | Overview tab | Optional |
| end_screen_video_id | Overview tab | Optional |
| has_subtitles | Studio subtitles | Boolean |
| subtitle_languages | Studio subtitles | Array |
| related_video_id | Overview tab | Optional |
| tags_title | Edit page tags | Array |
| tags_description | Description hashtags | Array |
| emoji_in_title | Check title for emoji | Boolean |
| emoji_list | Extract emojis | Array |
| red_alert_emoji | Check for 🔴 | Boolean |
| content_year | From title/date | 2024 |
| content_type | Classification | educational, schedule_alert, etc. |
| content_subtype | Sub-classification | exam_tips, counselling_alert, etc. |
| thumbnail_style | JSON | Optional |
| hook_type | 'alert'/'how-to'/'uncertainty' | |
| value_type | 'schedule_alert'/'utility' | |
| language | 'Hinglish' | Fixed |
| cta_placement | 'none'/'description'/'pinned' | |

## Performance Metrics

| Ingestion Field | Source | Calculation |
|-----------------|--------|-------------|
| views | Overview tab | |
| engaged_views | Overview tab | ≈ views |
| unique_viewers | Overview tab | |
| watch_time_hours | Overview tab | |
| avg_view_duration_seconds | Overview tab | |
| retention_pct | Overview tab | |
| completion_pct | Overview tab | 100 - swipe_away_pct |
| swipe_away_pct | Overview tab | |
| subscribers_gained | Overview tab | |
| subscribers_lost | Overview tab | Usually 0 |
| net_subscribers | Overview tab | gained - lost |
| likes | Overview tab | |
| comments_count | Overview tab | |
| shares | Overview tab | |
| hype_points | Overview tab | Usually 0 |
| engagement_rate | Overview tab | (likes+comments+shares)/views*100 |
| sub_conversion_rate | Overview tab | subscribers_gained/views*100 |
| engaged_view_rate | Overview tab | engaged_views/views |
| views_vs_channel_avg_pct | Overview tab | Optional |
| retention_vs_channel_avg | Overview tab | Optional |
| period_start | First publish date | ISO8601 |
| period_end | Today | ISO8601 |

## Traffic Sources (Array)

| Ingestion Field | Studio Label | Category Mapping |
|-----------------|--------------|------------------|
| source_name | "Shorts feed" | 'feed' |
| source_name | "YouTube search" | 'search' |
| source_name | "Browse features" | 'browse' |
| source_name | "Channel pages" | 'channel' |
| source_name | "External" | 'external' |
| source_name | "Other YouTube features" | 'other' |
| source_name | "Others" | 'other' |
| views | Views column | Calculate from percentage |
| percentage | % column | |
| avg_view_duration_seconds | AVD column | Optional |
| retention_pct | Retention column | Optional |

## Search Terms (Array)

| Ingestion Field | Source | Calculation |
|-----------------|--------|-------------|
| search_term | Reach tab | |
| views | Reach tab | round(total_views * %of_total / 100) |
| percentage_of_search | Reach tab | % within search |
| percentage_of_total | Reach tab | % of total views |
| intent_category | Analyze term | specific/related/noise/brand |
| relevance_score | Analyze term | 1-5 (5=exact match) |

## Retention Curve (Array - ≥3 points)

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| timestamp_seconds | Engagement tab | Parse from "0:00" format |
| retention_pct | Engagement tab | % value |
| is_key_moment | Auto | True for first, peak, last |
| moment_type | Auto | 'hook'/'spike'/'mid'/'end' |
| moment_note | Auto | 'Opening hook'/'Peak retention'/etc |

## Audience Demographics

| Table | Fields | Source |
|-------|--------|--------|
| audience_device | mobile_pct, desktop_pct, tv_pct, tablet_pct, mobile_views, desktop_views, tv_views, tablet_views, desktop_intent_proxy | Audience tab |
| audience_gender | male_pct, female_pct, unknown_pct, has_data | Audience tab |
| audience_age | age_13_17_pct, age_18_24_pct, age_25_34_pct, age_35_44_pct, age_45_54_pct, age_55_64_pct, age_65_plus_pct, target_audience_pct, non_target_pct, has_data | Audience tab |
| audience_geography | country_code, country_name, views, percentage, avg_view_duration_seconds, is_target_country | Audience tab |
| audience_subscriber_status | subscribed_pct, not_subscribed_pct, subscribed_views, not_subscribed_views, sub_viewer_retention_pct, non_sub_viewer_retention_pct | Audience tab |
| audience_subtitles | none_pct, hindi_pct, english_pct, other_pct, has_cc_data | Audience tab |

## Comments Analysis

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| total_comments | Comments tab | |
| comments_per_1k_views | Calculation | total_comments/views*1000 |
| top_level_comments | Comments extraction | Depth 0 |
| total_replies | Comments extraction | Depth > 0 |
| max_thread_depth | Comments extraction | Max depth |
| avg_thread_depth | Comments extraction | Average |
| creator_replies | Comments extraction | is_creator=true |
| creator_reply_rate | Calculation | creator_replies/top_level_comments |
| sentiment_pct | Analyze text | positive/negative/neutral |
| query_comments | Intent analysis | |
| gratitude_comments | Intent analysis | "thank you", "thanks" |
| gratitude_with_likes | Filter | gratitude + likes > 0 |
| spam_irrelevant_comments | Intent analysis | |
| unanswered_high_intent_queries | Filter | query + no creator reply |

## Individual Comments (Array)

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| comment_id | Generate | md5(author+text)[:16] |
| author_name | Comments tab | |
| author_channel_id | Comments tab | Optional |
| is_creator | Comments tab | Badge |
| is_pinned | Comments tab | Pin icon |
| is_hearted | Comments tab | Heart icon |
| text | Comments tab | Raw |
| text_clean | Clean | Remove emojis, extra whitespace |
| like_count | Comments tab | |
| reply_count | Comments tab | |
| parent_comment_id | Thread hierarchy | For replies |
| depth | Thread hierarchy | 0=top, 1=reply, etc |
| published_at | Comments tab | ISO8601 |
| updated_at | Comments tab | ISO8601 |
| sentiment | Analyze | positive/negative/neutral |
| intent_category | Analyze | query/gratitude/creator_reply/creator_promo/spam/other |
| query_subtype | Analyze | date/schedule/process/cutoff/etc |
| is_actionable | Analyze | Boolean |
| has_contact_info | Analyze | Phone/email in text |

## Classification

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| primary_type | Analysis | Schedule Alert, Utility, Uncertainty, etc. |
| secondary_type | Analysis | counselling_alert, admit_card, etc. |
| confidence_score | Analysis | 8-9 |

## Title Template

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| template_id | title_templates.id | FK! Must insert title_templates first |
| title_length | len(title) | |
| word_count | Split title | |
| hashtag_count | Count # | |
| emoji_count | Count emoji | |
| char_before_pipe | Before \| | 0 if no pipe |
| char_after_pipe | After \| | Full length if no pipe |
| keyword_density | JSON | {"keyword": count} |

## End Screen Performance

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| has_end_screen | Overview tab | Boolean |
| element_type | Overview tab | 'video'/'playlist'/'channel'/'subscribe' |
| element_video_id | Overview tab | Optional |
| impressions | Overview tab | |
| clicks | Overview tab | |
| channel_avg_ctr | Overview tab | Optional |
| vs_channel_avg_pct | Calculation | 0.0 if impressions=0 |

## Remix Metrics

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| remix_count | Overview tab | |
| remix_views | Overview tab | |
| top_remix_video_id | Overview tab | Optional |
| top_remix_views | Overview tab | Optional |

## Realtime Metrics

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| views_48h | Realtime tab | |
| period_start | Realtime tab | ISO8601 |
| period_end | Realtime tab | ISO8601 |
| velocity_views_per_hour | Calculation | views_48h/48 |

## External Sources (Array)

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| source_domain | Reach/External | google.com, whatsapp.com, etc. |
| source_type | Categorize | 'search'/'social'/'direct'/'other' |
| views | Reach/External | |
| percentage | Reach/External | |

## Memory Update

| Ingestion Field | Source | Notes |
|-----------------|--------|-------|
| update_type | 'pattern' | |
| title | Descriptive | "Short #65 - JAC Delhi Schedule Alert Pattern" |
| payload | JSON | Key metrics |
| source_analysis | Text | Pattern explanation |
| priority | 1-5 | 3 default |
| applied_to_pipeline | false | |

## Analysis Log (6 Entries)

| session_id | tab_analyzed | status | data_completeness |
|------------|--------------|--------|-------------------|
| 20260901 | overview | success/partial/failed | 0.0-1.0 |
| 20260901 | reach | success/partial/failed | 0.0-1.0 |
| 20260901 | engagement | success/partial/failed | 0.0-1.0 |
| 20260901 | audience | success/partial/failed | 0.0-1.0 |
| 20260901 | comments | success/partial/failed | 0.0-1.0 |
| 20260901 | edit | success/partial/failed | 0.0-1.0 |

## FK Requirements

- `short_title_template.template_id` → `title_templates.id` (bigint)
- `analysis_log.session_id` → `analysis_sessions.id` (bigint: 1, 2, 20260901)
- `individual_comments.comment_id` → generated md5 hash (NOT NULL)

## Category Mappings

### Traffic Source Category
```
Shorts feed → feed
YouTube search → search
Browse features → browse
Channel pages → channel
External → external
Other YouTube features → other
Others → other
```

### Search Intent Category
```
Exact exam/date terms → specific
Related exam terms → related
Generic/noise (cricket, horror) → noise
Channel name → brand
```

### Comment Intent Category
```
Question with ? → query
"thank", "thanks", "grateful" → gratitude
Creator badge → creator_reply
Promotes own channel → creator_promo
Spam/off-topic → spam
Other → other
```

### Comment Query Subtype
```
"when", "date", "schedule" → schedule
"how", "process", "procedure" → process
"cutoff", "marks", "percentile" → cutoff
"admit card", "hall ticket" → admit_card
"result", "score" → result
"category", "certificate" → category
Other → general
```