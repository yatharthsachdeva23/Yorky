# Short #56 Forensic Analysis Reference

**Video ID**: `dudb29Xqo60`  
**Short ID**: 56  
**Title**: "😋 New Café in DTU | Fully A/C #dtu #shorts #cafe"  
**Published**: May 19, 2024  
**Duration**: 27 seconds

## Session Notes

### Navigation Issues Encountered
1. **Direct analytics URL worked after refresh** - `https://studio.youtube.com/video/dudb29Xqo60/analytics/tab-overview/period-default` loaded successfully after initial "Oops" error and retry
2. **Engagement tab showed "Oops, something went wrong"** initially - required retry click and 5s wait
3. **Audience tab showed Engagement data instead of Audience data** - possible YouTube Studio UI bug where Audience tab renders Engagement content
4. **Retry button pattern**: After every navigation/click, must check for and click "Retry" button if present

### Data Extraction Results

| Tab | Status | Notes |
|-----|--------|-------|
| Overview | ✅ Success | Full metrics: 699 views, 48.2% retention, 16s avg duration |
| Reach | ✅ Success | 6 traffic sources, 5 search terms, external sources (WhatsApp 38.9%) |
| Engagement | ✅ Success (after retry) | Engaged views 579, unique viewers 511, end screen 0% CTR |
| Audience | ⚠️ Partial | Showed Engagement data again - limited demographic data |
| Comments | ✅ Success | 3 comments extracted after removing Unresponded filter |
| Edit/Details | ✅ Success | Title, metadata, creator reply visible |

### Key Metrics
- **Views**: 699 (279 more than usual = +66%)
- **Retention**: 48.2% (strong for 27s lifestyle short)
- **Engaged Views**: 579 (82.8% engaged view rate)
- **Subscribers**: +1
- **Comments**: 3 (4.29 per 1k views)
- **Creator Reply Rate**: 33.3% (1 of 3 comments)

### Traffic Source Breakdown
1. YouTube Search: 61.6% (431 views) - "dtu canteen", "dtu campus tour"
2. Shorts Feed: 28.9% (202 views)
3. Channel Pages: 4.9%
4. External: 2.6% (WhatsApp, Google Search, Bing, Samsung Launcher)

### Patterns Identified
1. **High search traffic for campus/food terms** - strong SEO for DTU-related queries
2. **Excellent retention (48.2%)** for 27-second lifestyle content
3. **WhatsApp sharing indicates word-of-mouth** - 38.9% of external traffic
4. **Creator engagement in comments** - replied to viewer asking about full food review

### Database Verification
All 20 tables populated successfully:
- 6 traffic_sources, 5 search_terms, 5 retention_curve points
- 5 audience_geography entries, 4 external_sources
- 3 individual_comments, 6 analysis_log entries