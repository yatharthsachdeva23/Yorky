"""
SQLite-backed state persistence for the YouTube Hermes Pipeline.
Stores pipeline runs, artifacts, and review loop history.
"""
from __future__ import annotations
import json
import os
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from domains.youtube_hermes.pipeline.shared.models import (
    PipelineRun, PipelineStage, ReviewResult, ReviewDecision,
    ResearchResult, ContentPlan, VideoScript, ClipScript,
    ThumbnailArtifact, VideoClipArtifact, FinalVideoArtifact,
    UploadResult, FeedbackItem, ChannelAuditReport
)


DB_PATH = Path("data/youtube_hermes/state.db")
DB_PATH.parent.mkdir(parents=True, exist_ok=True)


SCHEMA = """
CREATE TABLE IF NOT EXISTS pipeline_runs (
    run_id TEXT PRIMARY KEY,
    video_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    completed_at TEXT,
    current_stage TEXT NOT NULL,
    status TEXT NOT NULL,
    script_revision_count INTEGER DEFAULT 0,
    thumbnail_revision_count INTEGER DEFAULT 0,
    video_revision_count INTEGER DEFAULT 0,
    error TEXT,
    run_data TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS review_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT NOT NULL,
    stage TEXT NOT NULL,
    attempt INTEGER NOT NULL,
    score REAL NOT NULL,
    threshold REAL NOT NULL,
    decision TEXT NOT NULL,
    feedback TEXT NOT NULL,
    specific_fixes TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (run_id) REFERENCES pipeline_runs (run_id)
);

CREATE TABLE IF NOT EXISTS artifacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT NOT NULL,
    artifact_type TEXT NOT NULL,
    artifact_key TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (run_id) REFERENCES pipeline_runs (run_id)
);

CREATE TABLE IF NOT EXISTS feedback_routing (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT NOT NULL,
    video_id TEXT,
    source_comment_id TEXT,
    author TEXT,
    comment_text TEXT,
    reply_text TEXT,
    category TEXT NOT NULL,
    routed_to TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (run_id) REFERENCES pipeline_runs (run_id)
);

CREATE TABLE IF NOT EXISTS channel_audits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    period_start TEXT NOT NULL,
    period_end TEXT NOT NULL,
    total_views INTEGER,
    total_subscribers_gained INTEGER,
    avg_retention_rate REAL,
    top_performing_videos TEXT,
    content_gaps TEXT,
    recommendations TEXT,
    generated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_runs_status ON pipeline_runs (status);
CREATE INDEX IF NOT EXISTS idx_runs_video ON pipeline_runs (video_id);
CREATE INDEX IF NOT EXISTS idx_reviews_run ON review_history (run_id);
CREATE INDEX IF NOT EXISTS idx_artifacts_run ON artifacts (run_id);
CREATE INDEX IF NOT EXISTS idx_feedback_run ON feedback_routing (run_id);
"""


