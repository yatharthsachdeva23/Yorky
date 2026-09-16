#!/usr/bin/env python3
"""
scripts/extract_all_comments.py
================================
Dedicated standalone extractor to capture ALL comments and replies for any YouTube Short.
Bypasses YouTube Studio UI virtualization and truncation limits by communicating
directly with YouTube's Innertube API engine.

Features:
- Extracts 100% of top-level comment threads and nested replies.
- Parses author, author channel ID, creator flag, pinned status, hearted status,
  exact text, like counts, relative timestamps, reply depth, and parent comment IDs.
- Performs intent analysis (questions, gratitude, feedback, exam/counselling queries)
  and sentiment analysis (positive, neutral, negative).
- Optionally persists to PostgreSQL (individual_comments, comments_analysis, performance_metrics).
- Saves full extracted payload to data/comments_{video_id}.json.

Usage:
    python scripts/extract_all_comments.py --video-id pszcrf0uTbQ --update-db
    python scripts/extract_all_comments.py --short-id 41 --update-db
"""

import sys
import os
import re
import json
import time
import argparse
import hashlib
from datetime import datetime, timedelta
import urllib.request
import psycopg2
from psycopg2.extras import Json

MONTH_MAP = {
    'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
    'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
    'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12'
}

def parse_comment_date(date_str: str, ref_dt: datetime = None) -> str:
    """Convert relative comment dates (e.g. '2 years ago') or absolute dates to ISO timestamp."""
    if not date_str:
        return None
    if ref_dt is None:
        ref_dt = datetime.now()
    date_str = date_str.strip()
    m_dir = re.search(r'([A-Za-z]{3})\s+(\d{1,2}),\s+(\d{4})', date_str)
    if m_dir:
        mon, day, yr = m_dir.group(1).lower()[:3], m_dir.group(2).zfill(2), m_dir.group(3)
        if mon in MONTH_MAP:
            return f"{yr}-{MONTH_MAP[mon]}-{day} 00:00:00"
    m_rel = re.search(r'(\d+)\s+(second|minute|hour|day|week|month|year)s?\s+ago', date_str, re.IGNORECASE)
    if m_rel:
        val = int(m_rel.group(1))
        unit = m_rel.group(2).lower()
        if unit == 'second':
            delta = timedelta(seconds=val)
        elif unit == 'minute':
            delta = timedelta(minutes=val)
        elif unit == 'hour':
            delta = timedelta(hours=val)
        elif unit == 'day':
            delta = timedelta(days=val)
        elif unit == 'week':
            delta = timedelta(weeks=val)
        elif unit == 'month':
            delta = timedelta(days=val * 30)
        elif unit == 'year':
            delta = timedelta(days=val * 365)
        else:
            delta = timedelta()
        return (ref_dt - delta).strftime("%Y-%m-%d %H:%M:%S")
    return None

