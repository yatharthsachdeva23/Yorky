import os
import json
from typing import Dict, Any, Optional
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn

from hermes_manager.state import StateManager, PipelineState
from hermes_manager.prompts import HERMES_SYSTEM_PROMPT

console = Console()

class HermesOrchestrator:
    def __init__(self, mode: str = "auto", model_name: str = "gemini-2.5-flash"):
        self.mode = mode  # 'auto' or 'interactive'
        self.model_name = model_name
        self.state_mgr = StateManager()
        self.state = self.state_mgr.state

    def print_status(self):
        console.print(Panel(
            f"[bold cyan]HERMES MASTER ORCHESTRATOR[/bold cyan]\n"
            f"[yellow]Current Video ID:[/yellow] {self.state.video_id}\n"
            f"[yellow]Current Stage:[/yellow] {self.state.stage}\n"
            f"[yellow]Persona File:[/yellow] {self.state.persona_file}\n"
            f"[yellow]Topic:[/yellow] {self.state.topic or 'Not Selected'}",
            title="Hermes Status Dashboard",
            border_style="cyan"
        ))

    def run_pipeline_step(self) -> bool:
        """Executes the current active stage of the pipeline."""
        stage = self.state.stage
        console.print(f"\n[bold green]>>> Hermes executing Stage: {stage}[/bold green]")

        if stage == "0_LEARN":
            return self._step_learn_persona()
        elif stage == "1_TRENDS":
            return self._step_analyze_trends()
        elif stage == "2_PLAN":
            return self._step_plan_content()
        elif stage == "3_SCRIPT":
            return self._step_write_script()
        elif stage == "4_SCRIPT_QA":
            return self._step_script_qa()
        elif stage == "5_FLOW_GEN":
            return self._step_flow_video_gen()
        elif stage == "6_ASSEMBLE":
            return self._step_assemble_video()
        elif stage == "7_FINAL_QA":
            return self._step_final_qa()
        elif stage == "8_PUBLISH":
            return self._step_publish_youtube()
        elif stage == "9_FEEDBACK":
            return self._step_comment_feedback()
        else:
            console.print(f"[red]Unknown stage: {stage}[/red]")
            return False

    def _step_learn_persona(self) -> bool:
        console.print("[cyan]Hermes: Triggering Gemini Persona Learning Module...[/cyan]")
        from gemini_core.persona_analyzer import PersonaAnalyzer
        analyzer = PersonaAnalyzer()
        persona = analyzer.load_or_create_persona()
        console.print(f"[green]Persona Loaded: {persona.get('channel_name', 'Default Channel')} ({persona.get('tone', 'Casual')})[/green]")
        self.state_mgr.update_stage("1_TRENDS")
        return True

    def _step_analyze_trends(self) -> bool:
        console.print("[cyan]Hermes: Analyzing current trends & viewer feedback...[/cyan]")
        from gemini_core.planner import ContentPlanner
        planner = ContentPlanner()
        topic_info = planner.find_trending_topic(feedback_history=self.state.feedback_notes)
        self.state.topic = topic_info["topic"]
        self.state.target_audience = topic_info["target_audience"]
        self.state_mgr.save_state()
        console.print(f"[bold yellow]Selected Topic:[/bold yellow] {self.state.topic}")
        self.state_mgr.update_stage("2_PLAN")
        return True

    def _step_plan_content(self) -> bool:
        console.print("[cyan]Hermes: Creating 45-60s Short Content Plan (3-4 clips)...[/cyan]")
        from gemini_core.planner import ContentPlanner
        planner = ContentPlanner()
        plan = planner.create_shorts_plan(topic=self.state.topic)
        console.print(f"[green]Content Plan Created with {len(plan['scenes'])} Scenes.[/green]")
        self.state_mgr.update_stage("3_SCRIPT")
        return True

    def _step_write_script(self) -> bool:
        console.print("[cyan]Hermes: Writing persona-aligned script & Google Flow prompts...[/cyan]")
        from gemini_core.scriptwriter import ScriptWriter
        writer = ScriptWriter()
        script_data = writer.generate_script(topic=self.state.topic)
        self.state.script_data = script_data
        self.state_mgr.save_state()
        console.print(f"[green]Script Title:[/green] {script_data['title']}")
        self.state_mgr.update_stage("4_SCRIPT_QA")
        return True

    def _step_script_qa(self) -> bool:
        console.print("[cyan]Hermes: Reviewing script retention & hook strength...[/cyan]")
        from gemini_core.scriptwriter import ScriptWriter
        writer = ScriptWriter()
        qa_result = writer.review_script(self.state.script_data)
        if qa_result["approved"]:
            self.state.script_approved = True
            console.print("[bold green]Script Approved by Hermes QA![/bold green]")
            self.state_mgr.update_stage("5_FLOW_GEN")
        else:
            console.print(f"[yellow]Script revision requested: {qa_result['suggestions']}[/yellow]")
            # Re-run scriptwriting with suggestions
            self.state_mgr.update_stage("3_SCRIPT")
        self.state_mgr.save_state()
        return True

    def _step_flow_video_gen(self) -> bool:
        console.print("[cyan]Hermes: Launching Google Flow Web Automation for Multi-Clip Generation...[/cyan]")
        from flow_automation.generator import FlowVideoGenerator
        generator = FlowVideoGenerator()
        scenes = self.state.script_data.get("scenes", [])
        clips = generator.generate_all_clips(scenes=scenes, video_id=self.state.video_id)
        self.state.clips = clips
        self.state_mgr.save_state()
        self.state_mgr.update_stage("6_ASSEMBLE")
        return True

    def _step_assemble_video(self) -> bool:
        console.print("[cyan]Hermes: Stitching clips with ffmpeg...[/cyan]")
        from video_processing.assembler import VideoAssembler
        assembler = VideoAssembler()
        clip_paths = [c.video_path for c in self.state.clips if c.video_path and os.path.exists(c.video_path)]
        final_path = assembler.stitch_clips(clip_paths=clip_paths, output_id=self.state.video_id)
        self.state.final_video_path = final_path
        self.state_mgr.save_state()
        console.print(f"[bold green]Final Video Assembled at:[/bold green] {final_path}")
        self.state_mgr.update_stage("7_FINAL_QA")
        return True

    def _step_final_qa(self) -> bool:
        console.print("[cyan]Hermes: Verifying final video file...[/cyan]")
        if self.state.final_video_path and os.path.exists(self.state.final_video_path):
            console.print("[bold green]Final QA Passed![/bold green]")
            self.state_mgr.update_stage("8_PUBLISH")
            return True
        else:
            console.print("[red]Final video file missing. Returning to assembly stage.[/red]")
            self.state_mgr.update_stage("6_ASSEMBLE")
            return False

    def _step_publish_youtube(self) -> bool:
        console.print("[cyan]Hermes: Publishing YouTube Short...[/cyan]")
        from youtube_engine.uploader import YouTubeUploader
        uploader = YouTubeUploader()
        res = uploader.upload_short(
            file_path=self.state.final_video_path,
            title=self.state.script_data.get("title", "Awesome YouTube Short #Shorts"),
            description=self.state.script_data.get("description", "Uploaded by Autonomous Hermes System"),
            tags=self.state.script_data.get("tags", ["Shorts", "AI"])
        )
        self.state.youtube_video_id = res.get("id")
        self.state_mgr.save_state()
        console.print(f"[bold green]Uploaded Short Video ID:[/bold green] {self.state.youtube_video_id}")
        self.state_mgr.update_stage("9_FEEDBACK")
        return True

    def _step_comment_feedback(self) -> bool:
        console.print("[cyan]Hermes: Monitoring comments & extracting feedback...[/cyan]")
        from youtube_engine.comments import CommentFeedbackManager
        from data.event_bus.bus import EventBus
        
        mgr = CommentFeedbackManager()
        feedback = mgr.process_video_comments(video_id=self.state.youtube_video_id)
        self.state.feedback_notes.extend(feedback.get("learnings", []))
        self.state_mgr.save_state()
        
        # Publish domain report event to Main Executive Hermes
        EventBus().publish_event(
            domain="youtube",
            event_type="video_published_and_comments_analyzed",
            payload={
                "video_id": self.state.youtube_video_id,
                "topic": self.state.topic,
                "learnings": feedback.get("learnings", []),
                "replies_count": len(feedback.get("replies", []))
            }
        )
        
        console.print(f"[bold green]Extracted {len(feedback.get('learnings', []))} learnings and reported to Main Executive Hermes![/bold green]")
        return True
