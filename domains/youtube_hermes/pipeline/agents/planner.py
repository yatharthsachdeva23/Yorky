"""
Subagent 2: PLANNER
Deep-dives the selected topic and creates CONTENT STRUCTURE (not script).
Identifies audience pain points, myths, misconceptions, key angles, and structure outline.
"""
from __future__ import annotations
import json
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage, ResearchResult
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client, get_system_prompt


class PlannerAgent:
    """Subagent 2: Plans video content structure from research topic."""

    def __init__(self):
        self.llm = get_nvidia_client()
        self.system_prompt = get_system_prompt("planner")

    def _sanitize_cta(self, cta: str) -> str:
        """Ensure CTA is generic - no personalized reply promises."""
        if not cta:
            return "Like, share, subscribe, and comment! 🚨"
        
        cta_lower = cta.lower()
        # Detect personalized reply promises
        personalized_indicators = [
            "i'll tell", "i'll reply", "i will tell", "i will reply",
            "i'll answer", "i will answer", "i'll respond", "i will respond",
            "dm me", "direct message", "personal reply", "reply to each",
            "tell you", "guide you", "help you", "mentor you"
        ]
        
        if any(ind in cta_lower for ind in personalized_indicators):
            return "Like, share, subscribe, and comment! 🚨"
        
        # Ensure it has generic engagement words
        if not any(word in cta_lower for word in ["like", "share", "subscribe", "comment"]):
            return "Like, share, subscribe, and comment! 🚨"
        
        return cta

    def execute(self, run: PipelineRun, research: ResearchResult) -> ContentPlan:
        """Create content plan from research result."""
        print(f"\n[PLANNER] Creating content plan for: {research.selected_topic}")

        prompt = f"""Create a CONTENT STRUCTURE (not script) for a YouTube Short on this JEE topic.

SELECTED TOPIC: {research.selected_topic}
RATIONALE: {research.rationale}
TARGET AUDIENCE: {research.target_audience}
SEASONAL RELEVANCE: {research.seasonal_relevance}
DEMAND SIGNALS: {json.dumps(research.demand_signals)}
COMPETITOR GAPS: {json.dumps(research.competitor_gaps)}

CHANNEL CONSTRAINTS (NON-NEGOTIABLE):
- @YatharthSachdeva23 - Bhaiya mentor for JEE aspirants
- ZERO academic teaching - NO syllabus explanation, NO subject concepts
- ONLY: Process guidance, strategies, emotional support, college life insights, admission counseling
- Content pillars: JAC/JOSAA/IPU/DTU/NSUT counseling, Spot rounds, College life, Prep STRATEGIES (not syllabus), Motivation
- Voice: Hinglish mix, urgency markers (🚨 LAST CHANCE), brotherly empathy, action-oriented
- Hook in first 3 seconds mandatory
- Every piece ends with clear "what to do next"

Return JSON with:
- audience_pain_points: What specific problems does this audience have RIGHT NOW? (5 items)
- myths_misconceptions: What wrong beliefs do they hold? (OPTIONAL - empty list if not applicable)
- key_angles: Unique angles WE will cover that others miss (5 items)
- structure_outline: Ordered sections for the video (each ~15 seconds, 4-6 sections)
- cta: Generic call-to-action - "Like, share, subscribe, comment" style (NOT personalized replies)
- urgency_hooks: Specific urgency markers for hooks (🚨, LAST CHANCE, etc.)
"""

        try:
            result_dict = self.llm.generate_json(prompt, self.system_prompt)
            print(f"[PLANNER] LLM result keys: {list(result_dict.keys())}")

            # Validate required fields (myths_misconceptions is optional)
            required_fields = ['audience_pain_points', 'key_angles', 'structure_outline', 'cta', 'urgency_hooks']
            missing = [f for f in required_fields if f not in result_dict]
            if missing:
                print(f"[PLANNER] Missing fields: {missing}, using topic-aware fallback")
                raise ValueError(f"Missing fields: {missing}")

            # Ensure myths_misconceptions exists (optional)
            if 'myths_misconceptions' not in result_dict:
                result_dict['myths_misconceptions'] = []

            # Remove estimated_clips if present (no longer in model)
            if 'estimated_clips' in result_dict:
                del result_dict['estimated_clips']

            # Ensure 'topic' field exists (use research topic if missing)
            if 'topic' not in result_dict:
                result_dict['topic'] = research.selected_topic
                print(f"[PLANNER] Added missing 'topic' field from research: {research.selected_topic}")

            # Sanitize CTA to be generic (no personalized replies)
            result_dict['cta'] = self._sanitize_cta(result_dict.get('cta', ''))

            result = ContentPlan(**result_dict)

            db.save_artifact(run.run_id, "plan", "result", result_dict)

            run.content_plan = result
            run.current_stage = PipelineStage.SCRIPT_WRITE
            db.update_run(run)

            print(f"[PLANNER] Plan created with {len(result.structure_outline)} sections")
            print(f"[PLANNER] Pain points: {result.audience_pain_points[:2]}...")
            return result

        except Exception as e:
            print(f"[PLANNER] Error: {e}, using topic-aware fallback")
            # Topic-aware fallback based on research.target_audience segment
            return self._fallback_plan(run, research)

    def _fallback_plan(self, run: PipelineRun, research: ResearchResult) -> ContentPlan:
        """Generate topic-aware fallback plan based on audience segment AND topic keywords."""
        audience = research.target_audience
        topic_lower = research.selected_topic.lower()
        
        # Check for specific decision/dilemma topics - use word boundaries for precision
        import re
        is_drop_vs_college = any(re.search(rf'\b{re.escape(k)}\b', topic_lower) for k in ["drop year", "lower college", "join college", "worth it", "drop vs"])
        is_mock_strategy = any(re.search(rf'\b{re.escape(k)}\b', topic_lower) for k in ["mock", "test strategy", "attempt", "importance"])
        is_backlog = any(re.search(rf'\b{re.escape(k)}\b', topic_lower) for k in ["backlog", "11th", "clearance"])
        
        if audience == "counseling":
            fallback = ContentPlan(
                topic=research.selected_topic,
                audience_pain_points=[
                    "Confused about spot round dates and deadlines",
                    "Don't know eligibility criteria for branch upgrade",
                    "Fear of missing document verification",
                    "Unsure how choice filling works in spot round",
                    "Anxiety about missing better college options"
                ],
                myths_misconceptions=[
                    "Spot round is only for leftovers",
                    "Can't upgrade after JoSAA rounds",
                    "State counseling is only for low ranks",
                    "Documents needed are same as main counseling",
                    "Branch upgrade not worth the hassle"
                ],
                key_angles=[
                    "Exact step-by-step process for spot round",
                    "Document checklist specific to state counseling",
                    "Branch upgrade strategy: when to float vs freeze",
                    "Timeline: from choice filling to reporting",
                    "Common mistakes that cost seats"
                ],
                structure_outline=[
                    "Hook: Urgency + exact deadline",
                    "Eligibility & key dates breakdown",
                    "Step-by-step choice filling process",
                    "Document checklist + common mistakes",
                    "Action plan + CTA"
                ],
                cta="Like, share, subscribe, and comment your questions! 🚨",
                urgency_hooks=["🚨 SPOT ROUND LIVE", "LAST DATE APPROACHING", "DON'T MISS UPGRADE CHANCE"]
            )
        elif audience == "12th_droppers":
            # Specific fallback for drop vs college dilemma
            if is_drop_vs_college:
                fallback = ContentPlan(
                    topic=research.selected_topic,
                    audience_pain_points=[
                        "Can't decide between dropping a year vs accepting lower college seat",
                        "Fear of wasting a year if drop doesn't improve rank",
                        "Uncertainty about ROI of lower-tier colleges vs drop year cost",
                        "Pressure from parents/peers to just 'take admission somewhere'",
                        "No clear framework to make this life-changing decision"
                    ],
                    myths_misconceptions=[
                        "Dropping guarantees better rank next year",
                        "Lower college means career is over",
                        "Everyone who drops succeeds",
                        "College brand matters more than your skills",
                        "You can't prepare well while in college"
                    ],
                    key_angles=[
                        "Decision matrix: rank bands vs college tiers vs drop probability",
                        "ROI calculation: drop year cost (time/money) vs college placement data",
                        "Personal factors checklist: mental resilience, support system, financials",
                        "What successful droppers did differently vs those who regretted",
                        "Middle path: join college + prepare for JEE (if feasible)"
                    ],
                    structure_outline=[
                        "Hook: The brutal truth nobody tells you about drop vs college",
                        "Decision matrix: your rank band → what data says",
                        "ROI reality check: drop year cost vs college outcomes",
                        "5-question personal checklist to decide YOUR path",
                        "CTA: Like, share, subscribe, comment your rank & dilemma!"
                    ],
                    cta="Like, share, subscribe, and comment your rank & dilemma! 🚨",
                    urgency_hooks=["🚨 COUNSELING ENDING SOON", "LAST CHANCE TO DECIDE", "DROP OR JOIN - DECIDE TODAY"]
                )
            # Specific fallback for mock strategy
            elif is_mock_strategy:
                fallback = ContentPlan(
                    topic=research.selected_topic,
                    audience_pain_points=[
                        "Believe they must finish the entire syllabus before attempting any mock test",
                        "Feel demotivated by low scores in early mocks and think they are wasting time",
                        "Do not know how to analyze mock tests to improve their preparation",
                        "Struggle with time management and question selection during practice",
                        "Experience anxiety about the exam pattern and lack real-exam temperament"
                    ],
                    myths_misconceptions=[
                        "Mock tests are only useful after completing the syllabus",
                        "You need to score 90%+ in mocks for them to be worthwhile",
                        "More mocks automatically lead to higher scores without analysis",
                        "Mock tests are identical to the actual JEE Main paper",
                        "Analyzing a mock test takes too much time and reduces study hours"
                    ],
                    key_angles=[
                        "Mocks as a diagnostic tool to reveal gaps in real time",
                        "Building exam temperament and reducing fear through early exposure",
                        "Using mock scores to adjust study plan and prioritize weak topics",
                        "Practicing time-bound question selection and elimination strategies",
                        "Turning low-score mocks into actionable feedback loops for improvement"
                    ],
                    structure_outline=[
                        "Hook: Why waiting for 'syllabus finish' is your biggest mistake",
                        "Why mocks matter NOW: diagnosis, temperament, study guidance",
                        "How to attempt a mock strategically: timer, guesses, time per section",
                        "Post-mock analysis routine: categorize mistakes, update weak-topic list",
                        "CTA: Every mock counts - start today!"
                    ],
                    cta="Like, share, subscribe, and comment your mock test doubts below! 🚨",
                    urgency_hooks=["🚨 5 MONTHS TO JEE", "LAST CHANCE TO START MOCKS", "DON'T WAIT FOR SYLLABUS FINISH"]
                )
            # Specific fallback for backlog clearance
            elif is_backlog:
                fallback = ContentPlan(
                    topic=research.selected_topic,
                    audience_pain_points=[
                        "11th backlog overwhelming with 12th syllabus",
                        "Don't know which chapters to prioritize in 5 months",
                        "Fear of not completing syllabus before mocks",
                        "Confused about mock test strategy vs syllabus completion",
                        "Burnout from trying to do everything at once"
                    ],
                    myths_misconceptions=[
                        "Must finish 100% syllabus before first mock",
                        "NCERT alone is enough for JEE",
                        "14-hour study timetable is required",
                        "Droppers have advantage over 12th students",
                        "Coaching material is mandatory"
                    ],
                    key_angles=[
                        "70% 12th + 30% targeted 11th backlog strategy",
                        "Mock-first approach: learn from tests, not just syllabus",
                        "High-yield chapters that give 80% marks",
                        "Realistic weekly schedule (not impossible timetables)",
                        "Mental framework for consistency over intensity"
                    ],
                    structure_outline=[
                        "Hook: 5 months reality check + urgency",
                        "Myth busting: what actually works",
                        "Strategic framework: 70/30 split + mock cycle",
                        "Weekly action plan + high-yield chapters",
                        "CTA: Like, share, subscribe, comment your target!"
                    ],
                    cta="Like, share, subscribe, and comment your target college! 🚨",
                    urgency_hooks=["🚨 5 MONTHS LEFT", "LAST CHANCE TO FIX BACKLOG", "DON'T START MOCKS BLIND"]
                )
            else:
                # Generic 12th_droppers fallback
                fallback = ContentPlan(
                    topic=research.selected_topic,
                    audience_pain_points=[
                        "11th backlog overwhelming with 12th syllabus",
                        "Don't know which chapters to prioritize in 5 months",
                        "Fear of not completing syllabus before mocks",
                        "Confused about mock test strategy vs syllabus completion",
                        "Burnout from trying to do everything at once"
                    ],
                    myths_misconceptions=[
                        "Must finish 100% syllabus before first mock",
                        "NCERT alone is enough for JEE",
                        "14-hour study timetable is required",
                        "Droppers have advantage over 12th students",
                        "Coaching material is mandatory"
                    ],
                    key_angles=[
                        "70% 12th + 30% targeted 11th backlog strategy",
                        "Mock-first approach: learn from tests, not just syllabus",
                        "High-yield chapters that give 80% marks",
                        "Realistic weekly schedule (not impossible timetables)",
                        "Mental framework for consistency over intensity"
                    ],
                    structure_outline=[
                        "Hook: 5 months reality check + urgency",
                        "Myth busting: what actually works",
                        "Strategic framework: 70/30 split + mock cycle",
                        "Weekly action plan + high-yield chapters",
                        "CTA: Like, share, subscribe, comment your target!"
                    ],
                    cta="Like, share, subscribe, and comment your target college! 🚨",
                    urgency_hooks=["🚨 5 MONTHS LEFT", "LAST CHANCE TO FIX BACKLOG", "DON'T START MOCKS BLIND"]
                )
        else:  # 11th grade
            fallback = ContentPlan(
                topic=research.selected_topic,
                audience_pain_points=[
                    "Overwhelmed by JEE syllabus size in 11th",
                    "Don't know where to start with 20 months",
                    "School + JEE balance seems impossible",
                    "Fear of falling behind peers who started earlier",
                    "Confused about foundation vs advanced topics"
                ],
                myths_misconceptions=[
                    "Must solve advanced problems in 11th",
                    "Coaching is mandatory from day 1",
                    "NCERT is too basic for JEE",
                    "Need to study 10+ hours daily",
                    "11th marks don't matter for JEE"
                ],
                key_angles=[
                    "20-month roadmap: foundation first, advanced later",
                    "School + JEE integration (not separation)",
                    "Subject-wise weekly milestones for 20 months",
                    "When to start mocks, when to finish NCERT",
                    "Simple habit system: 2-3 focused hours daily"
                ],
                structure_outline=[
                    "Hook: 20 months is plenty - here's the proof",
                    "Myth busting: what 11th actually needs",
                    "20-month roadmap: Phase 1, 2, 3 breakdown",
                    "Daily/weekly habit system (not timetable)",
                    "CTA: Like, share, subscribe, comment your stream!"
                ],
                cta="Like, share, subscribe, and comment your stream! 🚨",
                urgency_hooks=["🚨 20 MONTHS TO JEE", "START RIGHT, NOT FAST", "BUILD FOUNDATIONS NOW"]
            )

        db.save_artifact(run.run_id, "plan", "result", fallback.__dict__)

        run.content_plan = fallback
        run.current_stage = PipelineStage.SCRIPT_WRITE
        db.update_run(run)
        return fallback


def run_planner(run_id: str) -> ContentPlan:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.research:
        raise ValueError(f"Run {run_id} not found or missing research")

    agent = PlannerAgent()
    return agent.execute(run, run.research)