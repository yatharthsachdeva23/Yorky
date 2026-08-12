"""
Main Pipeline Orchestrator for YouTube Hermes.
Coordinates all 11 subagents with proper feedback loops and thresholds.
"""
from __future__ import annotations
import os
import uuid
from datetime import datetime
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import (
    PipelineRun, PipelineStage, ResearchResult, ContentPlan, VideoScript,
    ReviewResult, ReviewDecision, ThumbnailArtifact, VideoClipArtifact,
    FinalVideoArtifact, UploadResult, FeedbackItem, ChannelAuditReport
)
from domains.youtube_hermes.pipeline.shared.storage import db

# Import all agents
from domains.youtube_hermes.pipeline.agents.researcher import run_researcher, ResearcherAgent
from domains.youtube_hermes.pipeline.agents.planner import run_planner
from domains.youtube_hermes.pipeline.agents.script_writer import run_script_writer
from domains.youtube_hermes.pipeline.agents.script_reviewer import run_script_reviewer
from domains.youtube_hermes.pipeline.agents.image_gen import run_image_gen
from domains.youtube_hermes.pipeline.agents.image_reviewer import run_image_reviewer
from domains.youtube_hermes.pipeline.agents.video_maker import run_video_maker
from domains.youtube_hermes.pipeline.agents.video_reviewer import run_video_reviewer
from domains.youtube_hermes.pipeline.agents.yt_uploader import run_yt_uploader
from domains.youtube_hermes.pipeline.agents.yt_representative import run_yt_representative
from domains.youtube_hermes.pipeline.agents.yt_analyser import run_yt_analyser


