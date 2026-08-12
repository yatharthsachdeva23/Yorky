#!/usr/bin/env python3
"""
Test script to verify YouTube Hermes Pipeline structure.
Run: python test_pipeline.py
"""
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test all pipeline imports work."""
    print("Testing imports...")
    
    try:
        from domains.youtube_hermes.pipeline.shared.models import (
            PipelineRun, PipelineStage, ResearchResult, ContentPlan, VideoScript, ClipScript,
            ReviewResult, ReviewDecision, ThumbnailArtifact, VideoClipArtifact,
            FinalVideoArtifact, UploadResult, FeedbackItem, ChannelAuditReport
        )
        print("✅ Models imported")
    except Exception as e:
        print(f"❌ Models import failed: {e}")
        return False
    
    try:
        from domains.youtube_hermes.pipeline.shared.storage import db, PipelineDB
        print("✅ Storage imported")
    except Exception as e:
        print(f"❌ Storage import failed: {e}")
        return False
    
    try:
        from domains.youtube_hermes.pipeline.shared.llm import (
            get_nvidia_client, get_gemini_client, get_browser_image_gen, SYSTEM_PROMPTS
        )
        print("✅ LLM utilities imported")
    except Exception as e:
        print(f"❌ LLM import failed: {e}")
        return False
    
    try:
        from domains.youtube_hermes.pipeline.shared.browser_automation import (
            flow_browser, image_gen_browser, youtube_uploader_browser,
            comment_manager_browser, channel_analyser_browser
        )
        print("✅ Browser automation imported")
    except Exception as e:
        print(f"❌ Browser automation import failed: {e}")
        return False
    
    try:
        from domains.youtube_hermes.pipeline.agents import (
            researcher, planner, script_writer, script_reviewer,
            image_gen, image_reviewer, video_maker, video_reviewer,
            yt_uploader, yt_representative, yt_analyser
        )
        print("✅ Agents imported")
    except Exception as e:
        print(f"❌ Agents import failed: {e}")
        return False
    
    try:
        from domains.youtube_hermes.pipeline.orchestrator.pipeline_orchestrator import YouTubeHermesPipelineOrchestrator
        print("✅ Orchestrator imported")
    except Exception as e:
        print(f"❌ Orchestrator import failed: {e}")
        return False
    
    return True


def test_database():
    """Test database initialization."""
    print("\nTesting database...")
    try:
        from domains.youtube_hermes.pipeline.shared.storage import db
        # Try to get latest run (should return None for fresh DB)
        run = db.get_latest_run()
        print(f"✅ Database initialized (latest run: {run.run_id if run else 'None'})")
        return True
    except Exception as e:
        print(f"❌ Database test failed: {e}")
        return False


def test_config():
    """Test config loading."""
    print("\nTesting config...")
    try:
        import json
        config_path = "domains/youtube_hermes/pipeline/config.json"
        with open(config_path, "r") as f:
            config = json.load(f)
        print(f"✅ Config loaded: {config['instance_name']}")
        print(f"   Thresholds: {config['pipeline']['thresholds']}")
        print(f"   Max revisions: {config['pipeline']['max_revisions']}")
        return True
    except Exception as e:
        print(f"❌ Config test failed: {e}")
        return False


def test_pipeline_creation():
    """Test pipeline run creation."""
    print("\nTesting pipeline run creation...")
    try:
        from domains.youtube_hermes.pipeline.orchestrator.pipeline_orchestrator import YouTubeHermesPipelineOrchestrator
        orchestrator = YouTubeHermesPipelineOrchestrator()
        run = orchestrator.create_run(video_id="test_short_123", user_feedback="Test run")
        print(f"✅ Pipeline run created: {run.run_id}")
        print(f"   Video ID: {run.video_id}")
        print(f"   Stage: {run.current_stage.value}")
        return True
    except Exception as e:
        print(f"❌ Pipeline creation failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    print("=" * 60)
    print("YOUTUBE HERMES PIPELINE - STRUCTURE TEST")
    print("=" * 60)
    
    all_passed = True
    
    all_passed &= test_imports()
    all_passed &= test_database()
    all_passed &= test_config()
    all_passed &= test_pipeline_creation()
    
    print("\n" + "=" * 60)
    if all_passed:
        print("✅ ALL TESTS PASSED - Pipeline structure is ready!")
    else:
        print("❌ SOME TESTS FAILED - Check errors above")
    print("=" * 60)
    
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())