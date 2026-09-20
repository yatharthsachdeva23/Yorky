---
tags: [history, learnings, evolution, sessions]
created: 2026-09-20
---

# 📜 Historical Session Learnings Timeline (Sept 7 – Sept 20, 2026)

> [!INFO] Chronological Record
> Summary of operational breakthroughs, forensic discoveries, and bug fixes across all batch sessions.

---

* **Sept 7**: Discovered only 3/80 shorts complete in DB. Fixed foreign key on `analysis_log.session_id`. Mapped traffic source category codes.
* **Sept 10**: Fixed Windows relative path handling (`data/payload_short{id}.json`). Discovered comments filter chip X-button click rule. Enforced 3-point retention curve regex.
* **Sept 11**: Implemented 5-short batch limits. Transitioned comment extraction to headless Innertube API. Validated legitimate zero-comment handling.
* **Sept 12**: Developed Pure CDP WebSocket engine (`extract_short_pure_cdp.py`). Added automatic orphan blank tab sweeping.
* **Sept 15**: Solved `published_at` bug. Eliminated `COALESCE` shortcuts. Enforced single canonical location in `scripts/`.
* **Sept 16–19**: Reached 100% completion on all 111 Shorts. Corrected Short #62 date. Standardized Google Flow 3-clip sequential protocol.
* **Sept 20**: Completed Yorky skills overhaul (consolidated into 6 modular skills) and launched the Yorky Obsidian Vault.
* **Sept 20**: Implemented **Yorky Auto-Learning Protocol** (`yorky-auto-learning` skill) — mandatory post-task learning capture, memory/skill classification, descriptive naming conventions, vault sync. Eliminates session-specific skill names (e.g., "short-35-fix" → "short-forensic-troubleshooting").
* **Sept 20**: **Google Flow Timeline Assembly Mastered** — 3x10s clips assembled into 30s Short via Flow timeline editor (NO ffmpeg). Project: "100% Syllabus Trap - JEE 2027 Short" (ID: 2171ab5a-3950-4b25-a9de-1c0fc26be0a2). All 3 clips generated in SAME session, assembled via timeline editor. Key learnings: Timeline classes (.scene-timeline, .timeline-controls, .timeline-area, .cdk-drop-list.timeline-contents), Clip elements (.clip.is-first, .clip, .clip.is-last), Add clip button (.add-clip-button-container button.add-clip-button), Timeline timestamps (text nodes '00'-'21'). Critical rules: 1) SAME SESSION for all 3 clips, 2) CLICK TIMELINE SEGMENT BEFORE ADDING (click Clip 2's 10-20s segment before adding Clip 3), 3) USE CDP FOR TIMELINE INTERACTIONS (+ on timeline, clip selection, Add media dialog), 4) Click Clip 2's 10-20s segment before adding Clip 3, 5) Asset selection: Videos tab → select clip by name → Add media. NO ffmpeg needed - Flow timeline editor handles stitching.

See also: [[⚙️ Active Skills Architecture]] • [[🤖 Subagent Delegation Protocol]]
