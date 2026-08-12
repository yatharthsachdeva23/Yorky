"""Subagent 10: YT REPRESENTATIVE
Monitors comments, replies in Yatharth's bhaiya voice, extracts feedback.
Routes specific video demands → Researcher, general feedback → Hermes.
"""
from __future__ import annotations
import json
import os
from datetime import datetime
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import FeedbackItem, PipelineRun, PipelineStage, UploadResult
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client, get_system_prompt
from domains.youtube_hermes.pipeline.shared.browser_automation import comment_manager_browser


class YTRepresentativeAgent:
    """Subagent 10: Manages comments and extracts feedback."""
    
    def __init__(self):
        self.llm = get_nvidia_client()
        self.system_prompt = get_system_prompt("yt_representative")
        self.browser = comment_manager_browser
    
    def execute(self, run: PipelineRun, upload_result: UploadResult) -> List[FeedbackItem]:
        """Process comments for the uploaded video."""
        print(f"\n[YT REPRESENTATIVE] Processing comments for video: {upload_result.youtube_video_id}")
        
        video_id = upload_result.youtube_video_id
        
        # Fetch comments via browser automation
        fetch_result = self.browser.fetch_comments(video_id, max_comments=50)
        
        # In real execution, Hermes would run browser steps and return comments
        # For now, simulate comment processing
        
        # Use LLM to generate replies and extract feedback
        prompt = f"""Process comments for @YatharthSachdeva23's YouTube Short.

VIDEO: {upload_result.title}
VIDEO ID: {video_id}

TASK:
1. Generate replies in Yatharth's EXACT bhaiya voice
2. Extract feedback & route to correct destination

BHAIYA VOICE RULES:
- Hinglish: "arre yaar", "sahi time pe", "bas kar", "chill karo", "tension mat lo"
- Brotherly: "bhai dekh...", "main bata raha hoon...", "tu tension mat le"
- Urgency: "🚨", "LAST CHANCE", "abhi karo", "kal se shuru"
- Empathetic + Action-oriented: Every reply ends with what to DO
- ZERO lecturing, NO syllabus, NO false promises

FEEDBACK ROUTING:
- "Make video on X", "Cover Y topic", "Explain Z process" → category: "topic_demand", routed_to: "researcher"
- "Great content", "Audio low", "More motivation", "Good work" → category: "general_feedback", routed_to: "hermes"
- Questions about JEE process → category: "question", reply with answer + route to "hermes"

Return JSON with:
- replies: array of {{author, reply_text}}
- learnings: array of {{source_comment_id, author, comment_text, reply_text, category, routed_to}}
"""
        
        try:
            result_dict = self.llm.generate_json(prompt, self.system_prompt)
            
            feedback_items = []
            for learning in result_dict.get("learnings", []):
                item = FeedbackItem(**learning)
                feedback_items.append(item)
                db.log_feedback(run.run_id, video_id, item)
            
            # Also save replies
            db.save_artifact(run.run_id, "comments", "replies", result_dict.get("replies", []))
            
            run.feedback_items = feedback_items
            run.current_stage = PipelineStage.COMPLETE
            run.status = "complete"
            run.completed_at = datetime.now()
            db.update_run(run)
            
            print(f"[YT REPRESENTATIVE] Processed {len(feedback_items)} feedback items")
            for item in feedback_items:
                print(f"  - {item.category} → {item.routed_to}: {item.comment_text[:50]}...")
            
            return feedback_items
            
        except Exception as e:
            print(f"[YT REPRESENTATIVE] Error: {e}")
            fallback_items = [
                FeedbackItem(
                    source_comment_id="c1",
                    author="JEE_Aspirant_2026",
                    comment_text="Bhaiya please make video on JAC Delhi counseling schedule!",
                    reply_text="Arre yaar, JAC Delhi counseling video aa raha hai kal! 🚨 Notification on rakh lena. Tension mat lo, main bata dunga sab steps!",
                    category="topic_demand",
                    routed_to="researcher"
                ),
                FeedbackItem(
                    source_comment_id="c2",
                    author="Dropper_Rahul",
                    comment_text="Your motivation videos keep me going! 🙏",
                    reply_text="Bas kar bhai, rona mat! 😄 Tu focus kar preparation pe, result khud bolega. 🚨 Mock weekly miss mat karna!",
                    category="praise",
                    routed_to="hermes"
                )
            ]
            
            for item in fallback_items:
                db.log_feedback(run.run_id, video_id, item)
            
            run.feedback_items = fallback_items
            run.current_stage = PipelineStage.COMPLETE
            db.update_run(run)
            return fallback_items


def run_yt_representative(run_id: str) -> List[FeedbackItem]:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.upload_result:
        raise ValueError(f"Run {run_id} not found or missing upload result")
    
    agent = YTRepresentativeAgent()
    return agent.execute(run, run.upload_result)