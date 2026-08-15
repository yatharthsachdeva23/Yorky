import sys
sys.path.insert(0, r"C:\Desktop\Antigravity Projects\YouTube Manager")

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan

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

agent = ScriptWriterAgent()

print("=" * 80)
print("MASTER CONTEXT PROMPT (Sent FIRST to set up everything)")
print("=" * 80)
context_prompt = agent._build_master_context_prompt(plan)
print(context_prompt)

print("\n" + "=" * 80)
print("CLIP-BY-CLIP PROMPTS (Sent ONE BY ONE after context is acknowledged)")
print("=" * 80)

for i, section in enumerate(plan.structure_outline[:4], 1):
    clip_prompt = agent._build_clip_prompt(plan, i, section, plan.structure_outline)
    print(f"\n{'='*80}")
    print(f"CLIP {i} PROMPT")
    print(f"{'='*80}")
    print(clip_prompt)

print("\n" + "=" * 80)
print("WORKFLOW:")
print("1. Send MASTER CONTEXT PROMPT → Get acknowledgment")
print("2. Send CLIP 1 PROMPT → Get JSON response")
print("3. Send CLIP 2 PROMPT → Get JSON response")
print("4. Send CLIP 3 PROMPT → Get JSON response")
print("5. Send CLIP 4 PROMPT → Get JSON response")
print("6. Send METADATA PROMPT → Get title/description/tags/thumbnail")
print("=" * 80)