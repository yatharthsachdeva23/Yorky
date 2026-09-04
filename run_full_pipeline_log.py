#!/usr/bin/env python
"""
Full pipeline test: Researcher -> Planner -> Script Writer -> Script Reviewer
Captures exact inputs and outputs for each subagent.
CLEAN VERSION: Does NOT overwrite agent.llm — wraps each agent's own client.
"""
import sys
import json
sys.path.insert(0, '/c/Desktop/Antigravity Projects/YouTube Manager')

from datetime import datetime
from domains.youtube_hermes.pipeline.agents.researcher import ResearcherAgent
from domains.youtube_hermes.pipeline.agents.planner import PlannerAgent
from domains.youtube_hermes.pipeline.agents.script_writer import ScriptWriterAgent
from domains.youtube_hermes.pipeline.agents.script_reviewer import ScriptReviewerAgent
from domains.youtube_hermes.pipeline.shared.models import PipelineRun, PipelineStage, ContentPlan, ResearchResult, VideoScript
from domains.youtube_hermes.pipeline.shared.storage import PipelineDB
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client


# Capture all LLM calls
all_llm_calls = []


def wrap_llm_for_logging(agent_name, llm_client):
    """Wrap an agent's existing LLM client to capture calls without overwriting."""
    orig_gen = llm_client.generate
    orig_gen_json = llm_client.generate_json

    def cap_gen(prompt, system_prompt=None, **kwargs):
        all_llm_calls.append({
            'agent': agent_name,
            'method': 'generate',
            'system_prompt': system_prompt,
            'full_prompt': prompt,
            'kwargs': {k: v for k, v in kwargs.items() if k != 'timeout'}
        })
        return orig_gen(prompt, system_prompt, **kwargs)

    def cap_gen_json(prompt, system_prompt=None, schema=None, **kwargs):
        all_llm_calls.append({
            'agent': agent_name,
            'method': 'generate_json',
            'system_prompt': system_prompt,
            'full_prompt': prompt,
            'schema': schema,
            'kwargs': {k: v for k, v in kwargs.items() if k != 'timeout'}
        })
        return orig_gen_json(prompt, system_prompt, schema, **kwargs)

    llm_client.generate = cap_gen
    llm_client.generate_json = cap_gen_json


# Output log
log_entries = []

def log_subagent(name, input_data, output_data):
    log_entries.append({
        'subagent': name,
        'timestamp': datetime.now().isoformat(),
        'input': input_data,
        'output': output_data
    })


# ============================================================
# RUN PIPELINE
# ============================================================
print("=" * 80)
print("STARTING FULL PIPELINE: Researcher -> Planner -> Script Writer -> Script Reviewer")
print("=" * 80)

# Create run
run = PipelineRun(
    run_id=f"full_pipeline_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
    video_id="",
    started_at=datetime.now(),
    current_stage=PipelineStage.RESEARCH,
    status="running"
)

db = PipelineDB()
db.create_run(run)


# -----------------------------------------------------------------
# SUBAGENT 1: RESEARCHER
# -----------------------------------------------------------------
print("\n[1/4] RUNNING RESEARCHER...")
print("-" * 80)

researcher = ResearcherAgent()
# Researcher uses Gemini directly, no NVIDIA LLM to wrap

# Input: run object (no user feedback for first run)
research_input = {
    'run': {
        'run_id': run.run_id,
        'stage': str(run.current_stage),
        'status': run.status
    },
    'user_feedback': None,
    'yt_rep_demands': None
}

research_result = researcher.execute(run, user_feedback=None, yt_rep_demands=None)

research_output = {
    'selected_topic': research_result.selected_topic,
    'rationale': research_result.rationale,
    'demand_signals': research_result.demand_signals,
    'target_audience': research_result.target_audience,
    'seasonal_relevance': research_result.seasonal_relevance,
    'competitor_gaps': research_result.competitor_gaps
}

log_subagent('researcher', research_input, research_output)

print(f"[RESEARCHER] Selected Topic: {research_result.selected_topic}")
print(f"[RESEARCHER] Target Audience: {research_result.target_audience}")

run.research = research_result
run.current_stage = PipelineStage.PLAN
db.update_run(run)


# -----------------------------------------------------------------
# SUBAGENT 2: PLANNER
# -----------------------------------------------------------------
print("\n[2/4] RUNNING PLANNER...")
print("-" * 80)

planner = PlannerAgent()
wrap_llm_for_logging('planner', planner.llm)  # Wrap existing client, don't replace

# Input: run + research result
planner_input = {
    'run': {
        'run_id': run.run_id,
        'stage': str(run.current_stage)
    },
    'research': {
        'selected_topic': research_result.selected_topic,
        'rationale': research_result.rationale,
        'target_audience': research_result.target_audience,
        'seasonal_relevance': research_result.seasonal_relevance,
        'demand_signals': research_result.demand_signals,
        'competitor_gaps': research_result.competitor_gaps
    }
}

plan_result = planner.execute(run, research_result)

plan_output = {
    'topic': plan_result.topic,
    'audience_pain_points': plan_result.audience_pain_points,
    'myths_misconceptions': plan_result.myths_misconceptions,
    'key_angles': plan_result.key_angles,
    'structure_outline': plan_result.structure_outline,
    'cta': plan_result.cta,
    'urgency_hooks': plan_result.urgency_hooks
}

