import sys
sys.path.insert(0, r"C:\Desktop\Antigravity Projects\YouTube Manager")

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.agents.script_reviewer import ScriptReviewerAgent, run_script_reviewer
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import db
from datetime import datetime
import uuid

# The exact ContentPlan from the user's specification
plan = ContentPlan(
    topic='🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy',
    audience_pain_points=[
        'Believe they must finish the entire syllabus before attempting any mock test',
        'Feel demotivated by low scores in early mocks and think they are wasting time',
        'Do not know how to analyze mock tests to improve their preparation',
        'Struggle with time management and question selection during practice',
        'Experience anxiety about the exam pattern and lack real-exam temperament'
    ],
    myths_misconceptions=[
        'Mock tests are only useful after completing the syllabus',
        'You need to score 90%+ in mocks for them to be worthwhile',
        'More mocks automatically lead to higher scores without analysis',
        'Mock tests are identical to the actual JEE Main paper',
        'Analyzing a mock test takes too much time and reduces study hours'
    ],
    key_angles=[
        'Mocks as a diagnostic tool to reveal gaps in real time',
        'Building exam temperament and reducing fear through early exposure',
        'Using mock scores to adjust study plan and prioritize weak topics',
        'Practicing time-bound question selection and elimination strategies',
        'Turning low-score mocks into actionable feedback loops for improvement'
    ],
    structure_outline=[
        'Hook (0-3s): 🚨 LAST CHANCE - Start mocks NOW, 5 months to JEE Main 2027!',
        'Why mocks matter today (3-18s): Early mocks diagnose gaps, build temperament, guide study plan - no syllabus finish needed',
        'How to attempt a mock strategically (18-33s): Set timer, attempt full paper, mark guesses, note time per section, avoid looking at solutions immediately',
        'Post-mock analysis routine (33-48s): Check answers, categorize mistakes (concept/silly/time), update weak-topic list, adjust next week targets',
        'CTA & urgency (48-60s): Like, share, subscribe, comment your mock doubts - every mock counts, start today!'
    ],
    cta='Like, share, subscribe, and comment your mock test doubts below.',
    urgency_hooks=[
        '🚨 LAST CHANCE to start mocks before JEE Main 2027',
        'Only 5 months left - every mock counts',
        "Don't wait for syllabus finish - start NOW",
        'This is your final window to build exam temperament'
    ]
)

print("=== Testing Full Script Write + Review Loop ===")
print(f"Topic: {plan.topic}")
print()

# Create a pipeline run
run = PipelineRun(
    run_id=str(uuid.uuid4()),
    video_id=str(uuid.uuid4()),
    started_at=datetime.now(),
    current_stage=PipelineStage.RESEARCH,
    content_plan=plan
)
db.create_run(run)

# Step 1: Run Script Writer
print("--- STEP 1: Script Writer ---")
agent = ScriptWriterAgent()
script = agent.write_script(run)
print(f"Title: {script.title}")
print(f"Duration: {script.total_duration_seconds}s")
print(f"Clips: {len(script.clips)}")
print(f"Thumbnail: {script.thumbnail_concept}")
print()

# Step 2: Run Script Reviewer
print("--- STEP 2: Script Reviewer ---")
reviewer = ScriptReviewerAgent()
result = reviewer.execute(run, script)
print(f"Score: {result.score:.2f}")
print(f"Threshold: {result.threshold}")
print(f"Decision: {result.decision.value}")
print(f"Approved: {result.approved}")
print(f"Feedback: {result.feedback}")
print(f"Specific Fixes: {result.specific_fixes}")
print()

# Check if revision loop works
if not result.approved:
    print("--- REVISION LOOP: Script needs revision ---")
    print(f"Revision count: {run.script_revision_count}")
    # Would loop back to script writer with feedback
else:
    print("--- SCRIPT APPROVED - Moving to Image Gen / Video Make ---")
    print(f"Next stage: {run.current_stage.value}")

print()
print("=== FULL LOOP TEST COMPLETE ===")