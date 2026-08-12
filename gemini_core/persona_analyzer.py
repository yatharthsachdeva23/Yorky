import os
import json
from typing import Dict, Any, List

DEFAULT_PERSONA = {
    "channel_name": "My YouTube Channel",
    "niche": "Tech & AI News",
    "tone": "Engaging, Fast-paced, Informative, Energetic",
    "speaking_style": "Direct hook in first 3 seconds, quick bullet points, clear call to action.",
    "catchphrases": ["Let's dive right in!", "Drop a comment below!"],
    "target_shorts_length_seconds": 55,
    "visual_theme": "High energy cinematic visuals with fast cuts"
}

class PersonaAnalyzer:
    def __init__(self, persona_path: str = "data/channel_persona.json"):
        self.persona_path = persona_path
        os.makedirs(os.path.dirname(self.persona_path), exist_ok=True)

    def load_or_create_persona(self) -> Dict[str, Any]:
        if os.path.exists(self.persona_path):
            with open(self.persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        return self.save_persona(DEFAULT_PERSONA)

    def save_persona(self, persona_data: Dict[str, Any]) -> Dict[str, Any]:
        with open(self.persona_path, "w", encoding="utf-8") as f:
            json.dump(persona_data, f, indent=2)
        return persona_data

    def learn_from_text_samples(self, text_samples: List[str]) -> Dict[str, Any]:
        """Analyzes text samples/transcripts using Gemini to extract style parameters."""
        try:
            from google import genai
            client = genai.Client()
            prompt = f"""
Analyze the following video scripts/transcripts and extract the channel persona:
{json.dumps(text_samples)}

Return a JSON object with:
- channel_name
- niche
- tone
- speaking_style
- catchphrases (list)
- visual_theme
"""
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
            )
            # Parse JSON from response
            import re
            match = re.search(r"\{.*\}", response.text, re.DOTALL)
            if match:
                persona_data = json.loads(match.group(0))
                return self.save_persona(persona_data)
        except Exception as e:
            print(f"[PersonaAnalyzer] Gemini analysis warning: {e}. Using default persona.")
        
        return self.load_or_create_persona()
