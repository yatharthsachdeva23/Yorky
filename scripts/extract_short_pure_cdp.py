#!/usr/bin/env python3
"""
Pure CDP Isolated YouTube Studio Extractor
Creates an independent target tab via Chrome DevTools Protocol (CDP HTTP API: /json/new?url),
connects over WebSocket with suppress_origin=True,
extracts all 6 tabs (Overview, Reach, Engagement, Audience, Comments, Details/Edit),
saves structured JSON to data/extracted_short{short_id}.json,
and cleanly closes the target via /json/close/{target_id}.

ZERO Playwright dependency. 100% native CDP.
Allows multiple subagents to run concurrently without stealing window focus.

CRITICAL SUBAGENT INSTRUCTION:
- DO NOT run manual curl /json/new commands! That creates orphan blank tabs.
- For CDP connectivity checks, use /json/version (e.g. curl -s http://127.0.0.1:9222/json/version).
"""

import sys
import io
import os
import json
import time
import argparse
import urllib.request
import websocket

# Ensure current script directory is in sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Force UTF-8 encoding for Windows terminal safely
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

CDP_BASE = "http://127.0.0.1:9222"

def cleanup_orphan_blank_tabs():
    """Automatically sweep and close any orphan about:blank tabs without touching user tabs."""
    try:
        req = urllib.request.Request(f"{CDP_BASE}/json/list")
        with urllib.request.urlopen(req, timeout=3) as resp:
            tabs = json.load(resp)
        for t in tabs:
            if t.get("url") == "about:blank" and t.get("type") == "page":
                tid = t.get("id")
                try:
                    urllib.request.urlopen(f"{CDP_BASE}/json/close/{tid}", timeout=2)
                except Exception:
                    pass
    except Exception:
        pass

def create_background_target(init_url: str):
    """
    Creates a target tab strictly in the background (background=True)
    via Browser WebSocket, and minimizes the Chrome window so that
    it NEVER steals focus or pops up in front of the user's active work.
    """
    try:
        req = urllib.request.Request(f"{CDP_BASE}/json/version")
        with urllib.request.urlopen(req, timeout=5) as r:
            ver = json.load(r)
        browser_ws_url = ver.get("webSocketDebuggerUrl")
        if browser_ws_url:
            ws_b = websocket.create_connection(browser_ws_url, timeout=10, suppress_origin=True)
            # Create target with background=True (prevents tab focus)
            ws_b.send(json.dumps({
                "id": 1,
                "method": "Target.createTarget",
                "params": {"url": init_url, "background": True}
            }))
            res = json.loads(ws_b.recv())
            tid = res.get("result", {}).get("targetId")
            
            if tid:
                # Keep Chrome minimized on taskbar so it NEVER pops in front of other apps
                try:
                    ws_b.send(json.dumps({
                        "id": 2,
                        "method": "Browser.getWindowForTarget",
                        "params": {"targetId": tid}
                    }))
                    res_w = json.loads(ws_b.recv())
                    wid = res_w.get("result", {}).get("windowId")
                    if wid:
                        ws_b.send(json.dumps({
                            "id": 3,
                            "method": "Browser.setWindowBounds",
                            "params": {"windowId": wid, "bounds": {"windowState": "minimized"}}
                        }))
                        ws_b.recv()
                except Exception:
                    pass
                
                ws_b.close()
                ws_url = f"ws://127.0.0.1:9222/devtools/page/{tid}"
                return tid, ws_url
            ws_b.close()
    except Exception as e:
        print(f"[-] Background target creation fallback: {e}")

    # Fallback to HTTP API if browser endpoint is unavailable
    req = urllib.request.Request(f"{CDP_BASE}/json/new?{init_url}", method="PUT")
    with urllib.request.urlopen(req, timeout=10) as r:
        target = json.load(r)
    return target["id"], target["webSocketDebuggerUrl"]

def cdp_send(ws, method, params=None, req_id=1):
    ws.send(json.dumps({"id": req_id, "method": method, "params": params or {}}))
    while True:
        res = json.loads(ws.recv())
        if res.get("id") == req_id:
            return res.get("result", {})

def cdp_eval(ws, expr, req_id=1):
    res = cdp_send(ws, "Runtime.evaluate", {
        "expression": expr,
        "returnByValue": True,
        "awaitPromise": True
    }, req_id=req_id)
    return res.get("result", {}).get("value")

