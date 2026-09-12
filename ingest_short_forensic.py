#!/usr/bin/env python3
"""
Unified Ingestion Engine for YouTube Shorts Forensic Analysis Database (PostgreSQL)
Ingests all 20+ tables for a Short in ONE single atomic transaction (< 0.1s).
"""

import sys
import json
import psycopg2
from psycopg2.extras import Json

DB_PARAMS = {
    "dbname": "youtube_shorts",
    "user": "postgres",
    "host": "localhost",
    "port": 5432
}

def ingest_short(data: dict):
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    
    video_id = data.get("video_id")
    if not video_id:
        raise ValueError("Missing required 'video_id'")
        
    try:
        # 1. SHORTS MASTER TABLE
        s = data.get("shorts", {})
        cur.execute("""
            INSERT INTO shorts (
                short_id, video_id, title, title_raw, description, description_length,
                description_has_cta, description_has_links, published_at, duration_seconds,
                duration_bucket, visibility, playlist_id, playlist_title, end_screen_type,
                end_screen_video_id, has_subtitles, subtitle_languages, related_video_id,
                tags_title, tags_description, emoji_in_title, emoji_list, red_alert_emoji,
                content_year, content_type, content_subtype, thumbnail_style, hook_type,
                value_type, language, cta_placement
            ) VALUES (
                %(short_id)s, %(video_id)s, %(title)s, %(title_raw)s, %(description)s, %(description_length)s,
                %(description_has_cta)s, %(description_has_links)s, %(published_at)s, %(duration_seconds)s,
                %(duration_bucket)s, %(visibility)s, %(playlist_id)s, %(playlist_title)s, %(end_screen_type)s,
                %(end_screen_video_id)s, %(has_subtitles)s, %(subtitle_languages)s, %(related_video_id)s,
                %(tags_title)s, %(tags_description)s, %(emoji_in_title)s, %(emoji_list)s, %(red_alert_emoji)s,
                %(content_year)s, %(content_type)s, %(content_subtype)s, %(thumbnail_style)s, %(hook_type)s,
                %(value_type)s, %(language)s, %(cta_placement)s
            )
            ON CONFLICT (video_id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                updated_at = CURRENT_TIMESTAMP;
        """, {
            "short_id": s.get("short_id"),
            "video_id": video_id,
            "title": s.get("title"),
            "title_raw": s.get("title_raw", s.get("title")),
            "description": s.get("description", ""),
            "description_length": len(s.get("description", "")),
            "description_has_cta": s.get("description_has_cta", False),
            "description_has_links": s.get("description_has_links", False),
            "published_at": s.get("published_at"),
            "duration_seconds": s.get("duration_seconds", 0),
            "duration_bucket": s.get("duration_bucket", "15-60s"),
            "visibility": s.get("visibility", "public"),
            "playlist_id": s.get("playlist_id"),
            "playlist_title": s.get("playlist_title"),
            "end_screen_type": s.get("end_screen_type"),
            "end_screen_video_id": s.get("end_screen_video_id"),
            "has_subtitles": s.get("has_subtitles", False),
            "subtitle_languages": s.get("subtitle_languages", []),
            "related_video_id": s.get("related_video_id"),
            "tags_title": s.get("tags_title", []),
            "tags_description": s.get("tags_description", []),
            "emoji_in_title": s.get("emoji_in_title", False),
            "emoji_list": s.get("emoji_list", []),
            "red_alert_emoji": s.get("red_alert_emoji", False),
            "content_year": s.get("content_year", 2024),
            "content_type": s.get("content_type", "educational"),
            "content_subtype": s.get("content_subtype", "exam_tips"),
            "thumbnail_style": Json(s.get("thumbnail_style", {})),
            "hook_type": s.get("hook_type"),
            "value_type": s.get("value_type"),
            "language": s.get("language", "Hinglish"),
            "cta_placement": s.get("cta_placement", "none")
        })

        # 2. PERFORMANCE METRICS
        p = data.get("performance_metrics", {})
        if p:
            cur.execute("""
                INSERT INTO performance_metrics (
                    video_id, views, engaged_views, unique_viewers, watch_time_hours,
                    avg_view_duration_seconds, retention_pct, completion_pct, swipe_away_pct,
                    subscribers_gained, subscribers_lost, net_subscribers, likes, comments_count,
                    shares, hype_points, engagement_rate, sub_conversion_rate, engaged_view_rate,
                    views_vs_channel_avg_pct, retention_vs_channel_avg, period_start, period_end
                ) VALUES (
                    %(video_id)s, %(views)s, %(engaged_views)s, %(unique_viewers)s, %(watch_time_hours)s,
                    %(avg_view_duration_seconds)s, %(retention_pct)s, %(completion_pct)s, %(swipe_away_pct)s,
                    %(subscribers_gained)s, %(subscribers_lost)s, %(net_subscribers)s, %(likes)s, %(comments_count)s,
                    %(shares)s, %(hype_points)s, %(engagement_rate)s, %(sub_conversion_rate)s, %(engaged_view_rate)s,
                    %(views_vs_channel_avg_pct)s, %(retention_vs_channel_avg)s, %(period_start)s, %(period_end)s
                )
                ON CONFLICT (video_id) DO UPDATE SET
                    views = EXCLUDED.views,
                    retention_pct = EXCLUDED.retention_pct,
                    fetched_at = CURRENT_TIMESTAMP;
            """, {
                "video_id": video_id,
                "views": p.get("views", 0),
                "engaged_views": p.get("engaged_views", p.get("views", 0)),
                "unique_viewers": p.get("unique_viewers", 0),
                "watch_time_hours": p.get("watch_time_hours", 0.0),
                "avg_view_duration_seconds": p.get("avg_view_duration_seconds", 0.0),
                "retention_pct": p.get("retention_pct", 0.0),
                "completion_pct": p.get("completion_pct", 0.0),
                "swipe_away_pct": p.get("swipe_away_pct", 0.0),
                "subscribers_gained": p.get("subscribers_gained", 0),
                "subscribers_lost": p.get("subscribers_lost", 0),
                "net_subscribers": p.get("net_subscribers", p.get("subscribers_gained", 0) - p.get("subscribers_lost", 0)),
                "likes": p.get("likes", 0),
                "comments_count": p.get("comments_count", 0),
                "shares": p.get("shares", 0),
                "hype_points": p.get("hype_points", 0),
                "engagement_rate": p.get("engagement_rate", 0.0),
                "sub_conversion_rate": p.get("sub_conversion_rate", 0.0),
                "engaged_view_rate": p.get("engaged_view_rate", 1.0),
                "views_vs_channel_avg_pct": p.get("views_vs_channel_avg_pct"),
                "retention_vs_channel_avg": p.get("retention_vs_channel_avg"),
                "period_start": p.get("period_start"),
                "period_end": p.get("period_end")
            })

        # 3. TRAFFIC SOURCES
        ts_list = data.get("traffic_sources", [])
        if ts_list:
            cur.execute("DELETE FROM traffic_sources WHERE video_id = %s;", (video_id,))
            for ts in ts_list:
                cur.execute("""
                    INSERT INTO traffic_sources (
                        video_id, source_name, source_category, views, percentage,
                        avg_view_duration_seconds, retention_pct
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    video_id, ts.get("source_name"), ts.get("source_category"),
                    ts.get("views", 0), ts.get("percentage", 0.0),
                    ts.get("avg_view_duration_seconds"), ts.get("retention_pct")
                ))

        # 4. RETENTION CURVE
        rc_list = data.get("retention_curve", [])
        if rc_list:
            cur.execute("DELETE FROM retention_curve WHERE video_id = %s;", (video_id,))
            for rc in rc_list:
                cur.execute("""
                    INSERT INTO retention_curve (
                        video_id, timestamp_seconds, retention_pct, is_key_moment, moment_type, moment_note
                    ) VALUES (%s, %s, %s, %s, %s, %s);
                """, (
                    video_id, rc.get("timestamp_seconds", 0.0), rc.get("retention_pct", 0.0),
                    rc.get("is_key_moment", False), rc.get("moment_type"), rc.get("moment_note")
                ))

        # 5. SEARCH TERMS
        st_list = data.get("search_terms", [])
        if st_list:
            cur.execute("DELETE FROM search_terms WHERE video_id = %s;", (video_id,))
            for st in st_list:
                cur.execute("""
                    INSERT INTO search_terms (
                        video_id, search_term, views, percentage_of_search, percentage_of_total,
                        intent_category, relevance_score
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    video_id, st.get("search_term"), st.get("views", 0),
                    st.get("percentage_of_search", 0.0), st.get("percentage_of_total", 0.0),
                    st.get("intent_category", "related"), st.get("relevance_score", 3)
                ))

        # 6. AUDIENCE DEMOGRAPHICS
        ad = data.get("audience_device", {})
        if ad:
            cur.execute("""
                INSERT INTO audience_device (
                    video_id, mobile_pct, desktop_pct, tv_pct, tablet_pct,
                    mobile_views, desktop_views, tv_views, tablet_views, desktop_intent_proxy
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET mobile_pct = EXCLUDED.mobile_pct;
            """, (
                video_id, ad.get("mobile_pct", 0.0), ad.get("desktop_pct", 0.0),
                ad.get("tv_pct", 0.0), ad.get("tablet_pct", 0.0),
                ad.get("mobile_views", 0), ad.get("desktop_views", 0),
                ad.get("tv_views", 0), ad.get("tablet_views", 0),
                ad.get("desktop_intent_proxy", 0.0)
            ))

        ag = data.get("audience_gender", {})
        if ag:
            cur.execute("""
                INSERT INTO audience_gender (video_id, male_pct, female_pct, unknown_pct, has_data)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET male_pct = EXCLUDED.male_pct;
            """, (video_id, ag.get("male_pct"), ag.get("female_pct"), ag.get("unknown_pct"), ag.get("has_data", False)))

        aa = data.get("audience_age", {})
        if aa:
            cur.execute("""
                INSERT INTO audience_age (
                    video_id, age_13_17_pct, age_18_24_pct, age_25_34_pct, age_35_44_pct,
                    age_45_54_pct, age_55_64_pct, age_65_plus_pct, target_audience_pct, non_target_pct, has_data
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET age_18_24_pct = EXCLUDED.age_18_24_pct;
            """, (
                video_id, aa.get("age_13_17_pct", 0.0), aa.get("age_18_24_pct", 0.0),
                aa.get("age_25_34_pct", 0.0), aa.get("age_35_44_pct", 0.0),
                aa.get("age_45_54_pct", 0.0), aa.get("age_55_64_pct", 0.0),
                aa.get("age_65_plus_pct", 0.0), aa.get("target_audience_pct", 0.0),
                aa.get("non_target_pct", 0.0), aa.get("has_data", False)
            ))

        geo_list = data.get("audience_geography", [])
        if geo_list:
            cur.execute("DELETE FROM audience_geography WHERE video_id = %s;", (video_id,))
            for g in geo_list:
                cur.execute("""
                    INSERT INTO audience_geography (
                        video_id, country_code, country_name, views, percentage,
                        avg_view_duration_seconds, is_target_country
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    video_id, g.get("country_code", "IN"), g.get("country_name", "India"),
                    g.get("views", 0), g.get("percentage", 0.0),
                    g.get("avg_view_duration_seconds"), g.get("is_target_country", True)
                ))

        # 7. COMMENTS ANALYSIS
        ca = data.get("comments_analysis", {})
        if ca:
            cur.execute("""
                INSERT INTO comments_analysis (
                    video_id, total_comments, comments_per_1k_views, top_level_comments,
                    total_replies, max_thread_depth, avg_thread_depth, creator_replies,
                    creator_reply_rate, positive_sentiment_pct, negative_sentiment_pct,
                    neutral_sentiment_pct, query_comments, gratitude_comments,
                    gratitude_with_likes, spam_irrelevant_comments, unanswered_high_intent_queries
                ) VALUES (
                    %(video_id)s, %(total_comments)s, %(comments_per_1k_views)s, %(top_level_comments)s,
                    %(total_replies)s, %(max_thread_depth)s, %(avg_thread_depth)s, %(creator_replies)s,
                    %(creator_reply_rate)s, %(positive_sentiment_pct)s, %(negative_sentiment_pct)s,
                    %(neutral_sentiment_pct)s, %(query_comments)s, %(gratitude_comments)s,
                    %(gratitude_with_likes)s, %(spam_irrelevant_comments)s, %(unanswered_high_intent_queries)s
                )
                ON CONFLICT (video_id) DO UPDATE SET total_comments = EXCLUDED.total_comments;
            """, {
                "video_id": video_id,
                "total_comments": ca.get("total_comments", 0),
                "comments_per_1k_views": ca.get("comments_per_1k_views", 0.0),
                "top_level_comments": ca.get("top_level_comments", 0),
                "total_replies": ca.get("total_replies", 0),
                "max_thread_depth": ca.get("max_thread_depth", 0),
                "avg_thread_depth": ca.get("avg_thread_depth"),
                "creator_replies": ca.get("creator_replies", 0),
                "creator_reply_rate": ca.get("creator_reply_rate", 0.0),
                "positive_sentiment_pct": ca.get("positive_sentiment_pct", 0.0),
                "negative_sentiment_pct": ca.get("negative_sentiment_pct", 0.0),
                "neutral_sentiment_pct": ca.get("neutral_sentiment_pct", 0.0),
                "query_comments": ca.get("query_comments", 0),
                "gratitude_comments": ca.get("gratitude_comments", 0),
                "gratitude_with_likes": ca.get("gratitude_with_likes", 0),
                "spam_irrelevant_comments": ca.get("spam_irrelevant_comments", 0),
                "unanswered_high_intent_queries": ca.get("unanswered_high_intent_queries", 0)
            })

        # 8. CONTENT CLASSIFICATION (Auto-create parent content_type if missing)
        primary_type = s.get("content_type", "educational")
        secondary_type = s.get("content_subtype", "exam_tips")
        
        cur.execute("""
            INSERT INTO content_types (content_type, description, shelf_life_category, annual_remake_required, audience_match_score)
            VALUES (%s, %s, 'evergreen', false, 9)
            ON CONFLICT (content_type) DO NOTHING;
        """, (primary_type, f"Automated category for {primary_type}"))
        
        if secondary_type:
            cur.execute("""
                INSERT INTO content_types (content_type, description, shelf_life_category, annual_remake_required, audience_match_score)
                VALUES (%s, %s, 'evergreen', false, 9)
                ON CONFLICT (content_type) DO NOTHING;
            """, (secondary_type, f"Automated category for {secondary_type}"))
            
        cur.execute("""
            INSERT INTO short_content_classification (video_id, primary_type, secondary_type, confidence_score, classified_by)
            VALUES (%s, %s, %s, %s, 'automated_pipeline')
            ON CONFLICT (video_id) DO UPDATE SET primary_type = EXCLUDED.primary_type;
        """, (video_id, primary_type, secondary_type, 9))

        # 9. INDIVIDUAL COMMENTS
        ic_list = data.get("individual_comments", [])
        if ic_list:
            cur.execute("DELETE FROM individual_comments WHERE video_id = %s;", (video_id,))
            for ic in ic_list:
                cur.execute("""
                    INSERT INTO individual_comments (
                        video_id, comment_id, author_name, author_channel_id, is_creator,
                        is_pinned, is_hearted, text, text_clean, like_count, reply_count,
                        parent_comment_id, depth, published_at, updated_at, sentiment,
                        intent_category, query_subtype, is_actionable, has_contact_info
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
                """, (
                    video_id, ic.get("comment_id"), ic.get("author_name"), ic.get("author_channel_id"), ic.get("is_creator", False),
                    ic.get("is_pinned", False), ic.get("is_hearted", False), ic.get("text"), ic.get("text_clean"), ic.get("like_count", 0), ic.get("reply_count", 0),
                    ic.get("parent_comment_id"), ic.get("depth", 0), ic.get("published_at"), ic.get("updated_at"), ic.get("sentiment"),
                    ic.get("intent_category"), ic.get("query_subtype"), ic.get("is_actionable", False), ic.get("has_contact_info", False)
                ))

        # 10. SHORT TITLE TEMPLATE - defensive type coercion
        stt = data.get("short_title_template", {})
        if stt:
            cur.execute("""
                INSERT INTO short_title_template (video_id, template_id, title_length, word_count, hashtag_count,
                                                  emoji_count, char_before_pipe, char_after_pipe, keyword_density)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    template_id = EXCLUDED.template_id, title_length = EXCLUDED.title_length,
                    word_count = EXCLUDED.word_count, hashtag_count = EXCLUDED.hashtag_count,
                    emoji_count = EXCLUDED.emoji_count, char_before_pipe = EXCLUDED.char_before_pipe,
                    char_after_pipe = EXCLUDED.char_after_pipe, keyword_density = EXCLUDED.keyword_density,
                    fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id,
                int(stt.get("template_id", 0)) if stt.get("template_id") is not None else 0,
                int(stt.get("title_length", 0)) if stt.get("title_length") is not None else 0,
                int(stt.get("word_count", 0)) if stt.get("word_count") is not None else 0,
                int(stt.get("hashtag_count", 0)) if stt.get("hashtag_count") is not None else 0,
                int(stt.get("emoji_count", 0)) if stt.get("emoji_count") is not None else 0,
                int(stt.get("char_before_pipe", 0)) if stt.get("char_before_pipe") is not None else 0,
                int(stt.get("char_after_pipe", 0)) if stt.get("char_after_pipe") is not None else 0,
                Json(stt.get("keyword_density", {}))
            ))

        # 11. END SCREEN PERFORMANCE
        esp = data.get("end_screen_performance", {})
        if esp:
            cur.execute("""
                INSERT INTO end_screen_performance (video_id, has_end_screen, element_type, element_video_id,
                                                    impressions, clicks, channel_avg_ctr, vs_channel_avg_pct)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    has_end_screen = EXCLUDED.has_end_screen, element_type = EXCLUDED.element_type,
                    element_video_id = EXCLUDED.element_video_id, impressions = EXCLUDED.impressions,
                    clicks = EXCLUDED.clicks, channel_avg_ctr = EXCLUDED.channel_avg_ctr,
                    vs_channel_avg_pct = EXCLUDED.vs_channel_avg_pct, fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id, esp.get("has_end_screen", False), esp.get("element_type"), esp.get("element_video_id"),
                esp.get("impressions", 0), esp.get("clicks", 0), esp.get("channel_avg_ctr"), esp.get("vs_channel_avg_pct")
            ))

        # 12. REMIX METRICS
        rm = data.get("remix_metrics", {})
        if rm:
            cur.execute("""
                INSERT INTO remix_metrics (video_id, remix_count, remix_views, top_remix_video_id, top_remix_views)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    remix_count = EXCLUDED.remix_count, remix_views = EXCLUDED.remix_views,
                    top_remix_video_id = EXCLUDED.top_remix_video_id, top_remix_views = EXCLUDED.top_remix_views,
                    fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id, rm.get("remix_count", 0), rm.get("remix_views", 0), rm.get("top_remix_video_id"), rm.get("top_remix_views", 0)
            ))

        # 13. AUDIENCE SUBSCRIBER STATUS
        ass = data.get("audience_subscriber_status", {})
        if ass:
            cur.execute("""
                INSERT INTO audience_subscriber_status (video_id, subscribed_pct, not_subscribed_pct,
                                                        subscribed_views, not_subscribed_views,
                                                        sub_viewer_retention_pct, non_sub_viewer_retention_pct)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    subscribed_pct = EXCLUDED.subscribed_pct, not_subscribed_pct = EXCLUDED.not_subscribed_pct,
                    subscribed_views = EXCLUDED.subscribed_views, not_subscribed_views = EXCLUDED.not_subscribed_views,
                    sub_viewer_retention_pct = EXCLUDED.sub_viewer_retention_pct,
                    non_sub_viewer_retention_pct = EXCLUDED.non_sub_viewer_retention_pct,
                    fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id, ass.get("subscribed_pct"), ass.get("not_subscribed_pct"),
                ass.get("subscribed_views"), ass.get("not_subscribed_views"),
                ass.get("sub_viewer_retention_pct"), ass.get("non_sub_viewer_retention_pct")
            ))

        # 14. AUDIENCE SUBTITLES
        asub = data.get("audience_subtitles", {})
        if asub:
            cur.execute("""
                INSERT INTO audience_subtitles (video_id, none_pct, hindi_pct, english_pct, other_pct, has_cc_data)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    none_pct = EXCLUDED.none_pct, hindi_pct = EXCLUDED.hindi_pct,
                    english_pct = EXCLUDED.english_pct, other_pct = EXCLUDED.other_pct,
                    has_cc_data = EXCLUDED.has_cc_data, fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id, asub.get("none_pct"), asub.get("hindi_pct"), asub.get("english_pct"),
                asub.get("other_pct"), asub.get("has_cc_data")
            ))

        # 15. REALTIME METRICS
        rt = data.get("realtime_metrics", {})
        if rt:
            cur.execute("""
                INSERT INTO realtime_metrics (video_id, views_48h, period_start, period_end, velocity_views_per_hour)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (video_id) DO UPDATE SET
                    views_48h = EXCLUDED.views_48h, period_start = EXCLUDED.period_start,
                    period_end = EXCLUDED.period_end, velocity_views_per_hour = EXCLUDED.velocity_views_per_hour,
                    fetched_at = CURRENT_TIMESTAMP;
            """, (
                video_id, rt.get("views_48h"), rt.get("period_start"), rt.get("period_end"), rt.get("velocity_views_per_hour")
            ))

        # 16. EXTERNAL SOURCES
        es_list = data.get("external_sources", [])
        if es_list:
            cur.execute("DELETE FROM external_sources WHERE video_id = %s;", (video_id,))
            for es in es_list:
                cur.execute("""
                    INSERT INTO external_sources (video_id, source_domain, source_type, views, percentage)
                    VALUES (%s, %s, %s, %s, %s);
                """, (
                    video_id, es.get("source_domain"), es.get("source_type"), es.get("views", 0), es.get("percentage", 0.0)
                ))

        # 17. MEMORY UPDATES
        mu = data.get("memory_update", {})
        if mu:
            cur.execute("""
                INSERT INTO memory_updates (video_id, update_type, title, payload, source_analysis, priority, applied_to_pipeline)
                VALUES (%s, %s, %s, %s, %s, %s, %s);
            """, (
                video_id, mu.get("update_type"), mu.get("title"), Json(mu.get("payload", {})),
                mu.get("source_analysis"), mu.get("priority", 3), mu.get("applied_to_pipeline", False)
            ))

        # 18. ANALYSIS LOG
        al_list = data.get("analysis_log", [])
        if al_list:
            for al in al_list:
                cur.execute("""
                    INSERT INTO analysis_log (session_id, video_id, tab_analyzed, status, error_message,
                                              data_completeness, duration_seconds)
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    al.get("session_id"), video_id, al.get("tab_analyzed"), al.get("status"),
                    al.get("error_message"), al.get("data_completeness"), al.get("duration_seconds")
                ))

        conn.commit()
        print(f"SUCCESS: Ingested Short [{video_id}] into all tables in a single transaction!")

    except Exception as e:
        conn.rollback()
        print(f"ERROR: Ingestion failed for [{video_id}]: {e}")
        raise e
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], "r", encoding="utf-8") as f:
            payload = json.load(f)
        ingest_short(payload)
    else:
        print("Usage: python ingest_short_forensic.py <payload.json>")
