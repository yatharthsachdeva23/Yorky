# 🚀 Yorky: Autonomous YouTube Channel Manager

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Chrome CDP](https://img.shields.io/badge/Chrome_DevTools_Protocol-v1.3-green.svg)](https://chromedevtools.github.io/devtools-protocol/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Yorky** is an enterprise-grade autonomous multi-agent YouTube channel management system. It orchestrates the full lifecycle of content creation—from real-time trend research and scriptwriting to AI video synthesis, automated Studio publishing, community engagement, and forensic retention analytics—all integrated with a dual-tier Human-in-the-Loop (HITL) governance model.

---

## 🏗️ System Architecture

Yorky coordinates an **11-subagent pipeline** with automated quality thresholds and parallel execution gates:

```
                          [ 🌐 Live NTA Exam Dates & News ]
                                          │
                                          ▼
STAGE 1: STRATEGY              [ 1. RESEARCHER ]
                                          │
                                          ▼
                                [ 2. PLANNER ]
                                          │
                                          ▼
STAGE 2: SCRIPT GATE        ┌─► [ 3. SCRIPT WRITER ]
                            │             │
                            │             ▼
                            └── [ 4. SCRIPT REVIEWER ] ── (Score ≥ 0.75 & 0 fixes)
                                                             │
                       ┌─────────────────────────────────────┴─────────────────────────────────────┐
                       ▼                                                                           ▼
STAGE 3: MEDIA ASSETS  [ 5. VIDEO MAKER ] (Google Flow / Omni Flash)                               │
                       │ (Generates 4x15s video clips + 9:16 thumbnail)                           │
                       │                                                                           │
                       ├───────────────────────────────────┐                                       │
                       ▼ (Parallel QA)                     ▼ (Parallel QA)                         │
               [ 6. VIDEO REVIEWER ]               [ 7. IMAGE REVIEWER ]                           │
               (Pacing & Voiceover ≥ 0.75)         (9:16 Safe-Zone & 32px Bubble ≥ 0.85)           │
                       │                                   │                                       │
                       └───────────────────┬───────────────┘                                       │
                                           ▼                                                       ▼
STAGE 4: DEPLOYMENT                 [ 8. YT UPLOADER ] ◄───────────────────────────────────────────┘
                                           │
                          ┌────────────────┴────────────────┐
                          ▼                                 ▼
              [ 9. YT REPRESENTATIVE ]            [ 10. YT ANALYSER ]
              (Comments & FAQ Routing)             (Retention Curves & Forensic Audits)
                                                            │
                                                            └─► Upstream Feedback to Researcher & Planner
──────────────────────────────────────────────────────────────────────────────────────────────────────────
[ 11. STATUS MANAGER ] (Cross-cutting: Real-time event synchronization to Google Sheets dashboard)
```

---

## 🌟 Key Features

- **End-to-End Content Pipeline**: Automates topic discovery, 4-clip Hinglish script generation (130–150 WPM), AI video rendering, thumbnail synthesis, and upload scheduling.
- **Dual-Tier Governance (HITL)**:
  - **Automated QA Tier**: Specialized reviewer agents evaluate scripts (≥0.75), videos (≥0.75), and thumbnails (≥0.85) autonomously.
  - **Executive HITL Tier**: Interactive conversational approval interface reserved strictly for high-stakes channel decisions, strategic pivots, and anomaly escalations—**slashing operational overhead by 85%**.
- **Pure Chrome DevTools Protocol (CDP) Engine**:
  - Headless/isolated target execution on port 9222 with zero UI focus-stealing (`background=True`, minimized state).
  - Automated blank-tab garbage collection and Google Studio bot-retry mitigation.
  - **70x Latency Reduction**: Slashed per-video audit time from **35 minutes down to 24 seconds**.
- **Forensic Analytics Warehouse**:
  - 28-table normalized PostgreSQL database tracking 6 Studio dimensions (second-by-second retention curves, traffic sources, demographics, and comments) across **111 channel Shorts**.
  - Closed-loop intelligence routing viewer retention drop-offs back into upstream script hooks.

---

## 📂 Project Structure

```
YouTube Manager/
├── domains/
│   └── youtube_hermes/
│       ├── pipeline/
│       │   ├── agents/            # Specialized Subagents (1-11)
│       │   │   ├── researcher.py
│       │   │   ├── planner.py
│       │   │   ├── script_writer.py
│       │   │   ├── script_reviewer.py
│       │   │   ├── video_maker.py
│       │   │   ├── video_reviewer.py
│       │   │   ├── image_reviewer.py
│       │   │   ├── yt_uploader.py
│       │   │   ├── yt_representative.py
│       │   │   └── yt_analyser.py
│       │   ├── orchestrator/      # State machine & feedback revision loops
│       │   │   └── pipeline_orchestrator.py
│       │   └── shared/            # Data models, DB storage, LLM factory
│       │       ├── models.py
│       │       ├── storage.py
│       │       └── llm.py
├── scripts/                       # Canonical forensic pipeline tools
│   ├── extract_short_pure_cdp.py  # Isolated Chrome CDP extractor
│   ├── build_payload.py           # 21-root-key payload synthesis
│   ├── ingest_short_forensic.py   # Atomic 28-table PostgreSQL ingestion
│   └── verify_comprehensive.py    # 10-level verification suite
├── .env.example
├── .gitignore
└── README.md
```

---

## ⚡ Quick Start

### 1. Prerequisites
- Python 3.10+
- PostgreSQL 15+
- Google Chrome (with remote debugging enabled)

### 2. Environment Setup
```bash
# Clone the repository
git clone https://github.com/yatharthsachdeva23/Yorky.git
cd Yorky

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
```

### 3. Launch Chrome CDP
```bash
chrome.exe --remote-debugging-port=9222 --user-data-dir="<path-to-profile>"
```

### 4. Run Forensic Pipeline
```bash
# Execute isolated 3-stage extraction for any Short
python scripts/extract_short_pure_cdp.py <video_id> <short_id>
python scripts/build_payload.py <video_id> <short_id>
python scripts/ingest_short_forensic.py <short_id>
```

---

## 📊 Benchmarks & Performance

| Metric | Legacy Pipeline | Yorky CDP Engine | Improvement |
| :--- | :---: | :---: | :---: |
| **Audit Latency per Short** | ~35 min | **24 sec** | **70x speedup** |
| **Browser Interaction** | Foreground Popups | **Isolated Background Tab** | Zero UI disruption |
| **Database Transactions** | Fragmented | **Atomic Single Transaction** | 100% data integrity |
| **Review Automation** | Manual editorial check | **Automated threshold score (≥0.75)** | 85% overhead reduction |

---

## 📜 License
This project is open-source under the [MIT License](LICENSE).