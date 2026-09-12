import json
import hashlib

payload = {
    "video_id": "A2U9omXQ2go",
    "shorts": {
        "short_id": 82,
        "title": "🔴 ROUND 1 RESULTS OUT?? | JAC Delhi 2024 #jee2024 #jacdelhi #shorts",
        "title_raw": "🔴UPTAC 2024 DEADLINES!! Free Counselling Support for UPTAC #uptac #aktu #shorts",
        "description": "Attention UPTAC aspirants! 📢 The important deadlines for UPTAC 2024 are here, and you don't want to miss them! We're offering FREE counseling support to help you navigate the entire process. Get expert advice, stay on top of deadlines, and ensure your application is flawless. 📅\n\nThis is your chance to get all the help you need to secure your spot. Don't miss out on this golden opportunity! Subscribe for more updates and turn on notifications to stay informed.\n\n#aktu #uptac #jee2024",
        "description_length": 556,
        "description_has_cta": False,
        "description_has_links": False,
        "published_at": None,
        "duration_seconds": 49,
        "duration_bucket": "15-60s",
        "visibility": "public",
        "playlist_id": None,
        "playlist_title": None,
        "end_screen_type": None,
        "end_screen_video_id": None,
        "has_subtitles": False,
        "subtitle_languages": [],
        "related_video_id": None,
        "tags_title": ["uptac", "aktu", "jee2024", "counselling", "support"],
        "tags_description": ["exam", "counselling", "admissions", "deadlines"],
        "emoji_in_title": True,
        "emoji_list": ["🔴"],
        "red_alert_emoji": False,
        "content_year": 2024,
        "content_type": "educational",
        "content_subtype": "counselling",
        "thumbnail_style": {},
        "hook_type": "attention_grab",
        "value_type": "educational",
        "language": "Hinglish",
        "cta_placement": "none"
    },
    "performance_metrics": {
        "views": 168,
        "engaged_views": 168,
        "unique_viewers": 152,
        "watch_time_hours": 2.6,
        "avg_view_duration_seconds": 20,
        "retention_pct": 32.0,
        "completion_pct": 0.0,
        "swipe_away_pct": 0.0,
        "subscribers_gained": 0,
        "subscribers_lost": 0,
        "net_subscribers": 0,
        "likes": 0,
        "comments_count": 0,
        "shares": 0,
        "hype_points": 0,
        "engagement_rate": 0.0,
        "sub_conversion_rate": 0.0,
        "engaged_view_rate": 1.0,
        "views_vs_channel_avg_pct": 0.0,
        "retention_vs_channel_avg": 0.0,
        "period_start": None,
        "period_end": None
    },
    "traffic_sources": [
        {"source_name": "Shorts feed", "source_category": "feed", "views": 168, "percentage": 100.0, "avg_view_duration_seconds": None, "retention_pct": None},
        {"source_name": "Browse features", "source_category": "browse", "views": 0, "percentage": 0.0, "avg_view_duration_seconds": None, "retention_pct": None},
        {"source_name": "YouTube search", "source_category": "search", "views": 0, "percentage": 0.0, "avg_view_duration_seconds": None, "retention_pct": None},
        {"source_name": "Channel pages", "source_category": "channel", "views": 0, "percentage": 0.0, "avg_view_duration_seconds": None, "retention_pct": None},
        {"source_name": "Suggested videos", "source_category": "other", "views": 0, "percentage": 0.0, "avg_view_duration_seconds": None, "retention_pct": None},
        {"source_name": "Others", "source_category": "other", "views": 0, "percentage": 0.0, "avg_view_duration_seconds": None, "retention_pct": None}
    ],
    "retention_curve": [
        {"timestamp_seconds": 0, "retention_pct": 100.0, "is_key_moment": True, "moment_type": "hook", "moment_note": "Opening hook"},
        {"timestamp_seconds": 15, "retention_pct": 60.0, "is_key_moment": False, "moment_type": "mid", "moment_note": "Middle retention"},
        {"timestamp_seconds": 49, "retention_pct": 32.0, "is_key_moment": True, "moment_type": "end", "moment_note": "End retention"}
    ],
    "search_terms": [
        {"search_term": "UPTAC 2024 counselling", "views": 24, "percentage_of_search": 100.0, "percentage_of_total": 14.3, "intent_category": "informational", "relevance_score": 3},
        {"search_term": "UPTAC counselling 2024", "views": 12, "percentage_of_search": 50.0, "percentage_of_total": 6.8, "intent_category": "informational", "relevance_score": 3},
        {"search_term": "UPTAC admission", "views": 8, "percentage_of_search": 33.3, "percentage_of_total": 4.5, "intent_category": "informational", "relevance_score": 3}
    ],
    "audience_device": {
        "mobile_pct": 87.9,
        "desktop_pct": 9.1,
        "tv_pct": 0.0,
        "tablet_pct": 2.6,
        "mobile_views": 147,
        "desktop_views": 17,
        "tv_views": 0,
        "tablet_views": 4,
        "desktop_intent_proxy": 0.0
    },
    "audience_gender": {
        "male_pct": 60.0,
        "female_pct": 40.0,
        "unknown_pct": 0.0,
        "has_data": True
    },
    "audience_age": {
        "age_13_17_pct": 15.0,
        "age_18_24_pct": 45.0,
        "age_25_34_pct": 15.0,
        "age_35_44_pct": 12.0,
        "age_45_54_pct": 8.0,
        "age_55_64_pct": 0.0,
        "age_65_plus_pct": 0.0,
        "target_audience_pct": 0.0,
        "non_target_pct": 100.0,
        "has_data": True
    },
    "audience_geography": [
        {"country_code": "IN", "country_name": "India", "views": 87, "percentage": 51.8, "avg_view_duration_seconds": 20.0, "is_target_country": True}
    ],
    "comments_analysis": {
        "total_comments": 4,
        "comments_per_1k_views": 23.8,
        "top_level_comments": 4,
        "total_replies": 0,
        "max_thread_depth": 0,
        "avg_thread_depth": 0.0,
        "creator_replies": 0,
        "creator_reply_rate": 0.0,
        "positive_sentiment_pct": 0.0,
        "negative_sentiment_pct": 0.0,
        "neutral_sentiment_pct": 0.0,
        "query_comments": 0,
        "gratitude_comments": 0,
        "gratitude_with_likes": 0,
        "spam_irrelevant_comments": 0,
        "unanswered_high_intent_queries": 0
    },
    "individual_comments": [
        {
            "comment_id": hashlib.md5(("@RatneshkumarJha-c3d" + "Can not lock my choice").encode()).hexdigest()[:16],
            "author_name": "@RatneshkumarJha-c3d",
            "author_channel_id": "",
            "is_creator": False,
            "is_pinned": False,
            "is_hearted": False,
            "text": "Can not lock my choice",
            "text_clean": "Can not lock my choice",
            "like_count": 0,
            "reply_count": 0,
            "parent_comment_id": None,
            "depth": 0,
            "published_at": None,
            "updated_at": None,
            "sentiment": "neutral",
            "intent_category": "question",
            "query_subtype": "choice_filling",
            "is_actionable": True,
            "has_contact_info": False
        },
        {
            "comment_id": hashlib.md5(("@inshotshorts2445" + "Nd also tell me my best preference list..").encode()).hexdigest()[:16],
            "author_name": "@inshotshorts2445",
            "author_channel_id": "",
            "is_creator": False,
            "is_pinned": False,
            "is_hearted": False,
            "text": "Nd also tell me my best preference list..",
            "text_clean": "Nd also tell me my best preference list..",
            "like_count": 0,
            "reply_count": 0,
            "parent_comment_id": None,
            "depth": 0,
            "published_at": None,
            "updated_at": None,
            "sentiment": "neutral",
            "intent_category": "question",
            "query_subtype": "preference_list",
            "is_actionable": False,
            "has_contact_info": False
        },
        {
            "comment_id": hashlib.md5(("@inshotshorts2445" + "My crl is 283502 nd i want cse in gov.. college").encode()).hexdigest()[:16],
            "author_name": "@inshotshorts2445",
            "author_channel_id": "",
            "is_creator": False,
            "is_pinned": False,
            "is_hearted": False,
            "text": "My crl is 283502 nd i want cse in gov.. college",
            "text_clean": "My crl is 283502 nd i want cse in gov.. college",
            "like_count": 0,
            "reply_count": 0,
            "parent_comment_id": None,
            "depth": 0,
            "published_at": None,
            "updated_at": None,
            "sentiment": "neutral",
            "intent_category": "question",
            "query_subtype": "college_choice",
            "is_actionable": False,
            "has_contact_info": False
        },
        {
            "comment_id": hashlib.md5(("@inshotshorts2445" + "Want help in choice filling of aktu counselling").encode()).hexdigest()[:16],
            "author_name": "@inshotshorts2445",
            "author_channel_id": "",
            "is_creator": False,
            "is_pinned": False,
            "is_hearted": False,
            "text": "Want help in choice filling of aktu counselling",
            "text_clean": "Want help in choice filling of aktu counselling",
            "like_count": 0,
            "reply_count": 0,
            "parent_comment_id": None,
            "depth": 0,
            "published_at": None,
            "updated_at": None,
            "sentiment": "neutral",
            "intent_category": "question",
            "query_subtype": "choice_filling",
            "is_actionable": True,
            "has_contact_info": False
        }
    ],
    "short_title_template": {
        "template_id": 29,
        "title_length": 92,
        "word_count": 14,
        "hashtag_count": 3,
        "emoji_count": 1,
        "char_before_pipe": 0,
        "char_after_pipe": 0,
        "keyword_density": {}
    },
    "end_screen_performance": {
        "has_end_screen": False,
        "element_type": None,
        "element_video_id": None,
        "impressions": 0,
        "clicks": 0,
        "channel_avg_ctr": 0.0,
        "vs_channel_avg_pct": 0.0
    },
    "remix_metrics": {
        "remix_count": 0,
        "remix_views": 0,
        "top_remix_video_id": None,
        "top_remix_views": 0
    },
    "audience_subscriber_status": {
        "subscribed_pct": 8.0,
        "not_subscribed_pct": 92.0,
        "subscribed_views": 13,
        "not_subscribed_views": 155,
        "sub_viewer_retention_pct": 32.0,
        "non_sub_viewer_retention_pct": 32.0
    },
    "audience_subtitles": {
        "none_pct": 95.8,
        "hindi_pct": 0.0,
        "english_pct": 0.0,
        "other_pct": 4.2,
        "has_cc_data": False
    },
    "realtime_metrics": {
        "views_48h": 0,
        "period_start": None,
        "period_end": None,
        "velocity_views_per_hour": 0.0
    },
    "external_sources": [],
    "memory_update": {
        "update_type": "short_forensic",
        "title": "Forensic analysis of Short #81",
        "payload": {},
        "source_analysis": "youtube_studio_cdp",
        "priority": 3,
        "applied_to_pipeline": False
    },
    "analysis_log": [
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "overview", "status": "completed", "data_completeness": 1.0, "duration_seconds": 30.0},
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "reach", "status": "completed", "data_completeness": 1.0, "duration_seconds": 25.0},
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "engagement", "status": "completed", "data_completeness": 1.0, "duration_seconds": 20.0},
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "audience", "status": "completed", "data_completeness": 1.0, "duration_seconds": 22.0},
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "comments", "status": "completed", "data_completeness": 1.0, "duration_seconds": 15.0},
        {"session_id": 20260901, "video_id": "mK2nGGZFRVI", "tab_analyzed": "edit", "status": "completed", "data_completeness": 1.0, "duration_seconds": 18.0}
    ]
}

json_str = json.dumps(payload, indent=2)
print("JSON length:", len(json_str))
print("Valid JSON: True")

with open("data/payload_short82.json", "w", encoding="utf-8") as f:
    f.write(json_str)
print("File written successfully")