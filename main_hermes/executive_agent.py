import os
import json
import httpx
from rich.console import Console
from rich.panel import Panel
from data.event_bus.bus import EventBus

console = Console()

class MainExecutiveHermes:
    def __init__(self, config_path: str = r"C:\Users\DELL\AppData\Local\hermes\config.yaml"):
        self.config_path = config_path
        self.bus = EventBus()
        self.api_key = "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"
        self.model = "nvidia/nemotron-3-super-120b-a12b"
        self.base_url = "https://integrate.api.nvidia.com/v1"

    def review_domain_reports(self) -> str:
        """Main Hermes checks all pending domain events and creates an Executive Summary."""
        events = self.bus.fetch_unprocessed_events()
        if not events:
            return "No new domain events reported. All systems operational."

        console.print(f"\n[bold cyan]>>> Main Executive Hermes Processing {len(events)} Domain Reports...[/bold cyan]")
        
        prompt = f"""
You are MAIN EXECUTIVE HERMES, the top-level Brand & Automation Manager.
Review these incoming domain events from sub-agents:
{json.dumps(events, indent=2)}

Create an Executive Briefing summarizing:
1. Videos/Content Published across domains
2. Audience Feedback & Key Insights
3. Strategic Directives for tomorrow's content cycles
"""
        try:
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            payload = {
                "model": self.model,
                "messages": [{"role": "user", "content": prompt}]
            }
            res = httpx.post(f"{self.base_url}/chat/completions", headers=headers, json=payload, timeout=30.0)
            if res.status_code == 200:
                summary = res.json()["choices"][0]["message"]["content"]
                # Mark events as processed
                for e in events:
                    self.bus.mark_event_processed(e["id"])
                
                console.print(Panel(summary, title="Main Executive Hermes Daily Briefing", border_style="gold1"))
                return summary
        except Exception as e:
            console.print(f"[red]Main Hermes Summary Error: {e}[/red]")
            
        return f"Processed {len(events)} events."
