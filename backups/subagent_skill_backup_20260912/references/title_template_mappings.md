# Title Template ID Mappings

Valid `template_id` values (FK to `title_templates.id`):

| ID | Template Name | Pattern | Use Case |
|----|---------------|---------|----------|
| 1 | educational_series_part | `{topic} (Part-{part}) #{hashtags}` | Multi-part educational series |
| 2 | educational_series_part | (duplicate) | |
| 6 | educational_series_part | (duplicate) | |
| 7 | educational_series_part | (duplicate) | |
| 12 | educational_series_part | (duplicate) | |
| 24 | series_part_format | `MOST IMP TIPS for JEE & other competitive exams (Part-{N}) #iit #jee #part{N} #jee2024` | JEE tips series |
| 26 | series_part_format | (duplicate) | |
| 27 | series_part_format | (duplicate) | |
| **28** | **alert_announcement** | `[EMOJI] [TOPIC] [ACTION]!! #[HASHTAG1] #[HASHTAG2] #[HASHTAG3]` | **Breaking news/alerts with emoji prefix & triple !!** |
| 29 | urgent_download_warning | `[EMOJI] [TOPIC] [URGENCY] | [ACTION] #[HASHTAG1] #[HASHTAG2]` | Urgent warnings with pipe separator |

## Selection Rules

- **Alert/Announcement** (emoji prefix + !! + 3 hashtags) → **template_id = 28**
- **Urgent/Download** (emoji + pipe separator + 2 hashtags) → **template_id = 29**
- **Educational Series Part** (Part-N format) → **template_id = 24/26/27**
- **Generic Educational Series** → **template_id = 1/2/6/7/12**

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using string like "jo2024_schedule_announcement" | Use integer ID (28) |
| Using short_id as template_id | template_id ≠ short_id |
| Omitting template_id | Required field (FK NOT NULL) |

## Example

Title: `🚨 FULL SCHEDULE & BROCHURE RELEASED!! | JOSSA 2024 #jee2024 #josaa #shorts`
→ Matches alert_announcement pattern → **template_id = 28**