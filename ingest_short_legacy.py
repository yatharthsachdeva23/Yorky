#!/usr/bin/env python3
"""
Ingest a single Short's forensic analysis into all 28 PostgreSQL tables
in one atomic transaction. Usage: python ingest_short.py <payload.json>
"""

import json
import sys
import psycopg2
from psycopg2.extras import execute_values, Json
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'database': 'youtube_shorts'
}

INSERT_ORDER = [
    # parent tables first (no FK dependencies)
    ('channels', """
        INSERT INTO channels (channel_id, channel_name, custom_handle, subscriber_count, created_at,
                              niche_primary, target_audience, brand_colors, tagline)
        VALUES (%(channel_id)s, %(channel_name)s, %(custom_handle)s, %(subscriber_count)s, %(created_at)s,
                %(niche_primary)s, %(target_audience)s, %(brand_colors)s, %(tagline)s)
        ON CONFLICT (channel_id) DO UPDATE SET
            channel_name = EXCLUDED.channel_name,
            custom_handle = EXCLUDED.custom_handle,
            subscriber_count = EXCLUDED.subscriber_count,
            niche_primary = EXCLUDED.niche_primary,
            target_audience = EXCLUDED.target_audience,
            brand_colors = EXCLUDED.brand_colors,
            tagline = EXCLUDED.tagline,
            updated_at = CURRENT_TIMESTAMP
    """),
    ('content_types', """
        INSERT INTO content_types (content_type, description, typical_duration_range, typical_retention_range,
                                   typical_search_pct_range, shelf_life_category, annual_remake_required,
                                   audience_match_score, examples)
        VALUES (%(content_type)s, %(description)s, %(typical_duration_range)s, %(typical_retention_range)s,
                %(typical_search_pct_range)s, %(shelf_life_category)s, %(annual_remake_required)s,
                %(audience_match_score)s, %(examples)s)
        ON CONFLICT (content_type) DO UPDATE SET
            description = EXCLUDED.description,
            typical_duration_range = EXCLUDED.typical_duration_range,
            typical_retention_range = EXCLUDED.typical_retention_range,
            typical_search_pct_range = EXCLUDED.typical_search_pct_range,
            shelf_life_category = EXCLUDED.shelf_life_category,
            annual_remake_required = EXCLUDED.annual_remake_required,
            audience_match_score = EXCLUDED.audience_match_score,
            examples = EXCLUDED.examples
    """),
    ('title_templates', """
        INSERT INTO title_templates (template_name, template_pattern, emoji_position, has_pipe_separator,
                                     has_how_to, has_question_mark, has_double_exclamation)
        VALUES (%(template_name)s, %(template_pattern)s, %(emoji_position)s, %(has_pipe_separator)s,
                %(has_how_to)s, %(has_question_mark)s, %(has_double_exclamation)s)
        ON CONFLICT DO NOTHING
        RETURNING id
    """),
    
    # master shorts table
    ('shorts', """
        INSERT INTO shorts (short_id, video_id, title, title_raw, description, description_length,
                            description_has_cta, description_has_links, published_at, duration_seconds,
                            duration_bucket, visibility, playlist_id, playlist_title, end_screen_type,
                            end_screen_video_id, has_subtitles, subtitle_languages, related_video_id,
                            tags_title, tags_description, emoji_in_title, emoji_list, red_alert_emoji,
                            content_year, content_type, content_subtype, thumbnail_style, hook_type,
                            value_type, language, cta_placement)
        VALUES (%(short_id)s, %(video_id)s, %(title)s, %(title_raw)s, %(description)s, %(description_length)s,
                %(description_has_cta)s, %(description_has_links)s, %(published_at)s, %(duration_seconds)s,
                %(duration_bucket)s, %(visibility)s, %(playlist_id)s, %(playlist_title)s, %(end_screen_type)s,
                %(end_screen_video_id)s, %(has_subtitles)s, %(subtitle_languages)s, %(related_video_id)s,
                %(tags_title)s, %(tags_description)s, %(emoji_in_title)s, %(emoji_list)s, %(red_alert_emoji)s,
                %(content_year)s, %(content_type)s, %(content_subtype)s, %(thumbnail_style)s, %(hook_type)s,
                %(value_type)s, %(language)s, %(cta_placement)s)
        ON CONFLICT (short_id) DO UPDATE SET
            video_id = EXCLUDED.video_id, title = EXCLUDED.title, title_raw = EXCLUDED.title_raw,
            description = EXCLUDED.description, description_length = EXCLUDED.description_length,
            description_has_cta = EXCLUDED.description_has_cta, description_has_links = EXCLUDED.description_has_links,
            published_at = EXCLUDED.published_at, duration_seconds = EXCLUDED.duration_seconds,
            duration_bucket = EXCLUDED.duration_bucket, visibility = EXCLUDED.visibility,
            playlist_id = EXCLUDED.playlist_id, playlist_title = EXCLUDED.playlist_title,
            end_screen_type = EXCLUDED.end_screen_type, end_screen_video_id = EXCLUDED.end_screen_video_id,
            has_subtitles = EXCLUDED.has_subtitles, subtitle_languages = EXCLUDED.subtitle_languages,
            related_video_id = EXCLUDED.related_video_id, tags_title = EXCLUDED.tags_title,
            tags_description = EXCLUDED.tags_description, emoji_in_title = EXCLUDED.emoji_in_title,
            emoji_list = EXCLUDED.emoji_list, red_alert_emoji = EXCLUDED.red_alert_emoji,
            content_year = EXCLUDED.content_year, content_type = EXCLUDED.content_type,
            content_subtype = EXCLUDED.content_subtype, thumbnail_style = EXCLUDED.thumbnail_style,
            hook_type = EXCLUDED.hook_type, value_type = EXCLUDED.value_type, language = EXCLUDED.language,
            cta_placement = EXCLUDED.cta_placement, updated_at = CURRENT_TIMESTAMP
    """),
    
    # child tables (FK to shorts.video_id)
    ('performance_metrics', """
        INSERT INTO performance_metrics (video_id, views, engaged_views, unique_viewers, watch_time_hours,
                                         avg_view_duration_seconds, retention_pct, completion_pct, swipe_away_pct,
                                         subscribers_gained, subscribers_lost, net_subscribers, likes,
                                         comments_count, shares, hype_points, engagement_rate,
                                         sub_conversion_rate, engaged_view_rate, views_vs_channel_avg_pct,
                                         retention_vs_channel_avg, period_start, period_end)
        VALUES (%(video_id)s, %(views)s, %(engaged_views)s, %(unique_viewers)s, %(watch_time_hours)s,
                %(avg_view_duration_seconds)s, %(retention_pct)s, %(completion_pct)s, %(swipe_away_pct)s,
                %(subscribers_gained)s, %(subscribers_lost)s, %(net_subscribers)s, %(likes)s,
                %(comments_count)s, %(shares)s, %(hype_points)s, %(engagement_rate)s,
                %(sub_conversion_rate)s, %(engaged_view_rate)s, %(views_vs_channel_avg_pct)s,
                %(retention_vs_channel_avg)s, %(period_start)s, %(period_end)s)
        ON CONFLICT (video_id) DO UPDATE SET
            views = EXCLUDED.views, engaged_views = EXCLUDED.engaged_views, unique_viewers = EXCLUDED.unique_viewers,
            watch_time_hours = EXCLUDED.watch_time_hours, avg_view_duration_seconds = EXCLUDED.avg_view_duration_seconds,
            retention_pct = EXCLUDED.retention_pct, completion_pct = EXCLUDED.completion_pct,
            swipe_away_pct = EXCLUDED.swipe_away_pct, subscribers_gained = EXCLUDED.subscribers_gained,
            subscribers_lost = EXCLUDED.subscribers_lost, net_subscribers = EXCLUDED.net_subscribers,
            likes = EXCLUDED.likes, comments_count = EXCLUDED.comments_count, shares = EXCLUDED.shares,
            hype_points = EXCLUDED.hype_points, engagement_rate = EXCLUDED.engagement_rate,
            sub_conversion_rate = EXCLUDED.sub_conversion_rate, engaged_view_rate = EXCLUDED.engaged_view_rate,
            views_vs_channel_avg_pct = EXCLUDED.views_vs_channel_avg_pct,
            retention_vs_channel_avg = EXCLUDED.retention_vs_channel_avg,
            period_start = EXCLUDED.period_start, period_end = EXCLUDED.period_end,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('traffic_sources', """
        INSERT INTO traffic_sources (video_id, source_name, source_category, views, percentage,
                                     avg_view_duration_seconds, retention_pct)
        VALUES (%(video_id)s, %(source_name)s, %(source_category)s, %(views)s, %(percentage)s,
                %(avg_view_duration_seconds)s, %(retention_pct)s)
        ON CONFLICT (video_id, source_name) DO UPDATE SET
            source_category = EXCLUDED.source_category, views = EXCLUDED.views, percentage = EXCLUDED.percentage,
            avg_view_duration_seconds = EXCLUDED.avg_view_duration_seconds, retention_pct = EXCLUDED.retention_pct,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('retention_curve', """
        INSERT INTO retention_curve (video_id, timestamp_seconds, retention_pct, is_key_moment,
                                     moment_type, moment_note)
        VALUES (%(video_id)s, %(timestamp_seconds)s, %(retention_pct)s, %(is_key_moment)s,
                %(moment_type)s, %(moment_note)s)
        ON CONFLICT (video_id, timestamp_seconds) DO UPDATE SET
            retention_pct = EXCLUDED.retention_pct, is_key_moment = EXCLUDED.is_key_moment,
            moment_type = EXCLUDED.moment_type, moment_note = EXCLUDED.moment_note
    """),
    ('audience_device', """
        INSERT INTO audience_device (video_id, mobile_pct, desktop_pct, tv_pct, tablet_pct,
                                     mobile_views, desktop_views, tv_views, tablet_views,
                                     desktop_intent_proxy)
        VALUES (%(video_id)s, %(mobile_pct)s, %(desktop_pct)s, %(tv_pct)s, %(tablet_pct)s,
                %(mobile_views)s, %(desktop_views)s, %(tv_views)s, %(tablet_views)s,
                %(desktop_intent_proxy)s)
        ON CONFLICT (video_id) DO UPDATE SET
            mobile_pct = EXCLUDED.mobile_pct, desktop_pct = EXCLUDED.desktop_pct,
            tv_pct = EXCLUDED.tv_pct, tablet_pct = EXCLUDED.tablet_pct,
            mobile_views = EXCLUDED.mobile_views, desktop_views = EXCLUDED.desktop_views,
            tv_views = EXCLUDED.tv_views, tablet_views = EXCLUDED.tablet_views,
            desktop_intent_proxy = EXCLUDED.desktop_intent_proxy, fetched_at = CURRENT_TIMESTAMP
    """),
    ('audience_gender', """
        INSERT INTO audience_gender (video_id, male_pct, female_pct, unknown_pct, has_data)
        VALUES (%(video_id)s, %(male_pct)s, %(female_pct)s, %(unknown_pct)s, %(has_data)s)
        ON CONFLICT (video_id) DO UPDATE SET
            male_pct = EXCLUDED.male_pct, female_pct = EXCLUDED.female_pct,
            unknown_pct = EXCLUDED.unknown_pct, has_data = EXCLUDED.has_data,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('audience_age', """
        INSERT INTO audience_age (video_id, age_13_17_pct, age_18_24_pct, age_25_34_pct, age_35_44_pct,
                                  age_45_54_pct, age_55_64_pct, age_65_plus_pct, target_audience_pct,
                                  non_target_pct, has_data)
        VALUES (%(video_id)s, %(age_13_17_pct)s, %(age_18_24_pct)s, %(age_25_34_pct)s, %(age_35_44_pct)s,
                %(age_45_54_pct)s, %(age_55_64_pct)s, %(age_65_plus_pct)s, %(target_audience_pct)s,
                %(non_target_pct)s, %(has_data)s)
        ON CONFLICT (video_id) DO UPDATE SET
            age_13_17_pct = EXCLUDED.age_13_17_pct, age_18_24_pct = EXCLUDED.age_18_24_pct,
            age_25_34_pct = EXCLUDED.age_25_34_pct, age_35_44_pct = EXCLUDED.age_35_44_pct,
            age_45_54_pct = EXCLUDED.age_45_54_pct, age_55_64_pct = EXCLUDED.age_55_64_pct,
            age_65_plus_pct = EXCLUDED.age_65_plus_pct, target_audience_pct = EXCLUDED.target_audience_pct,
            non_target_pct = EXCLUDED.non_target_pct, has_data = EXCLUDED.has_data,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('audience_geography', """
        INSERT INTO audience_geography (video_id, country_code, country_name, views, percentage,
                                        avg_view_duration_seconds, is_target_country)
        VALUES (%(video_id)s, %(country_code)s, %(country_name)s, %(views)s, %(percentage)s,
                %(avg_view_duration_seconds)s, %(is_target_country)s)
        ON CONFLICT (video_id, country_code) DO UPDATE SET
            country_name = EXCLUDED.country_name, views = EXCLUDED.views, percentage = EXCLUDED.percentage,
            avg_view_duration_seconds = EXCLUDED.avg_view_duration_seconds,
            is_target_country = EXCLUDED.is_target_country, fetched_at = CURRENT_TIMESTAMP
    """),
    ('comments_analysis', """
        INSERT INTO comments_analysis (video_id, total_comments, comments_per_1k_views, top_level_comments,
                                       total_replies, max_thread_depth, avg_thread_depth, creator_replies,
                                       creator_reply_rate, pinned_comment_id, pinned_comment_text, hearted_comments,
                                       positive_sentiment_pct, negative_sentiment_pct, neutral_sentiment_pct,
                                       query_comments, gratitude_comments, gratitude_with_likes,
                                       spam_irrelevant_comments, query_categories, unanswered_high_intent_queries)
        VALUES (%(video_id)s, %(total_comments)s, %(comments_per_1k_views)s, %(top_level_comments)s,
                %(total_replies)s, %(max_thread_depth)s, %(avg_thread_depth)s, %(creator_replies)s,
                %(creator_reply_rate)s, %(pinned_comment_id)s, %(pinned_comment_text)s, %(hearted_comments)s,
                %(positive_sentiment_pct)s, %(negative_sentiment_pct)s, %(neutral_sentiment_pct)s,
                %(query_comments)s, %(gratitude_comments)s, %(gratitude_with_likes)s,
                %(spam_irrelevant_comments)s, %(query_categories)s, %(unanswered_high_intent_queries)s)
        ON CONFLICT (video_id) DO UPDATE SET
            total_comments = EXCLUDED.total_comments, comments_per_1k_views = EXCLUDED.comments_per_1k_views,
            top_level_comments = EXCLUDED.top_level_comments, total_replies = EXCLUDED.total_replies,
            max_thread_depth = EXCLUDED.max_thread_depth, avg_thread_depth = EXCLUDED.avg_thread_depth,
            creator_replies = EXCLUDED.creator_replies, creator_reply_rate = EXCLUDED.creator_reply_rate,
            pinned_comment_id = EXCLUDED.pinned_comment_id, pinned_comment_text = EXCLUDED.pinned_comment_text,
            hearted_comments = EXCLUDED.hearted_comments, positive_sentiment_pct = EXCLUDED.positive_sentiment_pct,
            negative_sentiment_pct = EXCLUDED.negative_sentiment_pct, neutral_sentiment_pct = EXCLUDED.neutral_sentiment_pct,
            query_comments = EXCLUDED.query_comments, gratitude_comments = EXCLUDED.gratitude_comments,
            gratitude_with_likes = EXCLUDED.gratitude_with_likes, spam_irrelevant_comments = EXCLUDED.spam_irrelevant_comments,
            query_categories = EXCLUDED.query_categories, unanswered_high_intent_queries = EXCLUDED.unanswered_high_intent_queries,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('short_content_classification', """
        INSERT INTO short_content_classification (video_id, primary_type, secondary_type, confidence_score, classified_by)
        VALUES (%(video_id)s, %(primary_type)s, %(secondary_type)s, %(confidence_score)s, %(classified_by)s)
        ON CONFLICT (video_id) DO UPDATE SET
            primary_type = EXCLUDED.primary_type, secondary_type = EXCLUDED.secondary_type,
            confidence_score = EXCLUDED.confidence_score, classified_by = EXCLUDED.classified_by,
            classified_at = CURRENT_TIMESTAMP
    """),
    ('short_title_template', """
        INSERT INTO short_title_template (video_id, template_id, title_length, word_count, hashtag_count,
                                          emoji_count, char_before_pipe, char_after_pipe, keyword_density)
        VALUES (%(video_id)s, %(template_id)s, %(title_length)s, %(word_count)s, %(hashtag_count)s,
                %(emoji_count)s, %(char_before_pipe)s, %(char_after_pipe)s, %(keyword_density)s)
        ON CONFLICT (video_id) DO UPDATE SET
            template_id = EXCLUDED.template_id, title_length = EXCLUDED.title_length,
            word_count = EXCLUDED.word_count, hashtag_count = EXCLUDED.hashtag_count,
            emoji_count = EXCLUDED.emoji_count, char_before_pipe = EXCLUDED.char_before_pipe,
            char_after_pipe = EXCLUDED.char_after_pipe, keyword_density = EXCLUDED.keyword_density,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('hidden_patterns', """
        INSERT INTO hidden_patterns (pattern_name, pattern_category, description, evidence_summary,
                                     supporting_video_ids, contradicting_video_ids, confidence,
                                     actionable_insight, pipeline_implication)
        VALUES (%(pattern_name)s, %(pattern_category)s, %(description)s, %(evidence_summary)s,
                %(supporting_video_ids)s, %(contradicting_video_ids)s, %(confidence)s,
                %(actionable_insight)s, %(pipeline_implication)s)
        ON CONFLICT (pattern_name) DO UPDATE SET
            pattern_category = EXCLUDED.pattern_category, description = EXCLUDED.description,
            evidence_summary = EXCLUDED.evidence_summary, supporting_video_ids = EXCLUDED.supporting_video_ids,
            contradicting_video_ids = EXCLUDED.contradicting_video_ids, confidence = EXCLUDED.confidence,
            actionable_insight = EXCLUDED.actionable_insight, pipeline_implication = EXCLUDED.pipeline_implication,
            validated_at = CURRENT_TIMESTAMP, is_active = TRUE
    """),
    ('comparison_clusters', """
        INSERT INTO comparison_clusters (cluster_name, cluster_type, definition, video_ids,
                                         aggregate_metrics, top_performer_id, bottom_performer_id,
                                         key_differentiators)
        VALUES (%(cluster_name)s, %(cluster_type)s, %(definition)s, %(video_ids)s,
                %(aggregate_metrics)s, %(top_performer_id)s, %(bottom_performer_id)s,
                %(key_differentiators)s)
        ON CONFLICT (cluster_name) DO UPDATE SET
            cluster_type = EXCLUDED.cluster_type, definition = EXCLUDED.definition,
            video_ids = EXCLUDED.video_ids, aggregate_metrics = EXCLUDED.aggregate_metrics,
            top_performer_id = EXCLUDED.top_performer_id, bottom_performer_id = EXCLUDED.bottom_performer_id,
            key_differentiators = EXCLUDED.key_differentiators
    """),
    ('analysis_sessions', """
        INSERT INTO analysis_sessions (id, session_id, started_at, completed_at, videos_analyzed,
                                       analyzer_version, notes, status)
        VALUES (%(id)s, %(session_id)s, %(started_at)s, %(completed_at)s, %(videos_analyzed)s,
                %(analyzer_version)s, %(notes)s, %(status)s)
        ON CONFLICT (id) DO UPDATE SET
            session_id = EXCLUDED.session_id,
            completed_at = EXCLUDED.completed_at, videos_analyzed = EXCLUDED.videos_analyzed,
            analyzer_version = EXCLUDED.analyzer_version, notes = EXCLUDED.notes, status = EXCLUDED.status
    """),
    ('memory_updates', """
        INSERT INTO memory_updates (video_id, update_type, title, payload, source_analysis, priority, applied_to_pipeline)
        VALUES (%(video_id)s, %(update_type)s, %(title)s, %(payload)s, %(source_analysis)s, %(priority)s, %(applied_to_pipeline)s)
    """),
    ('search_terms', """
        INSERT INTO search_terms (video_id, search_term, views, percentage_of_search, percentage_of_total,
                                  intent_category, relevance_score)
        VALUES (%(video_id)s, %(search_term)s, %(views)s, %(percentage_of_search)s, %(percentage_of_total)s,
                %(intent_category)s, %(relevance_score)s)
        ON CONFLICT DO NOTHING
    """),
    ('external_sources', """
        INSERT INTO external_sources (video_id, source_domain, source_type, views, percentage)
        VALUES (%(video_id)s, %(source_domain)s, %(source_type)s, %(views)s, %(percentage)s)
        ON CONFLICT DO NOTHING
    """),
    ('end_screen_performance', """
        INSERT INTO end_screen_performance (video_id, has_end_screen, element_type, element_video_id,
                                            impressions, clicks, channel_avg_ctr, vs_channel_avg_pct)
        VALUES (%(video_id)s, %(has_end_screen)s, %(element_type)s, %(element_video_id)s,
                %(impressions)s, %(clicks)s, %(channel_avg_ctr)s, %(vs_channel_avg_pct)s)
        ON CONFLICT (video_id) DO UPDATE SET
            has_end_screen = EXCLUDED.has_end_screen, element_type = EXCLUDED.element_type,
            element_video_id = EXCLUDED.element_video_id, impressions = EXCLUDED.impressions,
            clicks = EXCLUDED.clicks, channel_avg_ctr = EXCLUDED.channel_avg_ctr,
            vs_channel_avg_pct = EXCLUDED.vs_channel_avg_pct, fetched_at = CURRENT_TIMESTAMP
    """),
    ('remix_metrics', """
        INSERT INTO remix_metrics (video_id, remix_count, remix_views, top_remix_video_id, top_remix_views)
        VALUES (%(video_id)s, %(remix_count)s, %(remix_views)s, %(top_remix_video_id)s, %(top_remix_views)s)
        ON CONFLICT (video_id) DO UPDATE SET
            remix_count = EXCLUDED.remix_count, remix_views = EXCLUDED.remix_views,
            top_remix_video_id = EXCLUDED.top_remix_video_id, top_remix_views = EXCLUDED.top_remix_views,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('audience_subscriber_status', """
        INSERT INTO audience_subscriber_status (video_id, subscribed_pct, not_subscribed_pct,
                                                subscribed_views, not_subscribed_views,
                                                sub_viewer_retention_pct, non_sub_viewer_retention_pct)
        VALUES (%(video_id)s, %(subscribed_pct)s, %(not_subscribed_pct)s,
                %(subscribed_views)s, %(not_subscribed_views)s,
                %(sub_viewer_retention_pct)s, %(non_sub_viewer_retention_pct)s)
        ON CONFLICT (video_id) DO UPDATE SET
            subscribed_pct = EXCLUDED.subscribed_pct, not_subscribed_pct = EXCLUDED.not_subscribed_pct,
            subscribed_views = EXCLUDED.subscribed_views, not_subscribed_views = EXCLUDED.not_subscribed_views,
            sub_viewer_retention_pct = EXCLUDED.sub_viewer_retention_pct,
            non_sub_viewer_retention_pct = EXCLUDED.non_sub_viewer_retention_pct,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('audience_subtitles', """
        INSERT INTO audience_subtitles (video_id, none_pct, hindi_pct, english_pct, other_pct, has_cc_data)
        VALUES (%(video_id)s, %(none_pct)s, %(hindi_pct)s, %(english_pct)s, %(other_pct)s, %(has_cc_data)s)
        ON CONFLICT (video_id) DO UPDATE SET
            none_pct = EXCLUDED.none_pct, hindi_pct = EXCLUDED.hindi_pct,
            english_pct = EXCLUDED.english_pct, other_pct = EXCLUDED.other_pct,
            has_cc_data = EXCLUDED.has_cc_data, fetched_at = CURRENT_TIMESTAMP
    """),
    ('realtime_metrics', """
        INSERT INTO realtime_metrics (video_id, views_48h, period_start, period_end, velocity_views_per_hour)
        VALUES (%(video_id)s, %(views_48h)s, %(period_start)s, %(period_end)s, %(velocity_views_per_hour)s)
        ON CONFLICT (video_id) DO UPDATE SET
            views_48h = EXCLUDED.views_48h, period_start = EXCLUDED.period_start,
            period_end = EXCLUDED.period_end, velocity_views_per_hour = EXCLUDED.velocity_views_per_hour,
            fetched_at = CURRENT_TIMESTAMP
    """),
    ('analysis_log', """
        INSERT INTO analysis_log (session_id, video_id, tab_analyzed, status, error_message,
                                  data_completeness, duration_seconds)
        VALUES (%(session_id)s, %(video_id)s, %(tab_analyzed)s, %(status)s, %(error_message)s,
                %(data_completeness)s, %(duration_seconds)s)
    """),
    ('short_analysis', """
        INSERT INTO short_analysis (short_id, video_id, views, engaged_views, unique_viewers, watch_time_hours,
                                    avg_view_duration_seconds, retention_percent, swiped_away_percent, subscribers_gained,
                                    likes, comments, shares, hype_points, shorts_feed_pct, youtube_search_pct,
                                    browse_features_pct, channel_pages_pct, suggested_videos_pct, external_pct,
                                    notifications_pct, other_youtube_features_pct, others_pct,
                                    search_terms_json, retention_curve_json, key_moments_json,
                                    end_screen_ctr, end_screen_ctr_channel_avg, remixes, bell_notification_ctr,
                                    device_mobile_pct, device_computer_pct, device_tablet_pct, device_tv_pct,
                                    gender_male_pct, gender_female_pct, age_13_17_pct, age_18_24_pct, age_25_34_pct,
                                    age_35_44_pct, age_45_54_pct, age_55_64_pct, age_65_plus_pct,
                                    geography_india_pct, geography_other_json,
                                    subscriber_status_subscribed_pct, subscriber_status_not_subscribed_pct,
                                    new_viewers_pct, returning_viewers_pct,
                                    subtitles_none_pct, subtitles_hindi_pct, subtitles_english_auto_pct,
                                    description_text, description_length, tags_title, tags_description,
                                    hashtag_count, playlist_name, end_screen, captions, related_video_title,
                                    related_video_type, hook_type, clip_breakdown_json, language_mix,
                                    content_category, value_delivery, cta_type, academic_teaching,
                                    total_comments, top_comments_json, sentiment_clusters_json,
                                    topic_demands_json, quality_signals_json, creator_reply_rate,
                                    gratitude_signals, trust_proxy, content_type,
                                    what_works_json, what_fails_json, root_cause, hidden_pattern,
                                    actionable_fix, comparison_cluster_json, memory_update_json)
        VALUES (%(short_id)s, %(video_id)s, %(views)s, %(engaged_views)s, %(unique_viewers)s, %(watch_time_hours)s,
                %(avg_view_duration_seconds)s, %(retention_percent)s, %(swiped_away_percent)s, %(subscribers_gained)s,
                %(likes)s, %(comments)s, %(shares)s, %(hype_points)s, %(shorts_feed_pct)s, %(youtube_search_pct)s,
                %(browse_features_pct)s, %(channel_pages_pct)s, %(suggested_videos_pct)s, %(external_pct)s,
                %(notifications_pct)s, %(other_youtube_features_pct)s, %(others_pct)s,
                %(search_terms_json)s, %(retention_curve_json)s, %(key_moments_json)s,
                %(end_screen_ctr)s, %(end_screen_ctr_channel_avg)s, %(remixes)s, %(bell_notification_ctr)s,
                %(device_mobile_pct)s, %(device_computer_pct)s, %(device_tablet_pct)s, %(device_tv_pct)s,
                %(gender_male_pct)s, %(gender_female_pct)s, %(age_13_17_pct)s, %(age_18_24_pct)s, %(age_25_34_pct)s,
                %(age_35_44_pct)s, %(age_45_54_pct)s, %(age_55_64_pct)s, %(age_65_plus_pct)s,
                %(geography_india_pct)s, %(geography_other_json)s,
                %(subscriber_status_subscribed_pct)s, %(subscriber_status_not_subscribed_pct)s,
                %(new_viewers_pct)s, %(returning_viewers_pct)s,
                %(subtitles_none_pct)s, %(subtitles_hindi_pct)s, %(subtitles_english_auto_pct)s,
                %(description_text)s, %(description_length)s, %(tags_title)s, %(tags_description)s,
                %(hashtag_count)s, %(playlist_name)s, %(end_screen)s, %(captions)s, %(related_video_title)s,
                %(related_video_type)s, %(hook_type)s, %(clip_breakdown_json)s, %(language_mix)s,
                %(content_category)s, %(value_delivery)s, %(cta_type)s, %(academic_teaching)s,
                %(total_comments)s, %(top_comments_json)s, %(sentiment_clusters_json)s,
                %(topic_demands_json)s, %(quality_signals_json)s, %(creator_reply_rate)s,
                %(gratitude_signals)s, %(trust_proxy)s, %(content_type)s,
                %(what_works_json)s, %(what_fails_json)s, %(root_cause)s, %(hidden_pattern)s,
                %(actionable_fix)s, %(comparison_cluster_json)s, %(memory_update_json)s)
        ON CONFLICT (short_id) DO UPDATE SET
            video_id = EXCLUDED.video_id, views = EXCLUDED.views, engaged_views = EXCLUDED.engaged_views,
            unique_viewers = EXCLUDED.unique_viewers, watch_time_hours = EXCLUDED.watch_time_hours,
            avg_view_duration_seconds = EXCLUDED.avg_view_duration_seconds, retention_percent = EXCLUDED.retention_percent,
            swiped_away_percent = EXCLUDED.swiped_away_percent, subscribers_gained = EXCLUDED.subscribers_gained,
            likes = EXCLUDED.likes, comments = EXCLUDED.comments, shares = EXCLUDED.shares,
            hype_points = EXCLUDED.hype_points, shorts_feed_pct = EXCLUDED.shorts_feed_pct,
            youtube_search_pct = EXCLUDED.youtube_search_pct, browse_features_pct = EXCLUDED.browse_features_pct,
            channel_pages_pct = EXCLUDED.channel_pages_pct, suggested_videos_pct = EXCLUDED.suggested_videos_pct,
            external_pct = EXCLUDED.external_pct, notifications_pct = EXCLUDED.notifications_pct,
            other_youtube_features_pct = EXCLUDED.other_youtube_features_pct, others_pct = EXCLUDED.others_pct,
            search_terms_json = EXCLUDED.search_terms_json, retention_curve_json = EXCLUDED.retention_curve_json,
            key_moments_json = EXCLUDED.key_moments_json, end_screen_ctr = EXCLUDED.end_screen_ctr,
            end_screen_ctr_channel_avg = EXCLUDED.end_screen_ctr_channel_avg, remixes = EXCLUDED.remixes,
            bell_notification_ctr = EXCLUDED.bell_notification_ctr, device_mobile_pct = EXCLUDED.device_mobile_pct,
            device_computer_pct = EXCLUDED.device_computer_pct, device_tablet_pct = EXCLUDED.device_tablet_pct,
            device_tv_pct = EXCLUDED.device_tv_pct, gender_male_pct = EXCLUDED.gender_male_pct,
            gender_female_pct = EXCLUDED.gender_female_pct, age_13_17_pct = EXCLUDED.age_13_17_pct,
            age_18_24_pct = EXCLUDED.age_18_24_pct, age_25_34_pct = EXCLUDED.age_25_34_pct,
            age_35_44_pct = EXCLUDED.age_35_44_pct, age_45_54_pct = EXCLUDED.age_45_54_pct,
            age_55_64_pct = EXCLUDED.age_55_64_pct, age_65_plus_pct = EXCLUDED.age_65_plus_pct,
            geography_india_pct = EXCLUDED.geography_india_pct, geography_other_json = EXCLUDED.geography_other_json,
            subscriber_status_subscribed_pct = EXCLUDED.subscriber_status_subscribed_pct,
            subscriber_status_not_subscribed_pct = EXCLUDED.subscriber_status_not_subscribed_pct,
            new_viewers_pct = EXCLUDED.new_viewers_pct, returning_viewers_pct = EXCLUDED.returning_viewers_pct,
            subtitles_none_pct = EXCLUDED.subtitles_none_pct, subtitles_hindi_pct = EXCLUDED.subtitles_hindi_pct,
            subtitles_english_auto_pct = EXCLUDED.subtitles_english_auto_pct,
            description_text = EXCLUDED.description_text, description_length = EXCLUDED.description_length,
            tags_title = EXCLUDED.tags_title, tags_description = EXCLUDED.tags_description,
            hashtag_count = EXCLUDED.hashtag_count, playlist_name = EXCLUDED.playlist_name,
            end_screen = EXCLUDED.end_screen, captions = EXCLUDED.captions, related_video_title = EXCLUDED.related_video_title,
            related_video_type = EXCLUDED.related_video_type, hook_type = EXCLUDED.hook_type,
            clip_breakdown_json = EXCLUDED.clip_breakdown_json, language_mix = EXCLUDED.language_mix,
            content_category = EXCLUDED.content_category, value_delivery = EXCLUDED.value_delivery,
            cta_type = EXCLUDED.cta_type, academic_teaching = EXCLUDED.academic_teaching,
            total_comments = EXCLUDED.total_comments, top_comments_json = EXCLUDED.top_comments_json,
            sentiment_clusters_json = EXCLUDED.sentiment_clusters_json, topic_demands_json = EXCLUDED.topic_demands_json,
            quality_signals_json = EXCLUDED.quality_signals_json, creator_reply_rate = EXCLUDED.creator_reply_rate,
            gratitude_signals = EXCLUDED.gratitude_signals, trust_proxy = EXCLUDED.trust_proxy,
            content_type = EXCLUDED.content_type, what_works_json = EXCLUDED.what_works_json,
            what_fails_json = EXCLUDED.what_fails_json, root_cause = EXCLUDED.root_cause,
            hidden_pattern = EXCLUDED.hidden_pattern, actionable_fix = EXCLUDED.actionable_fix,
            comparison_cluster_json = EXCLUDED.comparison_cluster_json, memory_update_json = EXCLUDED.memory_update_json,
            analyzed_at = CURRENT_TIMESTAMP
    """),
    ('individual_comments', """
        INSERT INTO individual_comments (video_id, comment_id, author_name, author_channel_id, is_creator,
                                         is_pinned, is_hearted, text, text_clean, like_count, reply_count,
                                         parent_comment_id, depth, published_at, updated_at, sentiment,
                                         intent_category, query_subtype, is_actionable, has_contact_info)
        VALUES (%(video_id)s, %(comment_id)s, %(author_name)s, %(author_channel_id)s, %(is_creator)s,
                %(is_pinned)s, %(is_hearted)s, %(text)s, %(text_clean)s, %(like_count)s, %(reply_count)s,
                %(parent_comment_id)s, %(depth)s, %(published_at)s, %(updated_at)s, %(sentiment)s,
                %(intent_category)s, %(query_subtype)s, %(is_actionable)s, %(has_contact_info)s)
        ON CONFLICT (video_id, comment_id) DO UPDATE SET
            author_name = EXCLUDED.author_name, author_channel_id = EXCLUDED.author_channel_id,
            is_creator = EXCLUDED.is_creator, is_pinned = EXCLUDED.is_pinned, is_hearted = EXCLUDED.is_hearted,
            text = EXCLUDED.text, text_clean = EXCLUDED.text_clean, like_count = EXCLUDED.like_count,
            reply_count = EXCLUDED.reply_count, parent_comment_id = EXCLUDED.parent_comment_id,
            depth = EXCLUDED.depth, published_at = EXCLUDED.published_at, updated_at = EXCLUDED.updated_at,
            sentiment = EXCLUDED.sentiment, intent_category = EXCLUDED.intent_category,
            query_subtype = EXCLUDED.query_subtype, is_actionable = EXCLUDED.is_actionable,
            has_contact_info = EXCLUDED.has_contact_info, fetched_at = CURRENT_TIMESTAMP
    """),
]


def ingest(payload: dict):
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    cur = conn.cursor()
    try:
        for table, sql in INSERT_ORDER:
            rows = payload.get(table, [])
            if not rows:
                continue
            if isinstance(rows, dict):
                rows = [rows]
            for row in rows:
                # wrap dict/list values with Json for jsonb columns, pass arrays directly
                processed_row = {}
                for k, v in row.items():
                    if isinstance(v, dict):
                        processed_row[k] = Json(v)
                    elif isinstance(v, list):
                        # Check if it's a jsonb column (dict inside list) or array column (primitives)
                        if v and isinstance(v[0], dict):
                            processed_row[k] = Json(v)
                        else:
                            processed_row[k] = v  # pass array directly
                    else:
                        processed_row[k] = v
                cur.execute(sql, processed_row)
        conn.commit()
        print(f"SUCCESS: Committed {payload.get('shorts', [{}])[0].get('short_id', '?')} ({payload.get('shorts', [{}])[0].get('video_id', '?')})")
    except Exception as e:
        conn.rollback()
        print(f"ERROR: Rollback: {e}", file=sys.stderr)
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python ingest_short.py <payload.json>", file=sys.stderr)
        sys.exit(1)
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        payload = json.load(f)
    ingest(payload)