def extract_all_comments(video_id: str):
    """Fetch every comment and reply for the given video_id via Innertube."""
    url = f'https://www.youtube.com/shorts/{video_id}'
    req = urllib.request.Request(
        url,
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US,en;q=0.9'
        }
    )
    with urllib.request.urlopen(req, timeout=20) as resp:
        html = resp.read().decode('utf-8', 'ignore')

    api_key_m = re.search(r'\"INNERTUBE_API_KEY\":\"([^\"]+)\"', html)
    if not api_key_m:
        raise RuntimeError("Could not find INNERTUBE_API_KEY on YouTube page.")
    api_key = api_key_m.group(1)

    client_ver_m = re.search(r'\"INNERTUBE_CLIENT_VERSION\":\"([^\"]+)\"', html)
    client_ver = client_ver_m.group(1) if client_ver_m else "2.20240301.00.00"

    data_m = re.search(r'var ytInitialData\s*=\s*({.+?});</script>', html)
    if not data_m:
        raise RuntimeError("Could not find ytInitialData on YouTube page.")
    data = json.loads(data_m.group(1))

    # Identify comments continuation token and reported count
    token = None
    reported_total = None
    for p in data.get('engagementPanels', []):
        header = p.get('engagementPanelSectionListRenderer', {}).get('header', {}).get('engagementPanelTitleHeaderRenderer', {})
        contextual = header.get('contextualInfo', {}).get('runs', [{}])[0].get('text')
        if contextual and contextual.isdigit():
            reported_total = int(contextual)
        sub_menu = header.get('menu', {}).get('sortFilterSubMenuRenderer', {})
        for item in sub_menu.get('subMenuItems', []):
            if item.get('title') in ('Top', 'Newest'):
                token = item.get('serviceEndpoint', {}).get('continuationCommand', {}).get('token')
                break
        if token:
            break

    if not token:
        print(f"[*] No comment section token found for video {video_id}. It may have 0 comments or disabled comments.")
        return [], reported_total or 0

    browse_url = f"https://www.youtube.com/youtubei/v1/browse?key={api_key}"
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    def call_innertube(cont_token):
        payload = {
            "context": {"client": {"clientName": "WEB", "clientVersion": client_ver, "hl": "en", "gl": "US"}},
            "continuation": cont_token
        }
        post_req = urllib.request.Request(browse_url, data=json.dumps(payload).encode('utf-8'), headers=headers)
        with urllib.request.urlopen(post_req, timeout=20) as resp:
            return json.loads(resp.read().decode('utf-8', 'ignore'))

    all_comments = {}
    reply_tokens = []  # list of tuples: (reply_token, parent_comment_id)
    ref_dt = datetime.now()

    def parse_response(res, default_parent_id=None, default_depth=0):
        # 1. Parse commentEntityPayload mutations
        mutations = res.get('frameworkUpdates', {}).get('entityBatchUpdate', {}).get('mutations', [])
        for m in mutations:
            p = m.get('payload', {})
            if 'commentEntityPayload' in p:
                cep = p['commentEntityPayload']
                cid = cep.get('properties', {}).get('commentId')
                if cid:
                    author_name = cep.get('author', {}).get('displayName', '')
                    raw_text = cep.get('properties', {}).get('content', {}).get('content', '')
                    likes_str = cep.get('toolbar', {}).get('likeCountNotliked', '0')
                    try:
                        likes_int = int(re.sub(r'[^\d]', '', str(likes_str)) or 0)
                    except Exception:
                        likes_int = 0

                    reply_lvl = cep.get('properties', {}).get('replyLevel', default_depth)
                    parent_id = default_parent_id if reply_lvl > 0 else None

                    is_hearted = 'heartActiveTooltip' in str(cep.get('toolbar', {}))
                    is_pinned = 'pinned' in str(cep.get('properties', {})).lower() or 'pinned' in str(cep.get('toolbar', {})).lower()

                    all_comments[cid] = {
                        'comment_id': cid,
                        'author_name': author_name,
                        'author_channel_id': cep.get('author', {}).get('channelId'),
                        'is_creator': cep.get('author', {}).get('isCreator', False),
                        'is_pinned': is_pinned,
                        'is_hearted': is_hearted,
                        'text': raw_text,
                        'text_clean': raw_text.strip(),
                        'like_count': likes_int,
                        'reply_count': 0,
                        'parent_comment_id': parent_id,
                        'depth': reply_lvl,
                        'published_raw': cep.get('properties', {}).get('publishedTime'),
                        'published_at': parse_comment_date(cep.get('properties', {}).get('publishedTime'), ref_dt),
                    }

        # 2. Extract next page tokens & replies tokens
        next_cont = None
        for ep in res.get('onResponseReceivedEndpoints', []):
            action = ep.get('appendContinuationItemsAction') or ep.get('reloadContinuationItemsCommand')
            if not action:
                continue
            for item in action.get('continuationItems', []):
                if 'commentThreadRenderer' in item:
                    ctr = item['commentThreadRenderer']
                    thread_cid = None
                    if 'commentViewModel' in ctr:
                        thread_cid = ctr['commentViewModel'].get('commentViewModel', {}).get('commentId')
                        if 'pinnedText' in ctr['commentViewModel'].get('commentViewModel', {}):
                            if thread_cid and thread_cid in all_comments:
                                all_comments[thread_cid]['is_pinned'] = True

                    # Look up replies continuation
                    replies = ctr.get('replies', {}).get('commentRepliesRenderer', {})
                    for c in replies.get('contents', []):
                        if 'continuationItemRenderer' in c:
                            rtok = c['continuationItemRenderer'].get('continuationEndpoint', {}).get('continuationCommand', {}).get('token')
                            if rtok:
                                reply_tokens.append((rtok, thread_cid))

                elif 'continuationItemRenderer' in item:
                    tok = item['continuationItemRenderer'].get('continuationEndpoint', {}).get('continuationCommand', {}).get('token')
                    if tok:
                        next_cont = tok
        return next_cont

    # 1. Fetch all top-level comment threads
    current_token = token
    page = 1
    while current_token:
        res = call_innertube(current_token)
        current_token = parse_response(res, default_parent_id=None, default_depth=0)
        page += 1
        time.sleep(0.3)

    # 2. Fetch all nested replies
    for idx, (rtok, parent_cid) in enumerate(reply_tokens):
        rep_token = rtok
        while rep_token:
            res = call_innertube(rep_token)
            rep_token = parse_response(res, default_parent_id=parent_cid, default_depth=1)
            time.sleep(0.2)

    # Convert dictionary to list and perform sentiment / intent analysis
    parsed_comments = []
    for cid, c in all_comments.items():
        text_clean = c['text_clean']
        is_q = '?' in text_clean or any(k in text_clean.lower() for k in ['help', 'kya', 'kaise', 'batao', 'cutoff', 'rank', 'marks', 'admission', 'counselling', 'plz', 'please'])
        intent = 'question' if is_q else 'gratitude' if any(w in text_clean.lower() for w in ['thank', 'thanks', 'great', 'good', 'best', 'nice', 'helpful', 'love', '❤️', '🔥', '👍', 'dhanyawad', 'shukriya']) else 'feedback'
        sentiment = 'positive' if intent == 'gratitude' or any(w in text_clean.lower() for w in ['thank', 'thanks', 'great', 'good', 'best', 'nice', 'helpful', 'love', '❤️', '🔥', '👍']) else 'negative' if any(w in text_clean.lower() for w in ['bad', 'worst', 'fake', 'hate', 'useless', 'waste', 'lie', 'galat']) else 'neutral'

        c['sentiment'] = sentiment
        c['intent_category'] = intent
        c['query_subtype'] = 'general' if intent == 'question' else None
        c['is_actionable'] = intent == 'question'
        c['has_contact_info'] = bool(re.search(r'[\w\.-]+@[\w\.-]+|\b\d{10}\b', text_clean))
        parsed_comments.append(c)

    return parsed_comments, reported_total or len(parsed_comments)

