#!/usr/bin/env python3
"""
Main entry point for YouTube Hermes Pipeline.
Run: python -m domains.youtube_hermes.pipeline.main [run|audit|status] [args]
"""
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))

from domains.youtube_hermes.pipeline.orchestrator.pipeline_orchestrator import YouTubeHermesPipelineOrchestrator, main as orchestrator_main


if __name__ == "__main__":
    orchestrator_main()