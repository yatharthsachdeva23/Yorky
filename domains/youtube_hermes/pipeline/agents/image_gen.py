"""
Subagent 5: IMAGE GEN
Creates thumbnail via browser automation on ChatGPT Web / Gemini Web (Chrome Profile 8).
Uses Hermes native browser tools.
"""
from __future__ import annotations
import json
import os
from typing import Dict, Any, Optional

from domains.youtube_hermes.pipeline.shared.models import ThumbnailArtifact, PipelineRun, PipelineStage, VideoScript
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.browser_automation import image_gen_browser


class ImageGenAgent:
    """Subagent 5: Generates thumbnail using browser automation."""
    
    def __init__(self):
        self.browser = image_gen_browser
    
    def execute(self, run: PipelineRun, script: VideoScript, 
                revision_feedback: Optional[str] = None) -> ThumbnailArtifact:
        """Generate thumbnail from script's thumbnail concept."""
        print(f"\n[IMAGE GEN] Generating thumbnail (attempt {run.thumbnail_revision_count + 1})")
        
        concept = script.thumbnail_concept
        if revision_feedback:
            concept += f"\n\nREVISION FEEDBACK: {revision_feedback}"
        
        # Use browser automation to generate thumbnail
        result = self.browser.generate_thumbnail(
            prompt=concept,
            aspect_ratio="9:16",
            video_id=run.video_id
        )
        
        # In actual execution, Hermes would run the browser steps
        # For now, we create the artifact structure
        artifact = ThumbnailArtifact(
            image_path=result["image_path"],
            prompt_used=concept,
            aspect_ratio="9:16",
            metadata={
                "automation_steps": result["automation_steps"],
                "status": "generated_via_browser"
            }
        )
        
        db.save_artifact(run.run_id, "thumbnail", f"attempt_{run.thumbnail_revision_count + 1}", artifact.__dict__)
        
        run.thumbnail = artifact
        run.current_stage = PipelineStage.IMAGE_REVIEW
        db.update_run(run)
        
        print(f"[IMAGE GEN] Thumbnail generated: {artifact.image_path}")
        return artifact
    
    def execute_revision(self, run: PipelineRun, script: VideoScript, feedback: str) -> ThumbnailArtifact:
        """Generate revised thumbnail based on reviewer feedback."""
        return self.execute(run, script, revision_feedback=feedback)


def run_image_gen(run_id: str, revision_feedback: Optional[str] = None) -> ThumbnailArtifact:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.video_script:
        raise ValueError(f"Run {run_id} not found or missing script")
    
    agent = ImageGenAgent()
    return agent.execute(run, run.video_script, revision_feedback)