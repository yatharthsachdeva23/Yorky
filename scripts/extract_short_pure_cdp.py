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

    # 1. Create independent background target tab
    init_url = f"https://studio.youtube.com/video/{video_id}/analytics/tab-overview/period-default"
    req = urllib.request.Request(f"{CDP_BASE}/json/new?{init_url}", method="PUT")
    with urllib.request.urlopen(req, timeout=10) as r:
        target = json.load(r)

    tid = target["id"]
    ws_url = target["webSocketDebuggerUrl"]
    print(f"[+] Target created: {tid}")

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

        # ── 3. COMMENTS TAB ──
        print("  -> Navigating to Comments tab...")
        comments_url = f"https://studio.youtube.com/video/{video_id}/comments"
        cdp_eval(ws, f"window.location.href = '{comments_url}';", req_id)
        req_id += 1
        time.sleep(3.0)
        check_and_click_retry(ws, req_id)

        # Remove Unresponded / response status filter chip with robust selector
        filter_code = """
        (() => {
            // 1. Search all chip variants
            const chips = document.querySelectorAll('ytcp-chip-bar ytcp-chip, ytcp-filter-chip, .filter-chip, [role="button"]');
            for (const chip of chips) {
                const text = (chip.innerText || chip.textContent || '').toLowerCase();
                if (text.includes('unresponded') || text.includes('response status') || text.includes('responded') || text.includes('questions')) {
                    const closeBtn = chip.querySelector('button, [aria-label*="remove" i], [aria-label*="close" i], .close-button, ytcp-icon-button, [icon="close"]');
                    if (closeBtn) { closeBtn.click(); return 'clicked_close_btn'; }
                    chip.click(); return 'clicked_chip_direct';
                }
            }
            // 2. Specific filter-bar remove button
            const filterBar = document.querySelector('ytcp-filter-bar');
            if (filterBar) {
                const removeBtns = filterBar.querySelectorAll('ytcp-icon-button[aria-label*="remove" i], ytcp-icon-button[aria-label*="close" i], button.close-button, ytcp-icon-button[id="delete-button"]');
                if (removeBtns.length > 0) {
                    removeBtns[0].click();
                    return 'clicked_filter_bar_remove';
                }
            }
            return 'not_found';
        })()
        """
        filter_status = cdp_eval(ws, filter_code, req_id)
        req_id += 1
        print(f"     Unresponded filter status: {filter_status}")
        if filter_status in ('clicked_close_btn', 'clicked_chip_direct'):
            time.sleep(2.0)

        # Poll dynamically for up to 10s for comments to render or confirm empty
        comments_map = {}
        for _ in range(20):
            time.sleep(0.5)
            t_count = cdp_eval(ws, "document.querySelectorAll('ytcp-comment-thread').length", req_id)
            req_id += 1
            if t_count and t_count > 0:
                break
            body_txt = cdp_eval(ws, "document.body ? document.body.innerText : ''", req_id) or ""
            req_id += 1
            if "no comments" in body_txt.lower() or "nothing to show" in body_txt.lower():
                break

        # Scroll virtualized comments
        for step in range(15):
            scroll_code = """
            (() => {
                const container = document.querySelector('ytcp-activity-section') || document.querySelector('main');
                if (!container) return {status: 'no_container'};
                
                container.scrollTop += 400;
                const isBottom = (container.scrollTop + container.clientHeight >= container.scrollHeight - 50);
                
                const threads = Array.from(document.querySelectorAll('ytcp-comment-thread'));
                const extracted = threads.map(t => {
                    const authorEl = t.querySelector('#author-text, .author-text');
                    const contentEl = t.querySelector('#content-text, .content-text');
                    const dateEl = t.querySelector('#published-time-text, .published-time-text');
                    const replyCountEl = t.querySelector('#reply-count, .reply-count');
                    const pinnedEl = t.querySelector('#pinned-comment-badge, .pinned-comment-badge, [aria-label*="Pinned"], [aria-label*="pinned"]');
                    const cid = t.getAttribute('id') || ((authorEl ? authorEl.textContent.trim() : '') + (contentEl ? contentEl.textContent.trim() : ''));
                    
                    return {
                        id: cid,
                        author: authorEl ? authorEl.textContent.trim() : '',
                        text: contentEl ? contentEl.textContent.trim() : '',
                        date: dateEl ? dateEl.textContent.trim() : '',
                        reply_count: replyCountEl ? replyCountEl.textContent.trim() : '0',
                        is_pinned: pinnedEl !== null
                    };
                }).filter(c => c.text);
                
                return {
                    isBottom: isBottom,
                    comments: extracted
                };
            })()
            """
            scroll_res = cdp_eval(ws, scroll_code, req_id)
            req_id += 1
            if not scroll_res or scroll_res.get("status") == "no_container":
                break
            for c in scroll_res.get("comments", []):
                if c["id"] and c["id"] not in comments_map:
                    comments_map[c["id"]] = c
            if scroll_res.get("isBottom"):
                break
            time.sleep(0.2)

        extracted_data["comments"] = list(comments_map.values())
        print(f"     [Comments] Captured {len(extracted_data['comments'])} comments")

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