log_subagent('planner', planner_input, plan_output)

print(f"[PLANNER] Topic: {plan_result.topic}")
print(f"[PLANNER] Pain Points: {len(plan_result.audience_pain_points)}")
print(f"[PLANNER] Structure Outline: {len(plan_result.structure_outline)} sections")

run.content_plan = plan_result
run.current_stage = PipelineStage.SCRIPT_WRITE
db.update_run(run)


# -----------------------------------------------------------------
# SUBAGENT 3: SCRIPT WRITER
# -----------------------------------------------------------------
print("\n[3/4] RUNNING SCRIPT WRITER...")
print("-" * 80)

writer = ScriptWriterAgent()
wrap_llm_for_logging('script_writer', writer.llm)  # Wrap existing client, don't replace

# Input: run with content_plan
writer_input = {
    'run': {
        'run_id': run.run_id,
        'stage': str(run.current_stage)
    },
    'content_plan': {
        'topic': plan_result.topic,
        'audience_pain_points': plan_result.audience_pain_points,
        'myths_misconceptions': plan_result.myths_misconceptions,
        'key_angles': plan_result.key_angles,
        'structure_outline': plan_result.structure_outline,
        'cta': plan_result.cta,
        'urgency_hooks': plan_result.urgency_hooks
    }
}

script_result = writer.write_script(run)

# Serialize script output
clips_output = []
for c in script_result.clips:
    clips_output.append({
        'clip_index': c.clip_index,
        'duration_seconds': c.duration_seconds,
        'flow_prompt': c.flow_prompt,
        'voiceover_text': c.voiceover_text,
        'visual_cues': c.visual_cues,
        'transition_note': c.transition_note
    })

script_output = {
    'topic': script_result.topic,
    'title': script_result.title,
    'description': script_result.description,
    'tags': script_result.tags,
    'total_duration_seconds': script_result.total_duration_seconds,
    'thumbnail_concept': script_result.thumbnail_concept,
    'google_flow_context_prompt': script_result.google_flow_context_prompt,
    'clips': clips_output
}

log_subagent('script_writer', writer_input, script_output)

print(f"[SCRIPT WRITER] Title: {script_result.title}")
print(f"[SCRIPT WRITER] Clips: {len(script_result.clips)}")
print(f"[SCRIPT WRITER] Duration: {script_result.total_duration_seconds}s")

run.video_script = script_result
run.current_stage = PipelineStage.SCRIPT_REVIEW
db.update_run(run)


# -----------------------------------------------------------------
# SUBAGENT 4: SCRIPT REVIEWER
# -----------------------------------------------------------------
print("\n[4/4] RUNNING SCRIPT REVIEWER...")
print("-" * 80)

reviewer = ScriptReviewerAgent()
wrap_llm_for_logging('script_reviewer', reviewer.llm)  # Wrap existing client, don't replace

# Input: run + script
reviewer_input = {
    'run': {
        'run_id': run.run_id,
        'stage': str(run.current_stage),
        'script_revision_count': run.script_revision_count
    },
    'script': script_output
}

review_result = reviewer.execute(run, script_result)

review_output = {
    'score': review_result.score,
    'threshold': review_result.threshold,
    'decision': review_result.decision.value if hasattr(review_result.decision, 'value') else str(review_result.decision),
    'feedback': review_result.feedback,
    'specific_fixes': review_result.specific_fixes,
    'approved': review_result.approved
}

log_subagent('script_reviewer', reviewer_input, review_output)

print(f"[SCRIPT REVIEWER] Score: {review_result.score:.2f} / {review_result.threshold}")
print(f"[SCRIPT REVIEWER] Decision: {review_result.decision}")
print(f"[SCRIPT REVIEWER] Fixes: {len(review_result.specific_fixes)}")


# -----------------------------------------------------------------
# SAVE COMPLETE LOG
# -----------------------------------------------------------------
print("\n" + "=" * 80)
print("SAVING COMPLETE LOG...")
print("=" * 80)

# Organize LLM calls by agent
llm_by_agent = {}
for call in all_llm_calls:
    agent = call.get('agent', 'unknown')
    if agent not in llm_by_agent:
        llm_by_agent[agent] = []
    llm_by_agent[agent].append(call)

# Build final output
final_log = {
    'pipeline_run_id': run.run_id,
    'timestamp': datetime.now().isoformat(),
    'subagents': log_entries,
    'llm_calls_by_agent': llm_by_agent,
    'total_llm_calls': len(all_llm_calls)
}

output_path = 'full_pipeline_detailed_log.json'
with open(output_path, 'w') as f:
    json.dump(final_log, f, indent=2, default=str)

print(f"\n✅ COMPLETE LOG SAVED TO: {output_path}")
print(f"   Subagents logged: {len(log_entries)}")
print(f"   Total LLM calls: {len(all_llm_calls)}")

for agent, calls in llm_by_agent.items():
    print(f"   - {agent}: {len(calls)} calls")

print("\n" + "=" * 80)
print("PIPELINE COMPLETE")
print("=" * 80)