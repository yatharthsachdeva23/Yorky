#!/usr/bin/env python3
"""
Unified YouTube Studio CDP Helper & Virtualized Scroll Primitive
Replaces duplicated CDP JavaScript across skills with a single robust Python script.
"""

import sys
import json
import time
import argparse
import urllib.request
import websocket

CDP_BASE_URL = "http://127.0.0.1:9222"

def get_studio_target():
    """Finds the active YouTube Studio page target from Chrome CDP."""
    try:
        req = urllib.request.Request(f"{CDP_BASE_URL}/json", headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=5) as resp:
            targets = json.loads(resp.read().decode('utf-8'))
            for t in targets:
                if t.get("type") == "page" and "studio.youtube.com" in t.get("url", ""):
                    return t
            for t in targets:
                if t.get("type") == "page":
                    return t
    except Exception as e:
        print(f"Error finding CDP targets at {CDP_BASE_URL}: {e}", file=sys.stderr)
    return None

def send_cdp_command(ws, method, params=None, req_id=1):
    """Sends a CDP command over WebSocket and returns the result."""
    msg = {"id": req_id, "method": method, "params": params or {}}
    ws.send(json.dumps(msg))
    while True:
        resp = json.loads(ws.recv())
        if resp.get("id") == req_id:
            return resp.get("result", {})

def evaluate_js(ws, expression, req_id=1):
    """Evaluates JavaScript expression in the target page context."""
    res = send_cdp_command(ws, "Runtime.evaluate", {
        "expression": expression,
        "returnByValue": True,
        "awaitPromise": True
    }, req_id=req_id)
    return res.get("result", {}).get("value")

def scroll_virtualized_comments(ws):
    """
    Standard Virtualized Comments Extractor for YouTube Studio:
    Container: <ytcp-activity-section>
    Phase 1: 10 scrolls @ 500px
    Phase 2: 300px increments until bottom
    Captures all threads, deduplicates by ID, returns structured comments list.
    """
    init_script = """
    (() => {
        const unrespondedChip = Array.from(document.querySelectorAll('ytcp-chip, ytcp-filter-chip')).find(el => el.textContent.includes('Unresponded'));
        if (unrespondedChip) {
            const closeBtn = unrespondedChip.querySelector('#close-button, .close-button, ytcp-icon-button');
            if (closeBtn) closeBtn.click();
        }
        return 'Filter checked';
    })()
    """
    evaluate_js(ws, init_script, req_id=10)
    time.sleep(1.0)

    comments_map = {}
    
    for step in range(30):
        scroll_amount = 500 if step < 10 else 300
        scroll_script = f"""
        (() => {{
            const container = document.querySelector('ytcp-activity-section') || document.querySelector('main');
            if (!container) return {{ status: 'no_container' }};
            
            const prevTop = container.scrollTop;
            container.scrollTop += {scroll_amount};
            const isBottom = (container.scrollTop + container.clientHeight >= container.scrollHeight - 50);
            
            const threads = Array.from(document.querySelectorAll('ytcp-comment-thread'));
            const extracted = threads.map(t => {{
                const authorEl = t.querySelector('#author-text, .author-text');
                const contentEl = t.querySelector('#content-text, .content-text');
                const dateEl = t.querySelector('#published-time-text, .published-time-text');
                const replyCountEl = t.querySelector('#reply-count, .reply-count');
                const cid = t.getAttribute('id') || (authorEl ? authorEl.textContent.trim() : '') + (contentEl ? contentEl.textContent.trim() : '');
                
                return {{
                    id: cid,
                    author: authorEl ? authorEl.textContent.trim() : '',
                    text: contentEl ? contentEl.textContent.trim() : '',
                    date: dateEl ? dateEl.textContent.trim() : '',
                    reply_count: replyCountEl ? replyCountEl.textContent.trim() : '0'
                }};
            }}).filter(c => c.text);
            
            return {{
                prevTop: prevTop,
                newTop: container.scrollTop,
                isBottom: isBottom,
                comments: extracted
            }};
        }})()
        """
        res = evaluate_js(ws, scroll_script, req_id=20 + step)
        if not res or res.get('status') == 'no_container':
            break
            
        for c in res.get('comments', []):
            if c['id'] and c['id'] not in comments_map:
                comments_map[c['id']] = c
                
        if res.get('isBottom'):
            break
            
        time.sleep(0.4)

    return list(comments_map.values())

