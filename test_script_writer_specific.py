import sys
sys.path.insert(0, r"C:\Desktop\Antigravity Projects\YouTube Manager")

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import db

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

print("=== Testing Script Writer with User's Exact Content Plan ===")
print(f"Topic: {plan.topic}")
print(f"Pain Points: {len(plan.audience_pain_points)}")
print(f"Myths: {len(plan.myths_misconceptions)}")
print(f"Key Angles: {len(plan.key_angles)}")
print(f"Structure: {len(plan.structure_outline)} sections")
print()

# Create a pipeline run
from datetime import datetime
import uuid

run = PipelineRun(
    run_id=str(uuid.uuid4()),
    video_id=str(uuid.uuid4()),
    started_at=datetime.now(),
    current_stage=PipelineStage.RESEARCH,
    content_plan=plan
)
db.create_run(run)

# Run the script writer
agent = ScriptWriterAgent()
script = agent.write_script(run)

print("=== GENERATED SCRIPT ===")
print(f"Title: {script.title}")
print(f"Description: {script.description}")
print(f"Tags: {script.tags}")
print(f"Total Duration: {script.total_duration_seconds}s")
print(f"Clips: {len(script.clips)}")
print(f"Thumbnail Concept: {script.thumbnail_concept}")
print()

for clip in script.clips:
    print(f"--- Clip {clip.clip_index} ({clip.duration_seconds}s) ---")
    print(f"Voiceover: {clip.voiceover_text}")
    print(f"Visual Cues: {clip.visual_cues}")
    print(f"Transition: {clip.transition_note}")
    print(f"Flow Prompt (first 200 chars): {clip.flow_prompt[:200]}...")
    print()

print("=== TEST COMPLETE ===")