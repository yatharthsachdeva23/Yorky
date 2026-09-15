#!/bin/bash
# Process YouTube Shorts in batches of 5 using Pure CDP pipeline
BASE_DIR="C:/Desktop/Antigravity Projects/YouTube Manager"
cd "$BASE_DIR"

LIST_FILE="/tmp/shorts_list_clean.txt"
count=0

while IFS= read -r line; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi
    # Extract short_id and video_id: format is "short_id | video_id"
    short_id=$(echo "$line" | cut -d'|' -f1 | xargs)
    video_id=$(echo "$line" | cut -d'|' -f2 | xargs)
    # Run the three commands in sequence for this short, in the background
    (
        echo "Processing short $short_id ($video_id)"
        python scripts/extract_short_pure_cdp.py "$short_id" "$video_id"
        python scripts/build_payload.py "$short_id" "$video_id"
        python scripts/ingest_short_forensic.py "$short_id" "$video_id"
        echo "Finished short $short_id"
    ) &
    count=$((count+1))
    if [ $count -eq 5 ]; then
        echo "Waiting for batch of 5 to complete..."
        wait
        echo "Batch completed."
        count=0
    fi
done < "$LIST_FILE"

# Wait for any remaining jobs
if [ $count -gt 0 ]; then
    echo "Waiting for remaining $count jobs..."
    wait
    echo "All jobs completed."
fi
echo "All shorts processed."