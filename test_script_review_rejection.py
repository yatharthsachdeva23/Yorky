import sys
sys.path.insert(0, r"C:\Desktop\Antigravity Projects\YouTube Manager")

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.agents.script_reviewer import ScriptReviewerAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage, VideoScript, ClipScript
from domains.youtube_hermes.pipeline.shared.storage import db
from datetime import datetime
import uuid

# Create a BAD script that should be rejected (academic teaching, no urgency, poor CTA)
bad_plan = ContentPlan(
    topic='🚨 Mock Test Strategy JEE Main 2027',
    audience_pain_points=['Don\'t know how to study'],
    myths_misconceptions=['Mocks are hard'],
    key_angles=['Just do mocks'],
    structure_outline=['Intro', 'Content', 'CTA'],
    cta='Subscribe to my channel',
    urgency_hooks=['Urgent']
)

# Create a run
run = PipelineRun(
    run_id=str(uuid.uuid4()),
    video_id=str(uuid.uuid4()),
    started_at=datetime.now(),
    current_stage=PipelineStage.SCRIPT_WRITE,
    content_plan=bad_plan
)
db.create_run(run)

# Create a BAD script (academic teaching, no Hinglish, no urgency, bad CTA)
bad_script = VideoScript(
    topic=bad_plan.topic,
    title="Mock Test Strategy for JEE",
    description="Learn how to do mock tests for JEE preparation. Complete guide.",
    tags=["JEE", "Mock Test"],
    clips=[
        ClipScript(
            clip_index=1,
            duration_seconds=15,
            flow_prompt="Talking head explaining what mock tests are. Academic lecture style.",
            voiceover_text="Today we will learn about mock tests and how they help in JEE preparation. Mock tests are practice exams.",
            visual_cues=["What are mock tests", "JEE preparation"],
            transition_note="Next: how to study"
        ),
        ClipScript(
            clip_index=2,
            duration_seconds=15,
            flow_prompt="Whiteboard lecture on syllabus completion before mocks.",
            voiceover_text="First you must complete the full syllabus including all chapters of physics, chemistry, and mathematics. Then you can attempt mock tests.",
            visual_cues=["Complete syllabus first", "Physics Chemistry Math"],
            transition_note="Next: mock analysis"
        ),
        ClipScript(
            clip_index=3,
            duration_seconds=15,
            flow_prompt="Academic explanation of mock analysis.",
            voiceover_text="After the mock test, you should check every answer and understand the concepts behind each question. This is how you learn.",
            visual_cues=["Check answers", "Understand concepts"],
            transition_note="Next: subscribe"
        ),
        ClipScript(
            clip_index=4,
            duration_seconds=15,
            flow_prompt="Direct to camera asking for subscription.",
            voiceover_text="Please subscribe to my channel and I will personally reply to your comments with your rank prediction. DM me for study plan.",
            visual_cues=["Subscribe now", "Personal reply guaranteed", "DM for study plan"],
            transition_note="End"
        )
    ],
    thumbnail_concept="MOCK TESTS EXPLAINED"
)

print("=== Testing Script Reviewer with BAD Script (Should Reject) ===")
print(f"Script Title: {bad_script.title}")
print(f"Duration: {bad_script.total_duration_seconds}s")
print(f"Clips: {len(bad_script.clips)}")
print()

# Run Script Reviewer
reviewer = ScriptReviewerAgent()
result = reviewer.execute(run, bad_script)

print(f"Score: {result.score:.2f}")
print(f"Threshold: {result.threshold}")
print(f"Decision: {result.decision.value}")
print(f"Approved: {result.approved}")
print(f"Feedback: {result.feedback}")
print(f"Specific Fixes: {result.specific_fixes}")
print(f"Revision Count: {run.script_revision_count}")
print(f"Current Stage: {run.current_stage.value}")
print()

if not result.approved:
    print("✅ REVISION LOOP WORKING: Script rejected, looped back to SCRIPT_WRITE stage")
    print("   In real pipeline, Script Writer would re-run with these fixes:")
    for fix in result.specific_fixes:
        print(f"   - {fix}")
else:
    print("❌ Script was approved (unexpected for bad script)")