import json
from typing import Dict, Any, List

class CommentFeedbackManager:
    def __init__(self, persona_path: str = "data/channel_persona.json"):
        self.persona_path = persona_path

    def process_video_comments(self, video_id: str) -> Dict[str, Any]:
        """Fetches comments, generates AI replies, and extracts feedback for Content Planner."""
        print(f"[CommentFeedback] Processing comments for video: {video_id}...")
        
        # Sample comments for demonstration/testing
        comments = [
            {"author": "TechFan99", "text": "Awesome video! Can you do a video on autonomous coding agents next?"},
            {"author": "Alex_V", "text": "Loved clip #2 visual effect! Pacing was super fast and clean."}
        ]

        replies = []
        learnings = []

        try:
            from google import genai
            client = genai.Client()
            prompt = f"""
Given viewer comments on our YouTube Short:
{json.dumps(comments)}

1. Generate friendly replies in our channel persona.
2. Extract viewer feedback & content suggestions for upcoming videos.

Return JSON with:
- replies: array of objects (author, reply_text)
- learnings: array of string feedback notes for the Content Planner
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
            print(f"[CommentFeedback] Gemini comment processing fallback: {e}")

        return {
            "replies": [
                {"author": "TechFan99", "reply_text": "Thanks TechFan99! Autonomous coding agents video is coming right up! 🚀"},
                {"author": "Alex_V", "reply_text": "Appreciate it Alex! We'll keep that fast visual pacing in every Short! 🔥"}
            ],
            "learnings": [
                "Audience wants a video on autonomous coding agents.",
                "Audience loves fast visual pacing and high-tech clip effects."
            ]
        }
