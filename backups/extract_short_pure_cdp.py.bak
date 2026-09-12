#!/usr/bin/env python3
"""
Pure CDP Isolated YouTube Studio Extractor
Creates an independent target tab via Chrome DevTools Protocol (CDP HTTP API: /json/new),
connects over WebSocket with suppress_origin=True,
extracts all 6 tabs (Overview, Reach, Engagement, Audience, Comments, Details/Edit),
saves structured JSON to data/extracted_short{short_id}.json,
and cleanly closes the target via /json/close/{target_id}.

ZERO Playwright dependency. 100% native CDP.
Allows multiple subagents to run concurrently without stealing window focus.
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

        # Wait for tab buttons to exist before proceeding to tab clicks
        for _ in range(15):
            has_tabs = cdp_eval(ws, "document.querySelectorAll('tp-yt-paper-tab, [role=\"tab\"]').length > 0", req_id)
            req_id += 1
            if has_tabs:
                break
            time.sleep(0.5)

        # ── 2. REACH, ENGAGEMENT, AUDIENCE TABS (SPA Click) ──
        tab_mappings = [
            ("reach", "reach_viewers", "Reach"),
            ("engagement", "interest_viewers", "Engagement"),
            ("audience", "build_audience", "Audience")
        ]

        for name, tab_elem_id, label in tab_mappings:
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

            # Poll until aria-selected is true AND innerText length > 300
            text = ""
            for attempt in range(16):
                time.sleep(0.5)
                is_chal, req_id = check_security_challenge(ws, req_id)
                if is_chal:
                    break

                check_and_click_retry(ws, req_id)
                selected = cdp_eval(ws, f'document.querySelector("#{tab_elem_id}")?.getAttribute("aria-selected")', req_id)
                req_id += 1

                if selected == 'true':
                    time.sleep(0.8)  # Allow Polymer inner cards to render
                    text = cdp_eval(ws, "document.body ? document.body.innerText : ''", req_id) or ""
                    req_id += 1
                    if len(text) > 300:
                        break

            extracted_data["analytics"][name] = text
            print(f"     [{label}] Captured ({len(text or '')} chars)")

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
                    const cid = t.getAttribute('id') || ((authorEl ? authorEl.textContent.trim() : '') + (contentEl ? contentEl.textContent.trim() : ''));
                    
                    return {
                        id: cid,
                        author: authorEl ? authorEl.textContent.trim() : '',
                        text: contentEl ? contentEl.textContent.trim() : '',
                        date: dateEl ? dateEl.textContent.trim() : '',
                        reply_count: replyCountEl ? replyCountEl.textContent.trim() : '0'
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
            "edit_page_text": edit_text
        }
        print(f"     [Metadata] Title: {title}")
        print(f"     [Metadata] Description length: {len(desc or '')}")

        ws.close()
    finally:
        # Clean teardown
        try:
            urllib.request.urlopen(f"{CDP_BASE}/json/close/{tid}")
            print(f"[+] Cleanly closed isolated target: {tid}")
        except Exception as e:
            print(f"[-] Warning closing target {tid}: {e}")

    # Write output
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(extracted_data, f, indent=2, ensure_ascii=False)

    print(f"[SUCCESS] Saved extracted data to: {output_path}")
    return output_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Pure CDP YouTube Studio Extractor")
    parser.add_argument("video_id", help="YouTube video ID")
    parser.add_argument("short_id", type=int, help="Short number ID")
    parser.add_argument("--output", help="Output path")
    args = parser.parse_args()

    extract_studio_short_pure_cdp(args.video_id, args.short_id, args.output)
