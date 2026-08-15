#!/usr/bin/env python3
"""
Test Subagents 1-4: Researcher → Planner → Script Writer ↔ Script Reviewer
Run: python test_subagents_1_to_4.py
"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_researcher():
    print("=" * 60)
    print("TESTING: SUBAGENT 1 - RESEARCHER")
    print("=" * 60)
    
    from domains.youtube_hermes.pipeline.orchestrator.pipeline_orchestrator import YouTubeHermesPipelineOrchestrator
    from domains.youtube_hermes.pipeline.agents.researcher import run_researcher
    from domains.youtube_hermes.pipeline.shared.storage import db
    
    orchestrator = YouTubeHermesPipelineOrchestrator()
    run = orchestrator.create_run(video_id="test_1to4", user_feedback="Test run for subagents 1-4")
    
    print(f"\n[ORCHESTRATOR] Created run: {run.run_id}")
    print(f"[ORCHESTRATOR] Current stage: {run.current_stage.value}")
    
    # Run Researcher
    print("\n[RESEARCHER] Starting autonomous 2-call pipeline...")
    research_result = run_researcher(run.run_id, user_feedback="Select best topic for RIGHT NOW - August 2026")
    
    run = db.get_run(run.run_id)
    print(f"\n[RESEARCHER] Result:")
    print(f"  Selected Topic: {research_result.selected_topic}")
    print(f"  Target Audience: {research_result.target_audience}")
    print(f"  Rationale: {research_result.rationale[:100]}...")
    print(f"  Demand Signals: {research_result.demand_signals}")
    print(f"  Seasonal Relevance: {research_result.seasonal_relevance[:80]}...")
    print(f"  Stage after research: {run.current_stage.value}")
    
    assert run.current_stage.value == "plan", f"Expected 'plan', got {run.current_stage.value}"
    assert research_result.selected_topic is not None
    assert research_result.target_audience in ["counseling", "12th_droppers", "11th"]
    
    print("\n✅ RESEARCHER TEST PASSED")
    return run

def test_planner(run):
    print("\n" + "=" * 60)
    print("TESTING: SUBAGENT 2 - PLANNER")
    print("=" * 60)
    
    from domains.youtube_hermes.pipeline.agents.planner import run_planner
    
    print(f"\n[PLANNER] Creating content plan for: {run.research.selected_topic}")
    plan = run_planner(run.run_id)
    
    run = db.get_run(run.run_id)
    print(f"\n[PLANNER] Result:")
    print(f"  Topic: {plan.topic}")
    print(f"  Pain Points ({len(plan.audience_pain_points)}): {plan.audience_pain_points[:2]}...")
    print(f"  Myths ({len(plan.myths_misconceptions)}): {plan.myths_misconceptions[:2]}...")
    print(f"  Key Angles ({len(plan.key_angles)}): {plan.key_angles[:2]}...")
    print(f"  Structure Outline ({len(plan.structure_outline)}): {plan.structure_outline}")
    print(f"  CTA: {plan.cta}")
    print(f"  Urgency Hooks: {plan.urgency_hooks}")
    print(f"  Stage after planner: {run.current_stage.value}")
    
    assert run.current_stage.value == "script_write", f"Expected 'script_write', got {run.current_stage.value}"
    assert len(plan.audience_pain_points) == 5
    assert len(plan.key_angles) == 5
    assert len(plan.structure_outline) >= 4
    assert "like" in plan.cta.lower() and "subscribe" in plan.cta.lower()
    
    print("\n✅ PLANNER TEST PASSED")
    return run

def test_script_writer(run):
    print("\n" + "=" * 60)
    print("TESTING: SUBAGENT 3 - SCRIPT WRITER")
    print("=" * 60)
    
    from domains.youtube_hermes.pipeline.agents.script_writer import run_script_writer
    
    print(f"\n[SCRIPT WRITER] Generating script from plan...")
    script = run_script_writer(run.run_id)
    
    run = db.get_run(run.run_id)
    print(f"\n[SCRIPT WRITER] Result:")
    print(f"  Title: {script.title}")
    print(f"  Description: {script.description[:80]}...")
    print(f"  Tags: {script.tags}")
    print(f"  Total Duration: {script.total_duration_seconds}s")
    print(f"  Clips: {len(script.clips)}")
    print(f"  Thumbnail Concept: {script.thumbnail_concept}")
    print(f"  Google Flow Context: {len(script.google_flow_context_prompt)} chars")
    
    for clip in script.clips:
        print(f"\n  Clip {clip.clip_index} ({clip.duration_seconds}s):")
        print(f"    Voiceover: {clip.voiceover_text[:80]}...")
        print(f"    Visual Cues: {clip.visual_cues}")
        print(f"    Transition: {clip.transition_note}")
    
    assert run.current_stage.value == "script_review", f"Expected 'script_review', got {run.current_stage.value}"
    assert len(script.clips) >= 3
    assert len(script.clips) <= 5
    assert script.total_duration_seconds > 0
    assert len(script.thumbnail_concept) > 3
    
    print("\n✅ SCRIPT WRITER TEST PASSED")
    return run

def test_script_reviewer(run):
    print("\n" + "=" * 60)
    print("TESTING: SUBAGENT 4 - SCRIPT REVIEWER")
    print("=" * 60)
    
    from domains.youtube_hermes.pipeline.agents.script_reviewer import run_script_reviewer
    
    print(f"\n[SCRIPT REVIEWER] Reviewing script (attempt {run.script_revision_count + 1})...")
    review = run_script_reviewer(run.run_id)
    
    run = db.get_run(run.run_id)
    print(f"\n[SCRIPT REVIEWER] Result:")
    print(f"  Score: {review.score:.2f} / 1.00")
    print(f"  Threshold: {review.threshold}")
    print(f"  Decision: {review.decision.value}")
    print(f"  Approved: {review.approved}")
    print(f"  Feedback: {review.feedback}")
    print(f"  Specific Fixes: {review.specific_fixes}")
    print(f"  Stage after review: {run.current_stage.value}")
    print(f"  Script Revision Count: {run.script_revision_count}")
    
    # If not approved, show what would happen next
    if not review.approved:
        print(f"\n  ⚠️  Script needs revision. Fixes required:")
        for fix in review.specific_fixes:
            print(f"    - {fix}")
        print(f"  Would loop back to Script Writer (attempt {run.script_revision_count + 1})")
    else:
        print(f"\n  ✅ Script approved! Would proceed to IMAGE_GEN stage")
    
    print("\n✅ SCRIPT REVIEWER TEST PASSED")
    return run

def main():
    print("=" * 60)
    print("YOUTUBE HERMES - SUBAGENTS 1-4 END-TO-END TEST")
    print("=" * 60)
    
    try:
        # Run subagents 1-4 in sequence
        run = test_researcher()
        run = test_planner(run)
        run = test_script_writer(run)
        run = test_script_reviewer(run)
        
        print("\n" + "=" * 60)
        print("🎉 ALL SUBAGENTS 1-4 TESTS PASSED!")
        print("=" * 60)
        print(f"Final Run ID: {run.run_id}")
        print(f"Final Stage: {run.current_stage.value}")
        print(f"Script Revisions: {run.script_revision_count}")
        print(f"Script Approved: {run.script_review.approved if run.script_review else 'N/A'}")
        
        # Show full pipeline state
        print("\n📊 PIPELINE STATE SUMMARY:")
        print(f"  Research: ✅ ({run.research.target_audience})")
        print(f"  Plan: ✅ ({len(run.content_plan.structure_outline)} sections)")
        print(f"  Script: ✅ ({len(run.video_script.clips)} clips, {run.video_script.total_duration_seconds}s)")
        print(f"  Script Review: {'✅ Approved' if run.script_review and run.script_review.approved else '❌ Needs Revision'}")
        
        return 0
        
    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    # Import db at module level for all functions
    from domains.youtube_hermes.pipeline.shared.storage import db
    sys.exit(main())