class YouTubeHermesPipelineOrchestrator:
    """
    Main orchestrator for the 11-subagent YouTube Shorts pipeline.
    
    Flow:
    1. RESEARCHER → 2. PLANNER → 3. SCRIPT WRITER ↔ 4. SCRIPT REVIEWER (loop ≥75%)
       ↓
    5. IMAGE GEN ↔ 6. IMAGE REVIEWER (loop ≥85%)     7. VIDEO MAKER ↔ 8. VIDEO REVIEWER (loop ≥75%)
       ↓                                              ↓
       └──────────────→ 9. YT UPLOADER → 10. YT REPRESENTATIVE
       ↓
    11. YT ANALYSER (background, weekly)
    """
    
    def __init__(self):
        self.current_run: Optional[PipelineRun] = None
        self.max_script_revisions = 5
        self.max_thumbnail_revisions = 5
        self.max_video_revisions = 5
    
    def create_run(self, video_id: Optional[str] = None, user_feedback: Optional[str] = None) -> PipelineRun:
        """Create a new pipeline run."""
        if not video_id:
            video_id = f"short_{int(datetime.now().timestamp())}"
        
        run = PipelineRun(
            run_id=f"run_{uuid.uuid4().hex[:12]}",
            video_id=video_id,
            started_at=datetime.now(),
            current_stage=PipelineStage.RESEARCH,
            status="running"
        )
        
        db.create_run(run)
        self.current_run = run
        
        print(f"\n{'='*60}")
        print(f"🎬 YOUTUBE HERMES PIPELINE STARTED")
        print(f"Run ID: {run.run_id}")
        print(f"Video ID: {video_id}")
        print(f"{'='*60}")
        
        return run
    
    def execute_full_pipeline(self, user_feedback: Optional[str] = None) -> PipelineRun:
        """Execute the complete pipeline from research to upload."""
        run = self.create_run(user_feedback=user_feedback)
        
        try:
            # Stage 1: RESEARCHER
            run = self._run_researcher(run, user_feedback)
            if run.status == "failed":
                return run
            
            # Stage 2: PLANNER
            run = self._run_planner(run)
            if run.status == "failed":
                return run
            
            # Stage 3-4: SCRIPT WRITER ↔ SCRIPT REVIEWER (loop)
            run = self._run_script_loop(run)
            if run.status == "failed":
                return run
            
            # Stage 5-6: IMAGE GEN ↔ IMAGE REVIEWER (loop, parallel)
            run = self._run_image_loop(run)
            if run.status == "failed":
                return run
            
            # Stage 7-8: VIDEO MAKER ↔ VIDEO REVIEWER (loop)
            run = self._run_video_loop(run)
            if run.status == "failed":
                return run
            
            # Stage 9: YT UPLOADER
            run = self._run_yt_uploader(run)
            if run.status == "failed":
                return run
            
            # Stage 10: YT REPRESENTATIVE
            run = self._run_yt_representative(run)
            
            # Complete
            run.status = "complete"
            run.completed_at = datetime.now()
            db.update_run(run)
            
            print(f"\n{'='*60}")
            print(f"✅ PIPELINE COMPLETE: {run.video_id}")
            print(f"Uploaded: {run.upload_result.video_url if run.upload_result else 'N/A'}")
            print(f"{'='*60}")
            
            return run
            
        except Exception as e:
            print(f"\n❌ PIPELINE ERROR: {e}")
            run.status = "failed"
            run.error = str(e)
            db.update_run(run)
            return run
    
    def _run_researcher(self, run: PipelineRun, user_feedback: Optional[str]) -> PipelineRun:
        print(f"\n📍 STAGE: RESEARCHER")
        run_researcher(run.run_id, user_feedback)
        return db.get_run(run.run_id)
    
    def _run_planner(self, run: PipelineRun) -> PipelineRun:
        print(f"\n📍 STAGE: PLANNER")
        run_planner(run.run_id)
        return db.get_run(run.run_id)
    
    def _run_script_loop(self, run: PipelineRun) -> PipelineRun:
        """Run Script Writer → Script Reviewer loop until ≥75% or max revisions."""
        while run.script_revision_count < self.max_script_revisions:
            print(f"\n📍 STAGE: SCRIPT WRITER (attempt {run.script_revision_count + 1})")
            
            # Get revision feedback from previous review
            revision_feedback = None
            if run.script_revision_count > 0 and run.script_review:
                revision_feedback = run.script_review.feedback
                if run.script_review.specific_fixes:
                    revision_feedback += "\nSpecific fixes: " + "; ".join(run.script_review.specific_fixes)
            
            run_script_writer(run.run_id, revision_feedback)
            run = db.get_run(run.run_id)
            
            print(f"\n📍 STAGE: SCRIPT REVIEWER (attempt {run.script_revision_count + 1})")
            run_script_reviewer(run.run_id)
            run = db.get_run(run.run_id)
            
            if run.script_review and run.script_review.approved:
                break
        
        if run.script_revision_count >= self.max_script_revisions and not (run.script_review and run.script_review.approved):
            run.status = "failed"
            run.error = "Max script revisions exceeded"
            db.update_run(run)
        
        return run
    
    def _run_image_loop(self, run: PipelineRun) -> PipelineRun:
        """Run Image Gen → Image Reviewer loop until ≥85% or max revisions."""
        while run.thumbnail_revision_count < self.max_thumbnail_revisions:
            print(f"\n📍 STAGE: IMAGE GEN (attempt {run.thumbnail_revision_count + 1})")
            
            revision_feedback = None
            if run.thumbnail_revision_count > 0 and run.thumbnail_review:
                revision_feedback = run.thumbnail_review.feedback
                if run.thumbnail_review.specific_fixes:
                    revision_feedback += "\nSpecific fixes: " + "; ".join(run.thumbnail_review.specific_fixes)
            
            run_image_gen(run.run_id, revision_feedback)
            run = db.get_run(run.run_id)
            
            print(f"\n📍 STAGE: IMAGE REVIEWER (attempt {run.thumbnail_revision_count + 1})")
            run_image_reviewer(run.run_id)
            run = db.get_run(run.run_id)
            
            if run.thumbnail_review and run.thumbnail_review.approved:
                break
        
        if run.thumbnail_revision_count >= self.max_thumbnail_revisions and not (run.thumbnail_review and run.thumbnail_review.approved):
            run.status = "failed"
            run.error = "Max thumbnail revisions exceeded"
            db.update_run(run)
        
        return run
    
    def _run_video_loop(self, run: PipelineRun) -> PipelineRun:
        """Run Video Maker → Video Reviewer loop until ≥75% or max revisions."""
        while run.video_revision_count < self.max_video_revisions:
            print(f"\n📍 STAGE: VIDEO MAKER (attempt {run.video_revision_count + 1})")
            
            revision_feedback = None
            if run.video_revision_count > 0 and run.video_review:
                # Get failed clip indices
                failed = run.video_review.specific_fixes
                if isinstance(failed, list) and failed:
                    clip_indices = [f["clip_index"] if isinstance(f, dict) else f for f in failed]
                    revision_feedback = {"regen_clips": clip_indices}
            
            run_video_maker(run.run_id, revision_feedback)
            run = db.get_run(run.run_id)
            
            print(f"\n📍 STAGE: VIDEO REVIEWER (attempt {run.video_revision_count + 1})")
            run_video_reviewer(run.run_id)
            run = db.get_run(run.run_id)
            
            if run.video_review and run.video_review.approved:
                break
        
        if run.video_revision_count >= self.max_video_revisions and not (run.video_review and run.video_review.approved):
            run.status = "failed"
            run.error = "Max video revisions exceeded"
            db.update_run(run)
        
        return run
    
    def _run_yt_uploader(self, run: PipelineRun) -> PipelineRun:
        print(f"\n📍 STAGE: YT UPLOADER")
        run_yt_uploader(run.run_id)
        return db.get_run(run.run_id)
    
    def _run_yt_representative(self, run: PipelineRun) -> PipelineRun:
        print(f"\n📍 STAGE: YT REPRESENTATIVE")
        run_yt_representative(run.run_id)
        return db.get_run(run.run_id)
    
    def run_weekly_audit(self) -> ChannelAuditReport:
        """Run the YT Analyser (Subagent 11) independently."""
        print(f"\n📍 STAGE: YT ANALYSER (Weekly Audit)")
        return run_yt_analyser(7)
    
    def resume_from_stage(self, run_id: str, stage: PipelineStage) -> PipelineRun:
        """Resume pipeline from a specific stage."""
        run = db.get_run(run_id)
        if not run:
            raise ValueError(f"Run {run_id} not found")
        
        self.current_run = run
        
        # Map stage to execution method
        stage_map = {
            PipelineStage.RESEARCH: lambda: self._run_researcher(run, None),
            PipelineStage.PLAN: lambda: self._run_planner(run),
            PipelineStage.SCRIPT_WRITE: lambda: self._run_script_loop(run),
            PipelineStage.IMAGE_GEN: lambda: self._run_image_loop(run),
            PipelineStage.VIDEO_MAKE: lambda: self._run_video_loop(run),
            PipelineStage.YT_UPLOAD: lambda: self._run_yt_uploader(run),
            PipelineStage.YT_REPRESENTATIVE: lambda: self._run_yt_representative(run),
        }
        
        if stage in stage_map:
            run = stage_map[stage]()
        
        return run
    
    def get_pipeline_status(self, run_id: str) -> Dict[str, Any]:
        """Get current pipeline status."""
        run = db.get_run(run_id)
        if not run:
            return {"error": "Run not found"}
        
        return {
            "run_id": run.run_id,
            "video_id": run.video_id,
            "status": run.status,
            "current_stage": run.current_stage.value,
            "started_at": run.started_at.isoformat(),
            "completed_at": run.completed_at.isoformat() if run.completed_at else None,
            "revisions": {
                "script": run.script_revision_count,
                "thumbnail": run.thumbnail_revision_count,
                "video": run.video_revision_count,
            },
            "artifacts_ready": {
                "research": run.research is not None,
                "plan": run.content_plan is not None,
                "script": run.video_script is not None,
                "script_approved": run.script_review.approved if run.script_review else False,
                "thumbnail": run.thumbnail is not None,
                "thumbnail_approved": run.thumbnail_review.approved if run.thumbnail_review else False,
                "video_clips": len(run.video_clips) > 0,
                "video_approved": run.video_review.approved if run.video_review else False,
                "final_video": run.final_video is not None,
                "uploaded": run.upload_result is not None,
            },
            "error": run.error
        }


