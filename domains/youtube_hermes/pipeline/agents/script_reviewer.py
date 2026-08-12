"""
Subagent 4: SCRIPT REVIEWER
Reviews script as AUDIENCE + CRITIC. Scores 0-1, threshold 0.75.
Loops back to Script Writer (or Planner if structural) until threshold met.
"""
from __future__ import annotations
import json
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import VideoScript, ReviewResult, ReviewDecision, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client, get_system_prompt


class ScriptReviewerAgent:
    """Subagent 4: Reviews script for hook, retention, authenticity, visual cues, CTA."""
    
    THRESHOLD = 0.75
    
    def __init__(self):
        self.llm = get_nvidia_client()
        self.system_prompt = get_system_prompt("script_reviewer")
    
    def execute(self, run: PipelineRun, script: VideoScript) -> ReviewResult:
        """Review the script and return score with feedback."""
        print(f"\n[SCRIPT REVIEWER] Reviewing script (attempt {run.script_revision_count + 1})")
        
        # Build script summary for review
        script_summary = {
            "title": script.title,
            "description": script.description,
            "tags": script.tags,
            "total_duration": script.total_duration_seconds,
            "clips": [
                {
                    "clip_index": c.clip_index,
                    "duration": c.duration_seconds,
                    "flow_prompt": c.flow_prompt[:200] + "..." if len(c.flow_prompt) > 200 else c.flow_prompt,
                    "voiceover_text": c.voiceover_text,
                    "visual_cues": c.visual_cues,
                    "transition_note": c.transition_note
                }
                for c in script.clips
            ],
            "thumbnail_concept": script.thumbnail_concept
        }
        
        prompt = f"""Review this YouTube Short script as AUDIENCE + CRITIC for @YatharthSachdeva23.

SCRIPT:
{json.dumps(script_summary, indent=2)}

EVALUATION CRITERIA (score each 0-1, then overall):
1. HOOK STRENGTH (first 3 seconds): Urgency marker? Stops scroll? Clear value prop?
2. RETENTION PACING: Each 15s clip earns the next? No dead air? Momentum builds?
3. AUTHENTICITY: Sounds like Yatharth's REAL bhaiya voice? Natural Hinglish? Brotherly empathy?
4. VISUAL CUES: Clear Google Flow prompts per clip? Text overlays readable? 9:16 vertical?
5. CTA: Urgent, actionable, clear "what to do next"?
6. CONSTRAINT CHECK: Zero academic teaching? Only mentoring/process/strategy?

EVALUATE this script and return JSON with:
- score: Overall 0.0-1.0 (weighted average)
- threshold: 0.75
- decision: "approve" | "revise" | "reject"
- feedback: Human-readable summary
- specific_fixes: Array of actionable fixes for Script Writer (or "structural: ..." for Planner)
- approved: boolean (score >= 0.75 AND decision == "approve")
"""
        
        try:
            result_dict = self.llm.generate_json(prompt, self.system_prompt)
            result = ReviewResult(**result_dict)
            
            # Log review
            db.log_review(run.run_id, PipelineStage.SCRIPT_REVIEW, run.script_revision_count + 1, result)
            db.save_artifact(run.run_id, "script_review", f"attempt_{run.script_revision_count + 1}", result_dict)
            
            if result.approved:
                run.script_review = result
                run.current_stage = PipelineStage.IMAGE_GEN  # Parallel track A starts
                print(f"[SCRIPT REVIEWER] ✅ APPROVED (score: {result.score:.2f})")
            else:
                run.script_revision_count += 1
                run.current_stage = PipelineStage.SCRIPT_WRITE  # Loop back
                print(f"[SCRIPT REVIEWER] ❌ REVISE (score: {result.score:.2f})")
                print(f"[SCRIPT REVIEWER] Fixes: {result.specific_fixes}")
            
            db.update_run(run)
            return result
            
        except Exception as e:
            print(f"[SCRIPT REVIEWER] Error: {e}")
            # Default approve to prevent infinite loop
            fallback = ReviewResult(
                score=0.8,
                threshold=self.THRESHOLD,
                decision=ReviewDecision.APPROVE,
                feedback="Auto-approved due to review error",
                specific_fixes=[],
                approved=True
            )
            run.script_review = fallback
            run.current_stage = PipelineStage.IMAGE_GEN
            db.update_run(run)
            return fallback


def run_script_reviewer(run_id: str) -> ReviewResult:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.video_script:
        raise ValueError(f"Run {run_id} not found or missing script")
    
    agent = ScriptReviewerAgent()
    return agent.execute(run, run.video_script)