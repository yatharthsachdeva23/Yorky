import os
import sys
import argparse
from rich.console import Console
from rich.panel import Panel

from hermes_manager.agent import HermesOrchestrator
from main_hermes.executive_agent import MainExecutiveHermes
from flow_automation.generator import FlowVideoGenerator
from gemini_core.persona_analyzer import PersonaAnalyzer

console = Console()

def main():
    parser = argparse.ArgumentParser(description="Multi-Hermes Hierarchical System")
    parser.add_argument("command", choices=["status", "run-youtube", "executive", "learn", "setup-flow"], nargs="?", default="status")
    parser.add_argument("--samples", nargs="+", help="Past video transcript lines or links for learning style")
    
    args = parser.parse_args()

    if args.command == "status":
        orchestrator = HermesOrchestrator()
        orchestrator.print_status()
        console.print("\n[bold yellow]Available Multi-Hermes Commands:[/bold yellow]")
        console.print("  [green]python main.py run-youtube[/green] : Run YouTube Domain Hermes pipeline")
        console.print("  [green]python main.py executive[/green]   : Run Main Executive Hermes (summarize all domains)")
        console.print("  [green]python main.py learn[/green]       : Learn channel persona from past video transcripts")
        console.print("  [green]python main.py setup-flow[/green]  : Launch browser for 1-time Google Flow login\n")

    elif args.command == "executive":
        console.print("[bold cyan]>>> Launching Main Executive Hermes...[/bold cyan]")
        exec_agent = MainExecutiveHermes()
        exec_agent.review_domain_reports()

    elif args.command == "learn":
        console.print("[bold cyan]>>> Learning Channel Persona...[/bold cyan]")
        analyzer = PersonaAnalyzer()
        samples = args.samples or ["Hey guys! Welcome back to the channel. Today we dive fast into AI automation!"]
        persona = analyzer.learn_from_text_samples(samples)
        console.print(f"[bold green]Learned Persona Saved:[/bold green]\n{persona}")

    elif args.command == "setup-flow":
        console.print("[bold cyan]>>> Setting up Google Flow Web session...[/bold cyan]")
        flow_gen = FlowVideoGenerator()
        flow_gen.launch_setup_session()

    elif args.command == "run-youtube":
        console.print("[bold cyan]>>> Launching YouTube Domain Hermes Pipeline...[/bold cyan]")
        orchestrator = HermesOrchestrator()
        success = orchestrator.run_pipeline_step()
        if success:
            console.print("[bold green]YouTube Step Completed Successfully![/bold green]")
            orchestrator.print_status()

if __name__ == "__main__":
    main()