def main():
    """CLI entry point for testing."""
    import sys
    
    orchestrator = YouTubeHermesPipelineOrchestrator()
    
    if len(sys.argv) < 2:
        print("Usage: python -m pipeline.orchestrator [run|audit|status] [run_id]")
        return
    
    command = sys.argv[1]
    
    if command == "run":
        user_feedback = sys.argv[2] if len(sys.argv) > 2 else None
        run = orchestrator.execute_full_pipeline(user_feedback)
        print(f"\nFinal Status: {run.status}")
        if run.upload_result:
            print(f"Video URL: {run.upload_result.video_url}")
    
    elif command == "audit":
        audit = orchestrator.run_weekly_audit()
        print(f"\nAudit Complete:")
        print(f"  Views: {audit.total_views}")
        print(f"  Subscribers: {audit.total_subscribers_gained}")
        print(f"  Retention: {audit.avg_retention_rate:.1%}")
        print(f"  Gaps: {audit.content_gaps}")
        print(f"  Recommendations: {audit.recommendations}")
    
    elif command == "status":
        if len(sys.argv) < 3:
            print("Usage: python -m pipeline.orchestrator status <run_id>")
            return
        status = orchestrator.get_pipeline_status(sys.argv[2])
        print(json.dumps(status, indent=2))
    
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    import json
    main()