#!/usr/bin/env python3
"""
Hermy - Personal Assistant Agent
Manages multiple domain-specific Hermes agents (YouTube, Instagram, LinkedIn, Job tasks, etc.)
Assigns tasks, collects reports, reviews work, and provides executive summaries to the user.
"""

import os
import json
import httpx
from dotenv import load_dotenv
load_dotenv()
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Prompt, Confirm
from data.event_bus.bus import EventBus

console = Console()

class HermyPersonalAssistant:
    def __init__(self, config_path: str = r"C:\Users\DELL\AppData\Local\hermes\config.yaml"):
        self.config_path = config_path
        self.bus = EventBus()
        self.api_key = os.getenv("NVIDIA_API_KEY", "")
        self.model = "nvidia/nemotron-3-super-120b-a12b"
        self.base_url = "https://integrate.api.nvidia.com/v1"
        self.domains = {
            "youtube": "YouTube Content Automation",
            "instagram": "Instagram Content & Engagement", 
            "linkedin": "LinkedIn Professional Networking",
            "job": "Job Applications & Career Management",
            "personal": "Personal Tasks & Reminders"
        }
        
    def show_main_menu(self):
        """Display the main assistant menu"""
        console.print("\n[bold cyan]���🎯 HERMY - Your Personal Assistant[/bold cyan]")
        console.print("Managing your domains: YouTube, Instagram, LinkedIn, Job, Personal\n")
        
        table = Table(show_header=True, header_style="bold magenta")
        table.add_column("Option", style="dim", width=6)
        table.add_column("Domain", width=20)
        table.add_column("Description", width=40)
        table.add_column("Action", width=15)
        
        for key, desc in self.domains.items():
            table.add_row(
                f"[green]{key}[/green]",
                desc,
                "Manage tasks & view reports",
                "[yellow]Select[/yellow]"
            )
        
        table.add_row("[blue]status[/blue]", "System Overview", "View all domain statuses", "[cyan]Check[/cyan]")
        table.add_row("[blue]assign[/blue]", "Task Assignment", "Assign new tasks to domains", "[cyan]Create[/cyan]")
        table.add_row("[blue]reports[/blue]", "Domain Reports", "Review recent work from all domains", "[cyan]View[/cyan]")
        table.add_row("[blue]summary[/blue]", "Executive Brief", "Get AI-generated summary of all activity", "[cyan]Generate[/cyan]")
        table.add_row("[blue]quit[/blue]", "Exit Hermy", "Save and exit personal assistant", "[red]Quit[/red]")
        
        console.print(table)
    
    def assign_task(self, domain: str):
        """Assign a task to a specific domain"""
        console.print(f"\n[bold blue]���📝 Assigning Task to {domain.title()} Domain[/bold blue]")
        
        task_description = Prompt.ask(f"[yellow]What task would you like me to assign to the {domain} Hermes agent?[/yellow]")
        priority = Prompt.ask(
            "[yellow]Priority level[/yellow]", 
            choices=["low", "medium", "high", "urgent"], 
            default="medium"
        )
        due_date = Prompt.ask(
            "[yellow]Due date (optional, e.g., 'tomorrow', '2026-08-15')[/yellow]", 
            default=""
        )
        
        # Create task event
        task_payload = {
            "task_id": f"{domain}_{int(os.times().elapsed)}",
            "domain": domain,
            "description": task_description,
            "priority": priority,
            "due_date": due_date if due_date else None,
            "assigned_by": "hermy",
            "timestamp": os.times().elapsed,
            "status": "assigned"
        }
        
        # Publish task assignment event
        self.bus.publish_event(
            domain=f"{domain}_tasks",
            event_type="task_assigned",
            payload=task_payload
        )
        
        console.print(f"[green]��✅ Task assigned to {domain} Hermes agent![/green]")
        console.print(f"[dim]Task ID: {task_payload['task_id']}[/dim]")
        
        return task_payload
    
    def fetch_domain_reports(self, domain: str = None):
        """Fetch reports from specific domain or all domains"""
        events = self.bus.fetch_unprocessed_events()
        
        if domain:
            # Filter events for specific domain (including task events)
            filtered_events = [
                e for e in events 
                if e["domain"] == domain or e["domain"] == f"{domain}_tasks"
            ]
            return filtered_events
        else:
            return events
    
    def review_domain_work(self, domain: str):
        """Review completed work from a specific domain"""
        console.print(f"\n[bold cyan]���🔍 Reviewing {domain.title()} Domain Work[/bold cyan]")
        
        # Get completed work events (where domain Hermes published results)
        events = self.bus.fetch_unprocessed_events()
        domain_events = [
            e for e in events 
            if e["domain"] == domain and e["event_type"] != "task_assigned"
        ]
        
        if not domain_events:
            console.print(f"[yellow]No recent work found from {domain} domain.[/yellow]")
            return []
        
        console.print(f"[green]Found {len(domain_events)} completed items from {domain}[/green]")
        
        for i, event in enumerate(domain_events[-5:], 1):  # Show last 5
            console.print(f"\n[dim]{i}. {event['event_type']}[/dim]")
            console.print(f"[white]{json.dumps(event['payload'], indent=2)[:200]}...[/white]")
        
        return domain_events
    
    def generate_executive_summary(self):
        """Generate an executive summary using Main Executive Hermes logic"""
        console.print("\n[bold cyan]���📊 Generating Executive Summary...[/bold cyan]")
        
        events = self.bus.fetch_unprocessed_events()
        if not events:
            return "No recent activity across all domains. All systems idle."
        
        # Group events by domain
        domain_summary = {}
        for event in events:
            domain = event["domain"]
            if domain not in domain_summary:
                domain_summary[domain] = []
            domain_summary[domain].append(event)
        
        # Create prompt for AI summary
        prompt = f"""
You are HERMY, the Personal Assistant managing multiple domains for your user.
Review these recent activities from all managed domains:

{json.dumps(domain_summary, indent=2)}

Create a personal assistant briefing summarizing:
1. What's been accomplished across all domains today
2. Key insights and metrics from each domain
3. Any blockers or items needing attention
4. Recommended priorities for tomorrow

Keep it concise, actionable, and personalized - like a skilled EA would provide.
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
                
                # Mark events as processed after summary
                for e in events:
                    self.bus.mark_event_processed(e["id"])
                
                return summary
            else:
                return f"Error generating summary: {res.status_code}"
        except Exception as e:
            return f"Error generating summary: {str(e)}"
    
    def show_domain_status(self, domain: str):
        """Show status for a specific domain"""
        console.print(f"\n[bold blue]���📊 {domain.title()} Domain Status[/bold blue]")
        
        events = self.fetch_domain_reports(domain)
        task_events = self.fetch_domain_reports(f"{domain}_tasks")
        
        # Count by status
        pending_tasks = len([t for t in task_events if t["payload"].get("status") == "assigned"])
        completed_work = len([e for e in events if e["event_type"] != "task_assigned"])
        
        status_table = Table(show_header=False, box=None)
        status_table.add_column("Label", style="dim")
        status_table.add_column("Value", style="green")
        
        status_table.add_row("Domain", domain.title())
        status_table.add_row("Pending Tasks", str(pending_tasks))
        status_table.add_row("Completed Work Items", str(completed_work))
        status_table.add_row("Last Activity", "Just now" if events else "No recent activity")
        
        console.print(status_table)
        
        if pending_tasks > 0:
            console.print(f"\n[yellow]��⚠�️  {pending_tasks} pending task(s) awaiting completion[/yellow]")
        
        if completed_work > 0:
            if Confirm.ask(f"View recent {domain} work?"):
                self.review_domain_work(domain)
    
    def run(self):
        """Main assistant loop"""
        console.print("[bold green]���🚀 Hermy Personal Assistant starting...[/bold green]")
        console.print("[dim]Type 'help' at any time for commands[/dim]\n")
        
        while True:
            try:
                self.show_main_menu()
                choice = Prompt.ask(
                    "\n[bold cyan]What would you like to do?[/bold cyan]",
                    choices=list(self.domains.keys()) + ["status", "assign", "reports", "summary", "help", "quit"],
                    default="status"
                )
                
                if choice == "quit":
                    if Confirm.ask("Are you sure you want to exit Hermy?"):
                        console.print("[bold green]���👋 Goodbye! Hermy signing off.[/bold green]")
                        break
                
                elif choice == "help":
                    self.show_help()
                
                elif choice == "status":
                    console.print("\n[bold cyan]���📈 Overall System Status[/bold cyan]")
                    for domain in self.domains.keys():
                        self.show_domain_status(domain)
                
                elif choice == "assign":
                    domain = Prompt.ask(
                        "[yellow]Which domain to assign task to?[/yellow]",
                        choices=list(self.domains.keys())
                    )
                    self.assign_task(domain)
                
                elif choice == "reports":
                    domain = Prompt.ask(
                        "[yellow]View reports from which domain?[/yellow] (leave blank for all)",
                        default=""
                    )
                    if domain and domain in self.domains:
                        self.review_domain_work(domain)
                    else:
                        events = self.fetch_domain_reports()
                        console.print(f"\n[bold cyan]���📋 All Domain Reports ({len(events)} total)[/bold cyan]")
                        for event in events[-10:]:  # Last 10
                            console.print(f"[dim]{event['domain']}: {event['event_type']}[/dim]")
                
                elif choice == "summary":
                    summary = self.generate_executive_summary()
                    console.print(Panel(
                        summary, 
                        title="���🎯 Hermy Executive Briefing", 
                        border_style="gold1"
                    ))
                
                elif choice in self.domains:
                    self.show_domain_status(choice)
                
                if choice != "help":
                    Prompt.ask("\n[dim]Press Enter to continue...[/dim]", default="")
                    
            except KeyboardInterrupt:
                console.print("\n[yellow]Use 'quit' to exit properly.[/yellow]")
            except Exception as e:
                console.print(f"[red]Error: {e}[/red]")
    
    def show_help(self):
        """Show help information"""
        console.print("\n[bold cyan]���📖 Hermy Help[/bold cyan]")
        console.print("""
Hermy is your personal assistant that manages domain-specific AI agents.

Available Commands:
• [green]status[/green] - View status of all domains
• [green]assign[/green] - Assign a new task to a domain
• [green]reports[/green] - View completed work from domains
• [green]summary[/green] - Get AI-generated executive briefing
• [green]youtube|instagram|linkedin|job|personal[/green] - View specific domain status
• [green]help[/green] - Show this help
• [green]quit[/green] - Exit Hermy

How it works:
1. You assign tasks to domain agents (YouTube, Instagram, etc.) through Hermy
2. Domain agents work on tasks and publish results to the EventBus
3. Hermy fetches these results and can review them
4. Hermy generates executive summaries using AI
5. You get concise, actionable updates like a personal assistant would provide

The system uses an event-driven architecture for loose coupling between domains.
        """)

if __name__ == "__main__":
    hermy = HermyPersonalAssistant()
    hermy.run()