def extract_shorts_list(ws):
    """
    Extracts chronological Shorts from YouTube Studio Videos tab.
    Container: <main>
    """
    script = """
    (() => {
        const rows = Array.from(document.querySelectorAll('ytcp-video-row'));
        return rows.map((r, idx) => {
            const titleEl = r.querySelector('#video-title, a[id="video-title"]');
            const dateEl = r.querySelector('.tablecell-date, [class*="date"]');
            const durationEl = r.querySelector('.duration, [class*="duration"]');
            const href = titleEl ? titleEl.getAttribute('href') : '';
            const vidMatch = href ? href.match(/video\\/([^\/]+)/) : null;
            const videoId = vidMatch ? vidMatch[1] : '';

            return {
                index: idx + 1,
                video_id: videoId,
                title: titleEl ? titleEl.textContent.trim() : '',
                date: dateEl ? dateEl.textContent.trim() : '',
                duration: durationEl ? durationEl.textContent.trim() : ''
            };
        });
    })()
    """
    return evaluate_js(ws, script, req_id=100) or []


def extract_short(ws, video_id):
    """
    Unified extraction: all 4 analytics tabs + comments + metadata in one WebSocket session.
    Returns complete raw data for a single short.
    """
    result = {
        "video_id": video_id,
        "analytics": {},
        "comments": [],
        "metadata": {}
    }
    
    # 1. Extract all 4 analytics tabs
    tab_names = ["overview", "reach", "engagement", "audience"]
    for tab_name in tab_names:
        tab_url = f"https://studio.youtube.com/video/{video_id}/analytics/tab-{tab_name}/period-default"
        
        # Navigate
        nav_script = f"""
        (() => {{
            window.location.href = '{tab_url}';
            return {{navigated: true}};
        }})()
        """
        evaluate_js(ws, nav_script, req_id=1000)
        time.sleep(4)  # Wait longer for full page load
        
        # Click tab to activate (tab name matching)
        tab_display = tab_name.capitalize()
        if tab_name == "overview":
            tab_display = "Overview"
        elif tab_name == "reach":
            tab_display = "Reach"
        elif tab_name == "engagement":
            tab_display = "Engagement"
        elif tab_name == "audience":
            tab_display = "Audience"
        
        click_script = f"""
        (() => {{
            const tabs = document.querySelectorAll('[role="tab"], tp-yt-paper-tab');
            for (const tab of tabs) {{
                const text = tab.textContent || tab.innerText || '';
                if (text.trim().toLowerCase() === '{tab_display.lower()}') {{
                    tab.click();
                    return {{clicked: true, text: text.trim()}};
                }}
            }}
            return {{clicked: false}};
        }})()
        """
        evaluate_js(ws, click_script, req_id=1010)
        time.sleep(3)  # Wait for tab content to render
        
        # Extract page text
        text = evaluate_js(ws, "document.body.innerText", req_id=1020)
        result["analytics"][tab_name] = text
    
    # 2. Extract comments
    comments_url = f"https://studio.youtube.com/video/{video_id}/comments"
    nav_script = f"""
    (() => {{
        window.location.href = '{comments_url}';
        return {{navigated: true}};
    }})()
    """
    evaluate_js(ws, nav_script, req_id=1100)
    time.sleep(3)
    
    # Remove Unresponded filter
    filter_script = """
    (() => {
        const chips = document.querySelectorAll('ytcp-chip-bar ytcp-chip, .filter-chip, [role="button"]');
        for (const chip of chips) {
            const text = (chip.innerText || chip.textContent || '').toLowerCase();
            if (text.includes('unresponded') || text.includes('response status')) {
                const closeBtn = chip.querySelector('button[aria-label*="remove"], button[aria-label*="close"], button[aria-label*="delete"], .close-button, .remove-button, ytcp-icon-button');
                if (closeBtn) { closeBtn.click(); return {clicked: true}; }
                chip.click(); return {clicked: true};
            }
        }
        return {clicked: false};
    })()
    """
    evaluate_js(ws, filter_script, req_id=1110)
    time.sleep(1.5)
    
    # Scroll and extract comments (reuse existing logic)
    comments_map = {}
    for step in range(30):
        scroll_amount = 500 if step < 10 else 300
        scroll_script = f"""
        (() => {{
            const container = document.querySelector('ytcp-activity-section');
            if (!container) return {{status: 'no_container'}};
            
            const prevTop = container.scrollTop;
            container.scrollTop += {scroll_amount};
            const isBottom = (container.scrollTop + container.clientHeight >= container.scrollHeight - 50);
            
            const threads = Array.from(document.querySelectorAll('ytcp-comment-thread'));
            const extracted = threads.map(t => {{
                const authorEl = t.querySelector('#author-text, .author-text');
                const contentEl = t.querySelector('#content-text, .content-text');
                const dateEl = t.querySelector('#published-time-text, .published-time-text');
                const replyCountEl = t.querySelector('#reply-count, .reply-count');
                const cid = t.getAttribute('id') || (authorEl ? authorEl.textContent.trim() : '') + (contentEl ? contentEl.textContent.trim() : '');
                
                return {{
                    id: cid,
                    author: authorEl ? authorEl.textContent.trim() : '',
                    text: contentEl ? contentEl.textContent.trim() : '',
                    date: dateEl ? dateEl.textContent.trim() : '',
                    reply_count: replyCountEl ? replyCountEl.textContent.trim() : '0'
                }};
            }}).filter(c => c.text);
            
            return {{
                prevTop: prevTop,
                newTop: container.scrollTop,
                isBottom: isBottom,
                comments: extracted
            }};
        }})()
        """
        res = evaluate_js(ws, scroll_script, req_id=1120 + step)
        if not res or res.get('status') == 'no_container':
            break
            
        for c in res.get('comments', []):
            if c['id'] and c['id'] not in comments_map:
                comments_map[c['id']] = c
                
        if res.get('isBottom'):
            break
        time.sleep(0.4)
    
    result["comments"] = list(comments_map.values())
    
    # 3. Extract metadata from edit page
    edit_url = f"https://studio.youtube.com/video/{video_id}/edit"
    nav_script = f"""
    (() => {{
        window.location.href = '{edit_url}';
        return {{navigated: true}};
    }})()
    """
    evaluate_js(ws, nav_script, req_id=1200)
    time.sleep(4)
    
    edit_text = evaluate_js(ws, "document.body.innerText", req_id=1210)
    result["metadata"]["edit_page_text"] = edit_text
    
    return result

