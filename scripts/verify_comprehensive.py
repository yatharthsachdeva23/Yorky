#!/usr/bin/env python3
"""
Comprehensive 10-level database verification for YouTube Shorts forensic analysis.
Runs all verification levels from verification_checklist.md and outputs JSON report.
"""

import sys
import json
import psycopg2
from psycopg2.extras import RealDictCursor

DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 5432,
    'database': 'youtube_shorts',
    'user': 'postgres',
}

def get_connection():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

def verify_short(short_id: int, video_id: str) -> dict:
    """Run all 10 verification levels for a single short."""
    results = {
        'short_id': short_id,
        'video_id': video_id,
        'levels': {},
        'overall_pass': True
    }
    
    with get_connection() as conn:
        cur = conn.cursor()
        
        # Level 1: Core Tables
        cur.execute("""
            SELECT s.short_id, s.video_id, s.title, pm.views, pm.retention_pct
            FROM shorts s
            LEFT JOIN performance_metrics pm ON s.video_id = pm.video_id
            WHERE s.short_id = %s
        """, (short_id,))
        row = cur.fetchone()
        level1 = row is not None and row['views'] is not None
        results['levels']['level1_core'] = {'pass': level1, 'data': dict(row) if row else None}
        if not level1: results['overall_pass'] = False
        
        # Level 2: Traffic Sources (5-6 rows)
        cur.execute("""
            SELECT source_name, source_category, views, percentage
            FROM traffic_sources WHERE video_id = %s ORDER BY percentage DESC
        """, (video_id,))
        rows = cur.fetchall()
        level2 = len(rows) >= 4
        results['levels']['level2_traffic'] = {'pass': level2, 'count': len(rows), 'sources': [dict(r) for r in rows]}
        if not level2: results['overall_pass'] = False
        
        # Level 3: Search Terms
        cur.execute("""
            SELECT search_term, views, percentage_of_search, percentage_of_total, intent_category, relevance_score
            FROM search_terms WHERE video_id = %s ORDER BY views DESC
        """, (video_id,))
        rows = cur.fetchall()
        level3 = len(rows) > 0  # May be 0 for pure feed shorts
        results['levels']['level3_search'] = {'pass': level3, 'count': len(rows), 'terms': [dict(r) for r in rows]}
        
        # Level 4: Retention Curve (3+ points)
        cur.execute("""
            SELECT timestamp_seconds, retention_pct, is_key_moment, moment_type, moment_note
            FROM retention_curve WHERE video_id = %s ORDER BY timestamp_seconds
        """, (video_id,))
        rows = cur.fetchall()
        level4 = len(rows) >= 3
        results['levels']['level4_retention'] = {'pass': level4, 'count': len(rows), 'points': [dict(r) for r in rows]}
        if not level4: results['overall_pass'] = False
        
        # Level 5: Audience Demographics (6 tables)
        aud_tables = ['audience_device', 'audience_gender', 'audience_age', 
                      'audience_geography', 'audience_subscriber_status', 'audience_subtitles']
        aud_results = {}
        aud_all_pass = True
        for table in aud_tables:
            cur.execute(f"SELECT * FROM {table} WHERE video_id = %s", (video_id,))
            rows = cur.fetchall()
            aud_results[table] = [dict(r) for r in rows]
            if len(rows) == 0:
                aud_all_pass = False
        results['levels']['level5_audience'] = {'pass': aud_all_pass, 'tables': aud_results}
        if not aud_all_pass: results['overall_pass'] = False
        
        # Level 6: Comments
        cur.execute("SELECT * FROM comments_analysis WHERE video_id = %s", (video_id,))
        ca = cur.fetchone()
        cur.execute("SELECT * FROM individual_comments WHERE video_id = %s ORDER BY depth, comment_id", (video_id,))
        ic = cur.fetchall()
        level6 = ca is not None and (len(ic) > 0 or ca.get('total_comments') == 0)
        results['levels']['level6_comments'] = {'pass': level6, 'analysis': dict(ca) if ca else None, 'individual_count': len(ic)}
        if not level6: results['overall_pass'] = False
        
        # Level 7: Classification & Templates
        cur.execute("SELECT * FROM short_content_classification WHERE video_id = %s", (video_id,))
        scc = cur.fetchone()
        cur.execute("SELECT * FROM short_title_template WHERE video_id = %s", (video_id,))
        stt = cur.fetchone()
        level7 = scc is not None  # Template may be missing for older shorts
        results['levels']['level7_classification'] = {'pass': level7, 'classification': dict(scc) if scc else None, 'template': dict(stt) if stt else None}
        if not level7: results['overall_pass'] = False
        
        # Level 8: End Screen & Remix
        cur.execute("SELECT * FROM end_screen_performance WHERE video_id = %s", (video_id,))
        esp = cur.fetchone()
        cur.execute("SELECT * FROM remix_metrics WHERE video_id = %s", (video_id,))
        rm = cur.fetchone()
        level8 = esp is not None
        results['levels']['level8_end_screen'] = {'pass': level8, 'end_screen': dict(esp) if esp else None, 'remix': dict(rm) if rm else None}
        if not level8: results['overall_pass'] = False
        
        # Level 9: Realtime & External
        cur.execute("SELECT * FROM realtime_metrics WHERE video_id = %s", (video_id,))
        rt = cur.fetchone()
        cur.execute("SELECT * FROM external_sources WHERE video_id = %s", (video_id,))
        es = cur.fetchall()
        # These may be empty for older shorts - valid
        results['levels']['level9_realtime'] = {'pass': True, 'realtime': dict(rt) if rt else None, 'external': [dict(r) for r in es]}
        
        # Level 10: Memory & Analysis Log
        cur.execute("SELECT * FROM memory_updates WHERE video_id = %s", (video_id,))
        mu = cur.fetchall()
        cur.execute("SELECT * FROM analysis_log WHERE video_id = %s", (video_id,))
        al = cur.fetchall()
        level10 = len(mu) > 0 and len(al) >= 4
        results['levels']['level10_memory'] = {'pass': level10, 'memory_updates': len(mu), 'analysis_log': len(al)}
        if not level10: results['overall_pass'] = False
        
        cur.close()
    
    return results

def verify_range(start_id: int, end_id: int):
    """Verify a range of shorts."""
    # Get video IDs for range
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT short_id, video_id FROM shorts WHERE short_id BETWEEN %s AND %s ORDER BY short_id", (start_id, end_id))
        shorts = cur.fetchall()
        cur.close()
    
    all_results = []
    for s in shorts:
        print(f"Verifying short #{s['short_id']} ({s['video_id']})...", file=sys.stderr)
        result = verify_short(s['short_id'], s['video_id'])
        all_results.append(result)
        status = "PASS" if result['overall_pass'] else "FAIL"
        print(f"  {status}", file=sys.stderr)
    
    return all_results

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--short-id', type=int, help='Single short ID to verify')
    parser.add_argument('--video-id', help='Video ID (required with --short-id)')
    parser.add_argument('--range', help='Range like 52-65')
    parser.add_argument('--output', help='Output JSON file')
    args = parser.parse_args()
    
    if args.short_id and args.video_id:
        results = [verify_short(args.short_id, args.video_id)]
    elif args.range:
        start, end = map(int, args.range.split('-'))
        results = verify_range(start, end)
    else:
        parser.print_help()
        sys.exit(1)
    
    output = json.dumps(results, indent=2, default=str)
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Results saved to {args.output}")
    else:
        print(output)