# Subagent Deployment Best Practices — YouTube Shorts Forensic Analysis

## Iteration Limit Constraint

**Config**: `delegation.max_iterations: 50` (config.yaml)

**Empirical Data** (batches 65-80, session 2026-09-07):

| Batch | Shorts | Completed | Iterations Used | Result |
|-------|--------|-----------|-----------------|--------|
| 65-70 | 6 | 65 only | ~50 | Exited after 1 short |
| 66-70 | 5 | 66, partial 67 | ~50 | Exited mid-67 |
| 67-70 | 4 | 67, partial 68 | ~50 | Exited mid-68 |
| 68-70 | 3 | **68, 69, 70** | ~45 | ✅ Complete |
| 71-80 | 10 | 71, 72 | ~50 | Exited mid-73 |

**Rule**: Dispatch **max 3 shorts per subagent delegation**. Chain multiple delegations for larger ranges.

## Ref ID Instability — Critical Pitfall

**Problem**: Ref IDs (`e19`, `e29`, etc.) change on every snapshot. They are NOT stable across page transitions.

**Failure Mode** (Session 2026-09-09):
- Subagent clicked Analytics (`e17`) → page re-rendered
- Subagent then used stale `e19` for Comments → clicked "Clips & Shorts" instead
- Correct element had new ref ID after Analytics navigation

**Correct Pattern**:
```javascript
// ALWAYS find by TEXT CONTENT, never cached ref ID
const links = document.querySelectorAll('a.menu-item-link');
for (const link of links) {
    const text = link.textContent.trim().toLowerCase();
    if (text === 'analytics' || text === 'comments' || text === 'details' || text === 'edit') {
        link.click();
        return {clicked: true, target: text};
    }
}
return {clicked: false, reason: 'not_found'};
```

**Applies to**: Analytics, Comments, Details/Edit sidebar links — ALL are `a.menu-item-link`.

## Comments Extraction — Exact Protocol

1. **Remove Unresponded filter**: Click X/CLOSE button on chip (`button[aria-label*="remove"]`, `ytcp-icon-button`) — NOT the chip itself
2. **Scroll container**: `ytcp-activity-section` (NOT `<main>`)
3. **Phase 1**: 10 × 500px scrolls, capture at EACH position
4. **Phase 2**: 300px increments to bottom, capture at EACH position
5. **Extract at EACH position**: `ytcp-comment-thread` → author, text, timestamp, likes, is_creator, depth
6. **Dedupe**: `seen_ids` with author+text hash in temp file `data/temp_comments_{VIDEO_ID}.json`
7. **Build hierarchy** → compute analytics → write to DB → delete temp file

**FAILURE MODE**: If `individual_comments` count < `comments_analysis.total_comments`, extraction INCOMPLETE — must redo.

## Retry Button Handling

After EVERY navigation AND tab click:
- Check for "Retry" button (up to 5×, wait 4s each)
- Engagement tab frequently shows in-panel "Oops, something went wrong. Retry"
- Wait 5s after Retry click for full render

## Payload Schema Enforcement

**Critical Fields** (ingestion failures if wrong):
| Field | Required Format | Common Mistake |
|-------|----------------|----------------|
| `short_title_template.template_id` | BIGINT (FK to title_templates.id) | String like "jo2024_schedule_announcement" |
| `search_terms[i].views` | INTEGER = round(total_views * pct/100) | 0 or missing (NOT NULL in DB) |
| `traffic_sources[i].source_category` | 'feed'/'search'/'browse'/'channel'/'external'/'other' | 'Shorts feed', 'YouTube search' |
| `individual_comments[i].comment_id` | md5(author+text)[:16] | Missing |
| `analysis_log[i].session_id` | bigint (1, 2, 20260901) | String fails FK |

## Verification Gate (MANDATORY)

Subagent MUST run UNION ALL query and confirm ALL 20 tables ≥1 row before reporting complete:
```sql
SELECT 'performance_metrics' t, COUNT(*) FROM performance_metrics WHERE video_id = 'VID'
UNION ALL SELECT 'traffic_sources', COUNT(*) FROM traffic_sources WHERE video_id = 'VID'
-- ... all 20 tables
```

## External Sources

Often 0 rows for many shorts — normal (only 8/70 shorts have data). Include empty array `[]` in payload.

## Duplicate Prevention

- `analysis_log`: Must be EXACTLY 6 entries (overview, reach, engagement, audience, comments, edit) — no duplicates
- `memory_updates`: 1 entry per short — no duplicates

## Deployment Checklist

Before dispatching subagent:
- [ ] Max 3 shorts per delegation
- [ ] Context includes EXACT payload schema reference
- [ ] Context warns about ref ID instability
- [ ] Context mandates text-based navigation
- [ ] Context requires verification gate before completion