def check_and_click_retry(ws, req_id):
    """
    Checks if 'Oops, something went wrong' or error banner is visible,
    and clicks the visible 'Retry' button.
    """
    retry_code = """
    (() => {
        const bodyText = document.body ? document.body.innerText : '';
        const hasError = bodyText.includes('Oops, something went wrong') ||
                         bodyText.includes('Something went wrong') ||
                         bodyText.includes('An error occurred');
        if (!hasError) return false;

        const buttons = Array.from(document.querySelectorAll('button, tp-yt-paper-button, [role="button"]'));
        for (const btn of buttons) {
            if (btn.offsetParent !== null && btn.offsetWidth > 0 && btn.offsetHeight > 0) {
                const txt = (btn.innerText || btn.textContent || '').trim().toLowerCase();
                if (txt === 'retry') {
                    btn.click();
                    return true;
                }
            }
        }
        return false;
    })()
    """
    clicked = cdp_eval(ws, retry_code, req_id)
    req_id += 1
    if clicked:
        print("     [!] Bot detection 'Retry' clicked! Waiting 5s...")
        time.sleep(5.0)
        return True, req_id
    return False, req_id

def check_security_challenge(ws, req_id):
    check_code = """
    (() => {
        const txt = document.body ? document.body.innerText : '';
        const href = window.location.href;
        if (href.includes('accounts.google.com') || txt.includes("Verify it's you") || txt.includes("unusual traffic")) {
            return {is_challenge: true, url: href};
        }
        return {is_challenge: false};
    })()
    """
    res = cdp_eval(ws, check_code, req_id)
    req_id += 1
    if res and res.get("is_challenge"):
        print(f"     [CRITICAL] Google Security Challenge triggered! URL: {res.get('url')}")
        return True, req_id
    return False, req_id

