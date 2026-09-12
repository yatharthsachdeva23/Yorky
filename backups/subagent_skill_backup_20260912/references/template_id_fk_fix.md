# short_title_template.template_id FK Fix — Critical Ingestion Error (Sept 9, 2026)

## Problem
Subagent payload had `"template_id": "jo2024_schedule_announcement"` (string) but DB column `short_title_template.template_id` is `bigint` FK to `title_templates.id`.

**Error**: `invalid input syntax for type bigint: "jo2024_schedule_announcement"`

## Root Cause
Subagent invented a descriptive string instead of querying existing `title_templates` table for valid integer IDs.

## Fix: Query Existing Templates

```sql
SELECT id, template_name FROM title_templates;
```

**Existing templates (as of Sept 9, 2026):**
| id | template_name |
|----|---------------|
| 1 | educational_series_part |
| 2 | educational_series_part |
| 6 | educational_series_part |
| 7 | educational_series_part |
| 12 | educational_series_part |
| 24 | series_part_format |
| 26 | series_part_format |
| 27 | series_part_format |
| 28 | alert_announcement |
| 29 | urgent_download_warning |

## Correct Usage
- For schedule/brochure announcements → use **template_id: 28** (alert_announcement)
- For urgent download warnings → use **template_id: 29** (urgent_download_warning)
- For educational series parts → use **template_id: 1, 2, 6, 7, or 12**

## Payload Correction
```json
"short_title_template": {
  "template_id": 28,  // INTEGER, not string
  "title_length": 57,
  "word_count": 10,
  "hashtag_count": 3,
  "emoji_count": 2,
  "char_before_pipe": 38,  // INTEGER count, not string
  "char_after_pipe": 13,   // INTEGER count, not string
  "keyword_density": {"jee": 0.15, "josaa": 0.12, "schedule": 0.20}
}
```

## Prevention
Add to subagent delegation context:
- "template_id MUST be integer from title_templates.id — query DB first"
- "char_before_pipe / char_after_pipe are INTEGER character counts, not text"
- "Never invent template IDs — use existing FK values"