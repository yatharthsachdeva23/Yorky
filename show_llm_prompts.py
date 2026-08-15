#!/usr/bin/env python3
"""Display the complete prompts that would be sent to NVIDIA LLM (master context + clip prompts)."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.shared.models import ContentPlan

def main():
    print("=" * 100)
    print("COMPLETE PROMPTS THAT WOULD BE SENT TO NVIDIA NEMOTRON LLM")
    print("=" * 100)
    
    # Create the ContentPlan
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
    
    writer = ScriptWriterAgent()
    
    # ============================================================
    # MASTER CONTEXT PROMPT (sent once at the beginning)
    # ============================================================
    print("\n" + "=" * 100)
    print("STAGE 1: MASTER CONTEXT PROMPT (sent ONCE to establish persona, style, rules)")
    print("=" * 100)
    
    master_prompt = writer._build_master_context_prompt(plan)
    print(master_prompt)
    print(f"\n[LENGTH: {len(master_prompt)} characters]")
    
    # ============================================================
    # CLIP PROMPTS (sent one by one after context acknowledged)
    # ============================================================
    print("\n" + "=" * 100)
    print("STAGE 2: CLIP-BY-CLIP PROMPTS (sent sequentially after context acknowledged)")
    print("=" * 100)
    
    all_sections = plan.structure_outline[:4]  # Max 4 clips
    
    for i, section in enumerate(all_sections, 1):
        clip_prompt = writer._build_clip_prompt(plan, i, section, all_sections)
        print(f"\n{'='*100}")
        print(f"CLIP {i} PROMPT")
        print(f"{'='*100}")
        print(clip_prompt)
        print(f"\n[LENGTH: {len(clip_prompt)} characters]")
    
    # ============================================================
    # SYSTEM PROMPT
    # ============================================================
    print("\n" + "=" * 100)
    print("SYSTEM PROMPT (Script Writer)")
    print("=" * 100)
    print(writer.system_prompt)
    
    print("\n" + "=" * 100)
    print("TOTAL PROMPTS THAT WOULD BE SENT TO LLM:")
    print(f"  1 Master Context Prompt: {len(master_prompt)} chars")
    for i in range(1, 5):
        clip_prompt = writer._build_clip_prompt(plan, i, all_sections[i-1], all_sections)
        print(f"  Clip {i} Prompt: {len(clip_prompt)} chars")
    print(f"  System Prompt: {len(writer.system_prompt)} chars")
    print(f"  TOTAL: {len(master_prompt) + sum(len(writer._build_clip_prompt(plan, i, all_sections[i-1], all_sections)) for i in range(1,5)) + len(writer.system_prompt)} chars")
    print("=" * 100)

if __name__ == "__main__":
    main()