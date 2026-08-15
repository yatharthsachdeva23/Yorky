#!/usr/bin/env python3
"""Test Script Writer + Reviewer with the Mock Test Strategy topic."""

import sys
import os
from pathlib import Path
from datetime import datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.agents.script_reviewer import ScriptReviewerAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import PipelineDB

def main():
    print("=" * 80)
    print("TESTING: Script Writer + Reviewer with Mock Test Strategy Topic")
    print("=" * 80)
    
    # Create the ContentPlan from user's topic
    plan = ContentPlan(
        topic="🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy",
        audience_pain_points=[
            "Believe they must finish the entire syllabus before attempting any mock test",
            "Feel demotivated by low scores in early mocks and think they are wasting time",
            "Do not know how to analyze mock tests to improve their preparation",
            "Struggle with time management and question selection during practice",
            "Experience anxiety about the exam pattern and lack real-exam temperament"
        ],
        myths_misconceptions=[
            "Mock tests are only useful after completing the syllabus",
            "You need to score 90%+ in mocks for them to be worthwhile",
            "More mocks automatically lead to higher scores without analysis",
            "Mock tests are identical to the actual JEE Main paper",
            "Analyzing a mock test takes too much time and reduces study hours"
        ],
        key_angles=[
            "Mocks as a diagnostic tool to reveal gaps in real time",
            "Building exam temperament and reducing fear through early exposure",
            "Using mock scores to adjust study plan and prioritize weak topics",
            "Practicing time-bound question selection and elimination strategies",
            "Turning low-score mocks into actionable feedback loops for improvement"
        ],
        structure_outline=[
            "Hook (0-3s): 🚨 LAST CHANCE – Start mocks NOW, 5 months to JEE Main 2027!",
            "Why mocks matter today (3-18s): Early mocks diagnose gaps, build temperament, guide study plan - no syllabus finish needed",
            "How to attempt a mock strategically (18-33s): Set timer, attempt full paper, mark guesses, note time per section, avoid looking at solutions immediately",
            "Post-mock analysis routine (33-48s): Check answers, categorize mistakes (concept/silly/time), update weak-topic list, adjust next week's targets",
            "CTA & urgency (48-60s): Like, share, subscribe, comment your mock doubts - every mock counts, start today!"
        ],
        cta="Like, share, subscribe, and comment your mock test doubts below.",
        urgency_hooks=[
            "🚨 LAST CHANCE to start mocks before JEE Main 2027",
            "Only 5 months left - every mock counts",
            "Don't wait for syllabus finish - start NOW",
            "This is your final window to build exam temperament"
        ],
    )
    
    # Initialize storage
    storage = PipelineDB()
    storage.db_path = Path("test_mock_pipeline.db")
    storage._init_db()
    
    # Create a run
    run = PipelineRun(
        run_id="test-mock-2027",
        video_id="test-mock-2027",
        started_at=datetime.now(),
        status="in_progress",
        current_stage=PipelineStage.SCRIPT_WRITE,
        content_plan=plan,
    )
    storage.create_run(run)
    
    print("\n📝 CONTENT PLAN CREATED")
    print(f"   Topic: {plan.topic}")
    print(f"   Pain Points: {len(plan.audience_pain_points)}")
    print(f"   Myths: {len(plan.myths_misconceptions)}")
    print(f"   Key Angles: {len(plan.key_angles)}")
    print(f"   Sections: {len(plan.structure_outline)}")
    print(f"   CTA: {plan.cta}")
    print(f"   Urgency Hooks: {len(plan.urgency_hooks)}")
    
    # ============================================================
    # STEP 1: SCRIPT WRITER
    # ============================================================
    print("\n" + "=" * 80)
    print("STEP 1: SCRIPT WRITER")
    print("=" * 80)
    
    writer = ScriptWriterAgent()
    script = writer.write_script(run)
    
    print(f"\n✅ SCRIPT GENERATED")
    print(f"   Title: {script.title}")
    print(f"   Duration: {script.total_duration_seconds}s")
    print(f"   Clips: {len(script.clips)}")
    print(f"   Thumbnail: {script.thumbnail_concept}")
    
    print("\n" + "-" * 60)
    print("CLIP DETAILS:")
    print("-" * 60)
    
    for i, clip in enumerate(script.clips, 1):
        print(f"\n📹 CLIP {i} ({clip.duration_seconds}s) - {plan.structure_outline[i-1] if i <= len(plan.structure_outline) else 'N/A'}")
        print(f"   Voiceover ({len(clip.voiceover_text.split())} words):")
        print(f"      {clip.voiceover_text[:120]}...")
        print(f"   Flow Prompt ({len(clip.flow_prompt)} chars):")
        print(f"      {clip.flow_prompt[:150]}...")
        print(f"   Visual Cues: {clip.visual_cues}")
        print(f"   Transition: {clip.transition_note}")
    
    # ============================================================
    # STEP 2: SCRIPT REVIEWER
    # ============================================================
    print("\n" + "=" * 80)
    print("STEP 2: SCRIPT REVIEWER")
    print("=" * 80)
    
    reviewer = ScriptReviewerAgent()
    review = reviewer.execute(run, script)
    
    print(f"\n📊 REVIEW RESULT:")
    print(f"   Score: {review.score:.2f} / 1.00")
    print(f"   Threshold: 0.75")
    print(f"   Decision: {'APPROVE ✅' if review.approved else 'REJECT ❌'}")
    print(f"   Feedback: {review.feedback}")
    print(f"   Specific Fixes Required: {len(review.specific_fixes)}")
    
    if review.specific_fixes:
        for i, fix in enumerate(review.specific_fixes, 1):
            print(f"   {i}. {fix}")
    
    # Save for inspection
    run.script = script
    run.script_review = review
    run.current_stage = PipelineStage.SCRIPT_REVIEW
    run.status = "completed" if review.approved else "revision_needed"
    storage.update_run(run)
    
    print("\n" + "=" * 80)
    print("FULL FLOW PROMPTS (what would be sent to Google Flow/Veo 3):")
    print("=" * 80)
    
    for i, clip in enumerate(script.clips, 1):
        print(f"\n{'='*80}")
        print(f"CLIP {i} FLOW PROMPT (for Google Flow/Veo 3):")
        print(f"{'='*80}")
        print(clip.flow_prompt)
        print()
    
    print("=" * 80)
    print("TEST COMPLETE - Script Writer + Reviewer pipeline working!")
    print("=" * 80)
    print(f"\n📁 Run saved to: test_mock_pipeline.db")
    print(f"📋 Next stage would be: {'image_gen' if review.approved else 'script_write (revision)'}")

if __name__ == "__main__":
    main()