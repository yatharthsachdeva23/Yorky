"""
YouTube Hermes Pipeline Package
"""
from domains.youtube_hermes.pipeline.shared.models import (
    PipelineRun, PipelineStage, ResearchResult, ContentPlan, VideoScript, ClipScript,
    ReviewResult, ReviewDecision, ThumbnailArtifact, VideoClipArtifact,
    FinalVideoArtifact, UploadResult, FeedbackItem, ChannelAuditReport
)

from domains.youtube_hermes.pipeline.shared.storage import db, PipelineDB
from domains.youtube_hermes.pipeline.shared.llm import (
    get_nvidia_client, get_gemini_client, get_browser_image_gen,
    NVIDIAClient, GeminiClient, BrowserImageGenClient, SYSTEM_PROMPTS
)
from domains.youtube_hermes.pipeline.shared.browser_automation import (
    flow_browser, image_gen_browser, youtube_uploader_browser,
    comment_manager_browser, channel_analyser_browser,
    FlowBrowserAutomation, ImageGenBrowserAutomation,
    YouTubeUploaderBrowser, CommentManagerBrowser, ChannelAnalyserBrowser
)

from domains.youtube_hermes.pipeline.agents import (
    researcher, planner, script_writer, script_reviewer,
    image_gen, image_reviewer, video_maker, video_reviewer,
    yt_uploader, yt_representative, yt_analyser
)

from domains.youtube_hermes.pipeline.orchestrator.pipeline_orchestrator import (
    YouTubeHermesPipelineOrchestrator
)

__all__ = [
    # Models
    "PipelineRun", "PipelineStage", "ResearchResult", "ContentPlan", "VideoScript", "ClipScript",
    "ReviewResult", "ReviewDecision", "ThumbnailArtifact", "VideoClipArtifact",
    "FinalVideoArtifact", "UploadResult", "FeedbackItem", "ChannelAuditReport",
    # Storage
    "db", "PipelineDB",
    # LLM
    "get_nvidia_client", "get_gemini_client", "get_browser_image_gen",
    "NVIDIAClient", "GeminiClient", "BrowserImageGenClient", "SYSTEM_PROMPTS",
    # Browser
    "flow_browser", "image_gen_browser", "youtube_uploader_browser",
    "comment_manager_browser", "channel_analyser_browser",
    "FlowBrowserAutomation", "ImageGenBrowserAutomation",
    "YouTubeUploaderBrowser", "CommentManagerBrowser", "ChannelAnalyserBrowser",
    # Agents
    "researcher", "planner", "script_writer", "script_reviewer",
    "image_gen", "image_reviewer", "video_maker", "video_reviewer",
    "yt_uploader", "yt_representative", "yt_analyser",
    # Orchestrator
    "YouTubeHermesPipelineOrchestrator",
]