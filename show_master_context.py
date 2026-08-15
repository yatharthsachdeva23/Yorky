#!/usr/bin/env python
"""
Show the exact master context prompt sent to NVIDIA LLM.
"""
import sys
sys.path.insert(0, '/c/Desktop/Antigravity Projects/YouTube Manager')

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan
from datetime import datetime


# Create test content plan
plan = ContentPlan(
    topic="🚨 You Should Do This NOW: Mock Test Strategy for JEE Main 2027 - Importance & Attempt Strategy",
    audience_pain_points=[
        "Syllabus incomplete - 'how can I give mocks if I haven't finished syllabus?'",
        "Fear of low scores - 'what if I score badly in mocks and lose confidence?'",
        "No strategy - 'I just solve papers randomly without any approach'",
        "Analysis paralysis - 'I give mocks but don't know how to analyse them properly'",
        "Time management - 'I spend too much time on one section and miss others'"
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
    cta="Like, share, subscribe, and comment your mock test doubts below.",
    urgency_hooks=[
        "🚨 LAST CHANCE – Start mocks NOW, 5 months to JEE Main 2027!",
        "🚨 STOP waiting for syllabus finish – mocks DIAGNOSE gaps, don't test completion!",
        "🚨 90% score myth is KILLING your prep – any score teaches you something!",
        "🚨 Every mock skipped = one less diagnostic data point for your rank!"
    ],
    myths_misconceptions=[
        "Mocks only after syllabus completion",
        "Need 90%+ score in mocks to be ready",
        "More mocks = better preparation automatically",
        "All mocks are identical - any platform works",
        "Analysis means just checking right/wrong answers"
    ]
)

# Create script writer agent
writer = ScriptWriterAgent()

# Build and show the master context prompt
master_context = writer._build_master_context_prompt(plan)

print("=" * 80)
print("MASTER CONTEXT PROMPT (sent to LLM FIRST to establish Google Flow context)")
print("=" * 80)
print(f"LENGTH: {len(master_context)} characters")
print()
print(master_context)
print()
print("=" * 80)
print("END OF MASTER CONTEXT PROMPT")
print("=" * 80)

# Also show what the LLM should reply with (the acknowledgment)
print()
print("EXPECTED LLM RESPONSE (acknowledgment):")
print("CONTEXT UNDERSTOOD. Ready for clip-by-clip generation. Don't show clip numbers - just generate the clips I will give you the prompt.")

# Save to file
with open('/c/Desktop/Antigravity Projects/YouTube Manager/master_context_prompt.txt', 'w') as f:
    f.write(master_context)

print(f"\n✅ Saved to: /c/Desktop/Antigravity Projects/YouTube Manager/master_context_prompt.txt")