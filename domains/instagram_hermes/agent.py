import os
import json
from rich.console import Console
from rich.panel import Panel

console = Console()

class InstagramHermesInstance:
    def __init__(self):
        self.domain_dir = os.path.dirname(__file__)
        self.config_file = os.path.join(self.domain_dir, "config.json")
        self.soul_file = os.path.join(self.domain_dir, "SOUL.md")
        self.config = self.load_config()

    def load_config(self):
        with open(self.config_file, "r", encoding="utf-8") as f:
            return json.load(f)

    def load_soul(self):
        with open(self.soul_file, "r", encoding="utf-8") as f:
            return f.read()

    def run(self):
        console.print(Panel(
            f"[bold magenta]INSTAGRAM DOMAIN HERMES INSTANCE[/bold magenta]\n"
            f"[yellow]Account:[/yellow] {self.config.get('account_email')}\n"
            f"[yellow]Chrome Profile:[/yellow] {self.config.get('chrome_profile_directory')}\n"
            f"[yellow]Model:[/yellow] {self.config.get('model_name')}\n"
            f"[yellow]Subagents:[/yellow] {', '.join(self.config.get('subagents', []))}\n"
            f"[yellow]Status:[/yellow] INITIALIZED & READY",
            border_style="magenta"
        ))

if __name__ == "__main__":
    instance = InstagramHermesInstance()
    instance.run()
