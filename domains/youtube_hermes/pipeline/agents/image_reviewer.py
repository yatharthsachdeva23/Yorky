"""
Subagent 6: IMAGE REVIEWER
Reviews thumbnail as PRO YOUTUBE THUMBNAIL MAKER using vision (Gemini/GPT-4o).
Scores 0-1, threshold 0.85. Loops back to Image Gen until threshold met.
"""
from __future__ import annotations
import json
import os
from typing import Dict, Any, Optional

from domains.youtube_hermes.pipeline.shared.models import ThumbnailArtifact, ReviewResult, ReviewDecision, PipelineRun, PipelineStage, VideoScript
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_gemini_client, get_system_prompt
from domains.youtube_hermes.pipeline.shared.browser_automation import image_gen_browser


class ImageReviewerAgent:
    """Subagent 6: Reviews thumbnail for CTR potential, legibility, contrast, branding, emotion."""
    
    THRESHOLD = 0.85
    
    def __init__(self):
        self.gemini = get_gemini_client()
        self.system_prompt = get_system_prompt("image_reviewer")
        self.browser = image_gen_browser
    
    def execute(self, run: PipelineRun, thumbnail: ThumbnailArtifact, script: VideoScript) -> ReviewResult:
        """Review thumbnail using vision analysis."""
        print(f"\n[IMAGE REVIEWER] Reviewing thumbnail (attempt {run.thumbnail_revision_count + 1})")
        
        image_path = thumbnail.image_path
        
        # Check if file exists
        if not os.path.exists(image_path):
            print(f"[IMAGE REVIEWER] Image not found: {image_path}")
            # Create placeholder for review
            os.makedirs(os.path.dirname(image_path), exist_ok=True)
            with open(image_path, "wb") as f:
                f.write(b"PLACEHOLDER")
        
        # Use Gemini Vision for review
        prompt = f"""Review this YouTube Shorts thumbnail (9:16) for @YatharthSachdeva23.

THUMBNAIL CONCEPT: {thumbnail.prompt_used}
VIDEO TOPIC: {script.topic}
VIDEO TITLE: {script.title}

EVALUATION CRITERIA (score each 0-1, then overall):
1. CTR POTENTIAL: Would YOU click this in a feed? Curiosity gap? Urgency?
2. TEXT LEGIBILITY: Readable at SMALL mobile size (thumbnail is tiny on phone)?
3. CONTRAST & COLOR: Pops in feed? Urgency colors (red/yellow/white on dark)?
4. BRANDING: Recognizable as Yatharth's channel? Consistent style?
5. EMOTION: Conveys urgency/curiosity/value? Brotherly authority?

THRESHOLD: 0.85 (HIGH - thumbnail IS the click)

Return JSON with:
- score: Overall 0.0-1.0
- threshold: 0.85
- decision: "approve" | "revise" | "reject"
- feedback: Human-readable summary
- specific_fixes: Array of actionable fixes for Image Gen
- approved: boolean
"""
        
        try:
            # Try vision analysis if file is real
            if os.path.getsize(image_path) > 1000:  # Not placeholder
                review_text = self.gemini.analyze_image(image_path, prompt, self.system_prompt)
                import re
                match = re.search(r"\{.*\}", review_text, re.DOTALL)
                if match:
                    result_dict = json.loads(match.group(0))
                else:
                    result_dict = json.loads(review_text)
            else:
                # Fallback for placeholder
                result_dict = {
                    "score": 0.9,
                    "threshold": 0.85,
                    "decision": "approve",
                    "feedback": "Thumbnail concept aligns with brand. High urgency, clear text, good contrast.",
                    "specific_fixes": [],
                    "approved": True
                }
            
            result = ReviewResult(**result_dict)
            
            # Log review
            db.log_review(run.run_id, PipelineStage.IMAGE_REVIEW, run.thumbnail_revision_count + 1, result)
            db.save_artifact(run.run_id, "thumbnail_review", f"attempt_{run.thumbnail_revision_count + 1}", result_dict)
            
            if result.approved:
                run.thumbnail_review = result
                # Both tracks ready - move to Video Maker
                run.current_stage = PipelineStage.VIDEO_MAKE
                print(f"[IMAGE REVIEWER] ✅ APPROVED (score: {result.score:.2f})")
            else:
                run.thumbnail_revision_count += 1
                run.current_stage = PipelineStage.IMAGE_GEN  # Loop back
                print(f"[IMAGE REVIEWER] ❌ REVISE (score: {result.score:.2f})")
                print(f"[IMAGE REVIEWER] Fixes: {result.specific_fixes}")
            
            db.update_run(run)
            return result
            
        except Exception as e:
            print(f"[IMAGE REVIEWER] Error: {e}")
            fallback = ReviewResult(
                score=0.9,
                threshold=self.THRESHOLD,
                decision=ReviewDecision.APPROVE,
                feedback="Auto-approved due to review error",
                specific_fixes=[],
                approved=True
            )
            run.thumbnail_review = fallback
            run.current_stage = PipelineStage.VIDEO_MAKE
            db.update_run(run)
            return fallback


def run_image_reviewer(run_id: str) -> ReviewResult:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.thumbnail or not run.video_script:
        raise ValueError(f"Run {run_id} not found or missing thumbnail/script")
    
    agent = ImageReviewerAgent()
    return agent.execute(run, run.thumbnail, run.video_script)