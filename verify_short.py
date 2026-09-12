#!/usr/bin/env python3
"""
Verification script for Short forensic analysis.
Usage: python verify_short.py <short_id> [video_id]
Checks all 20 tables for the given short and reports verification status.
"""
import sys
import psycopg2

DB_PARAMS = {
    "dbname": "youtube_shorts",
    "user": "postgres",
    "host": "127.0.0.1",
    "port": 5432
}

# Core 18 tables that MUST be populated for every short
CORE_TABLES = [
    'performance_metrics',
    'traffic_sources',
    'search_terms',
    'retention_curve',
    'audience_device',
    'audience_gender',
    'audience_age',
    'audience_geography',
    'audience_subscriber_status',
    'audience_subtitles',
    'comments_analysis',
    'short_content_classification',
    'short_title_template',
    'end_screen_performance',
    'remix_metrics',
    'realtime_metrics',
    'memory_updates',
    'analysis_log'
]

# Optional tables - only required if data exists on YouTube Studio
OPTIONAL_TABLES = [
    'individual_comments',   # Only required if comments_analysis.total_comments > 0
    'external_sources'       # Only required if external traffic > 0
]

# All 20 tables
TABLES = CORE_TABLES + OPTIONAL_TABLES

def verify_short(short_id, video_id=None):
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    
    # If video_id not provided, look it up by short_id
    if video_id is None:
        cur.execute("SELECT video_id FROM shorts WHERE short_id = %s", (short_id,))
        result = cur.fetchone()
        if result is None:
            print(f"[ERROR] Short #{short_id} not found in database")
            conn.close()
            return False
        video_id = result[0]
    
    print(f"Verifying Short #{short_id} (video_id: {video_id})...")
    
    missing = []
    empty = []
    ok_count = 0
    
    # Get comments count to determine if individual_comments should have data
    cur.execute("SELECT total_comments FROM comments_analysis WHERE video_id = %s", (video_id,))
    comments_result = cur.fetchone()
    has_comments = comments_result and comments_result[0] > 0
    
    # Get external sources count to determine if external_sources should have data
    cur.execute("SELECT COUNT(*) FROM external_sources WHERE video_id = %s", (video_id,))
    ext_count_result = cur.fetchone()
    has_external = ext_count_result and ext_count_result[0] > 0
    
    for table in TABLES:
        cur.execute(f"SELECT COUNT(*) FROM {table} WHERE video_id = %s", (video_id,))
        count = cur.fetchone()[0]
        
        # Skip optional tables if no data expected
        if table == 'individual_comments' and not has_comments:
            ok_count += 1
            continue
        if table == 'external_sources' and not has_external:
            ok_count += 1
            continue
            
        if count == 0:
            empty.append(table)
        elif count is None:
            missing.append(table)
        else:
            ok_count += 1
    
    conn.close()
    
    total = len(TABLES)
    print(f"Results: {ok_count}/{total} tables populated")
    
    if empty:
        print(f"[EMPTY] {len(empty)} table(s) with 0 rows:")
        for t in empty:
            print(f"  - {t}")
    
    if missing:
        print(f"[MISSING] {len(missing)} table(s) not queried:")
        for t in missing:
            print(f"  - {t}")
    
    if ok_count == total:
        print(f"[SUCCESS] {total}/{total} tables verified for Short #{short_id} ({video_id})")
        return True
    else:
        print(f"[FAIL] Only {ok_count}/{total} tables have data")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python verify_short.py <short_id> [video_id]")
        sys.exit(1)
    
    short_id = int(sys.argv[1])
    video_id = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = verify_short(short_id, video_id)
    sys.exit(0 if success else 1)