class PipelineDB:
    """SQLite persistence for pipeline state and artifacts."""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
        self._init_db()
    
    def _init_db(self):
        with sqlite3.connect(self.db_path) as conn:
            conn.executescript(SCHEMA)
            conn.commit()
    
    # ===== Pipeline Run CRUD =====
    
    def create_run(self, run: PipelineRun) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO pipeline_runs (run_id, video_id, started_at, current_stage, status, run_data)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                run.run_id,
                run.video_id,
                run.started_at.isoformat(),
                run.current_stage.value,
                run.status,
                json.dumps(run.to_dict())
            ))
            conn.commit()
    
    def update_run(self, run: PipelineRun) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                UPDATE pipeline_runs
                SET current_stage = ?, status = ?, script_revision_count = ?,
                    thumbnail_revision_count = ?, video_revision_count = ?,
                    completed_at = ?, error = ?, run_data = ?
                WHERE run_id = ?
            """, (
                run.current_stage.value,
                run.status,
                run.script_revision_count,
                run.thumbnail_revision_count,
                run.video_revision_count,
                run.completed_at.isoformat() if run.completed_at else None,
                run.error,
                json.dumps(run.to_dict()),
                run.run_id
            ))
            conn.commit()
    
    def get_run(self, run_id: str) -> Optional[PipelineRun]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            row = conn.execute("SELECT * FROM pipeline_runs WHERE run_id = ?", (run_id,)).fetchone()
            if not row:
                return None
            data = json.loads(row["run_data"])
            run = PipelineRun.from_dict(data)
            if row["error"]:
                run.error = row["error"]
            return run
    
    def get_latest_run(self, video_id: Optional[str] = None) -> Optional[PipelineRun]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            if video_id:
                row = conn.execute(
                    "SELECT * FROM pipeline_runs WHERE video_id = ? ORDER BY started_at DESC LIMIT 1",
                    (video_id,)
                ).fetchone()
            else:
                row = conn.execute(
                    "SELECT * FROM pipeline_runs ORDER BY started_at DESC LIMIT 1"
                ).fetchone()
            if not row:
                return None
            data = json.loads(row["run_data"])
            run = PipelineRun(
                run_id=data["run_id"],
                video_id=data["video_id"],
                started_at=datetime.fromisoformat(data["started_at"]),
                current_stage=PipelineStage(data["current_stage"]),
                status=data["status"],
                script_revision_count=data.get("script_revision_count", 0),
                thumbnail_revision_count=data.get("thumbnail_revision_count", 0),
                video_revision_count=data.get("video_revision_count", 0),
            )
            if data.get("completed_at"):
                run.completed_at = datetime.fromisoformat(data["completed_at"])
            return run
    
    def get_runs_by_status(self, status: str) -> List[PipelineRun]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            rows = conn.execute(
                "SELECT * FROM pipeline_runs WHERE status = ? ORDER BY started_at DESC",
                (status,)
            ).fetchall()
            return [self._row_to_run(row) for row in rows]
    
    def _row_to_run(self, row: sqlite3.Row) -> PipelineRun:
        data = json.loads(row["run_data"])
        run = PipelineRun(
            run_id=data["run_id"],
            video_id=data["video_id"],
            started_at=datetime.fromisoformat(data["started_at"]),
            current_stage=PipelineStage(data["current_stage"]),
            status=data["status"],
            script_revision_count=data.get("script_revision_count", 0),
            thumbnail_revision_count=data.get("thumbnail_revision_count", 0),
            video_revision_count=data.get("video_revision_count", 0),
        )
        if data.get("completed_at"):
            run.completed_at = datetime.fromisoformat(data["completed_at"])
        if row["error"]:
            run.error = row["error"]
        return run
    
    # ===== Review History =====
    
    def log_review(self, run_id: str, stage: PipelineStage, attempt: int, result: ReviewResult) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO review_history (run_id, stage, attempt, score, threshold, decision, feedback, specific_fixes, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                run_id,
                stage.value,
                attempt,
                result.score,
                result.threshold,
                result.decision.value,
                result.feedback,
                json.dumps(result.specific_fixes),
                datetime.now().isoformat()
            ))
            conn.commit()
    
    def get_review_history(self, run_id: str, stage: Optional[PipelineStage] = None) -> List[Dict[str, Any]]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            if stage:
                rows = conn.execute(
                    "SELECT * FROM review_history WHERE run_id = ? AND stage = ? ORDER BY attempt",
                    (run_id, stage.value)
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT * FROM review_history WHERE run_id = ? ORDER BY created_at",
                    (run_id,)
                ).fetchall()
            return [dict(row) for row in rows]
    
    # ===== Artifacts =====
    
    def save_artifact(self, run_id: str, artifact_type: str, artifact_key: str, content: Dict[str, Any]) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO artifacts (run_id, artifact_type, artifact_key, content, created_at)
                VALUES (?, ?, ?, ?, ?)
            """, (
                run_id,
                artifact_type,
                artifact_key,
                json.dumps(content),
                datetime.now().isoformat()
            ))
            conn.commit()
    
    def get_artifact(self, run_id: str, artifact_type: str, artifact_key: str) -> Optional[Dict[str, Any]]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            row = conn.execute(
                "SELECT content FROM artifacts WHERE run_id = ? AND artifact_type = ? AND artifact_key = ? ORDER BY created_at DESC LIMIT 1",
                (run_id, artifact_type, artifact_key)
            ).fetchone()
            if row:
                return json.loads(row["content"])
            return None
    
    def get_latest_artifact(self, run_id: str, artifact_type: str) -> Optional[Dict[str, Any]]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            row = conn.execute(
                "SELECT content FROM artifacts WHERE run_id = ? AND artifact_type = ? ORDER BY created_at DESC LIMIT 1",
                (run_id, artifact_type)
            ).fetchone()
            if row:
                return json.loads(row["content"])
            return None
    
    # ===== Feedback Routing =====
    
    def log_feedback(self, run_id: str, video_id: str, item: FeedbackItem) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO feedback_routing (run_id, video_id, source_comment_id, author, comment_text, reply_text, category, routed_to, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                run_id,
                video_id,
                item.source_comment_id,
                item.author,
                item.comment_text,
                item.reply_text,
                item.category,
                item.routed_to,
                datetime.now().isoformat()
            ))
            conn.commit()
    
    def get_feedback_for_researcher(self, run_id: str) -> List[FeedbackItem]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            rows = conn.execute(
                "SELECT * FROM feedback_routing WHERE run_id = ? AND routed_to = 'researcher' ORDER BY created_at",
                (run_id,)
            ).fetchall()
            return [FeedbackItem(
                source_comment_id=r["source_comment_id"],
                author=r["author"],
                comment_text=r["comment_text"],
                reply_text=r["reply_text"],
                category=r["category"],
                routed_to=r["routed_to"]
            ) for r in rows]
    
    # ===== Channel Audits =====
    
    def save_audit(self, audit: ChannelAuditReport) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO channel_audits (period_start, period_end, total_views, total_subscribers_gained, avg_retention_rate, top_performing_videos, content_gaps, recommendations, generated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                audit.period_start.isoformat(),
                audit.period_end.isoformat(),
                audit.total_views,
                audit.total_subscribers_gained,
                audit.avg_retention_rate,
                json.dumps(audit.top_performing_videos),
                json.dumps(audit.content_gaps),
                json.dumps(audit.recommendations),
                audit.generated_at.isoformat()
            ))
            conn.commit()
    
    def get_latest_audit(self) -> Optional[ChannelAuditReport]:
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            row = conn.execute(
                "SELECT * FROM channel_audits ORDER BY generated_at DESC LIMIT 1"
            ).fetchone()
            if not row:
                return None
            return ChannelAuditReport(
                period_start=datetime.fromisoformat(row["period_start"]),
                period_end=datetime.fromisoformat(row["period_end"]),
                total_views=row["total_views"],
                total_subscribers_gained=row["total_subscribers_gained"],
                avg_retention_rate=row["avg_retention_rate"],
                top_performing_videos=json.loads(row["top_performing_videos"]),
                content_gaps=json.loads(row["content_gaps"]),
                recommendations=json.loads(row["recommendations"]),
                generated_at=datetime.fromisoformat(row["generated_at"])
            )


# Global instance
db = PipelineDB()