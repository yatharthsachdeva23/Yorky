import json
import os
from datetime import datetime
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field

class ClipState(BaseModel):
    clip_index: int
    prompt: str
    video_path: Optional[str] = None
    approved: bool = False
    review_notes: Optional[str] = None
    attempts: int = 0

class PipelineState(BaseModel):
    video_id: str
    created_at: str = Field(default_factory=lambda: datetime.now().isoformat())
    stage: str = "0_LEARN"  # 0_LEARN, 1_TRENDS, 2_PLAN, 3_SCRIPT, 4_SCRIPT_QA, 5_FLOW_GEN, 6_ASSEMBLE, 7_FINAL_QA, 8_PUBLISH, 9_FEEDBACK
    persona_file: str = "data/channel_persona.json"
    topic: Optional[str] = None
    target_audience: Optional[str] = None
    script_data: Optional[Dict[str, Any]] = None
    script_approved: bool = False
    clips: List[ClipState] = []
    final_video_path: Optional[str] = None
    youtube_video_id: Optional[str] = None
    comments_summary: Optional[Dict[str, Any]] = None
    feedback_notes: List[str] = []

class StateManager:
    def __init__(self, state_file: str = "state/current_pipeline.json"):
        self.state_file = state_file
        os.makedirs(os.path.dirname(self.state_file), exist_ok=True)
        os.makedirs("data", exist_ok=True)
        self.state = self.load_state()

    def load_state(self) -> PipelineState:
        if os.path.exists(self.state_file):
            try:
                with open(self.state_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    return PipelineState(**data)
            except Exception as e:
                print(f"[StateManager] Warning loading state: {e}. Starting fresh.")
        return PipelineState(video_id=f"short_{int(datetime.now().timestamp())}")

    def save_state(self):
        with open(self.state_file, "w", encoding="utf-8") as f:
            json.dump(self.state.model_dump(), f, indent=2)

    def update_stage(self, stage: str):
        self.state.stage = stage
        self.save_state()