def main():
    parser = argparse.ArgumentParser(description="YouTube Studio CDP Automation Helper")
    parser.add_argument("--mode", choices=["comments", "shorts_list", "target", "extract_short"], required=True, help="Automation task mode")
    parser.add_argument("--video-id", help="YouTube video ID (required for extract_short)")
    parser.add_argument("--out", help="Optional output JSON file path")
    args = parser.parse_args()

    target = get_studio_target()
    if not target:
        print("ERROR: No YouTube Studio page found in Chrome CDP!", file=sys.stderr)
        sys.exit(1)

    if args.mode == "target":
        print(json.dumps(target, indent=2))
        return

    if args.mode == "extract_short" and not args.video_id:
        print("ERROR: --video-id required for extract_short mode", file=sys.stderr)
        sys.exit(1)

    ws_url = target.get("webSocketDebuggerUrl")
    if not ws_url:
        print("ERROR: Target has no webSocketDebuggerUrl", file=sys.stderr)
        sys.exit(1)

    ws = websocket.create_connection(ws_url, timeout=10, suppress_origin=True)
    try:
        if args.mode == "comments":
            data = scroll_virtualized_comments(ws)
            print(f"Extracted {len(data)} unique comments.", file=sys.stderr)
        elif args.mode == "shorts_list":
            data = extract_shorts_list(ws)
            print(f"Extracted {len(data)} visible Shorts rows.", file=sys.stderr)
        elif args.mode == "extract_short":
            data = extract_short(ws, args.video_id)
            print(f"Extracted complete data for {args.video_id}", file=sys.stderr)

        output_json = json.dumps(data, indent=2, ensure_ascii=False)
        if args.out:
            with open(args.out, "w", encoding="utf-8") as f:
                f.write(output_json)
            print(f"Results saved to {args.out}", file=sys.stderr)
        else:
            print(output_json)
    finally:
        ws.close()

if __name__ == "__main__":
    main()
