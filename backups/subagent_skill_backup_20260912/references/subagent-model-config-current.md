# Subagent Model Configuration (Active as of Sept 7, 2026)

## Current Active Configuration (from config.yaml)

```yaml
delegation:
  model: nvidia/nemotron-3.5-lightning-30b-a3b
  provider: custom
  base_url: https://integrate.api.nvidia.com/v1
  api_key: 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
  api_mode: chat_completions
  max_iterations: 50
  max_concurrent_children: 1
  max_spawn_depth: 2
  orchestrator_enabled: true
  subagent_auto_approve: false
  max_async_children: 1
```

**Model**: `nvidia/nemotron-3.5-lightning-30b-a3b`
**Provider**: Custom (NVIDIA API)
**Base URL**: `https://integrate.api.nvidia.com/v1`
**Auth**: API key (nvapi-...)
**Mode**: chat_completions

## Previous Configurations (Historical)

| Date | Model | Provider | Status |
|------|-------|----------|--------|
| Sept 7, 2026 | nvidia/nemotron-3.5-lightning-30b-a3b | NVIDIA custom | **ACTIVE** |
| Sept 6, 2026 | gemma4:31b | Ollama Cloud (https://ollama.com/v1) | Superseded |
| Sept 5, 2026 | minimax/minimax-m3:free | OpenRouter | Rate limited (429 RPD) |

## Key Notes

1. **Config.yaml is authoritative** — the skill documentation mentioning `gemma4:31b` via Ollama Cloud is outdated. Always check `config.yaml` for the current active model.

2. **Subagent inherits parent config** — the delegation section in config.yaml controls all child agents unless explicitly overridden in the delegation call.

3. **Rate limits**: NVIDIA provider has not shown daily caps in testing. OpenRouter minimax hit 429 RPD. Ollama Cloud may have monthly quotas.

4. **Verification**: Add a test task at delegation start: "Report model/provider being used" to confirm subagent is using the expected model.

## Subagent Delegation Parameters

- `max_iterations: 50` → limits batch to ~3 shorts (16-17 iterations/short)
- `max_concurrent_children: 1` → sequential only
- `max_spawn_depth: 2` → orchestrator can spawn one level deeper
- `orchestrator_enabled: true` → orchestrator role available

## Migration Path

If NVIDIA provider has issues, fallback order:
1. Local Ollama: `llama3.2:1b` @ `http://localhost:11434` (no auth, no rate limit)
2. OpenRouter paid model (higher RPD)
3. Parent agent execution (nemotron-3-ultra via NVIDIA)