import psycopg2
import json
from datetime import datetime, date
from decimal import Decimal

# Custom JSON encoder to handle Decimal, datetime, and date objects
class CustomJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        elif isinstance(obj, date):
            return obj.isoformat()
        elif isinstance(obj, Decimal):
            return float(obj)
        return super().default(obj)

print("Taking database snapshot of shorts 1-30...")

# Connect to database
conn = psycopg2.connect(host='127.0.0.1', port=5432, database='youtube_shorts', user='postgres', password='postgres')
cur = conn.cursor()

# Get all shorts 1-30 with all their data
cur.execute("""
SELECT 
    s.short_id,
    s.video_id,
    s.title,
    s.description,
    s.published_at,
    s.duration_seconds,
    s.visibility,
    
    -- Performance metrics
    pm.views,
    pm.engaged_views,
    pm.unique_viewers,
    pm.watch_time_hours,
    pm.avg_view_duration_seconds,
    pm.retention_pct,
    pm.completion_pct,
    pm.swipe_away_pct,
    pm.subscribers_gained,
    pm.subscribers_lost,
    pm.net_subscribers,
    pm.likes,
    pm.comments_count,
    pm.shares,
    pm.hype_points,
    pm.engagement_rate,
    pm.sub_conversion_rate,
    pm.engaged_view_rate,
    pm.views_vs_channel_avg_pct,
    pm.retention_vs_channel_avg,
    pm.period_start as perf_period_start,
    pm.period_end as perf_period_end,
    pm.fetched_at as perf_fetched_at,
    
    -- Audience device
    ad.mobile_pct,
    ad.desktop_pct,
    ad.tv_pct,
    ad.tablet_pct,
    ad.mobile_views,
    ad.desktop_views,
    ad.tv_views,
    ad.tablet_views,
    ad.desktop_intent_proxy,
    ad.fetched_at as device_fetched_at,
    
    -- Audience gender
    ag.male_pct,
    ag.female_pct,
    ag.unknown_pct,
    ag.has_data as gender_has_data,
    ag.fetched_at as gender_fetched_at,
    
    -- Audience age
    aa.age_13_17_pct,
    aa.age_18_24_pct,
    aa.age_25_34_pct,
    aa.age_35_44_pct,
    aa.age_45_54_pct,
    aa.age_55_64_pct,
    aa.age_65_plus_pct,
    aa.target_audience_pct,
    aa.non_target_pct,
    aa.has_data as age_has_data,
    aa.fetched_at as age_fetched_at,
    
    -- Audience subscriber status
    sub.subscribed_pct,
    sub.not_subscribed_pct,
    sub.subscribed_views,
    sub.not_subscribed_views,
    sub.sub_viewer_retention_pct,
    sub.non_sub_viewer_retention_pct,
    sub.fetched_at as subscriber_fetched_at,
    
    -- Audience subtitles
    ast.none_pct,
    ast.hindi_pct,
    ast.english_pct,
    ast.other_pct,
    ast.has_cc_data as subtitles_has_data,
    ast.fetched_at as subtitles_fetched_at,
    
    -- Comments analysis
    ca.total_comments,
    ca.comments_per_1k_views,
    ca.top_level_comments,
    ca.total_replies,
    ca.max_thread_depth,
    ca.avg_thread_depth,
    ca.creator_replies,
    ca.creator_reply_rate,
    ca.positive_sentiment_pct,
    ca.negative_sentiment_pct,
    ca.neutral_sentiment_pct,
    ca.query_comments,
    ca.gratitude_comments,
    ca.gratitude_with_likes,
    ca.spam_irrelevant_comments,
    ca.query_categories,
    ca.unanswered_high_intent_queries,
    ca.fetched_at as comments_fetched_at,
    
    -- Content classification
    csc.primary_type,
    csc.secondary_type,
    csc.confidence_score,
    csc.classified_at,
    csc.classified_by,
    
    -- Title template
    stt.template_id,
    stt.title_length,
    stt.word_count,
    stt.hashtag_count,
    stt.emoji_count,
    stt.char_before_pipe,
    stt.char_after_pipe,
    stt.keyword_density,
    
    -- End screen performance
    esp.has_end_screen,
    esp.element_type,
    esp.element_video_id,
    esp.impressions,
    esp.clicks,
    esp.channel_avg_ctr,
    esp.vs_channel_avg_pct,
    
    -- Remix metrics
    rm.remix_count,
    rm.remix_views,
    rm.top_remix_video_id,
    rm.top_remix_views,
    
    -- Realtime metrics
    rt.views_48h,
    rt.period_start as rt_period_start,
    rt.period_end as rt_period_end,
    rt.velocity_views_per_hour
    
FROM shorts s
LEFT JOIN performance_metrics pm ON pm.video_id = s.video_id
LEFT JOIN audience_device ad ON ad.video_id = s.video_id
LEFT JOIN audience_gender ag ON ag.video_id = s.video_id
LEFT JOIN audience_age aa ON aa.video_id = s.video_id
LEFT JOIN audience_subscriber_status sub ON sub.video_id = s.video_id
LEFT JOIN audience_subtitles ast ON ast.video_id = s.video_id
LEFT JOIN comments_analysis ca ON ca.video_id = s.video_id
LEFT JOIN short_content_classification csc ON csc.video_id = s.video_id
LEFT JOIN short_title_template stt ON stt.video_id = s.video_id
LEFT JOIN end_screen_performance esp ON esp.video_id = s.video_id
LEFT JOIN remix_metrics rm ON rm.video_id = s.video_id
LEFT JOIN realtime_metrics rt ON rt.video_id = s.video_id
WHERE s.short_id BETWEEN 1 AND 30
ORDER BY s.short_id
""")

rows = cur.fetchall()
column_names = [desc[0] for desc in cur.description]

# Convert to list of dictionaries
shorts_data = []
for row in rows:
    record = {}
    for i, value in enumerate(row):
        key = column_names[i]
        # Handle None values
        if value is None:
            record[key] = None
        else:
            record[key] = value
    shorts_data.append(record)

# Save to file with custom encoder
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
filename = f'data/db_snapshot_shorts_1_to_30_{timestamp}.json'
with open(filename, 'w', encoding='utf-8') as f:
    json.dump(shorts_data, f, indent=2, ensure_ascii=False, cls=CustomJSONEncoder)

print(f'Snapshot saved to: {filename}')
print(f'Total shorts captured: {len(shorts_data)}')

# Show brief summary
if shorts_data:
    sample = shorts_data[0]
    print(f'Sample - Short #{sample["short_id"]} ({sample["video_id"]}):')
    print(f'  Views: {sample["views"]}, Retention: {sample["retention_pct"]}%')
    print(f'  Comments: {sample["total_comments"]}')

cur.close()
conn.close()