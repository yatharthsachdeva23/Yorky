#!/usr/bin/env python
"""
Capture EXACT prompts sent to NVIDIA LLM during actual test_mock_topic.py run.
"""
import sys
sys.path.insert(0, '/c/Desktop/Antigravity Projects/YouTube Manager')

from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client
from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage
from datetime import datetime


# Capture ALL calls
captured = []

client = get_nvidia_client()
orig_gen = client.generate
orig_gen_json = client.generate_json

def cap_gen(prompt, system_prompt=None, **kwargs):
    captured.append({
        'method': 'generate',
        'system_prompt': system_prompt,
        'full_prompt': prompt,
        'kwargs': {k: v for k, v in kwargs.items() if k != 'timeout'}
    })
    return orig_gen(prompt, system_prompt, **kwargs)

def cap_gen_json(prompt, system_prompt=None, schema=None, **kwargs):
    captured.append({
        'method': 'generate_json',
        'system_prompt': system_prompt,
        'full_prompt': prompt,
        'schema': schema,
        'kwargs': {k: v for k, v in kwargs.items() if k != 'timeout'}
    })
    return orig_gen_json(prompt, system_prompt, schema, **kwargs)

client.generate = cap_gen
client.generate_json = cap_gen_json


# Same plan as test_mock_topic.py
plan = ContentPlan(
    topic="🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy",
    audience_pain_points=[
        "Syllabus incomplete - how can I give mocks if I have not finished syllabus?",
        "Fear of low scores - what if I score badly in mocks and lose confidence?",
        "No strategy - I just solve papers randomly without any approach",
        "Analysis paralysis - I give mocks but do not know how to analyse them properly",
        "Time management - I spend too much time on one section and miss others"
    ],
    key_angles=[
        "Mocks as diagnostic tool, not performance test",
        "Strategic attempt order: easy -> medium -> hard",
        "Mistake categorization: concept / silly / time",
        "Weak topic list drives next week study plan",
        "Consistency > intensity: 30 mocks over 5 months"
    ],
    structure_outline=[
        "Hook (0-3s): Shock urgency - 5 months to JEE Main 2027",
        "Why mocks matter today (3-18s): Myth 1-5 busting + diagnostic value",
        "How to attempt a mock strategically (18-33s): Timer, order, marking, time/section",
        "Post-mock analysis routine (33-48s): Categorize, update weak list, adjust targets",
        "CTA (48-60s): Generic like/share/subscribe/comment + start today"
    ],
    cta="Like, share, subscribe, and comment your mock test doubts below.",
    urgency_hooks=[
        "LAST CHANCE – Start mocks NOW, 5 months to JEE Main 2027!",
        "STOP waiting for syllabus finish – mocks DIAGNOSE gaps, do not test completion!",
        "90% score myth is KILLING your prep – any score teaches you something!",
        "Every mock skipped = one less diagnostic data point for your rank!"
    ],
    myths_misconceptions=[
        "Mocks only after syllabus completion",
        "Need 90%+ score in mocks to be ready",
        "More mocks = better preparation automatically",
        "All mocks are identical - any platform works",
        "Analysis means just checking right/wrong answers"
    ]
)

writer = ScriptWriterAgent()
writer.llm = client

run = PipelineRun(
    run_id="capture_prompts_001",
    stage=PipelineStage.script_write,
    status="running",
    topic=plan.topic,
    input_data=plan.to_dict(),
    created_at=datetime.now()
)

print("Running Script Writer (capturing all LLM calls)...\n")
script = writer.write_script(run)

print(f"\n{'='*80}")
print(f"TOTAL LLM CALLS MADE: {len(captured)}")
print(f"{'='*80}\n")

for i, c in enumerate(captured, 1):
    print(f"{'='*80}")
    print(f"CALL #{i} - {c['method'].upper()}")
    print(f"{'='*80}")
    print(f"SYSTEM PROMPT ({len(c['system_prompt']) if c['system_prompt'] else 0} chars):")
    print(c['system_prompt'][:300] + "..." if c['system_prompt'] and len(c['system_prompt']) > 300 else c['system_prompt'])
    print(f"\nFULL USER PROMPT ({len(c['full_prompt'])} chars):")
    print(c['full_prompt'][:500] + "..." if len(c['full_prompt']) > 500 else c['full_prompt'])
    if c['schema']:
        print(f"\nSCHEMA: {c['schema']}")
    print()

# Save full details to JSON
import json
with open('/c/Desktop/Antigravity Projects/YouTube Manager/exact_llm_calls_captured.json', 'w') as f:
    json.dump(captured, f, indent=2, default=str)

print(f"✅ Full prompts saved to: exact_llm_calls_captured.json")