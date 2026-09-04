"""
Subagent 7: VIDEO MAKER (Enhanced)
Generates video clips AND images on Google Flow via browser automation.
Returns artifacts for parallel review by Video Reviewer (video) + Image Reviewer (images).
"""
from __future__ import annotations
import json
import os
import uuid
from datetime import datetime
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import (
    VideoClipArtifact, PipelineRun, PipelineStage, VideoScript, ThumbnailArtifact,
    VideoClipArtifact, ImageArtifact
)
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.browser_automation import flow_browser, image_gen_browser


class VideoMakerAgent:
    """
    Subagent 7: Generates video clips AND images on Google Flow via browser automation.
    Returns VideoClipArtifact[] and ImageArtifact[] for parallel review.
    """

    def __init__(self):
        self.flow_browser = flow_browser
        self.image_browser = image_gen_browser
        self.clips_dir = os.path.join("data", "clips")
        self.images_dir = os.path.join("data", "images")
        os.makedirs(self.clips_dir, exist_ok=True)
        os.makedirs(self.images_dir, exist_ok=True)

    def execute(self, run: PipelineRun, script: VideoScript, thumbnail: ThumbnailArtifact,
                revision_feedback: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Generate all clips AND images on Google Flow.
        Returns dict with 'clips' (VideoClipArtifact[]) and 'images' (ImageArtifact[]).
        """
        print(f"\n[VIDEO MAKER] Generating {len(script.clips)} clips + images on Google Flow (attempt {run.video_revision_count + 1})")

        clips = []
        images = []

        # ============================================================
        # PHASE 1: Generate video clips on Google Flow
        # ============================================================
        for clip_script in script.clips:
            # Skip already approved clips if revising
            if revision_feedback and "regen_clips" in revision_feedback:
                if clip_script.clip_index not in revision_feedback["regen_clips"]:
                    existing = self._get_existing_clip(run, clip_script.clip_index)
                    if existing:
                        clips.append(existing)
                        continue

            clip_path = os.path.join(self.clips_dir, f"{run.video_id}_clip_{clip_script.clip_index}.mp4")

            # Generate clip via browser automation on Google Flow
            result = self.flow_browser.generate_clip(
                clip_index=clip_script.clip_index,
                flow_prompt=clip_script.flow_prompt,
                video_id=run.video_id
            )

            clip_artifact = VideoClipArtifact(
                clip_index=clip_script.clip_index,
                clip_path=clip_path,
                flow_prompt_used=clip_script.flow_prompt,
                duration_seconds=clip_script.duration_seconds,
                generation_metadata={
                    "automation_steps": result.get("automation_steps", []),
                    "voiceover_text": clip_script.voiceover_text,
                    "visual_cues": clip_script.visual_cues,
                    "status": "generated_pending_review",
                    "generated_at": datetime.now().isoformat(),
                    "flow_prompt": clip_script.flow_prompt,
                }
            )
            clips.append(clip_artifact)

        # ============================================================
        # PHASE 2: Generate images (thumbnail + keyframes) on Google Flow
        # ============================================================

        # 2a: Generate main thumbnail (last 1 second overlay)
        thumb_prompt = self._build_thumbnail_prompt(script, thumbnail)
        thumb_result = self._generate_image_on_flow(
            prompt=thumb_prompt,
            aspect_ratio="9:16",
            video_id=run.video_id,
            image_type="thumbnail"
        )
        images.append(thumb_result)

        # 2b: Generate keyframe images for each clip (for review/reference)
        for clip_script in script.clips:
            keyframe_prompt = self._build_keyframe_prompt(script, clip_script)
            kf_result = self._generate_image_on_flow(
                prompt=keyframe_prompt,
                aspect_ratio="9:16",
                video_id=run.video_id,
                image_type=f"keyframe_clip_{clip_script.clip_index}"
            )
            images.append(kf_result)

        # ============================================================
        # SAVE ARTIFACTS & UPDATE RUN
        # ============================================================
        db.save_artifact(run.run_id, "video_clips", f"attempt_{run.video_revision_count + 1}",
                        [c.to_dict() for c in clips])
        db.save_artifact(run.run_id, "video_images", f"attempt_{run.video_revision_count + 1}",
                        [img.to_dict() if hasattr(img, 'to_dict') else img.__dict__ for img in images])

        run.video_clips = clips
        run.video_images = images
        run.current_stage = PipelineStage.VIDEO_REVIEW
        db.update_run(run)

        print(f"[VIDEO MAKER] Generated {len(clips)} clips + {len(images)} images, pending parallel review")
        return {"clips": clips, "images": images}

    def _build_thumbnail_prompt(self, script: VideoScript, thumbnail: ThumbnailArtifact) -> str:
        """Build detailed thumbnail generation prompt for Google Flow."""
        return (
            f"YouTube Shorts thumbnail (9:16), high CTR design. "
            f"Topic: {script.title}. "
            f"Thumbnail concept: {thumbnail.concept}. "
            f"Style: Urgent, high contrast, bold text overlay. "
            f"Elements: {script.thumbnail_concept}. "
            f"Colors: Red/black urgent gradient, yellow/white text. "
            f"Text: Large bold '{script.thumbnail_concept}' center. "
            f"Character: Bhaiya avatar, urgent expression, pointing at text. "
            f"Format: 9:16 vertical, mobile-optimized, legible at small size."
        )

    def _build_keyframe_prompt(self, script: VideoScript, clip_script) -> str:
        """Build keyframe reference image prompt for a specific clip."""
        return (
            f"Keyframe reference for YouTube Short clip {clip_script.clip_index}. "
            f"Flow prompt: {clip_script.flow_prompt}. "
            f"Voiceover: {clip_script.voiceover_text}. "
            f"Visual cues: {', '.join(clip_script.visual_cues)}. "
            f"Format: 9:16 vertical, high quality reference frame."
        )

    def _generate_image_on_flow(self, prompt: str, aspect_ratio: str, video_id: str, image_type: str):
        """Generate image using Google Flow via browser automation."""
        image_filename = f"{video_id}_{image_type}_{uuid.uuid4().hex[:8]}.png"
        image_path = os.path.join(self.images_dir, image_filename)

        result = self.image_browser.generate_image(
            prompt=prompt,
            aspect_ratio=aspect_ratio,
            video_id=video_id
        )

        image_artifact = ImageArtifact(
            image_type=image_type,
            image_path=image_path,
            prompt_used=prompt,
            aspect_ratio=aspect_ratio,
            generation_metadata={
                "automation_steps": result.get("automation_steps", []),
                "status": "generated_pending_review",
                "generated_at": datetime.now().isoformat(),
                "flow_prompt": prompt,
            }
        )
        return image_artifact

    def _get_existing_clip(self, run: PipelineRun, clip_index: int) -> Optional[VideoClipArtifact]:
        """Get previously generated clip from artifacts."""
        artifacts = db.get_latest_artifact(run.run_id, "video_clips")
        if artifacts:
            for clip_data in artifacts:
                if clip_data.get("clip_index") == clip_index:
                    return VideoClipArtifact(**clip_data)
        return None

    def regenerate_clips(self, run: PipelineRun, script: VideoScript, clip_indices: List[int]) -> Dict[str, Any]:
        """Regenerate specific clips based on reviewer feedback."""
        print(f"\n[VIDEO MAKER] Regenerating clips: {clip_indices}")

        revision_feedback = {"regen_clips": clip_indices}
        return self.execute(run, script, run.thumbnail, revision_feedback)

    def regenerate_images(self, run: PipelineRun, script: VideoScript, image_indices: List[int]) -> List:
        """Regenerate specific images based on reviewer feedback."""
        print(f"\n[VIDEO MAKER] Regenerating images: {image_indices}")
        # Implementation similar to clip regeneration
        return []


def run_video_maker(run_id: str, revision_feedback: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.video_script or not run.thumbnail:
        raise ValueError(f"Run {run_id} not found or missing script/thumbnail")

    agent = VideoMakerAgent()
    return agent.execute(run, run.video_script, run.thumbnail, revision_feedback)