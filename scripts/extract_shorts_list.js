(() => {
  const rows = document.querySelectorAll('ytcp-video-row');
  const data = [];
  rows.forEach((row, i) => {
    const links = row.querySelectorAll('a');
    let videoId = '', title = '', duration = '';
    for (const link of links) {
      const href = link.getAttribute('href') || '';
      const text = link.innerText || link.textContent || '';
      const cleanText = text.trim();
      if (href.includes('/video/') && !href.includes('/analytics') && !href.includes('/edit') && !href.includes('/comments')) {
        const match = href.match(/\/video\/([^/?]+)/);
        if (match) videoId = match[1];
        if (cleanText && cleanText.length > title.length && !/^\d+:\d+$/.test(cleanText)) {
          title = cleanText;
        }
      }
    }
    const rowText = row.textContent || row.innerText || '';
    const durationMatch = rowText.match(/(\d+:\d{2})/);
    if (durationMatch) duration = durationMatch[1];
    if (videoId || title) data.push({index: i+1, videoId, title: title.substring(0, 100), duration});
  });
  return data;
})()