"""
Shared data models for the YouTube Hermes Pipeline.
All subagents communicate via these typed artifacts.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional
import json


class PipelineStage(str, Enum):
    """Pipeline stages matching the 11-subagent workflow."""
    RESEARCH = "research"                    # Subagent 1: Researcher
    PLAN = "plan"                            # Subagent 2: Planner
    SCRIPT_WRITE = "script_write"            # Subagent 3: Script Writer
    SCRIPT_REVIEW = "script_review"          # Subagent 4: Script Reviewer
    IMAGE_GEN = "image_gen"                  # Subagent 5: Image Gen
    IMAGE_REVIEW = "image_review"            # Subagent 6: Image Reviewer
    VIDEO_MAKE = "video_make"                # Subagent 7: Video Maker
    VIDEO_REVIEW = "video_review"            # Subagent 8: Video Reviewer
    YT_UPLOAD = "yt_upload"                  # Subagent 9: YT Uploader
    YT_REPRESENTATIVE = "yt_representative"  # Subagent 10: YT Representative
    YT_ANALYSE = "yt_analyse"                # Subagent 11: YT Analyser (background)
    COMPLETE = "complete"
    FAILED = "failed"


class ReviewDecision(str, Enum):
    """Review loop decisions."""
    APPROVE = "approve"
    REVISE = "revise"
    REJECT = "reject"


@dataclass
class ReviewResult:
    """Standardized review output for all review loops."""
    score: float                          # 0.0 - 1.0
    threshold: float                      # Required threshold (e.g., 0.75)
    decision: ReviewDecision
    feedback: str                         # Human-readable feedback
    specific_fixes: List[str] = field(default_factory=list)  # Actionable items
    approved: bool = False
    # Video-specific fields
    clip_reviews: List[Dict[str, Any]] = field(default_factory=list)
    failed_clips: List[int] = field(default_factory=list)
    thumbnail_embedded: bool = False
    
    def __post_init__(self):
        # Convert string decision to enum if needed
        if isinstance(self.decision, str):
            self.decision = ReviewDecision(self.decision)
        self.approved = self.score >= self.threshold and self.decision == ReviewDecision.APPROVE


@dataclass
class ClipScript:
    """A single 15-second clip script for Google Flow."""
    clip_index: int                       # 1-based
    duration_seconds: int = 15
    flow_prompt: str = ""                 # Prompt for Google Flow
    voiceover_text: str = ""              # Exact spoken line
    visual_cues: List[str] = field(default_factory=list)  # On-screen text, graphics
    transition_note: str = ""             # How to transition to next clip


@dataclass
class VideoScript:
    """Complete script divided into 15-second clips."""
    topic: str
    title: str
    description: str
    tags: List[str]
    clips: List[ClipScript] = field(default_factory=list)
    total_duration_seconds: int = 0
    thumbnail_concept: str = ""           # Brief for Image Gen
    
    def __post_init__(self):
        self.total_duration_seconds = sum(c.duration_seconds for c in self.clips)


@dataclass
class ContentPlan:
    """Subagent 2 (Planner) output - content structure, not script."""
    topic: str
    audience_pain_points: List[str]
    myths_misconceptions: List[str]
    key_angles: List[str]                 # Unique angles to cover
    structure_outline: List[str]          # Ordered sections
    cta: str                              # Call to action
    urgency_hooks: List[str]              # Urgency markers for hooks
    estimated_clips: int = 4              # Default 4 clips = 60s


@dataclass
class ResearchResult:
    """Subagent 1 (Researcher) output."""
    selected_topic: str
    rationale: str
    demand_signals: List[str]             # Trending keywords, search volume, feedback
    target_audience: str
    seasonal_relevance: str
    competitor_gaps: List[str] = field(default_factory=list)


@dataclass
class ThumbnailArtifact:
    """Subagent 5 (Image Gen) output."""
    image_path: str
    prompt_used: str
    aspect_ratio: str = "9:16"
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class VideoClipArtifact:
    """Subagent 7 (Video Maker) output per clip."""
    clip_index: int
    clip_path: str
    flow_prompt_used: str
    duration_seconds: float
    generation_metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class FinalVideoArtifact:
    """Subagent 8 (Video Reviewer) approved output."""
    video_path: str
    duration_seconds: float
    clips_included: List[int]
    thumbnail_embedded: bool = False
    review_score: float = 0.0


@dataclass
class UploadResult:
    """Subagent 9 (YT Uploader) output."""
    youtube_video_id: str
    video_url: str
    title: str
    description: str
    tags: List[str]
    scheduled_time: Optional[datetime] = None
    published: bool = True


@dataclass
class FeedbackItem:
    """Subagent 10 (YT Representative) extracted feedback."""
    source_comment_id: str
    author: str
    comment_text: str
    reply_text: str
    category: str                         # "topic_demand" | "general_feedback" | "question" | "praise"
    routed_to: str                        # "researcher" | "hermes"


@dataclass
class ChannelAuditReport:
    """Subagent 11 (YT Analyser) output."""
    period_start: datetime
    period_end: datetime
    total_views: int
    total_subscribers_gained: int
    avg_retention_rate: float
    top_performing_videos: List[Dict[str, Any]]
    content_gaps: List[str]
    recommendations: List[str]
    generated_at: datetime = field(default_factory=datetime.now)


@dataclass
class PipelineRun:
    """Complete pipeline execution state."""
    run_id: str
    video_id: str
    started_at: datetime
    current_stage: PipelineStage
    status: str = "running"               # running, complete, failed, paused
    
    # Artifacts produced at each stage
    research: Optional[ResearchResult] = None
    content_plan: Optional[ContentPlan] = None
    video_script: Optional[VideoScript] = None
    script_review: Optional[ReviewResult] = None
    thumbnail: Optional[ThumbnailArtifact] = None
    thumbnail_review: Optional[ReviewResult] = None
    video_clips: List[VideoClipArtifact] = field(default_factory=list)
    video_review: Optional[ReviewResult] = None
    final_video: Optional[FinalVideoArtifact] = None
    upload_result: Optional[UploadResult] = None
    feedback_items: List[FeedbackItem] = field(default_factory=list)
    
    # Loop counters
    script_revision_count: int = 0
    thumbnail_revision_count: int = 0
    video_revision_count: int = 0
    
    # Thresholds
    SCRIPT_THRESHOLD: float = 0.75
    THUMBNAIL_THRESHOLD: float = 0.85
    VIDEO_THRESHOLD: float = 0.75
    
    completed_at: Optional[datetime] = None
    error: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        def serialize_artifact(obj, visited=None):
            if visited is None:
                visited = set()
            obj_id = id(obj)
            if obj_id in visited:
                return "<circular_reference>"
            visited.add(obj_id)
            
            if obj is None:
                return None
            # Skip class-level attributes (descriptors, classmethods, etc.)
            if isinstance(obj, type):
                return "<class>"
            # Check for Enum BEFORE __dict__ (Enums have __dict__)
            if isinstance(obj, Enum):
                return obj.value
            if hasattr(obj, '__dict__'):
                # Handle dataclass objects
                result = {}
                for key, value in obj.__dict__.items():
                    # Skip private/dunder attributes and callables
                    if key.startswith('_') or callable(value):
                        continue
                    if hasattr(value, '__dict__'):
                        result[key] = serialize_artifact(value, visited)
                    elif isinstance(value, list):
                        result[key] = [serialize_artifact(v, visited) for v in value]
                    elif isinstance(value, datetime):
                        result[key] = value.isoformat()
                    elif isinstance(value, Enum):
                        result[key] = value.value
                    else:
                        result[key] = value
                return result
            elif isinstance(obj, list):
                return [serialize_artifact(v, visited) for v in obj]
            elif isinstance(obj, datetime):
                return obj.isoformat()
            elif isinstance(obj, Enum):
                return obj.value
            else:
                return obj
        
        return {
            "run_id": self.run_id,
            "video_id": self.video_id,
            "started_at": self.started_at.isoformat(),
            "current_stage": self.current_stage.value,
            "status": self.status,
            "script_revision_count": self.script_revision_count,
            "thumbnail_revision_count": self.thumbnail_revision_count,
            "video_revision_count": self.video_revision_count,
            "research": serialize_artifact(self.research),
            "content_plan": serialize_artifact(self.content_plan),
            "video_script": serialize_artifact(self.video_script),
            "script_review": serialize_artifact(self.script_review),
            "thumbnail": serialize_artifact(self.thumbnail),
            "thumbnail_review": serialize_artifact(self.thumbnail_review),
            "video_clips": [serialize_artifact(c) for c in self.video_clips],
            "video_review": serialize_artifact(self.video_review),
            "final_video": serialize_artifact(self.final_video),
            "upload_result": serialize_artifact(self.upload_result),
            "feedback_items": [serialize_artifact(f) for f in self.feedback_items],
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "error": self.error
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> PipelineRun:
        def deserialize_artifact(obj, cls_type):
            if obj is None:
                return None
            if cls_type == ResearchResult:
                return ResearchResult(**obj)
            elif cls_type == ContentPlan:
                return ContentPlan(**obj)
            elif cls_type == VideoScript:
                clips = [ClipScript(**c) for c in obj.get("clips", [])]
                obj_copy = obj.copy()
                obj_copy["clips"] = clips
                return VideoScript(**obj_copy)
            elif cls_type == ReviewResult:
                obj_copy = obj.copy()
                if "decision" in obj_copy and isinstance(obj_copy["decision"], str):
                    obj_copy["decision"] = ReviewDecision(obj_copy["decision"])
                return ReviewResult(**obj_copy)
            elif cls_type == ThumbnailArtifact:
                return ThumbnailArtifact(**obj)
            elif cls_type == VideoClipArtifact:
                return VideoClipArtifact(**obj)
            elif cls_type == FinalVideoArtifact:
                return FinalVideoArtifact(**obj)
            elif cls_type == UploadResult:
                return UploadResult(**obj)
            elif cls_type == FeedbackItem:
                return FeedbackItem(**obj)
            return obj
        
        run = cls(
            run_id=data["run_id"],
            video_id=data["video_id"],
            started_at=datetime.fromisoformat(data["started_at"]),
            current_stage=PipelineStage(data["current_stage"]),
            status=data["status"],
            script_revision_count=data.get("script_revision_count", 0),
            thumbnail_revision_count=data.get("thumbnail_revision_count", 0),
            video_revision_count=data.get("video_revision_count", 0),
        )
        if data.get("completed_at"):
            run.completed_at = datetime.fromisoformat(data["completed_at"])
        
        # Deserialize artifacts
        run.research = deserialize_artifact(data.get("research"), ResearchResult)
        run.content_plan = deserialize_artifact(data.get("content_plan"), ContentPlan)
        run.video_script = deserialize_artifact(data.get("video_script"), VideoScript)
        run.script_review = deserialize_artifact(data.get("script_review"), ReviewResult)
        run.thumbnail = deserialize_artifact(data.get("thumbnail"), ThumbnailArtifact)
        run.thumbnail_review = deserialize_artifact(data.get("thumbnail_review"), ReviewResult)
        run.video_clips = [deserialize_artifact(c, VideoClipArtifact) for c in data.get("video_clips", [])]
        run.video_review = deserialize_artifact(data.get("video_review"), ReviewResult)
        run.final_video = deserialize_artifact(data.get("final_video"), FinalVideoArtifact)
        run.upload_result = deserialize_artifact(data.get("upload_result"), UploadResult)
        run.feedback_items = [deserialize_artifact(f, FeedbackItem) for f in data.get("feedback_items", [])]
        run.error = data.get("error")
        
        return run