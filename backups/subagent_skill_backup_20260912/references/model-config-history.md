# Subagent Model Configuration History

## Current Working Configuration (2026-09-06 — User Directed)

**Provider:** ollama.com (custom)
**Model:** `gemma4:31b`
**Context:** 128K+ tokens
**API Key:** Stored in config.yaml (ollama-cloud key)

```yaml
delegation:
  model: gemma4:31b
  provider: custom
  base_url: https://ollama.com/v1
  api_key: <ollama-cloud-key>
  max_spawn_depth: 2
  orchestrator_enabled: true
  max_concurrent_children: 3
```

## Rate Limit Issue (2026-09-06)

**Problem**: `minimax/minimax-m3:free` via OpenRouter has a **daily rate limit (RPD)** that exhausts mid-batch. Error: `HTTP 429: Rate limit exceeded: limit_rpd/minimax/minimax-m3...`

**Impact**:
- Subagent fails mid-batch
- No payloads created, no DB ingestion
- Batch stops at the short where limit was hit

**Root Cause**: OpenRouter free tier enforces daily request limits per model. Credits don't affect this cap.

## Fallback Strategies (in order of preference)

### 1. Parent Agent Execution (Recommended for batches > 3)
Run the pipeline directly in the parent session which uses `nvidia/nemotron-3-ultra` via NVIDIA provider — no daily cap observed.

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

## Session Evidence (2026-09-06)
- Batch 61-65 dispatched to subagent
- Failed at Short #61 after extracting 4 analytics tabs + starting comments
- Error: `HTTP 429: Rate limit exceeded: limit_rpd/minimax/minimax-m3-20260531/3e7a48d4-53e2-4fff-92ce-9fd7839edc13`
- 0 payloads created, 0 DB rows inserted
- Parent agent (nemotron-3-ultra via NVIDIA) continued manually
- **User directed switch to ollama gemma4:31b — config updated, batch re-dispatched**

## Failed Configurations (Reference)

| Provider | Model | Error | Root Cause |
|----------|-------|-------|------------|
| Groq | `gpt-oss-120b` | 413 payload too large | Skill exceeds 8K context |
| Groq | `gpt-4o-mini` | 404 not found | Not on Groq |
| Groq | `llama-3.3-70b-versatile` | 404 not found | Not on Groq |
| Groq | `llama-3.1-70b-versatile` | 400 decommissioned | Model retired |
| Groq | `llama-3.1-8b-instant` | 404 not found | Not on Groq |
| Groq | `llama3-70b-8192` | 400 decommissioned | Model retired |
| Cerebras | `llama3.3-70b` | 401 wrong API key | Key mismatch |
| EastRouter | `minimax/minimax-m3:free` | 404 not supported | Only z-ai/glm-* and moonshotai/kimi-* |
| OpenRouter | `minimax/minimax-m3:free` | 429 rate limit | Daily RPD exhausted mid-batch |
| ollama.com (custom) | `gemma4:31b` | **User directed — pending test** | Config applied, batch re-dispatched |

## Key Rules

1. **Skill size = context requirement** - Forensic skill (~25KB) needs 128K+ context model
2. **Provider-model must match** - Check provider's model list before configuring
3. **Delegation is global** - All subagents share same pinned model (config.yaml)
4. **User preference = Minimax via OpenRouter** - Do not switch without user direction
5. **Config change requires restart** - Hermes must reload config.yaml

## Verification

```bash
grep -A6 "delegation:" ~/AppData/Local/hermes/profiles/youtube/config.yaml
```

## Troubleshooting Checklist

- [ ] Model exists on provider (check provider docs/console)
- [ ] Context window >= 128K tokens
- [ ] API key valid for provider
- [ ] base_url correct for provider
- [ ] Hermes restarted after config change
- [ ] Subagent role = "leaf" or "orchestrator"