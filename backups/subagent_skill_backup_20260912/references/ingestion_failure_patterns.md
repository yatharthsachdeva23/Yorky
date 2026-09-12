# Ingestion Failure Patterns & Fixes

Common ingestion failures and their fixes:

## 1. Invalid template_id (FK Constraint)

**Error**: `invalid input syntax for type bigint` or `foreign key constraint "short_title_template_template_id_fkey" violated`

**Cause**: `short_title_template.template_id` must be a valid `title_templates.id` integer

**Fix**: Use valid ID from `title_templates` table (see `references/title_template_mappings.md`)

| Wrong | Right |
|-------|-------|
| `"jo2024_schedule_announcement"` | `28` |
| `72` (short_id) | `28` (alert_announcement) |
| `"alert_announcement"` | `28` |

## 2. data_completeness Type Mismatch

**Error**: `invalid input syntax for type numeric: "full"`

**Cause**: `analysis_log.data_completeness` is `numeric` in DB but payload has string

**Fix**: Convert all `data_completeness` to float:
- `"full"` → `1.0`
- `"partial"` → `0.5`
- `"minimal"` → `0.25`
- Missing → `1.0`

## 3. search_terms.views = 0 or Missing

**Error**: `NOT NULL constraint failed` or `invalid input syntax for type integer`

**Cause**: `search_terms.views` is NOT NULL integer, must be ≥1

**Fix**: Calculate `views = round(total_views * percentage_of_total / 100)`, minimum 1

## 4. Missing shorts.short_id

**Error**: `NOT NULL constraint failed: shorts.short_id`

**Cause**: Payload root has `video_id` but `shorts` object missing or missing `short_id`

**Fix**: Ensure payload has:
```json
{
  "video_id": "xxx",
  "shorts": {"short_id": 72, ...}
}
```

## 5. individual_comments.comment_id NOT NULL

**Error**: `NOT NULL constraint failed: individual_comments.comment_id`

**Cause**: Studio doesn't provide comment_id

**Fix**: Generate deterministic hash:
```python
comment_id = hashlib.md5((author + text).encode()).hexdigest()[:16]
```

## 6. analysis_log.session_id FK Violation

**Error**: `foreign key constraint "analysis_log_session_id_fkey" violated`

**Cause**: Must be bigint referencing `analysis_sessions.id`

**Fix**: Use integer session IDs: `1`, `2`, `20260901`

## 7. end_screen_performance.vs_channel_avg_pct Out of Range

**Error**: `numeric field overflow` or `constraint violated`

**Cause**: Value like `-100.0` exceeds `numeric(6,4)` precision

**Fix**: Use `0.0` when no impressions (not negative)

## 8. traffic_sources.source_category Invalid

**Error**: `CHECK constraint violated` or wrong category

**Fix**: Must be one of: `feed`, `search`, `browse`, `channel`, `external`, `other`

| Studio Label | DB Category |
|--------------|-------------|
| Shorts feed | feed |
| YouTube search | search |
| Browse features | browse |
| Channel pages | channel |
| Notifications | external |
| Others | other |

## Verification Checklist Before Ingestion

- [ ] All 21 root keys present
- [ ] `template_id` is valid integer from title_templates
- [ ] All `data_completeness` are float
- [ ] All `search_terms.views` ≥ 1
- [ ] `shorts.short_id` present and correct
- [ ] All `individual_comments` have `comment_id`
- [ ] `analysis_log` has exactly 6 entries with `session_id=20260901`
- [ ] `traffic_sources.source_category` ∈ allowed set