def extract_studio_short_pure_cdp(video_id: str, short_id: int, output_path: str = None):
    if not output_path:
        output_path = os.path.join("data", f"extracted_short{short_id}.json")
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    # Automatically sweep away any rogue about:blank tabs left by exploratory commands
    cleanup_orphan_blank_tabs()

    print(f"[*] [Pure CDP] Opening isolated background target for Short #{short_id} ({video_id})...")

    # 1. Create independent background target tab (strictly background=True, window minimized)
    init_url = f"https://studio.youtube.com/video/{video_id}/analytics/tab-overview/period-default"
    tid, ws_url = create_background_target(init_url)
    print(f"[+] Target created in background: {tid}")

    extracted_data = {
        "video_id": video_id,
        "short_id": short_id,
        "extracted_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "analytics": {},
        "comments": [],
        "metadata": {}
    }

    req_id = 1000

    try:
        ws = websocket.create_connection(ws_url, timeout=45, suppress_origin=True)

        # ── 1. OVERVIEW TAB ──
        print("  -> Waiting for Analytics Overview to render...")
        overview_text = ""
        for poll in range(25):  # Up to 15s
            time.sleep(0.6)
            is_chal, req_id = check_security_challenge(ws, req_id)
            if is_chal:
                break
            check_and_click_retry(ws, req_id)
            ov_selected = cdp_eval(ws, 'document.querySelector("#overview")?.getAttribute("aria-selected")', req_id)
            req_id += 1
            body_text = cdp_eval(ws, 'document.body ? document.body.innerText : ""', req_id) or ""
            req_id += 1
            has_metrics = ("views" in body_text.lower() or 
                           "since published" in body_text.lower() or 
                           "typical performance" in body_text.lower() or
                           "your video" in body_text.lower())
            if len(body_text) > 450 and has_metrics:
                overview_text = body_text
                break
            elif poll > 16 and len(body_text) > 300:
                overview_text = body_text
                break

        extracted_data["analytics"]["overview"] = overview_text
        print(f"     [Overview] Captured ({len(overview_text or '')} chars)")

        # Extract explicit date chip text from Overview
        date_chip_code = """
        (() => {
            const selectors = ['#time-filter', 'ytcp-dropdown-trigger', '.date-picker-button', '[aria-label*="Date range"]', '#picker-container'];
            for (const s of selectors) {
                const el = document.querySelector(s);
                if (el && el.innerText && el.innerText.trim()) {
                    return el.innerText.trim();
                }
            }
            return '';
        })()
        """
        date_range_txt = cdp_eval(ws, date_chip_code, req_id)
        req_id += 1
        extracted_data["analytics"]["date_range_chip"] = date_range_txt or ""
        if date_range_txt:
            print(f"     [Overview] Date Range: {date_range_txt.replace(chr(10), ' ')}")

        # Wait for tab buttons to exist before proceeding to tab clicks
        for _ in range(15):
            has_tabs = cdp_eval(ws, "document.querySelectorAll('tp-yt-paper-tab, [role=\"tab\"]').length > 0", req_id)
            req_id += 1
            if has_tabs:
                break
            time.sleep(0.5)

        # ── 2. REACH, ENGAGEMENT, AUDIENCE TABS (SPA Click) ──
        tab_mappings = [
            ("reach", "reach_viewers", "Reach", ["how viewers find", "traffic source", "shorts feed", "content suggesting", "external sites"]),
            ("engagement", "interest_viewers", "Engagement", ["engaged views", "audience retention", "how viewers engaged", "top remixed", "end screen element"]),
            ("audience", "build_audience", "Audience", ["watch time from subscribers", "device type", "top geographies", "top subtitle", "age and gender", "returning viewers", "audience by watch behavior", "not enough eligible audience data"])
        ]

        for name, tab_elem_id, label, expected_keywords in tab_mappings:
            click_code = f"""
            (() => {{
                const tab = document.querySelector('#{tab_elem_id}');
                if (tab) {{
                    tab.click();
                    return true;
                }}
                return false;
            }})()
            """
            cdp_eval(ws, click_code, req_id)
            req_id += 1
            time.sleep(0.5)

            # Poll until tab-specific keywords appear AND tab is selected
            text = ""
            for attempt in range(35):
                is_chal, req_id = check_security_challenge(ws, req_id)
                if is_chal:
                    break

                check_and_click_retry(ws, req_id)
                body_t = cdp_eval(ws, "document.body ? document.body.innerText : ''", req_id) or ""
                req_id += 1
                selected = cdp_eval(ws, f'document.querySelector("#{tab_elem_id}")?.getAttribute("aria-selected")', req_id)
                req_id += 1

                is_selected = str(selected).lower() == 'true'
                has_kw = any(kw in body_t.lower() for kw in expected_keywords)
                
                if has_kw and is_selected and len(body_t) > 400:
                    text = body_t
                    break
                
                # Re-click if tab hasn't switched cards after 2s or every 5 attempts
                if (not is_selected or not has_kw) and attempt in (4, 10, 16, 22):
                    cdp_eval(ws, click_code, req_id)
                    req_id += 1

                if attempt > 30 and is_selected and len(body_t) > 300:
                    text = body_t
                    break
                
                time.sleep(0.5)

            extracted_data["analytics"][name] = text
            is_verified = any(kw in (text or '').lower() for kw in expected_keywords)
            print(f"     [{label}] Captured ({len(text or '')} chars, verified_cards={is_verified})")

        # ── 3. COMMENTS EXTRACTION (Innertube 100% Engine) ──
        print("  -> Extracting comments via Innertube API engine...")
        comments_list = []
        try:
            from extract_all_comments import extract_all_comments
            raw_comments, _ = extract_all_comments(video_id)
            for c in raw_comments:
                comments_list.append({
                    "id": c["comment_id"],
                    "author": c["author_name"],
                    "text": c["text"],
                    "date": c.get("published_raw", ""),
                    "like_count": c.get("like_count", 0),
                    "reply_count": c.get("reply_count", 0),
                    "is_pinned": c.get("is_pinned", False),
                    "parent_comment_id": c.get("parent_comment_id"),
                    "depth": c.get("depth", 0),
                    "is_creator": c.get("is_creator", False)
                })
            print(f"     [Comments] Captured {len(comments_list)} comments (100% threads + nested replies)")
        except Exception as e:
            print(f"     [Comments] Innertube extraction warning ({e})")
        extracted_data["comments"] = comments_list

        # ── 4. DETAILS / EDIT PAGE ──
        print("  -> Navigating to Details/Edit...")
        edit_url = f"https://studio.youtube.com/video/{video_id}/edit"
        cdp_eval(ws, f"window.location.href = '{edit_url}';", req_id)
        req_id += 1

        # Poll dynamically for up to 15s until title textbox is rendered
        title = ""
        desc = ""
        edit_text = ""
        edit_meta = {}
        for _ in range(25):
            time.sleep(0.6)
            check_and_click_retry(ws, req_id)
            t_val = cdp_eval(ws, 'document.querySelector("ytcp-video-title #textbox, #title-textarea #textbox")?.innerText', req_id)
            req_id += 1
            if t_val and t_val.strip():
                title = t_val.strip()
                desc = cdp_eval(ws, 'document.querySelector("ytcp-video-description #textbox, #description-textarea #textbox")?.innerText || ""', req_id)
                req_id += 1
                edit_text = cdp_eval(ws, "document.body.innerText", req_id)
                req_id += 1
                
                # Extract structured sidebar elements
                sidebar_code = """
                (() => {
                    let visibility = '';
                    let publishDate = '';
                    const visEl = document.querySelector('ytcp-video-metadata-visibility, [test-id="visibility-button"]');
                    if (visEl) {
                        const lines = visEl.innerText.split('\\n').map(s => s.trim()).filter(Boolean);
                        visibility = lines[0] || '';
                        for (const l of lines) {
                            if (/publish|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec/i.test(l)) {
                                publishDate = l;
                            }
                        }
                    }

                    let relatedVideo = '';
                    const relEl = document.querySelector('ytcp-video-metadata-related-video, [test-id="related-video"]');
                    if (relEl) {
                        const rLines = relEl.innerText.split('\\n').map(s => s.trim()).filter(Boolean);
                        // Filter out labels like "Related video"
                        const nonLabels = rLines.filter(l => !/^related video$/i.test(l));
                        if (nonLabels.length > 0) relatedVideo = nonLabels.join(' ');
                    }

                    let playlists = [];
                    const plEl = document.querySelector('ytcp-video-metadata-playlists');
                    if (plEl) {
                        const txt = plEl.innerText.trim();
                        if (txt && !txt.toLowerCase().includes('select')) {
                            playlists = txt.split('\\n').map(s => s.trim()).filter(Boolean);
                        }
                    }

                    let subtitles = '';
                    const subEl = document.querySelector('ytcp-video-metadata-subtitles');
                    if (subEl) subtitles = subEl.innerText.trim();

                    return {
                        visibility: visibility,
                        publish_date: publishDate,
                        related_video: relatedVideo,
                        playlists: playlists,
                        subtitles: subtitles
                    };
                })()
                """
                edit_meta = cdp_eval(ws, sidebar_code, req_id) or {}
                req_id += 1
                break
            body_t = cdp_eval(ws, "document.body ? document.body.innerText : ''", req_id) or ""
            req_id += 1
            if "oops, something went wrong" in body_t.lower() or "retry" in body_t.lower():
                check_and_click_retry(ws, req_id)

        if not title:
            doc_t = cdp_eval(ws, "document.title", req_id)
            req_id += 1
            title = doc_t if doc_t and "creator studio" not in doc_t.lower() else ""

        extracted_data["metadata"] = {
            "title": (title or "").strip(),
            "description": (desc or "").strip(),
            "edit_page_text": edit_text,
            "visibility": edit_meta.get("visibility", ""),
            "publish_date": edit_meta.get("publish_date", ""),
            "related_video": edit_meta.get("related_video", ""),
            "playlists": edit_meta.get("playlists", []),
            "subtitles": edit_meta.get("subtitles", "")
        }
        print(f"     [Metadata] Title: {title}")
        print(f"     [Metadata] Description length: {len(desc or '')}")
        if edit_meta.get("publish_date"):
            print(f"     [Metadata] Published: {edit_meta['publish_date']}")
        if edit_meta.get("related_video"):
            print(f"     [Metadata] Related Video: {edit_meta['related_video'][:50]}...")

        ws.close()
    finally:
        # Clean teardown
        try:
            urllib.request.urlopen(f"{CDP_BASE}/json/close/{tid}")
            print(f"[+] Cleanly closed isolated target: {tid}")
        except Exception as e:
            print(f"[-] Warning closing target {tid}: {e}")
        
        # Sweep away any orphan about:blank tabs
        cleanup_orphan_blank_tabs()

    # Write output
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(extracted_data, f, indent=2, ensure_ascii=False)

    print(f"[SUCCESS] Saved extracted data to: {output_path}")
    return output_path

if __name__ == "__main__":
    # Support positional arguments in either order (<video_id> <short_id> or <short_id> <video_id>)
    # and safely support video IDs starting with hyphens (e.g. -ntsqYRrjic)
    output_arg = None
    args_clean = []
    skip_next = False
    for i, a in enumerate(sys.argv[1:]):
        if skip_next:
            skip_next = False
            continue
        if a == "--output":
            if i + 1 < len(sys.argv[1:]):
                output_arg = sys.argv[1:][i + 1]
                skip_next = True
            continue
        if a.startswith("--output="):
            output_arg = a.split("=", 1)[1]
            continue
        args_clean.append(a)

    if len(args_clean) < 2:
        print("Usage: extract_short_pure_cdp.py <video_id> <short_id> [--output OUTPUT]")
        sys.exit(1)

    a1, a2 = args_clean[0], args_clean[1]
    if a1.isdigit():
        short_id = int(a1)
        video_id = a2
    elif a2.isdigit():
        short_id = int(a2)
        video_id = a1
    else:
        video_id = a1
        short_id = a2

    extract_studio_short_pure_cdp(video_id, short_id, output_arg)

