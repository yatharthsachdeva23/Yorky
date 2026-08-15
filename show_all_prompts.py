#!/usr/bin/env python
"""
Display all prompts sent to NVIDIA LLM during Script Writer execution.
"""
import sys
sys.path.insert(0, '/c/Desktop/Antigravity Projects/YouTube Manager')

from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client
from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan, PipelineRun, PipelineStage
from domains.youtube_hermes.pipeline.shared.storage import PipelineDB
import json
from datetime import datetime


# Monkey-patch to capture prompts
original_generate = get_nvidia_client().generate
original_generate_json = get_nvidia_client().generate_json

captured_prompts = []

def capture_generate(prompt, system_prompt=None, **kwargs):
    captured_prompts.append({
        'type': 'generate',
        'system_prompt': system_prompt[:500] + '...' if system_prompt and len(system_prompt) > 500 else system_prompt,
        'prompt': prompt[:800] + '...' if len(prompt) > 800 else prompt,
        'full_prompt': prompt,
        'kwargs': kwargs
    })
    return original_generate(prompt, system_prompt, **kwargs)

def capture_generate_json(prompt, system_prompt=None, schema=None, **kwargs):
    captured_prompts.append({
        'type': 'generate_json',
        'system_prompt': system_prompt[:500] + '...' if system_prompt and len(system_prompt) > 500 else system_prompt,
        'prompt': prompt[:800] + '...' if len(prompt) > 800 else prompt,
        'full_prompt': prompt,
        'schema': schema,
        'kwargs': kwargs
    })
    return original_generate_json(prompt, system_prompt, schema, **kwargs)

# Apply monkey patches
client = get_nvidia_client()
client.generate = capture_generate
client.generate_json = capture_generate_json


# Create test content plan (same as test_mock_topic.py)
plan = ContentPlan(
    topic="🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy",
    pain_points=[
        "Syllabus incomplete - 'how can I give mocks if I haven't finished syllabus?'",
        "Fear of low scores - 'what if I score badly in mocks and lose confidence?'",
        "No strategy - 'I just solve papers randomly without any approach'",
        "Analysis paralysis - 'I give mocks but don't know how to analyse them properly'",
        "Time management - 'I spend too much time on one section and miss others'"
    ],
    myths=[
        "Mocks only after syllabus completion",
        "Need 90%+ score in mocks to be ready",
        "More mocks = better preparation automatically",
        "All mocks are identical - any platform works",
        "Analysis means just checking right/wrong answers"
    ],
    key_angles=[
        "Mocks as diagnostic tool, not performance test",
        "Strategic attempt order: easy → medium → hard",
        "Mistake categorization: concept / silly / time",
        "Weak topic list drives next week's study plan",
        "Consistency > intensity: 30 mocks over 5 months"
    ],
    structure_outline=[
        "Hook (0-3s): Shock urgency - 5 months to JEE Main 2027",
        "Why mocks matter today (3-18s): Myth 1-5 busting + diagnostic value",
        "How to attempt a mock strategically (18-33s): Timer, order, marking, time/section",
        "Post-mock analysis routine (33-48s): Categorize, update weak list, adjust targets",
        "CTA (48-60s): Generic like/share/subscribe/comment + start today"
    ],
    section_durations=[3, 15, 15, 15, 12],
    cta="Like, share, subscribe, and comment your mock test doubts below.",
    urgency_hooks=[
        "🚨 LAST CHANCE – Start mocks NOW, 5 months to JEE Main 2027!",
        "🚨 STOP waiting for syllabus finish – mocks DIAGNOSE gaps, don't test completion!",
        "🚨 90% score myth is KILLING your prep – any score teaches you something!",
        "🚨 Every mock skipped = one less diagnostic data point for your rank!"
    ],
    target_date="2027-01-15",
    exam_type="JEE Main",
    audience_level="11th/12th/Dropper"
)

# Create script writer agent
writer = ScriptWriterAgent()
writer.llm = client  # Use patched client

# Run script writer
print("=" * 80)
print("RUNNING SCRIPT WRITER - CAPTURING ALL PROMPTS SENT TO NVIDIA LLM")
print("=" * 80)

run = PipelineRun(
    run_id="test_prompts_001",
    stage=PipelineStage.script_write,
    status="running",
    topic=plan.topic,
    input_data=plan.to_dict(),
    created_at=datetime.now()
)

script = writer.write_script(run)

print(f"\n{'=' * 80}")
print(f"CAPTURED {len(captured_prompts)} PROMPTS SENT TO NVIDIA LLM")
print(f"{'=' * 80}\n")

for i, cap in enumerate(captured_prompts, 1):
    print(f"{'=' * 80}")
    print(f"PROMPT #{i} - {cap['type'].upper()}")
    print(f"{'=' * 80}")
    print(f"SYSTEM PROMPT:")
    print(cap['system_prompt'] or "None")
    print(f"\nUSER PROMPT (first 800 chars):")
    print(cap['prompt'])
    print(f"\nFULL PROMPT LENGTH: {len(cap['full_prompt'])} chars")
    if cap.get('schema'):
        print(f"\nSCHEMA: {json.dumps(cap['schema'], indent=2)[:500]}")
    print()

# Also show the master context prompt separately
print(f"{'=' * 80}")
print("MASTER CONTEXT PROMPT (built by Script Writer)")
print(f"{'=' * 80}")
master_context = writer._build_master_context_prompt(plan)
print(f"LENGTH: {len(master_context)} chars")
print(master_context)

print(f"\n{'=' * 80}")
print("STRUCTURE PROMPT (for autonomous clip division)")
print(f"{'=' * 80}")
structure_prompt = writer._build_structure_prompt(plan)
print(f"LENGTH: {len(structure_prompt)} chars")
print(structure_prompt[:3000] + "..." if len(structure_prompt) > 3000 else structure_prompt)

print(f"\n{'=' * 80}")
print("CLIP 1 PROMPT")
print(f"{'=' * 80}")
clip1_prompt = writer._build_clip_prompt(plan, 1, {"section": "Hook + Myth 1-2", "focus": "Shock urgency + bust myths: mocks only after syllabus & need 90%+", "approx_words": 38, "is_first": True, "is_last": False, "next_segment_preview": "Myths 3-5"}, [])
print(f"LENGTH: {len(clip1_prompt)} chars")
print(clip1_prompt[:3000] + "..." if len(clip1_prompt) > 3000 else clip1_prompt)

# Save to file
output = {
    "captured_prompts": captured_prompts,
    "master_context_prompt": master_context,
    "structure_prompt": structure_prompt,
    "clip1_prompt": clip1_prompt,
    "total_prompts_sent": len(captured_prompts)
}

with open('/c/Desktop/Antigravity Projects/YouTube Manager/all_llm_prompts_captured.json', 'w') as f:
    json.dump(output, f, indent=2, default=str)

print(f"\n\n✅ ALL PROMPTS SAVED TO: /c/Desktop/Antigravity Projects/YouTube Manager/all_llm_prompts_captured.json")