import os
import json
from typing import Dict, Any, List

class ContentPlanner:
    def __init__(self, persona_path: str = "data/channel_persona.json"):
        self.persona_path = persona_path

    def find_trending_topic(self, feedback_history: List[str] = None) -> Dict[str, Any]:
        """Finds top trending topic using Gemini API."""
        try:
            from google import genai
            client = genai.Client()
            prompt = f"""
Find 1 high-performing YouTube Short topic trending right now.
Feedback from past videos: {json.dumps(feedback_history or [])}

Return JSON with:
- topic: specific title/topic
- rationale: why it will go viral
- target_audience: description of target viewer
"""
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
            )
            import re
            match = re.search(r"\{.*\}", response.text, re.DOTALL)
            if match:
                return json.loads(match.group(0))
        except Exception as e:
            print(f"[ContentPlanner] Topic research fallback: {e}")
        
        return {
            "topic": "The Future of AI Automation in 2026",
            "rationale": "High trending search volume and viewer engagement.",
            "target_audience": "Tech enthusiasts and creators."
        }

    def create_shorts_plan(self, topic: str) -> Dict[str, Any]:
        """Plans 3-4 scenes for a 45-60 second YouTube Short."""
        try:
            from google import genai
            client = genai.Client()
            prompt = f"""
Create a 4-scene breakdown for a YouTube Short video on: "{topic}".
Each scene should be 15 seconds long (total 60s).

Return JSON with key "scenes", where each scene has:
- scene_num (1-4)
- visual_description: detailed prompt for AI video generation (Google Flow)
- voiceover_text: script line for this scene
"""
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
            )
            import re
            match = re.search(r"\{.*\}", response.text, re.DOTALL)
            if match:
                return json.loads(match.group(0))
        except Exception as e:
            print(f"[ContentPlanner] Shorts plan fallback: {e}")

        return {
            "scenes": [
                {"scene_num": 1, "visual_description": "Cinematic futuristic AI core glowing in dark cyberpunk studio, 9:16 vertical", "voiceover_text": "Did you know AI agents can now run full YouTube channels on autopilot?"},
                {"scene_num": 2, "visual_description": "High tech digital workspace with glowing code streams and analytics graphs, vertical", "voiceover_text": "From researching viral trends to writing scripts and rendering video clips."},
                {"scene_num": 3, "visual_description": "Robotic hand holding a smartphone showing viral YouTube Shorts views counter, 9:16", "voiceover_text": "It handles uploads, reads viewer comments, and improves content automatically."},
                {"scene_num": 4, "visual_description": "Futuristic logo exploding into particles with Subscribe button callout, vertical", "voiceover_text": "Subscribe now to see what this AI builds next!"}
            ]
        }
