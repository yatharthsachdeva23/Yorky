#!/bin/bash
BASE_DIR="C:/Desktop/Antigravity Projects/YouTube Manager"
cd "$BASE_DIR"

count=0
while read line; do
  # Skip empty lines
  if [ -z "$line" ]; then
    continue
  fi
  short_id=$(echo "$line" | cut -d'|' -f2 | xargs)
  video_id=$(echo "$line" | cut -d'|' -f3 | xargs)
  # Run the three commands in sequence for this short, in the background
  (
    python scripts/extract_short_pure_cdp.py "$short_id" "$video_id"
    python scripts/build_payload.py "$short_id" "$video_id"
    python scripts/ingest_short_forensic.py "$short_id" "$video_id"
  ) &
  count=$((count+1))
  if [ $count -eq 5 ]; then
    wait
    count=0
  fi
done < /tmp/shorts_list_clean.txt

wait