#!/usr/bin/env python3
"""
Parallel 10-Shorts Test Harness with Bot-Detection Defenses
Runs 10 YouTube Shorts concurrently using Pure CDP with:
- Staggered thread startup (prevents InnerTube API burst rate limits)
- Isolated CDP background targets (zero window focus stealing)
- Active Bot Detection & "Retry" button auto-clicker
- Complete 6-tab extraction (Overview, Reach, Engagement, Audience, Comments, Edit)
- Automatic clean target teardown (no Chrome memory leaks)
- Forensic verification of all 10 extracted JSON payloads
"""

import os
import sys
import io
import time
import json
import concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract_short_pure_cdp import extract_studio_short_pure_cdp

# Force UTF-8 for Windows console safely
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

TEST_SHORTS = [
    {"short_id": 83, "video_id": "fsSkI-1Opvk"},
    {"short_id": 84, "video_id": "pbU_sJKSfrg"},
    {"short_id": 85, "video_id": "W1nCo6y71R8"},
    {"short_id": 86, "video_id": "rrTB_XW3pWA"},
    {"short_id": 87, "video_id": "kbLQ0kJ7pYQ"},
    {"short_id": 88, "video_id": "xj4emmUcJGE"},
    {"short_id": 89, "video_id": "w2UTdzsuads"},
    {"short_id": 90, "video_id": "SOKrC7BJ418"},
    {"short_id": 91, "video_id": "PaYUzmc11E8"},
    {"short_id": 92, "video_id": "0KAZqj8-gFo"},
]

def run_single_short(item, stagger_delay=0):
    if stagger_delay > 0:
        time.sleep(stagger_delay)
    
    sid = item["short_id"]
    vid = item["video_id"]
    start_t = time.time()
    out_file = os.path.join("data", f"extracted_short{sid}.json")
    
    print(f"\n[LAUNCH] Worker starting Short #{sid} ({vid}) at t={time.strftime('%H:%M:%S')}...")
    try:
        extract_studio_short_pure_cdp(vid, sid, out_file)
        elapsed = time.time() - start_t
        print(f"[FINISHED] Short #{sid} ({vid}) in {elapsed:.1f}s")
        return {
            "short_id": sid,
            "video_id": vid,
            "success": True,
            "elapsed_seconds": round(elapsed, 1),
            "file": out_file,
            "error": None
        }
    except Exception as e:
        elapsed = time.time() - start_t
        print(f"[FAILED] Short #{sid} ({vid}) after {elapsed:.1f}s: {e}")
        return {
            "short_id": sid,
            "video_id": vid,
            "success": False,
            "elapsed_seconds": round(elapsed, 1),
            "file": out_file,
            "error": str(e)
        }

def verify_extracted_data(results):
    print("\n" + "="*80)
    print("                    10-SHORTS FORENSIC VERIFICATION REPORT")
    print("="*80)
    
    all_passed = True
    summary_rows = []
    
    for r in results:
        sid = r["short_id"]
        vid = r["video_id"]
        fpath = r["file"]
        
        checks = {
            "file_exists": False,
            "valid_json": False,
            "overview_ok": False,
            "reach_ok": False,
            "engagement_ok": False,
            "audience_ok": False,
            "no_oops_banner": True,
            "comments_extracted": False,
            "title_extracted": False
        }
        
        title_snippet = ""
        comments_count = 0
        
        if os.path.exists(fpath):
            checks["file_exists"] = True
            try:
                with open(fpath, "r", encoding="utf-8") as f:
                    data = json.load(f)
                checks["valid_json"] = True
                
                analytics = data.get("analytics", {})
                ov = analytics.get("overview", "")
                reach = analytics.get("reach", "")
                eng = analytics.get("engagement", "")
                aud = analytics.get("audience", "")
                
                checks["overview_ok"] = len(ov) > 300
                checks["reach_ok"] = len(reach) > 300
                checks["engagement_ok"] = len(eng) > 300
                checks["audience_ok"] = len(aud) > 300
                
                for tab_name, txt in [("Overview", ov), ("Reach", reach), ("Engagement", eng), ("Audience", aud)]:
                    if "Oops, something went wrong" in txt or "Retry" == txt.strip():
                        checks["no_oops_banner"] = False
                        print(f"[-] Short #{sid} {tab_name} contains bot detection / oops banner!")
                        
                comments = data.get("comments", [])
                checks["comments_extracted"] = isinstance(comments, list)
                comments_count = len(comments)
                
                title = data.get("metadata", {}).get("title", "")
                checks["title_extracted"] = bool(title.strip())
                title_snippet = title[:35] + "..." if len(title) > 35 else title
                
            except Exception as e:
                print(f"[-] Error reading {fpath}: {e}")
        
        short_pass = all(checks.values())
        if not short_pass:
            all_passed = False
            
        summary_rows.append({
            "short_id": sid,
            "video_id": vid,
            "title": title_snippet,
            "status": "PASS" if short_pass else "FAIL",
            "time_s": r["elapsed_seconds"],
            "comments": comments_count,
            "checks": checks
        })
    
    print(f"{'Short':<7} | {'Video ID':<12} | {'Status':<6} | {'Time':<6} | {'Comments':<8} | {'Title'}")
    print("-" * 80)
    for row in summary_rows:
        print(f"#{row['short_id']:<6} | {row['video_id']:<12} | {row['status']:<6} | {row['time_s']:>4.1f}s | {row['comments']:>8} | {row['title']}")
        if row['status'] == "FAIL":
            failed_checks = [k for k, v in row['checks'].items() if not v]
            print(f"   -> Failed checks: {', '.join(failed_checks)}")
            
    print("="*80)
    print(f"OVERALL RESULT: {'ALL 10 SHORTS PASSED VERIFICATION' if all_passed else 'SOME SHORTS FAILED'}")
    print("="*80)
    return all_passed

def main():
    print("="*80)
    print("       STARTING 10-SHORTS CONCURRENT CDP EXTRACTION TEST")
    print(f"Targeting Shorts #83 - #92 (Total: {len(TEST_SHORTS)} shorts)")
    print("Concurrency: 3 Parallel Workers with 2.5s Staggered Startup")
    print("Bot Detection Defense: Active 'Retry' Clicker & InnerTube Rate Pacing")
    print("="*80)
    
    total_start = time.time()
    
    # 3 concurrent workers to prevent InnerTube burst collisions while keeping high speed
    max_workers = 3
    results = []
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for i, item in enumerate(TEST_SHORTS):
            stagger = (i % max_workers) * 2.5
            futures.append(executor.submit(run_single_short, item, stagger))
            
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())
            
    total_elapsed = time.time() - total_start
    results.sort(key=lambda x: x["short_id"])
    
    print(f"\n[DONE] All 10 extractions completed in {total_elapsed:.1f}s ({total_elapsed/60:.2f} mins)!")
    verify_extracted_data(results)

if __name__ == "__main__":
    main()
