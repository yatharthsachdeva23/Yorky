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
- audience_pain_points: What specific problems does this audience have RIGHT NOW?
- myths_misconceptions: What wrong beliefs do they hold about this topic?
- key_angles: Unique angles WE will cover that others miss
- structure_outline: Ordered sections for the video (each ~15 seconds)
- cta: Exact call-to-action (urgent, actionable)
- urgency_hooks: Specific urgency markers for hooks (🚨, LAST CHANCE, etc.)
- estimated_clips: Number of 15-second clips (2-6, default 4)
"""
        
        try:
            result_dict = self.llm.generate_json(prompt, self.system_prompt)
            print(f"[PLANNER] LLM result keys: {list(result_dict.keys())}")
            
            # Validate required fields
            required_fields = ['audience_pain_points', 'myths_misconceptions', 'key_angles', 'structure_outline', 'cta', 'urgency_hooks', 'estimated_clips']
            missing = [f for f in required_fields if f not in result_dict]
            if missing:
                print(f"[PLANNER] Missing fields: {missing}, using topic-aware fallback")
                raise ValueError(f"Missing fields: {missing}")
            
            # Ensure 'topic' field exists (use research topic if missing)
            if 'topic' not in result_dict:
                result_dict['topic'] = research.selected_topic
                print(f"[PLANNER] Added missing 'topic' field from research: {research.selected_topic}")
            
            result = ContentPlan(**result_dict)
            
            db.save_artifact(run.run_id, "plan", "result", result_dict)
            
            run.content_plan = result
            run.current_stage = PipelineStage.SCRIPT_WRITE
            db.update_run(run)
            
            print(f"[PLANNER] Plan created with {result.estimated_clips} clips")
            print(f"[PLANNER] Pain points: {result.audience_pain_points[:2]}...")
            return result
            
        except Exception as e:
            print(f"[PLANNER] Error: {e}, using topic-aware fallback")
            # Topic-aware fallback for JAC/Spot/Counseling topics
            is_jac_spot = any(k in research.selected_topic.upper() for k in ["JAC", "SPOT", "COUNSEL", "CHOICE", "SEAT"])
            
            if is_jac_spot:
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
                        "Exact step-by-step process for JAC spot round",
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
                        "Action plan + urgent CTA"
                    ],
                    cta="Comment your JEE rank & preferred college - I'll tell if spot round is worth it! 🚨",
                    urgency_hooks=["🚨 JAC SPOT ROUND LIVE", "LAST DATE APPROACHING", "DON'T MISS UPGRADE CHANCE"],
                    estimated_clips=4
                )
            else:
                fallback = ContentPlan(
                    topic=research.selected_topic,
                    audience_pain_points=["Overwhelmed by syllabus", "Don't know where to start", "Fear of falling behind"],
                    myths_misconceptions=["Need to finish 100% syllabus before mocks", "NCERT alone is enough", "Coaching is mandatory"],
                    key_angles=["Strategic syllabus prioritization", "Mock-first approach", "Mental framework for consistency"],
                    structure_outline=["Hook: Urgency + problem", "Myth busting", "Strategic framework", "Action plan + CTA"],
                    cta="Comment your biggest syllabus block - I'll reply with your exact next step! 🚨",
                    urgency_hooks=["🚨 AUGUST IS CRITICAL", "LAST CHANCE to fix 11th backlog", "DON'T START 12TH BLIND"],
                    estimated_clips=4
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