# Subagent Batch Mode Iteration Limits

## Problem
- Each subagent delegation has `max_iterations: 50` (set in config.yaml under `delegation.max_iterations`)
- A full forensic short analysis takes ~10-15 iterations (browser navigation, 4 tab clicks, comments scroll, metadata extraction, payload build, ingestion, verification)
- Batches > 3-4 shorts will hit the iteration limit mid-batch, causing the subagent to exit with partial results

## Session 2026-09-06 Empirical Data

| Batch | Shorts | Completed | Iterations Used | Result |
|-------|--------|-----------|-----------------|--------|
| 65-70 | 6 | 65 only | ~50 | Exited after 1 short |
| 66-70 | 5 | 66, partial 67 | ~50 | Exited mid-67 |
| 67-70 | 4 | 67, partial 68 | ~50 | Exited mid-68 |
| 68-70 | 3 | **68, 69, 70** | ~45 | ✅ Complete |

**Pattern**: ~16-17 iterations per short → 3 shorts = ~48-51 iterations (at limit)

## Session 2026-09-09 Updated Empirical Data

| Batch | Shorts | Completed | Result |
|-------|--------|-----------|--------|
| 69-71 | 3 | 0 | ❌ Iteration limit hit (50) — subagent exited mid-payload-build |

## Subagent Execution Fixes (Sept 9, 2026 Session Learnings)

The following issues caused subagent failure on Short #69. **Must be explicitly addressed in subagent context:**

| Failure | Root Cause | Fix for Subagent Context |
|---------|------------|--------------------------|
| Used `/c/...` paths in execute_code | Phantom directory bug | **Explicitly forbid `/c/` paths** — use relative `data/` paths only |
| Couldn't read reference payload | `read_file` with `/c/` path failed | Reference payload is at `data/payload_short68.json` (relative) — use `read_file(path="data/payload_short68.json")` |
| Didn't save payload via `write_file` | Tried to use execute_code with file write | **Must use `write_file(path="data/payload_short69.json", content=...)`** — NOT execute_code |
| Didn't run ingestion script | Never called terminal with ingestion command | **Must run via terminal**: `cd "C:/Desktop/Antigravity Projects/YouTube Manager" && python ingest_short_forensic.py data/payload_short69.json` |
| Didn't verify with UNION ALL | Assumed ingestion worked | **Must run verification query** after ingestion — all 20 child tables ≥1 row |
| Had 22 root keys instead of 21 | Extra key in payload structure | **Exactly 21 root keys** — cross-check with reference payload |

### Required Subagent Context Additions
Add to every subagent delegation context:
```
CRITICAL TOOL USAGE:
- read_file: Use relative paths only (e.g., "data/payload_short68.json")
- write_file: Use relative paths only (e.g., "data/payload_short69.json") 
- terminal: Run ingestion from project dir with relative payload path
- execute_code: NEVER use for file I/O — use read_file/write_file instead
- NEVER use `/c/` or `C:\\` paths in any tool
```

## Workaround Strategy

| Batch Size | Iterations | Result |
|------------|------------|--------|
| 1-2 shorts | 15-30 | ✅ Complete |
| 3 shorts | ~45-50 | ✅ Complete (barely) |
| 4+ shorts | 60+ | ❌ Exits mid-batch |

**Recommended**: Dispatch max 3 shorts per subagent delegation. For larger ranges, chain multiple delegations.

## Updated Wait Constants (2026-09-09)

| Operation | Wait Time |
|-----------|-----------|
| Main page nav | **5s** |
| Tab click (Analytics/Comments/Details) | **5s** |
| Retry button check | 2s |
| After Retry click | **5s** |
| Data extraction | 2s |
| Comments scroll step | 0.4s |
| Comments filter removal | 2s |

**3-second waits are insufficient** — YouTube Studio takes 4-6s to fully render analytics data after any tab click or Retry click.

```python
# Instead of: delegate_task(goal="65-70", range_end=70)
# Do:
delegate_task(goal="65-67", context="short_id=65, range_end=67")
# Wait for completion, verify DB, then:
delegate_task(goal="68-70", context="short_id=68, range_end=70")
```

## Monitoring & Recovery

1. **Live transcript**: `C:\Users\DELL\AppData\Local\hermes\profiles\youtube\cache\delegation\live\deleg_<id>\task-0.log`
2. **DB verification after each batch**:
   ```sql
   SELECT short_id, video_id FROM shorts WHERE short_id >= 65 ORDER BY short_id;
   ```
3. **Re-dispatch from last completed + 1** if batch exits early

## Bot Detection Complication

Each short requires ~5 navigation clicks (video page → Analytics → 4 tabs → Comments → Edit), each triggering potential "Retry" button clicks. This adds 2-3 iterations per tab = ~15 extra iterations per short for bot handling alone.

**Timing constants** (must wait):
- Navigation: 3s
- Tab click: 3s  
- Retry check: 2s (repeat up to 5x)
- Comments scroll: 2s per step × 40 steps = 80s
- Edit page: 3s

**Total per short**: ~3-5 minutes wall time, ~15-20 iterations

## Rate Limit Interaction

When subagent model (minimax/minimax-m3:free via OpenRouter) hits daily RPD limit:
- Subagent fails with HTTP 429
- No payloads created, no DB ingestion
- Batch stops at the failed short
- **Fallback**: Switch to parent agent execution (uses nvidia/nemotron-3-ultra, no daily cap observed)

## Updated Batch Protocol

```python
def dispatch_batch(start_short_id, end_short_id, batch_size=3):
    for batch_start in range(start_short_id, end_short_id + 1, batch_size):
        batch_end = min(batch_start + batch_size - 1, end_short_id)
        delegate_task(
            goal=f"Analyze Shorts {batch_start}-{batch_end}",
            context=f"short_id={batch_start}, range_end={batch_end}",
            role="leaf"
        )
        # Wait for completion (monitor transcript or poll DB)
        verify_batch_completion(batch_start, batch_end)
```

## Model Configuration Notes
- **Working**: `gemma4:31b` via ollama.com/v1 (custom provider)
- **Rate limited**: `minimax/minimax-m3:free` via OpenRouter (daily cap)
- **Unsupported**: `minimax/minimax-m3:free` via eastrouter (only supports z-ai/glm-* and moonshotai/kimi-*)
- Config in config.yaml under `delegation` section

## Bot Detection Workaround (YouTube Studio)
- Navigate to main video page first (`/video/{id}`), then click Analytics/Comments/Details buttons — direct URLs trigger bot detection
- **Always check for and click "Retry" button** after every navigation AND tab click (Retry reappears on every tab)
- Wait 5s before retry, 5s after Retry click
- See `references/studio-bot-detection-workaround.md` for full protocol