def update_database(video_id: str, comments: list, reported_total: int):
    """Write extracted comments directly to PostgreSQL."""
    conn = psycopg2.connect(dbname="youtube_shorts", user="postgres", host="localhost", port=5432)
    cur = conn.cursor()

    # 1. Clear old individual comments for this video
    cur.execute("DELETE FROM individual_comments WHERE video_id = %s;", (video_id,))

    # 2. Insert all extracted comments
    now_dt = datetime.now()
    insert_sql = """
        INSERT INTO individual_comments (
            video_id, comment_id, author_name, author_channel_id, is_creator,
            is_pinned, is_hearted, text, text_clean, like_count, reply_count,
            parent_comment_id, depth, published_at, sentiment, intent_category,
            query_subtype, is_actionable, has_contact_info, fetched_at
        ) VALUES (
            %(video_id)s, %(comment_id)s, %(author_name)s, %(author_channel_id)s, %(is_creator)s,
            %(is_pinned)s, %(is_hearted)s, %(text)s, %(text_clean)s, %(like_count)s, %(reply_count)s,
            %(parent_comment_id)s, %(depth)s, %(published_at)s, %(sentiment)s, %(intent_category)s,
            %(query_subtype)s, %(is_actionable)s, %(has_contact_info)s, %(fetched_at)s
        );
    """
    for c in comments:
        cur.execute(insert_sql, {
            'video_id': video_id,
            'comment_id': c['comment_id'],
            'author_name': c['author_name'],
            'author_channel_id': c.get('author_channel_id'),
            'is_creator': c['is_creator'],
            'is_pinned': c['is_pinned'],
            'is_hearted': c['is_hearted'],
            'text': c['text'],
            'text_clean': c['text_clean'],
            'like_count': c['like_count'],
            'reply_count': c['reply_count'],
            'parent_comment_id': c['parent_comment_id'],
            'depth': c['depth'],
            'published_at': c['published_at'],
            'sentiment': c['sentiment'],
            'intent_category': c['intent_category'],
            'query_subtype': c['query_subtype'],
            'is_actionable': c['is_actionable'],
            'has_contact_info': c['has_contact_info'],
            'fetched_at': now_dt
        })

    # 3. Compute comments_analysis metrics
    total_count = len(comments)
    top_level = sum(1 for c in comments if c['depth'] == 0)
    total_replies = sum(1 for c in comments if c['depth'] > 0)
    creator_replies = sum(1 for c in comments if c['is_creator'] and c['depth'] > 0)
    pos_count = sum(1 for c in comments if c['sentiment'] == 'positive')
    neg_count = sum(1 for c in comments if c['sentiment'] == 'negative')
    pos_pct = round(pos_count / max(total_count, 1) * 100, 1) if total_count > 0 else 0.0
    neg_pct = round(neg_count / max(total_count, 1) * 100, 1) if total_count > 0 else 0.0
    neu_pct = round(100.0 - pos_pct - neg_pct, 1) if total_count > 0 else 100.0

    query_cats = set()
    for c in comments:
        if c['intent_category'] == 'question':
            tl = c['text'].lower()
            if any(w in tl for w in ['counsel', 'round', 'choice', 'allotment']):
                query_cats.add('counselling')
            if any(w in tl for w in ['cutoff', 'rank', 'marks', 'percentile', 'score']):
                query_cats.add('cutoff_and_ranks')
            if any(w in tl for w in ['date', 'admit', 'exam', 'schedule', 'shift', 'postpone']):
                query_cats.add('exam_schedule')
            if any(w in tl for w in ['college', 'branch', 'iit', 'nit', 'iiit', 'aktu', 'uptu', 'placement']):
                query_cats.add('college_admission')
    if not query_cats and any(c['intent_category'] == 'question' for c in comments):
        query_cats.add('general_query')

    pinned_comment = next((c for c in comments if c['is_pinned']), None)

    # Fetch views for cpk calculation
    cur.execute("SELECT views, likes, shares FROM performance_metrics WHERE video_id = %s;", (video_id,))
    perf_row = cur.fetchone()
    views = perf_row[0] if perf_row else 0
    likes = perf_row[1] if perf_row else 0
    shares = perf_row[2] if perf_row else 0
    cpk = min(round((total_count / max(views, 1)) * 1000, 1), 9999.0)

    cur.execute("DELETE FROM comments_analysis WHERE video_id = %s;", (video_id,))
    cur.execute("""
        INSERT INTO comments_analysis (
            video_id, total_comments, comments_per_1k_views, top_level_comments,
            total_replies, max_thread_depth, avg_thread_depth, creator_replies,
            creator_reply_rate, pinned_comment_id, pinned_comment_text, hearted_comments,
            positive_sentiment_pct, negative_sentiment_pct, neutral_sentiment_pct,
            query_comments, gratitude_comments, gratitude_with_likes,
            spam_irrelevant_comments, query_categories, unanswered_high_intent_queries,
            fetched_at
        ) VALUES (
            %s, %s, %s, %s,
            %s, %s, %s, %s,
            %s, %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s,
            %s
        );
    """, (
        video_id, total_count, cpk, top_level,
        total_replies, 1 if total_replies > 0 else 0, round(total_replies / max(top_level, 1), 2), creator_replies,
        round(creator_replies / max(total_replies, 1) * 100, 1) if total_replies > 0 else 0.0,
        pinned_comment['comment_id'] if pinned_comment else None,
        pinned_comment['text'] if pinned_comment else None,
        sum(1 for c in comments if c['is_hearted']),
        pos_pct, neg_pct, neu_pct,
        sum(1 for c in comments if c['intent_category'] == 'question'),
        sum(1 for c in comments if c['intent_category'] == 'gratitude'),
        0,
        0,
        Json(sorted(list(query_cats))),
        sum(1 for c in comments if c['is_actionable']),
        now_dt
    ))

    # 4. Update performance_metrics
    if views > 0:
        new_engagement = round((likes + total_count + shares) / views * 100, 2)
        cur.execute("""
            UPDATE performance_metrics
            SET comments_count = %s, engagement_rate = %s
            WHERE video_id = %s;
        """, (total_count, new_engagement, video_id))
    else:
        cur.execute("UPDATE performance_metrics SET comments_count = %s WHERE video_id = %s;", (total_count, video_id))

    conn.commit()
    conn.close()

