import json
import os
import psycopg2
from psycopg2.extras import RealDictCursor

base = r"C:\Desktop\Antigravity Projects\YouTube Manager"

# Get data for shorts 1-5 from the database
conn = psycopg2.connect(
    host='localhost',
    port=5432,
    user='postgres',
    database='youtube_shorts',
    cursor_factory=RealDictCursor
)
cur = conn.cursor()

for short_id in range(1, 6):
    cur.execute("SELECT * FROM shorts WHERE short_id = %s", (short_id,))
    short = cur.fetchone()
    if short:
        video_id = short['video_id']
        print(f"\n=== Short {short_id} ({video_id}) ===")
        
        # Get all related data
        cur.execute("SELECT * FROM performance_metrics WHERE video_id = %s", (video_id,))
        perf = cur.fetchone()
        
        cur.execute("SELECT * FROM traffic_sources WHERE video_id = %s", (video_id,))
        traffic = cur.fetchall()
        
        cur.execute("SELECT * FROM search_terms WHERE video_id = %s", (video_id,))
        search = cur.fetchall()
        
        cur.execute("SELECT * FROM retention_curve WHERE video_id = %s", (video_id,))
        retention = cur.fetchall()
        
        cur.execute("SELECT * FROM audience_device WHERE video_id = %s", (video_id,))
        device = cur.fetchone()
        
        cur.execute("SELECT * FROM audience_gender WHERE video_id = %s", (video_id,))
        gender = cur.fetchone()
        
        cur.execute("SELECT * FROM audience_age WHERE video_id = %s", (video_id,))
        age = cur.fetchone()
        
        cur.execute("SELECT * FROM audience_geography WHERE video_id = %s", (video_id,))
        geo = cur.fetchall()
        
        cur.execute("SELECT * FROM comments_analysis WHERE video_id = %s", (video_id,))
        comments = cur.fetchone()
        
        cur.execute("SELECT * FROM individual_comments WHERE video_id = %s", (video_id,))
        ind_comments = cur.fetchall()
        
        cur.execute("SELECT * FROM short_content_classification WHERE video_id = %s", (video_id,))
        classification = cur.fetchone()
        
        cur.execute("SELECT * FROM short_title_template WHERE video_id = %s", (video_id,))
        title_template = cur.fetchone()
        
        cur.execute("SELECT * FROM end_screen_performance WHERE video_id = %s", (video_id,))
        end_screen = cur.fetchone()
        
        cur.execute("SELECT * FROM remix_metrics WHERE video_id = %s", (video_id,))
        remix = cur.fetchone()
        
        cur.execute("SELECT * FROM audience_subscriber_status WHERE video_id = %s", (video_id,))
        sub_status = cur.fetchone()
        
        cur.execute("SELECT * FROM audience_subtitles WHERE video_id = %s", (video_id,))
        subtitles = cur.fetchone()
        
        cur.execute("SELECT * FROM realtime_metrics WHERE video_id = %s", (video_id,))
        realtime = cur.fetchone()
        
        cur.execute("SELECT * FROM external_sources WHERE video_id = %s", (video_id,))
        external = cur.fetchall()
        
        cur.execute("SELECT * FROM memory_updates WHERE video_id = %s", (video_id,))
        memory = cur.fetchall()
        
        cur.execute("SELECT * FROM analysis_log WHERE video_id = %s", (video_id,))
        analysis_log = cur.fetchall()
        
        # Build payload
        payload = {
            "video_id": video_id,
            "shorts": dict(short),
            "performance_metrics": dict(perf) if perf else {},
            "traffic_sources": [dict(t) for t in traffic],
            "search_terms": [dict(s) for s in search],
            "retention_curve": [dict(r) for r in retention],
            "audience_device": dict(device) if device else {},
            "audience_gender": dict(gender) if gender else {},
            "audience_age": dict(age) if age else {},
            "audience_geography": [dict(g) for g in geo],
            "comments_analysis": dict(comments) if comments else {},
            "individual_comments": [dict(ic) for ic in ind_comments],
            "short_content_classification": dict(classification) if classification else {},
            "short_title_template": dict(title_template) if title_template else {},
            "end_screen_performance": dict(end_screen) if end_screen else {},
            "remix_metrics": dict(remix) if remix else {},
            "audience_subscriber_status": dict(sub_status) if sub_status else {},
            "audience_subtitles": dict(subtitles) if subtitles else {},
            "realtime_metrics": dict(realtime) if realtime else {},
            "external_sources": [dict(e) for e in external],
            "memory_update": dict(memory[0]) if memory else {},
            "analysis_log": [dict(a) for a in analysis_log]
        }
        
        filepath = os.path.join(base, f'payload_short{short_id}.json')
        with open(filepath, 'w') as f:
            json.dump(payload, f, indent=2, default=str)
        
        print(f"Created payload_short{short_id}.json")

cur.close()
conn.close()
print("\nAll payloads created!")