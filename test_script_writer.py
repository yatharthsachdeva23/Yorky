import sys
sys.path.insert(0, r"C:\Desktop\Antigravity Projects\YouTube Manager")

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent, get_script_writer, run_script_writer
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, ResearchResult

# Test 1: Mock Strategy (12th/droppers)
print('=== TEST 1: MOCK STRATEGY ===')
plan1 = ContentPlan(
    topic='🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy',
    audience_pain_points=['Believe they must finish the entire syllabus before attempting any mock test', 'Feel demotivated by low scores in early mocks', 'Do not know how to analyze mock tests', 'Struggle with time management', 'Experience anxiety about the exam pattern'],
    myths_misconceptions=['Mock tests are only useful after completing the syllabus', 'You need to score 90%+ in mocks', 'More mocks automatically lead to higher scores', 'Mock tests are identical to the actual JEE Main paper', 'Analyzing a mock test takes too much time'],
    key_angles=['Mocks as diagnostic tool', 'Building exam temperament', 'Using mock scores to adjust study plan', 'Practicing time-bound question selection', 'Turning low-score mocks into feedback loops'],
    structure_outline=['Hook: LAST CHANCE - Start mocks NOW, 5 months to JEE Main 2027!', 'Why mocks matter today: Early mocks diagnose gaps, build temperament, guide study plan', 'How to attempt a mock strategically: Set timer, attempt full paper, mark guesses', 'Post-mock analysis routine: Check answers, categorize mistakes, update weak-topic list', 'CTA: Like, share, subscribe, comment your mock doubts - every mock counts'],
    cta='Like, share, subscribe, and comment your mock test doubts below.',
    urgency_hooks=['LAST CHANCE to start mocks before JEE Main 2027', 'Only 5 months left - every mock counts', "Don't wait for syllabus finish - start NOW", 'Final window to build exam temperament']
)
script1 = ScriptWriterAgent()._fallback_script(None, plan1)
print(f'Title: {script1.title}')
print(f'Duration: {script1.total_duration_seconds}s')
print(f'Clips: {len(script1.clips)}')
print(f'Thumbnail: {script1.thumbnail_concept}')
for i, clip in enumerate(script1.clips):
    print(f'  Clip {clip.clip_index}: {clip.duration_seconds}s - {clip.voiceover_text[:60]}...')
    print(f'    Flow: {clip.flow_prompt[:100]}...')
print()

# Test 2: Counseling
print('=== TEST 2: COUNSELING ===')
plan2 = ContentPlan(
    topic='🚨 CSAB Special Round 2026: Deadlines Aug 18-20 | IPU Spot Round 2 Notice OUT',
    audience_pain_points=['Confused about CSAB Special Round dates', "Don't know IPU Spot Round 2 process", 'Missing document checklist', 'State-specific counseling unclear'],
    myths_misconceptions=['Spot rounds are only for low-rankers', "Can't skip document verification", 'Choice filling does not matter'],
    key_angles=['Exact deadlines for CSAB Special', 'IPU Spot Round 2 new notice details', 'Document checklist with common mistakes', 'State-specific guidance'],
    structure_outline=['Hook: DEADLINES THIS WEEK - CSAB Special + IPU Spot R2', 'Key dates and process for CSAB Special Round', 'IPU Spot Round 2 notice and JAC Spot Round', 'Document checklist + state-specific guidance'],
    cta='Like, share, subscribe, comment YOUR state for specific info.',
    urgency_hooks=['DEADLINES AUG 18-20', 'CSAB Special Round live', 'IPU Spot Round 2 notice out', 'Seats filling fast']
)
script2 = ScriptWriterAgent()._fallback_script(None, plan2)
print(f'Title: {script2.title}')
print(f'Duration: {script2.total_duration_seconds}s')
print(f'Clips: {len(script2.clips)}')
print(f'Thumbnail: {script2.thumbnail_concept}')
for i, clip in enumerate(script2.clips):
    print(f'  Clip {clip.clip_index}: {clip.duration_seconds}s - {clip.voiceover_text[:60]}...')
    print(f'    Flow: {clip.flow_prompt[:100]}...')
print()

# Test 3: 11th Grade
print('=== TEST 3: 11TH GRADE ===')
plan3 = ContentPlan(
    topic='🚨 20 Months to JEE 2028: Start Right Not Fast | 11th Grade Complete Roadmap',
    audience_pain_points=['Think they are behind in 11th grade', "Don't know when to start JEE prep", 'Confused about coaching vs self-study', 'Struggle with school + JEE balance'],
    myths_misconceptions=['Must solve advanced problems from day 1', 'Coaching mandatory from day 1', 'NCERT is too basic'],
    key_angles=['Positive 20-month framing', 'Foundation first approach', 'School+JEE integration', 'Simple daily habits'],
    structure_outline=['Hook: 20 MONTHS to JEE 2028 - Start Right Not Fast', 'Bust myths: No advanced yet, coaching not mandatory, NCERT is foundation', '20-month roadmap: 3 phases with school integration', 'Daily habits + weekly reviews + CTA'],
    cta='Like, share, subscribe, comment your 11th grade doubts.',
    urgency_hooks=['20 MONTHS = PLENTY OF TIME', 'Start RIGHT not fast', 'Foundation first wins', 'School + JEE integrated']
)
script3 = ScriptWriterAgent()._fallback_script(None, plan3)
print(f'Title: {script3.title}')
print(f'Duration: {script3.total_duration_seconds}s')
print(f'Clips: {len(script3.clips)}')
print(f'Thumbnail: {script3.thumbnail_concept}')
for i, clip in enumerate(script3.clips):
    print(f'  Clip {clip.clip_index}: {clip.duration_seconds}s - {clip.voiceover_text[:60]}...')
    print(f'    Flow: {clip.flow_prompt[:100]}...')
print()

print('=== ALL TESTS PASSED ===')