def main():
    parser = argparse.ArgumentParser(description="Extract 100% of comments and replies for a YouTube Short.")
    parser.add_argument("--video-id", type=str, default=None, help="11-character YouTube video ID")
    parser.add_argument("--short-id", type=int, default=None, help="Database short ID (e.g. 41)")
    parser.add_argument("--update-db", action="store_true", help="Persist extracted comments to PostgreSQL")
    parser.add_argument("--out", type=str, default=None, help="Output JSON path")
    args = parser.parse_args()

    video_id = args.video_id
    if not video_id and args.short_id:
        conn = psycopg2.connect(dbname="youtube_shorts", user="postgres", host="localhost", port=5432)
        cur = conn.cursor()
        cur.execute("SELECT video_id FROM shorts WHERE short_id = %s;", (args.short_id,))
        r = cur.fetchone()
        conn.close()
        if r:
            video_id = r[0]
        else:
            print(f"[!] Error: Short ID {args.short_id} not found in database.")
            sys.exit(1)

    if not video_id:
        video_id = "pszcrf0uTbQ"  # default to Short #41

    sys.stdout.buffer.write(f"\n=======================================================\n".encode('utf-8'))
    sys.stdout.buffer.write(f"  STARTING FULL COMMENTS EXTRACTION FOR VIDEO: {video_id}\n".encode('utf-8'))
    sys.stdout.buffer.write(f"=======================================================\n\n".encode('utf-8'))

    t0 = time.time()
    comments, reported_total = extract_all_comments(video_id)
    dur = round(time.time() - t0, 2)

    top_level_count = sum(1 for c in comments if c['depth'] == 0)
    replies_count = sum(1 for c in comments if c['depth'] > 0)
    q_count = sum(1 for c in comments if c['intent_category'] == 'question')
    g_count = sum(1 for c in comments if c['intent_category'] == 'gratitude')

    sys.stdout.buffer.write(f"[*] Extraction finished in {dur}s:\n".encode('utf-8'))
    sys.stdout.buffer.write(f"    - Reported Header Total: {reported_total}\n".encode('utf-8'))
    sys.stdout.buffer.write(f"    - Extracted Unique Comments: {len(comments)}\n".encode('utf-8'))
    sys.stdout.buffer.write(f"    - Top-Level Threads: {top_level_count}\n".encode('utf-8'))
    sys.stdout.buffer.write(f"    - Nested Replies: {replies_count}\n".encode('utf-8'))
    sys.stdout.buffer.write(f"    - Questions: {q_count} | Gratitude: {g_count}\n\n".encode('utf-8'))

    out_file = args.out or os.path.join("data", f"comments_{video_id}.json")
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump({
            'video_id': video_id,
            'reported_total': reported_total,
            'extracted_count': len(comments),
            'extracted_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'comments': comments
        }, f, indent=2, ensure_ascii=False)
    sys.stdout.buffer.write(f"[*] Saved full comments JSON to: {out_file}\n".encode('utf-8'))

    if args.update_db:
        sys.stdout.buffer.write(f"[*] Updating PostgreSQL database (individual_comments, comments_analysis, performance_metrics)...\n".encode('utf-8'))
        update_database(video_id, comments, reported_total)
        sys.stdout.buffer.write(f"[+] Successfully synced {len(comments)} comments to PostgreSQL!\n".encode('utf-8'))

    # Display sample comments
    sys.stdout.buffer.write(f"\n--- SAMPLE EXTRACTED COMMENTS ---\n".encode('utf-8'))
    for idx, c in enumerate(comments[:15]):
        prefix = "  [REPLY]" if c['depth'] > 0 else "[THREAD]"
        sys.stdout.buffer.write(f"{prefix} #{idx+1} {c['author_name']} ({c['published_raw']}) - Likes: {c['like_count']} [{c['intent_category'].upper()}]\n".encode('utf-8', 'replace'))
        sys.stdout.buffer.write(f"         \"{c['text_clean'][:90]}\"\n".encode('utf-8', 'replace'))

if __name__ == '__main__':
    main()
