---
tags: [google-flow, ai-video, production, guide]
created: 2026-09-20
---

# ⚡ Google Flow Master Guide (AI Creative Studio)

> [!INFO] Platform URL
> Accessible at **https://flow.google.com/** via Chrome CDP (`Profile 8`).

---

## ⚙️ Mandatory Project Settings

| Parameter | Production Value | Why |
| :--- | :--- | :--- |
| **Aspect Ratio** | `9:16` | Vertical format mandatory for YouTube Shorts |
| **Batch Count** | `x1` | Always generate single clip per prompt to prevent drift |
| **Model (Testing)** | `Omni 1.1 Flash` (360p) | 7 credits/10s — rapid concept validation |
| **Model (Production)** | `Veo 3.1 - Fast` (720p) | 15 credits/10s — high-definition master export |
| **Confirm Before Gen** | `Never` | Required for autonomous agent mode |

---

## ⏱️ 30-Second Multi-Clip Sequential Protocol

### Phase 1: Clip Generation (All in Same Session)
1. **Clip 1 (0:00 – 0:10)**: Generate first. Verify audio length and face stability.
2. **Clip 2 (0:10 – 0:20)**: In SAME session, enter Clip 2 prompt after Clip 1 completes. Reference Clip 1 for visual continuity.
3. **Clip 3 (0:20 – 0:30)**: In SAME session, enter Clip 3 prompt after Clip 2 completes. Ensure clean 1-second holding posture at the end.

**Session Rule**: ONE session per Short (all 3 clips). Do NOT start new session between clips. Only start new session for NEW project/short. Agent Instructions persist within project.

### Phase 2: Timeline Assembly (After All 3 Clips Generated)
**CRITICAL**: All 3 clips must be in the same session before assembly. NO ffmpeg needed.

1. **Open First Clip in Editor**: Click first clip's "Open video in editor" (thumbnail-button[0]) → timeline editor loads with Clip 1 at 0-10s.
2. **Add Clip 2**: Click "+" button on RIGHT side of Clip 1's timeline segment (class: `.add-clip-button-container button.add-clip-button`) → Select Clip 2 in "Select media" dialog → Click "Add media" → Timeline shows 00:20:00.
3. **Click Clip 2 Timeline Segment**: Click the 10-20s position (Clip 2) on timeline to position playhead at end of Clip 2.
4. **Add Clip 3**: Click "+" button on RIGHT side of Clip 2's timeline segment → Select Clip 3 in "Select media" dialog → Click "Add media" → Timeline shows 00:30:00.
6. **Verify & Export**: Total duration 00:30:00 → Click "Done editing scene" → Download/Export.

**KEY RULE**: Must click Clip 2's timeline segment (10-20s position) before clicking "+" for Clip 3, otherwise Clip 3 inserts after Clip 1.

See also: [[👤 Master Avatar & Studio Anchor]] • [[⏱️ Retention & Hook Playbook]] • [[🎞️ Google Flow Timeline Assembly]]
