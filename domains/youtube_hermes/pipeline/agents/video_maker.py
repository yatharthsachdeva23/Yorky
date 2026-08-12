"""
Subagent 7: VIDEO MAKER
Generates clips on Google Flow using browser automation (Chrome Profile 8, port 9222).
Creates all 15-second clips, combines in Flow, adds thumbnail as last 1 second.
Waits for Video Reviewer approval before downloading.
"""
from __future__ import annotations
import json
import os
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import VideoClipArtifact, PipelineRun, PipelineStage, VideoScript, ThumbnailArtifact
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.browser_automation import flow_browser


class VideoMakerAgent:
    """Subagent 7: Generates video clips on Google Flow via browser automation."""
    
    def __init__(self):
        self.browser = flow_browser
    
    def execute(self, run: PipelineRun, script: VideoScript, thumbnail: ThumbnailArtifact,
                revision_feedback: Optional[Dict[str, Any]] = None) -> List[VideoClipArtifact]:
        """Generate all clips on Google Flow."""
        print(f"\n[VIDEO MAKER] Generating {len(script.clips)} clips on Google Flow (attempt {run.video_revision_count + 1})")
        
        clips = []
        
        for clip_script in script.clips:
            # Skip already approved clips if revising
            if revision_feedback and "regen_clips" in revision_feedback:
                if clip_script.clip_index not in revision_feedback["regen_clips"]:
                    # Reuse existing clip
                    existing = self._get_existing_clip(run, clip_script.clip_index)
                    if existing:
                        clips.append(existing)
                        continue
            
            # Generate clip via browser automation
            result = self.browser.generate_clip(
                clip_index=clip_script.clip_index,
                flow_prompt=clip_script.flow_prompt,
                video_id=run.video_id
            )
            
            clip_artifact = VideoClipArtifact(
                clip_index=clip_script.clip_index,
                clip_path=result["clip_path"],
                flow_prompt_used=clip_script.flow_prompt,
                duration_seconds=clip_script.duration_seconds,
                generation_metadata={
                    "automation_steps": result["automation_steps"],
                    "voiceover_text": clip_script.voiceover_text,
                    "visual_cues": clip_script.visual_cues,
                    "status": "generated_pending_review"
                }
            )
            clips.append(clip_artifact)
        
        # Add thumbnail as last 1 second (handled in Flow combination)
        # This is a note for the Flow combination step
        
        db.save_artifact(run.run_id, "video_clips", f"attempt_{run.video_revision_count + 1}", 
                        [c.__dict__ for c in clips])
        
        run.video_clips = clips
        run.current_stage = PipelineStage.VIDEO_REVIEW
        db.update_run(run)
        
        print(f"[VIDEO MAKER] Generated {len(clips)} clips, pending review")
        return clips
    
    def _get_existing_clip(self, run: PipelineRun, clip_index: int) -> Optional[VideoClipArtifact]:
        """Get previously generated clip from artifacts."""
        artifacts = db.get_latest_artifact(run.run_id, "video_clips")
        if artifacts:
            for clip_data in artifacts:
                if clip_data.get("clip_index") == clip_index:
                    return VideoClipArtifact(**clip_data)
        return None
    
    def regenerate_clips(self, run: PipelineRun, script: VideoScript, clip_indices: List[int]) -> List[VideoClipArtifact]:
        """Regenerate specific clips based on reviewer feedback."""
        print(f"\n[VIDEO MAKER] Regenerating clips: {clip_indices}")
        
        revision_feedback = {"regen_clips": clip_indices}
        return self.execute(run, script, run.thumbnail, revision_feedback)


def run_video_maker(run_id: str, revision_feedback: Optional[Dict[str, Any]] = None) -> List[VideoClipArtifact]:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.video_script or not run.thumbnail:
        raise ValueError(f"Run {run_id} not found or missing script/thumbnail")
    
    agent = VideoMakerAgent()
    return agent.execute(run, run.video_script, run.thumbnail, revision_feedback)