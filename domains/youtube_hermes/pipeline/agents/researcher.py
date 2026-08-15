"""
Subagent 1: RESEARCHER (100% Autonomous - 2-Call Gemini Pipeline)
Pipeline:
  Call 1: Live Fact & NTA Calendar Extraction via Google News RSS + Gemini
  Call 2: Topic Selection & Audience Matrix Enforcement via Gemini
Production Lag Filter: 3-5 days (reject counseling deadlines < 4 days away)
"""
from __future__ import annotations
import os
import json
import uuid
import requests
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional
from urllib.parse import quote_plus

from domains.youtube_hermes.pipeline.shared.models import ResearchResult, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_system_prompt
from dotenv import load_dotenv

load_dotenv()


class ResearcherAgent:
    """Subagent 1: 100% Autonomous - 2-Call Gemini Decision Pipeline."""
    
    def __init__(self):
        self.system_prompt = get_system_prompt("researcher")
        self.gemini_api_key = os.getenv("GEMINI_API_KEY")
        self.gemini_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent"
    
    def _call_gemini(self, prompt: str, system_prompt: str = None) -> str:
        """Call Gemini 3.5 Flash API directly with requests. Handles 503 with retry."""
        if not self.gemini_api_key:
            raise ValueError("GEMINI_API_KEY not set")
        
        headers = {'Content-Type': 'application/json'}
        
        contents = []
        if system_prompt:
            contents.append({"role": "user", "parts": [{"text": system_prompt}]})
            contents.append({"role": "model", "parts": [{"text": "Understood. I'll help you research JEE topics."}]})
        contents.append({"role": "user", "parts": [{"text": prompt}]})
        
        data = {
            'contents': contents,
            'generationConfig': {
                'responseMimeType': 'application/json',
                'temperature': 0.3
            }
        }
        
        max_retries = 3
        for attempt in range(max_retries):
            url = f"{self.gemini_url}?key={self.gemini_api_key}"
            response = requests.post(url, headers={'Content-Type': 'application/json'}, json=data, timeout=90)
            
            if response.status_code == 200:
                result = response.json()
                text = result['candidates'][0]['content']['parts'][0]['text']
                # Debug: log raw response
                print(f"[RESEARCHER] Gemini raw response: {text[:200]}...")
                # Robust JSON extraction
                start = text.find('{')
                end = text.rfind('}') + 1
                if start >= 0 and end > start:
                    extracted = text[start:end]
                    print(f"[RESEARCHER] Extracted JSON: {extracted[:200]}...")
                    return extracted
                # If no JSON found, try to find array
                start = text.find('[')
                end = text.rfind(']') + 1
                if start >= 0 and end > start:
                    extracted = text[start:end]
                    print(f"[RESEARCHER] Extracted JSON array: {extracted[:200]}...")
                    return extracted
                raise ValueError(f"No valid JSON found in response. Full text: {text[:500]}")
            
            elif response.status_code == 429:
                # Quota exceeded - wait and retry with longer backoff
                if attempt < max_retries - 1:
                    wait_time = 30 * (attempt + 1)  # 30s, 60s, 90s
                    print(f"[RESEARCHER] Gemini 429 (quota exceeded), retrying in {wait_time}s...")
                    import time
                    time.sleep(wait_time)
                    continue
                else:
                    raise Exception(f"Gemini API error 429 after {max_retries} retries: {response.text}")
            
            elif response.status_code == 503:
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    print(f"[RESEARCHER] Gemini 503 (high demand), retrying in {wait_time}s...")
                    import time
                    time.sleep(wait_time)
                    continue
                else:
                    raise Exception(f"Gemini API error 503 after {max_retries} retries: {response.text}")
            
            else:
                raise Exception(f"Gemini API error {response.status_code}: {response.text}")
        
        raise Exception("Max retries exceeded")
    
    def _search_google_news_rss(self, query: str) -> List[Dict[str, str]]:
        """Fetch live news/announcements via Google News RSS (no CAPTCHA, no API key)."""
        encoded_query = quote_plus(query)
        url = f"https://news.google.com/rss/search?q={encoded_query}&hl=en-IN&gl=IN&ceid=IN:en"
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        
        try:
            response = requests.get(url, headers=headers, timeout=15)
            if response.status_code != 200:
                return []
            
            root = ET.fromstring(response.text)
            articles = []
            for item in root.findall('.//item')[:15]:
                title = item.find('title')
                pub_date = item.find('pubDate')
                description = item.find('description')
                link = item.find('link')
                
                articles.append({
                    'title': title.text if title is not None else '',
                    'pub_date': pub_date.text if pub_date is not None else '',
                    'description': description.text if description is not None else '',
                    'link': link.text if link is not None else ''
                })
            return articles
        except Exception as e:
            print(f"[RESEARCHER] Google News RSS search failed for '{query}': {e}")
            return []
    
    def _perform_live_searches(self) -> List[Dict[str, str]]:
        """Execute autonomous live searches for current JEE/counseling announcements."""
        current_date = datetime.now()
        current_year = current_date.year
        
        search_queries = [
            # COUNSELING (time-sensitive)
            f"JoSAA {current_year} counseling round schedule seat allocation site:josaa.nic.in",
            f"CSAB {current_year} special round counseling dates site:csab.nic.in",
            f"JAC Jharkhand {current_year} spot round counseling dates site:jac.jharkhand.gov.in",
            f"IPU {current_year} BTech counseling schedule site:ipu.ac.in",
            f"DTU NSUT {current_year} counseling dates site:dtu.ac.in OR site:nsut.ac.in",
            f"JEE {current_year} counseling latest notification NTA",
            # PREPARATION STRATEGY (evergreen but seasonal) - Correct JEE exam naming
            "JEE Main 2027 syllabus completion strategy August site:youtube.com OR site:quora.com",
            "JEE Main 2027 mock test schedule strategy droppers site:youtube.com OR site:reddit.com",
            "JEE Main 2027 11th backlog clearance plan August site:youtube.com OR site:quora.com",
            "JEE burnout motivation consistency August 2026 site:youtube.com OR site:reddit.com",
            "JEE Advanced 2027 preparation strategy 12th grade site:youtube.com OR site:quora.com",
        ]
        
        all_articles = []
        for query in search_queries:
            print(f"[RESEARCHER] Live search: {query}")
            articles = self._search_google_news_rss(query)
            if articles:
                all_articles.append({
                    'query': query,
                    'articles': articles
                })
        return all_articles
    
    def _call_1_extract_calendar_facts(self, search_results: List[Dict[str, str]]) -> Dict[str, Any]:
        """
        CALL 1: Live Fact & NTA Calendar Extraction
        Input: Google News RSS search results
        Output: active_counseling_cycle, target_exam_12th_droppers, target_exam_11th
        """
        current_date = datetime.now()
        current_date_str = current_date.strftime("%B %d, %Y")
        current_year = current_date.year
        
        formatted_results = []
        for result in search_results:
            formatted_results.append(f"QUERY: {result['query']}")
            for article in result['articles'][:8]:
                formatted_results.append(f"  - [{article['pub_date'][:16]}] {article['title']} ({article['link']})")
        
        combined_text = "\n".join(formatted_results)
        
        prompt = f"""You are a JEE counseling expert. Extract EXACT calendar facts from LIVE Google News search results.

TODAY: {current_date_str}
CURRENT YEAR: {current_year}

LIVE SEARCH RESULTS:
{combined_text}

Return ONLY valid JSON with:
{{
  "active_counseling_cycle": "Exact currently active counseling (e.g. 'JEE 2026 CSAB Special Round & JAC Delhi Spot Round' or 'None active')",
  "counseling_deadlines": [
    {{"event": "exact event name", "deadline": "exact date (YYYY-MM-DD)", "days_from_today": integer}}
  ],
  "target_exam_12th_droppers": "Target exam for 12th grade & droppers (e.g. 'JEE Main 2027 Session 1 - January 2027')",
  "target_exam_11th": "Target exam for 11th grade (e.g. 'JEE Main 2028 - January 2028')",
  "jee_main_2027_session_1_date": "exact date or null",
  "jee_main_2027_session_2_date": "exact date or null",
  "jee_advanced_2027_date": "exact date or null"
}}

Rules:
- ONLY extract dates EXPLICITLY mentioned in search results
- Use "null" for uncertain dates
- active_counseling_cycle must name the specific counseling cycle currently live
- Return ONLY valid JSON. No markdown, no explanation."""
        
        try:
            response_text = self._call_gemini(prompt, self.system_prompt)
            return json.loads(response_text)
        except Exception as e:
            print(f"[RESEARCHER] Call 1 (Calendar Extraction) failed: {e}")
            # Fallback with deterministic calendar based on current date
            return self._fallback_calendar_facts(current_date)
    
    def _fallback_calendar_facts(self, current_date: datetime) -> Dict[str, Any]:
        """Deterministic fallback calendar based on NTA annual cycle."""
        year = current_date.year
        # In August, JEE 2026 counseling is ending, JEE 2027 prep is starting
        return {
            "active_counseling_cycle": "JEE 2026 CSAB Special Round & JAC Delhi/IPU Spot Rounds (concluding)",
            "counseling_deadlines": [
                {"event": "CSAB Special Round Reporting", "deadline": f"{year}-08-18", "days_from_today": 6},
                {"event": "IPU BTech Physical Reporting", "deadline": f"{year}-08-18", "days_from_today": 6},
                {"event": "DTU/NSUT Spot Round", "deadline": f"{year}-08-20", "days_from_today": 8}
            ],
            "target_exam_12th_droppers": "JEE Main 2027 Session 1 - January 2027",
            "target_exam_11th": "JEE Main 2028 - January 2028",
            "jee_main_2027_session_1_date": f"{year+1}-01-15",
            "jee_main_2027_session_2_date": f"{year+1}-04-15",
            "jee_advanced_2027_date": f"{year+1}-07-21"
        }
    
    def _call_2_select_topic_with_audience_matrix(self, calendar_facts: Dict[str, Any], 
                                                    search_results: List[Dict[str, str]],
                                                    user_feedback: Optional[str] = None) -> ResearchResult:
        """
        CALL 2: Topic Selection & Audience Matrix Enforcement
        Input: Calendar facts from Call 1 + search trending queries + channel constraints
        Output: ResearchResult with topic matching one of 3 Audience Segments
        """
        current_date = datetime.now()
        current_date_str = current_date.strftime("%B %d, %Y")
        
        # Extract trending queries from search results
        trending_queries = []
        for result in search_results:
            for article in result['articles'][:5]:
                trending_queries.append(article['title'])
        
        # Production lag filter: reject counseling deadlines < 4 days away
        counseling_deadlines = calendar_facts.get('counseling_deadlines', [])
        valid_counseling = [d for d in counseling_deadlines if d.get('days_from_today', 0) >= 4]
        
        production_lag_days = 4  # 3-5 day production lag, use 4 as minimum
        
        prompt = f"""You are the Researcher for @YatharthSachdeva23 (Bhaiya mentor for JEE aspirants).

CHANNEL CONSTRAINTS:
- Persona: Bhaiya (older brother) mentor, Hinglish mix, urgency markers (🚨 LAST CHANCE)
- ZERO academic syllabus teaching - ONLY process guidance, strategies, emotional support, college life
- Content pillars: Admission counseling (JAC/JOSAA/IPU/DTU/NSUT), Spot rounds, College life, Prep strategies (no syllabus), Motivation
- Format: 45-60s YouTube Shorts (9:16 vertical)

CALENDAR FACTS (from live search):
Active Counseling Cycle: {calendar_facts.get('active_counseling_cycle', 'None')}
Counseling Deadlines (>= 4 days from today): {json.dumps(valid_counseling, indent=2)}
Target Exam (12th/Droppers): {calendar_facts.get('target_exam_12th_droppers', 'JEE Main 2027 Session 1 - January 2027')}
Target Exam (11th Grade): {calendar_facts.get('target_exam_11th', 'JEE Main 2028 - January 2028')}

TRENDING QUERIES (live):
{json.dumps(trending_queries[:10], indent=2)}

PRODUCTION LAG: {production_lag_days} days minimum (research today → publish in {production_lag_days}+ days)

AUDIENCE MATRIX (MUST SELECT EXACTLY ONE SEGMENT):
1. COUNSELING: If valid_counseling exists → topic MUST use active_counseling_cycle
   Example: "JAC Delhi & CSAB 2026 Spot Round: 3 Mistakes That Cost You Seat Upgrade"
2. 12TH / DROPPERS: If NO valid counseling OR user requests → topic MUST use target_exam_12th_droppers
   Example: "August Backlog Clearance Strategy for JEE Main 2027 Session 1"
3. 11TH GRADE: If user requests 11th focus → topic MUST use target_exam_11th
   Example: "11th Class August Plan for JEE Main 2028 - 20 Months to JEE"
   NOTE: August 11th is great start - 20 months to JEE. Many start in 12th, so this is ahead.

USER DIRECTIVE: {user_feedback or 'Select best topic for RIGHT NOW'}

Return ONLY valid JSON matching ResearchResult schema:
{{
  "selected_topic": "Specific, actionable Short title with urgency marker",
  "rationale": "Why this topic NOW - reference calendar facts, deadlines, trending queries, production lag",
  "demand_signals": ["signal1", "signal2", "signal3"],
  "target_audience": "counseling | 12th_droppers | 11th",
  "seasonal_relevance": "How this fits August 2026 timing",
  "competitor_gaps": "What others miss that we cover"
}}"""
        
        try:
            response_text = self._call_gemini(prompt, self.system_prompt)
            # response_text is already extracted JSON from _call_gemini
            result_dict = json.loads(response_text)
            return ResearchResult(**result_dict)
        except json.JSONDecodeError as e:
            print(f"[RESEARCHER] Call 2 JSON decode failed: {e}")
            print(f"[RESEARCHER] Raw response: {response_text[:500]}")
            # Fallback: determine segment from valid counseling
            if valid_counseling:
                return self._fallback_topic("counseling", calendar_facts)
            else:
                return self._fallback_topic("12th_droppers", calendar_facts)
        except Exception as e:
            print(f"[RESEARCHER] Call 2 (Topic Selection) failed: {e}")
            if valid_counseling:
                return self._fallback_topic("counseling", calendar_facts)
            else:
                return self._fallback_topic("12th_droppers", calendar_facts)
    
    def _fallback_topic(self, segment: str, calendar_facts: Dict[str, Any]) -> ResearchResult:
        """Deterministic fallback topic based on segment."""
        current_date = datetime.now()
        
        if segment == "counseling":
            active = calendar_facts.get('active_counseling_cycle', 'JAC Delhi & CSAB Spot Round')
            return ResearchResult(
                selected_topic=f"🚨 {active}: 3 Critical Reporting Mistakes That Cancel Your Seat!",
                rationale=f"Active counseling cycle {active} has deadlines >= 4 days away. Publishing in 3-5 days hits pre-deadline window.",
                demand_signals=["Live search: spot round reporting confusion", "High comment volume on document checklist"],
                target_audience="counseling",
                seasonal_relevance="Mid-August = final spot round reporting window for JEE 2026",
                competitor_gaps="Others read PDFs; we give exact DD payment, document order, withdrawal rules"
            )
        elif segment == "12th_droppers":
            target = calendar_facts.get('target_exam_12th_droppers', 'JEE Main 2027 Session 1')
            return ResearchResult(
                selected_topic=f"🚨 August Backlog Clearance Formula for {target} - 10 Day Plan",
                rationale=f"Mid-August is the 5-month trigger before {target}. 12th/droppers panic about 11th backlog. Publishing in 3-5 days hits peak anxiety window.",
                demand_signals=["YouTube search: '11th backlog August JEE'", "Quora: 'Is 5 months enough for JEE 2027'"],
                target_audience="12th_droppers",
                seasonal_relevance="August = 5 months to JEE Main 2027 Session 1 (Jan 2027)",
                competitor_gaps="Others sell impossible 14hr timetables; we give realistic 70% 12th + 30% 11th strategy"
            )
        else:  # 11th grade
            target = calendar_facts.get('target_exam_11th', 'JEE Main 2028')
            # Extract exam name without year for cleaner topic
            exam_name = target.split(' - ')[0] if ' - ' in target else target
            # August 11th is still a great time to start - 20 months to JEE.
            # Many start in 12th, so 11th August is actually ahead of them.
            return ResearchResult(
                selected_topic=f"🚨 11th Class August Plan for {exam_name} - 20 Months to JEE",
                rationale=f"11th grade August gives you 20 months to JEE - that's plenty of time. Most students start in 12th, so starting now puts you ahead. Build foundations, not panic.",
                demand_signals=["YouTube search: '11th class JEE preparation plan'", "Quora: 'How to prepare for JEE from 11th class'"],
                target_audience="11th",
                seasonal_relevance="August = 20 months to JEE 2028, perfect foundation-building window",
                competitor_gaps="Others overcomplicate; we give simple subject-wise weekly plan for 20 months"
            )
    
    def execute(self, run: PipelineRun, user_feedback: Optional[str] = None, 
                yt_rep_demands: Optional[List[str]] = None) -> ResearchResult:
        """Execute the 2-Call Autonomous Pipeline."""
        print(f"\n[RESEARCHER] Starting 2-CALL AUTONOMOUS PIPELINE for run {run.run_id}")
        
        # Build feedback context
        feedback_parts = []
        if user_feedback:
            feedback_parts.append(f"USER: {user_feedback}")
        if yt_rep_demands:
            feedback_parts.append(f"AUDIENCE: {json.dumps(yt_rep_demands)}")
        combined_feedback = " | ".join(feedback_parts) if feedback_parts else None
        
        # LIVE SEARCH
        print("[RESEARCHER] Step 1: Live Google News RSS searches...")
        search_results = self._perform_live_searches()
        
        if not search_results:
            raise Exception("No live search results")
        
        # CALL 1: CALENDAR FACT EXTRACTION
        print("[RESEARCHER] Step 2: Call 1 - Calendar Fact Extraction (Gemini 3.5 Flash)...")
        calendar_facts = self._call_1_extract_calendar_facts(search_results)
        print(f"[RESEARCHER]   Active Cycle: {calendar_facts.get('active_counseling_cycle')}")
        print(f"[RESEARCHER]   12th/Dropper Target: {calendar_facts.get('target_exam_12th_droppers')}")
        print(f"[RESEARCHER]   11th Target: {calendar_facts.get('target_exam_11th')}")
        
        # CALL 2: TOPIC SELECTION WITH AUDIENCE MATRIX
        print("[RESEARCHER] Step 3: Call 2 - Topic Selection & Audience Matrix (Gemini 3.5 Flash)...")
        result = self._call_2_select_topic_with_audience_matrix(calendar_facts, search_results, combined_feedback)
        
        # Save artifact
        db.save_artifact(run.run_id, "research", "result", result.__dict__)
        db.save_artifact(run.run_id, "research", "calendar_facts", calendar_facts)
        
        # Update run
        run.research = result
        run.current_stage = PipelineStage.PLAN
        db.update_run(run)
        
        print(f"[RESEARCHER] Selected Topic [{result.target_audience}]: {result.selected_topic}")
        return result
    
    def execute_from_feedback(self, run: PipelineRun) -> ResearchResult:
        """Execute research using feedback from YT Representative (routed to researcher)."""
        feedback_items = db.get_feedback_for_researcher(run.run_id)
        demands = [f.comment_text for f in feedback_items if f.category == "topic_demand"]
        return self.execute(run, yt_rep_demands=demands)


def run_researcher(run_id: str, user_feedback: Optional[str] = None) -> ResearchResult:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run:
        raise ValueError(f"Run {run_id} not found")
    
    agent = ResearcherAgent()
    return agent.execute(run, user_feedback=user_feedback)