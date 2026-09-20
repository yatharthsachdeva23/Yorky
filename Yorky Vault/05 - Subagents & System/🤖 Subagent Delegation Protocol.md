---
tags: [subagents, delegation, safety, rules]
created: 2026-09-20
---

# 🤖 Subagent Delegation Protocol

> [!CAUTION] Strict Subagent Guardrails
> Unconstrained subagents can cause Chrome crashes and memory leaks. These rules are non-negotiable.

---

## 📋 The 1-Turn Command Rule

When delegating batch tasks to subagents via `delegate_task`:
* **Never Give Vague Goals**: Do not say *"Process short 45"*. Always pass the exact 3 commands:
  ```bash
  python scripts/extract_short_pure_cdp.py {video_id} {short_id}
  python scripts/build_payload.py {video_id} {short_id}
  python scripts/ingest_short_forensic.py {short_id}
  ```

---

## 🚫 Absolute Prohibitions

1. **NO Probing `/json/new`**: Never allow subagents to test CDP with `curl /json/new`. It creates orphan `about:blank` tabs.
2. **NO Exploratory File Browsing**: Subagents must not run `ls -la`, `find`, or read unrelated files.
3. **NO Polling Loops or Sleep Commands**: Trust the system async completion signal:  
   `[ASYNC DELEGATION BATCH COMPLETE — deleg_{ID}]`
4. **Max Batch Size**: Maximum **5 Shorts** per batch. Always obtain user approval before starting the next batch.

See also: [[🔬 Pure CDP Pipeline Architecture]] • [[📜 Historical Session Learnings]]
