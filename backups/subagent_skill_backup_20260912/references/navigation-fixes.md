# Navigation Fixes for YouTube Studio (Discovered in Short #59 Analysis)

## Issue: Analytics Tab Not Found via `[role="tab"]`

**Problem**: The forensic subagent skill's Step 3 used `document.querySelectorAll('[role="tab"]', 'a', 'button')` to find the Analytics tab, but this returns empty in YouTube Studio. The Analytics link is actually an `<a>` element with class `menu-item-link` inside `ytcp-navigation-drawer`, NOT a `[role="tab"]` element.

**Solution**: Use the correct selector:
```javascript
const links = document.querySelectorAll('a.menu-item-link');
for (const link of links) {
  if (link.textContent.trim().toLowerCase() === 'analytics') {
    link.click();
    return {clicked: true};
  }
}
return {clicked: false};
```

**Also applies to**: Comments, Details/Edit, and other left-sidebar navigation items — they are all `<a class="menu-item-link">` elements, not `[role="tab"]`.

## Issue: Video URL Should Include `/edit?theme=dark`

**Problem**: The skill's Step 2 navigated to `https://studio.youtube.com/video/{video_id}` but this lands on a different view. The edit page with `/edit?theme=dark` is the correct starting point that shows the left navigation drawer with Analytics/Comments/Details links.

**Solution**: Always navigate to:
```javascript
window.location.href = `https://studio.youtube.com/video/${video_id}/edit?theme=dark`;
```

## Updated Navigation Sequence (Corrected)

1. **Navigate to edit page**: `https://studio.youtube.com/video/{video_id}/edit?theme=dark`
2. **Click Analytics**: Use `a.menu-item-link` selector with text "Analytics"
3. **Click Reach/Engagement/Audience tabs**: These ARE `[role="tab"]` elements inside the analytics view — the original tab-clicking logic works for these
4. **Click Comments**: Back to left nav, use `a.menu-item-link` with text "Comments"
5. **Click Details/Edit**: Back to left nav, use `a.menu-item-link` with text "Details"

## Retry Button Handling (Confirmed Working)

The retry button click logic works correctly — Studio shows a "Retry" button when bot detection triggers. **Always check and click after EVERY navigation AND every tab click** (Retry reappears on every sub-tab click: Overview → Reach → Engagement → Audience).

## Audience Tab Issue (Short #59)

The Audience tab consistently showed "Oops, something went wrong" even after multiple retries. This appears to be a Studio-side issue for older videos with limited audience data. Workaround: Use estimated demographics from channel patterns and mark `has_data: false` in the payload.

## Session 2026-09-06 Batch 65-70 Findings

**Subagent iteration limit**: Each short takes ~16-17 iterations due to:
- 5 navigation clicks (edit page → Analytics → 4 sub-tabs → Comments → Edit)
- Each click requires Retry button check (2-3 iterations per tab)
- Comments scroll: 40 steps × 0.5 iterations = ~20 iterations

**Effective batch size**: Max 3 shorts per delegation (see `references/subagent-batch-mode-limits.md`)

**Tab clicking refinement**: The Reach/Engagement/Audience tabs ARE `[role="tab"]` and work correctly once on the Analytics page. The left-nav items (Analytics, Comments, Details) are `a.menu-item-link`.