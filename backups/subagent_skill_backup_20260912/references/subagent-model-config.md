# Subagent Model Configuration Reference

## Working Configuration (2026-09-06)

**Provider:** Ollama Cloud (custom)
**Model:** `gemma4:31b`
**Base URL:** `https://ollama.com/v1`
**Context:** 128K tokens (sufficient for skill + extraction)

**Config in config.yaml:**
```yaml
delegation:
  model: gemma4:31b
  provider: custom
  base_url: https://ollama.com/v1
  api_key: <ollama-cloud-key>
  max_spawn_depth: 2
  orchestrator_enabled: true
```

## Previously Working (Exhausted Rate Limit)

**Provider:** OpenRouter
**Model:** `minimax/minimax-m3:free`
**Issue:** Daily rate limit (RPD) hit mid-batch → subagent fails with HTTP 429
**Fallback:** Switched to gemma4:31b via Ollama Cloud (no daily cap observed)

## Failed Configurations (for reference)

| Provider | Model | Error | Reason |
|----------|-------|-------|--------|
| Groq | `gpt-oss-120b` | 413 payload too large | Context too small for skill |
| Groq | `gpt-4o-mini` | 404 not found | Not available on Groq |
| Groq | `llama-3.3-70b-versatile` | 404 not found | Not available on Groq |
| Groq | `llama-3.1-70b-versatile` | 400 decommissioned | Model retired |
| Groq | `llama-3.1-8b-instant` | 404 not found | Not available on Groq |
| Groq | `llama3-70b-8192` | 400 decommissioned | Model retired |
| Cerebras | `llama3.3-70b` | 401 wrong API key | Key mismatch |

## Key Learnings

1. **Skill size matters** - The forensic skill (~25KB) exceeds context of smaller models (8K). Use 128K+ models.
2. **Provider-model matching** - Must use models actually available on the provider (check console.groq.com/docs/models)
3. **User preference** - Minimax via OpenRouter was designated, but daily rate limit exhausted; switched to gemma4:31b via Ollama Cloud
4. **Delegation config is global** - All subagents use the same pinned model; cannot vary per-task
5. **Restart required** - Config changes need Hermes restart to take effect
6. **Rate limit monitoring** - Check daily quota before dispatching large batches; if exhausted, fall back to parent agent execution

## Verification Command

```bash
grep -A5 "delegation:" ~/AppData/Local/hermes/profiles/youtube/config.yaml
```