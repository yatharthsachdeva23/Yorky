import os
import sys
import json
import httpx
from dotenv import load_dotenv
load_dotenv()
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

console = Console()

HERMES_SYSTEM_PROMPT = """You are Hermes, a highly intelligent autonomous agent.
You excel at reasoning, task planning, decision making, tool orchestration, and content management.
Respond clearly, concisely, and act as an expert autonomous master agent.
"""

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY", "")
NVIDIA_MODEL = "z-ai/glm-5.2"
NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"

def test_nvidia_hermes():
    console.print(f"\n[bold cyan]>>> Testing Hermes with NVIDIA NIM ({NVIDIA_MODEL})...[/bold cyan]")
    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": NVIDIA_MODEL,
        "messages": [
            {"role": "system", "content": HERMES_SYSTEM_PROMPT},
            {"role": "user", "content": "Hello Hermes! State your active model and confirm you are ready to manage the YouTube pipeline."}
        ]
    }
    try:
        res = httpx.post(f"{NVIDIA_BASE_URL}/chat/completions", headers=headers, json=payload, timeout=30.0)
        if res.status_code == 200:
            content = res.json()["choices"][0]["message"]["content"]
            console.print(Panel(content, title=f"Hermes Agent Response ({NVIDIA_MODEL})", border_style="green"))
            return True
        else:
            console.print(f"[red]NVIDIA API Status: {res.status_code} - {res.text}[/red]")
    except Exception as e:
        console.print(f"[red]Error connecting to NVIDIA Hermes model: {e}[/red]")
    return False

def interactive_chat():
    console.print(f"\n[bold green]=== Interactive Session with Hermes Agent ({NVIDIA_MODEL}) ===[/bold green]")
    console.print("[yellow]Type your message and press ENTER. Type 'exit' or 'quit' to stop.[/yellow]\n")
    
    messages = [{"role": "system", "content": HERMES_SYSTEM_PROMPT}]
    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json"
    }
    
    while True:
        try:
            user_input = Prompt.ask("\n[bold cyan]You[/bold cyan]")
            if user_input.strip().lower() in ["exit", "quit", "q"]:
                console.print("[bold yellow]Exiting Hermes session.[/bold yellow]")
                break
                
            messages.append({"role": "user", "content": user_input})
            payload = {
                "model": NVIDIA_MODEL,
                "messages": messages
            }
            res = httpx.post(f"{NVIDIA_BASE_URL}/chat/completions", headers=headers, json=payload, timeout=30.0)
            if res.status_code == 200:
                reply = res.json()["choices"][0]["message"]["content"]
                messages.append({"role": "assistant", "content": reply})
                console.print(Panel(reply, title=f"Hermes ({NVIDIA_MODEL})", border_style="green"))
            else:
                console.print(f"[red]API error {res.status_code}[/red]")
        except KeyboardInterrupt:
            break
        except Exception as e:
            console.print(f"[red]Error: {e}[/red]")

def main():
    console.print(Panel(
        f"[bold yellow]HERMES AGENT CONFIGURATION[/bold yellow]\n"
        f"[green]Data Store Located:[/green] C:\\Users\\DELL\\AppData\\Local\\hermes\n"
        f"[green]Provider:[/green] NVIDIA NIM\n"
        f"[green]Model:[/green] {NVIDIA_MODEL}\n"
        f"[green]Config Updated:[/green] C:\\Users\\DELL\\AppData\\Local\\hermes\\config.yaml",
        border_style="cyan"
    ))
    
    success = test_nvidia_hermes()
    if success:
        chat_choice = Prompt.ask("\nDo you want to start an interactive chat session with Hermes right now? (y/n)", default="y")
        if chat_choice.lower() in ["y", "yes"]:
            interactive_chat()

if __name__ == "__main__":
    main()
