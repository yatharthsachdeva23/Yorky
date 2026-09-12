# Subagent Delegation Model Configuration Issue (Sept 7, 2026)

## Problem
The subagent delegation config in `config.yaml` specifies:
```yaml
delegation:
  model: llama3.2:1b
  provider: custom
  base_url: http://localhost:11434/v1
  api_key: ollama
```

But test subagent (`deleg_15b3be44`) reported:
- **model_name**: "hermes-agent"
- **provider**: "youtube"

This is NOT the configured `llama3.2:1b` via local Ollama. The subagent appears to be using some default/fallback rather than the configured delegation model.

## Impact
- Previous subagents were using `gemma4:31b` via Ollama Cloud (https://ollama.com/v1) which hit HTTP 429 monthly rate limit
- Local Ollama at localhost:11434 may not be running or may not have `llama3.2:1b` model
- Subagent model verification is needed at dispatch time

## Root Cause Hypotheses
1. Local Ollama not running on localhost:11434
2. `llama3.2:1b` model not pulled in local Ollama
3. Delegation config not being read by subagent spawning mechanism
4. Subagent falling back to parent profile defaults when delegation config fails

## Verification Steps for Future Sessions
1. **Before dispatching subagent**: Run test delegation to verify model
   ```bash
   # Test delegation
   delegate_task(goal="Report the model name and provider being used for this subagent.")
   ```
2. **Check local Ollama status**:
   ```bash
   curl http://localhost:11434/api/tags
   # Should show llama3.2:1b in models list
   ```
3. **Start local Ollama if needed**:
   ```bash
   ollama serve
   ollama pull llama3.2:1b
   ```

## Workaround
If local Ollama unavailable, configure delegation to use NVIDIA provider (same as parent):
```yaml
delegation:
  model: nvidia/nemotron-3-ultra-550b-a55b
  provider: nvidia
  base_url: https://integrate.api.nvidia.com/v1
  api_key: ${NVIDIA_API_KEY}
```

## Session Evidence
- **deleg_839229fd** (Short 66, first attempt): Used gemma4:31b via Ollama Cloud, hit HTTP 429, produced low-quality data
- **deleg_25af8ea9** (Short 66, second attempt): Hit HTTP 429 immediately, no data extracted
- **deleg_15b3be44** (test): Reported model="hermes-agent", provider="youtube" — NOT the configured llama3.2:1b

## Action Required
Before any subagent dispatch, verify:
1. Local Ollama is running on localhost:11434
2. llama3.2:1b model is available
3. Test delegation reports correct model/provider