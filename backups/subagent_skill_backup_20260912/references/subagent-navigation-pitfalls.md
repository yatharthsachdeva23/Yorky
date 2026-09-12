# Subagent Navigation Pitfalls — Critical Fixes (Sept 9, 2026)

## Problem: Ref IDs Are Not Stable

**Root Cause**: `browser_click(ref="e19")` uses element reference IDs from a previous `browser_snapshot`. These IDs (`e1`, `e19`, `e29`, etc.) are **regenerated on every snapshot** and shift when the page content changes.

**Observed Failure**: Subagent clicked `e19` thinking it was "Comments" tab, but after navigating to Analytics and back, `e19` pointed to "Clips and Shorts" instead.

## Correct Pattern: Click by TEXT Content

```python
# WRONG - uses stale ref ID
browser_click(ref="e19")

# CORRECT - find by text content via browser_console
browser_console(expression="""
(() => {
  const links = document.querySelectorAll('a.menu-item-link');
  for (const link of links) {
    if (link.textContent.trim().toLowerCase() === 'comments') {
      link.click();
      return {clicked: true, text: link.textContent.trim()};
    }
  }
  return {clicked: false, reason: 'not_found'};
})()
""")
```

## Navigation Selectors (Verified Working)

| Target | Selector | Method |
|--------|----------|--------|
| Analytics | `a.menu-item-link` with text "Analytics" | browser_console click by text |
| Overview/Reach/Engagement/Audience | `[role="tab"]` with exact text match | browser_console click by text |
| Comments | `a.menu-item-link` with text "Comments" | browser_console click by text |
| Details/Edit | `a.menu-item-link` with text "Details" or "Edit" | browser_console click by text |

## Mandatory Workflow Per Navigation

1. **Take fresh snapshot** after every navigation
2. **Query DOM by text** via `browser_console` — never trust ref IDs
3. **Click the matched element** via `browser_console`
4. **Wait 5s** for render
5. **Check Retry button** (up to 5×, 4s each)
6. **Extract data** via `document.body.innerText`

## Comments Tab Specific Pitfall

After clicking Analytics tab, the left sidebar menu items shift. The "Comments" link moves to a different ref ID. **Always re-query fresh**.

```python
# After Analytics extraction, before Comments:
# 1. Fresh snapshot
browser_snapshot(full=False)

# 2. Click Comments by text
browser_console(expression='''
(() => {
  const links = document.querySelectorAll('a.menu-item-link');
  for (const link of links) {
    const text = link.textContent.trim().toLowerCase();
    if (text === 'comments') {
      link.click();
      return {clicked: true};
    }
  }
  return {clicked: false};
})()
''')

# 3. Wait 3s + Retry check
```

## Verification Checklist for Subagent Delegation

Add to delegation context:
- [ ] "Ref IDs change every snapshot — click by TEXT via browser_console"
- [ ] "After EVERY navigation, take fresh snapshot before clicking"
- [ ] "Comments tab: click a.menu-item-link with text 'Comments' via browser_console"
- [ ] "Analytics tabs: click [role='tab'] with exact text via browser_console"