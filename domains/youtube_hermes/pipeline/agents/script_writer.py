"""
Subagent 3: SCRIPT WRITER
Writes the EXACT SCRIPT divided into 15-second clips for Google Flow.
Ensures seamless flow for 30-90 second video. Uses bhaiya voice with Hinglish, urgency markers.
"""
from __future__ import annotations
import json
from typing import Dict, Any, List, Optional

from domains.youtube_hermes.pipeline.shared.models import VideoScript, ClipScript, PipelineRun, PipelineStage, ContentPlan
from domains.youtube_hermes.pipeline.shared.storage import db
from domains.youtube_hermes.pipeline.shared.llm import get_nvidia_client, get_system_prompt


class ScriptWriterAgent:
    """Subagent 3: Writes script divided into 15-second clips for Google Flow."""
    
    def __init__(self):
        self.llm = get_nvidia_client()
        self.system_prompt = get_system_prompt("script_writer")
    
    def execute(self, run: PipelineRun, plan: ContentPlan, 
                revision_feedback: Optional[str] = None) -> VideoScript:
        """Write script from content plan."""
        print(f"\n[SCRIPT WRITER] Writing script for: {plan.topic}")
        print(f"[SCRIPT WRITER] Estimated clips: {plan.estimated_clips}")
        
        revision_context = ""
        if revision_feedback:
            revision_context = f"""
REVISION REQUIRED (from Script Reviewer):
{revision_feedback}

PREVIOUS ATTEMPT: {run.script_revision_count}
FIX THE ABOVE ISSUES IN THIS REVISION.
"""
        
        prompt = f"""Write a VIRAL YouTube Short SCRIPT for @YatharthSachdeva23.

TOPIC: {plan.topic}
CONTENT PLAN:
- Pain points: {json.dumps(plan.audience_pain_points)}
- Myths to bust: {json.dumps(plan.myths_misconceptions)}
- Key angles: {json.dumps(plan.key_angles)}
- Structure: {json.dumps(plan.structure_outline)}
- CTA: {plan.cta}
- Urgency hooks: {json.dumps(plan.urgency_hooks)}
- Estimated clips: {plan.estimated_clips}

{revision_context}

CRITICAL REQUIREMENTS:
1. DIVIDE INTO EXACT 15-SECOND CLIPS (Google Flow limit)
2. Total duration: 30-90 seconds (2-6 clips)
3. SEAMLESS FLOW - each clip must lead naturally to next
4. HOOK in FIRST 3 SECONDS: Urgency marker (🚨 LAST CHANCE, BREAKING, DON'T MISS)
5. VOICE: Yatharth's EXACT bhaiya persona
   - Hinglish mix: "arre yaar", "sahi time pe", "bas kar", "chill karo", "tension mat lo"
   - Brotherly: "bhai dekh...", "main bata raha hoon...", "tu tension mat le"
   - Urgency: "abhi karo", "kal se shuru", "aaj hi dekho"
   - Empathetic but action-oriented
6. ZERO academic teaching - ONLY mentoring/process/strategy
7. Each clip needs:
   - flow_prompt: Hyper-detailed 9:16 vertical prompt for Google Flow
   - voiceover_text: Exact spoken line (15 seconds of speech ~35-40 words)
   - visual_cues: On-screen text overlays, graphics, key points
   - transition_note: How this clip flows to next
8. Thumbnail concept for Image Gen

Return JSON with:
- title: High CTR title with #Shorts
- description: SEO description
- tags: Relevant tags
- clips: Array of clip objects (clip_index, flow_prompt, voiceover_text, visual_cues, transition_note, duration_seconds=15)
- thumbnail_concept: Brief for thumbnail
"""
        
        try:
            result_dict = self.llm.generate_json(prompt, self.system_prompt)
            
            # Convert clips to ClipScript objects
            clips = []
            for clip_data in result_dict.get("clips", []):
                clips.append(ClipScript(
                    clip_index=clip_data.get("clip_index", len(clips) + 1),
                    duration_seconds=clip_data.get("duration_seconds", 15),
                    flow_prompt=clip_data.get("flow_prompt", ""),
                    voiceover_text=clip_data.get("voiceover_text", ""),
                    visual_cues=clip_data.get("visual_cues", []),
                    transition_note=clip_data.get("transition_note", "")
                ))
            
            result = VideoScript(
                topic=plan.topic,
                title=result_dict.get("title", ""),
                description=result_dict.get("description", ""),
                tags=result_dict.get("tags", []),
                clips=clips,
                thumbnail_concept=result_dict.get("thumbnail_concept", "")
            )
            
            db.save_artifact(run.run_id, "script", "result", result_dict)
            
            run.video_script = result
            run.current_stage = PipelineStage.SCRIPT_REVIEW
            db.update_run(run)
            
            print(f"[SCRIPT WRITER] Script written: {len(clips)} clips, {result.total_duration_seconds}s total")
            return result
            
        except Exception as e:
            print(f"[SCRIPT WRITER] Error: {e}")
            # Fallback
            fallback_clips = [
                ClipScript(1, 15, "Cinematic 9:16 vertical: worried student at desk surrounded by books, clock showing August, dramatic lighting", 
                          "🚨 AUGUST STARTED! 11th backlog? 12th syllabus? Bhai tension mat lo - main hoon na!", 
                          ["🚨 AUGUST = CRITICAL MONTH", "11th BACKLOG + 12TH SYLLABUS"], 
                          "Cut to: calm bhaiya explaining the strategy"),
                ClipScript(2, 15, "9:16 vertical: bhaiya (Yatharth) talking to camera, warm brotherly expression, text overlay 'MYTH BUSTING'", 
                          "Arre yaar, sabse bada myth - '100% syllabus khatam karo tab mocks'. GALAT! Mocks se hi pata chalega kya reh gaya.", 
                          ["MYTH: 'Finish syllabus first'", "TRUTH: Mocks guide preparation"], 
                          "Transition to: strategic framework"),
                ClipScript(3, 15, "9:16 vertical: animated framework - 3 boxes 'Prioritize', 'Mock Weekly', 'Consistency > Intensity'", 
                          "Simple 3-step framework bhai: 1) High-weight topics first 2) Weekly mock non-negotiable 3) Daily 3 hours > Sunday 10 hours. Sahi time pe sahi kaam.", 
                          ["FRAMEWORK: Prioritize → Mock → Consistency", "HIGH WEIGHT TOPICS FIRST"], 
                          "End with urgent CTA"),
                ClipScript(4, 15, "9:16 vertical: bhaiya close-up, intense but caring, pointing at camera, 'SUBSCRIBE' animation", 
                          "Comment right now - tera biggest block kya hai? 11th backlog? Time management? Main personally reply karunga action plan ke saath. 🚨 SUBSCRIBE for daily JEE reality checks!", 
                          ["COMMENT YOUR BLOCK", "PERSONAL REPLY GUARANTEED", "🚨 SUBSCRIBE"], 
                          "")
            ]
            
            fallback = VideoScript(
                topic=plan.topic,
                title="🚨 JEE 2026: August Strategy for 11th Backlog + 12th Syllabus! #Shorts #JEE",
                description="Bhaiya's exact framework to handle 11th backlog while starting 12th. No lecturing - pure strategy!",
                tags=["JEE2026", "JEEPreparation", "BacklogClearance", "SyllabusStrategy", "Shorts"],
                clips=fallback_clips,
                thumbnail_concept="Split screen: Stressed student vs Calm bhaiya with framework. Text: 'AUGUST STRATEGY 🚨' Red/yellow urgency colors."
            )
            
            db.save_artifact(run.run_id, "script", "result", fallback.__dict__)
            run.video_script = fallback
            run.current_stage = PipelineStage.SCRIPT_REVIEW
            db.update_run(run)
            return fallback


def run_script_writer(run_id: str, revision_feedback: Optional[str] = None) -> VideoScript:
    """Entry point for orchestrator."""
    run = db.get_run(run_id)
    if not run or not run.content_plan:
        raise ValueError(f"Run {run_id} not found or missing content plan")
    
    agent = ScriptWriterAgent()
    return agent.execute(run, run.content_plan, revision_feedback)