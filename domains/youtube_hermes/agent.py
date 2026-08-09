import os
import json
from rich.console import Console
from rich.panel import Panel

from hermes_manager.agent import HermesOrchestrator
from data.event_bus.bus import EventBus

console = Console()

class YouTubeHermesDomainManager:
    """Dedicated YouTube Domain Hermes Agent."""
    def __init__(self):
        self.domain_dir = os.path.dirname(__file__)
        self.config_file = os.path.join(self.domain_dir, "config.json")
        self.soul_file = os.path.join(self.domain_dir, "SOUL.md")
        self.config = self.load_config()
        self.orchestrator = HermesOrchestrator()
        self.event_bus = EventBus()

    def load_config(self) -> dict:
        with open(self.config_file, "r", encoding="utf-8") as f:
            return json.load(f)

    def load_soul(self) -> str:
        with open(self.soul_file, "r", encoding="utf-8") as f:
            return f.read()

    def print_status(self):
        console.print(Panel(
            f"[bold cyan]YOUTUBE DOMAIN HERMES INSTANCE[/bold cyan]\n"
            f"[yellow]Account:[/yellow] {self.config.get('account_email')}\n"
            f"[yellow]Chrome Profile:[/yellow] {self.config.get('chrome_profile_directory')}\n"
            f"[yellow]Model:[/yellow] {self.config.get('model_name')}\n"
            f"[yellow]Subagents:[/yellow] {', '.join(self.config.get('subagents', []))}\n"
            f"[yellow]Current Pipeline Stage:[/yellow] {self.orchestrator.state.stage}\n"
            f"[yellow]Active Topic:[/yellow] {self.orchestrator.state.topic or 'Not Selected'}",
            title="YouTube Domain Status",
            border_style="cyan"
        ))

    def run_next_stage(self) -> bool:
        """Executes the current active pipeline step for YouTube Shorts."""
        console.print("\n[bold cyan]>>> YouTube Domain Hermes: Executing Active Pipeline Step...[/bold cyan]")
        success = self.orchestrator.run_pipeline_step()
        if success:
            self.print_status()
        return success

if __name__ == "__main__":
    manager = YouTubeHermesDomainManager()
    manager.print_status()
