# Subagent Model Rate Limit Workaround

## Problem
The default subagent model `minimax/minimax-m3:free` via OpenRouter has a **daily rate limit (RPD)** that exhausts mid-batch. Error: `HTTP 429: Rate limit exceeded: limit_rpd/minimax/minimax-m3...`

## Impact
- Subagent fails mid-batch
- No payloads created, no DB ingestion
- Batch stops at the short where limit was hit

## Root Cause
OpenRouter free tier enforces daily request limits per model. Credits don't affect this cap.

## Fallback Strategies (in order of preference)

### 1. Parent Agent Execution (Recommended for batches > 3)
Run the pipeline directly in the parent session which uses `nvidia/nemotron-3-ultra` via NVIDIA provider — no daily cap observed.
```bash
# In parent session, use browser_cdp tools directly
# Same workflow, no delegation
```

### 2. Model Override in Config
Pin a different model in `config.yaml`:
```yaml
delegation:
  model: "openrouter/auto"  # or a paid model with higher limits
  provider: "openrouter"
```

### 3. Batch Splitting
Process smaller batches (2-3 shorts) with cooldown periods between batches.

### 4. Sequential with Verification
After each short, verify DB ingestion before proceeding. If rate limit hit, switch to parent agent for remaining shorts.

## Verification Before Dispatch
Check subagent model quota before dispatching large batches:
```bash
# No direct API to check quota - rely on historical success
# If previous batch of 5 succeeded, quota likely available
# If failed, quota exhausted - switch to parent agent
```

## Session Evidence (2026-09-06)
- Batch 61-65 dispatched to subagent
- Failed at Short #61 after extracting 4 analytics tabs + starting comments
- Error: `HTTP 429: Rate limit exceeded: limit_rpd/minimax/minimax-m3-20260531/3e7a48d4-53e2-4fff-92ce-9fd7839edc13`
- 0 payloads created, 0 DB rows inserted
- Parent agent (nemotron-3-ultra via NVIDIA) continued manually