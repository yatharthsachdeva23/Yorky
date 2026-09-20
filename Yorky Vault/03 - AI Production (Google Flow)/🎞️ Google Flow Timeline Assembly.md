---
tags: [google-flow, timeline, assembly, production, video]
created: 2026-09-20
updated: 2026-09-20
---

# 🎞️ Google Flow Timeline Assembly Protocol

> [!SUCCESS] In-Platform 30s Stitching (No FFmpeg Needed)
> Discovered & verified on Sept 20, 2026 for **"100% Syllabus Trap - JEE 2027 Short"** (Project ID: `2171ab5a-3950-4b25-a9de-1c0fc26be0a2`). Google Flow's built-in timeline editor stitches 3×10s clips into a single continuous 30-second Short directly on the web.

---

## 🛑 Prerequisite: The Same-Session Rule

* **ALL 3 CLIPS MUST BE GENERATED IN THE SAME SESSION**.
* Do **NOT** start a new session between clips.
* Agent Instructions (Avatar Specs + Studio Lighting) persist within the project.
* All generated clips automatically appear in the project's **Media options gallery**.

---

## 📋 Step-by-Step Timeline Stitching Sequence

```text
[Clip 1: 0-10s]  ──(+)──>  [Clip 2: 10-20s]  ──(+)──>  [Clip 3: 20-30s]  ──>  [Export 30s]
      ▲                          ▲
(Open in Editor)        (Click Clip 2 Segment First!)
```

### 1. Open First Clip in Timeline Editor
* In the project gallery, find Clip 1.
* Click **"Open video in editor"** (thumbnail button).
* The timeline editor opens with Clip 1 placed at `00:00:00` to `00:10:00`.

### 2. Append Clip 2 (10s – 20s)
* Click the **`+`** icon on the **RIGHT edge of Clip 1's timeline segment** (`.add-clip-button-container button.add-clip-button`).
* The **"Select media"** modal appears (Videos tab).
* Select **Clip 2** (Close-up: *"Hard truth..."*).
* Click **"Add media"**.
* Clip 2 auto-appends at the 10-second mark. Total timeline duration becomes **`00:20:00`**.

### 3. Critical Step: Select Clip 2 Timeline Segment
> [!CAUTION] The Insertion Bug
> If you click `+` without selecting Clip 2's timeline segment first, Clip 3 will insert at the 10s mark between Clip 1 and Clip 2!
* Click directly on **Clip 2's timeline segment** (between 10s and 20s).
* This advances the timeline cursor/playhead to the 20s mark at the end of Clip 2.

### 4. Append Clip 3 (20s – 30s)
* Click the **`+`** icon on the **RIGHT edge of Clip 2's timeline segment**.
* The **"Select media"** modal appears.
* Select **Clip 3** (Medium: *"Toh naye low weightage..."*).
* Click **"Add media"**.
* Clip 3 appends at the 20-second mark. Total timeline duration becomes **`00:30:00`**.

### 5. Final Verification & Export
* Total timeline reads **`00:30:00`**.
* Click play to preview seamless transitions across all 3 clips.
* Click **"Done editing scene"** in the top right to download/export the final 30s `.mp4`.

---

See also: [[⚡ Google Flow Master Guide]] • [[🎬 Short - 100% Syllabus Trap (30s)]] • [[👤 Master Avatar & Studio Anchor]]
