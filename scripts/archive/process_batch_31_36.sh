#!/bin/bash
BASE_DIR="C:/Desktop/Antigravity Projects/YouTube Manager"
cd "$BASE_DIR"

# Function to process a single short
process_short() {
    local short_id="$1"
    local video_id="$2"
    echo "Processing short $short_id ($video_id)"
    python scripts/extract_short_pure_cdp.py "$video_id" "$short_id"
    python scripts/build_payload.py "$short_id" "$video_id"
    python ingest_short_forensic.py "data/payload_short${short_id}.json"
    echo "Finished short $short_id"
}

# Read shorts 31-36
shorts=()
while IFS='|' read -r short_id video_id; do
    # Skip empty lines and header
    if [[ -z "$short_id" || "$short_id" == "short_id" ]]; then
        continue
    fi
    shorts+=("$short_id|$video_id")
done < /tmp/shorts_list_new.txt

# Filter for shorts 31-36
batch1=()
for pair in "${shorts[@]}"; do
    short_id=$(echo "$pair" | cut -d'|' -f1)
    if [[ "$short_id" -ge 31 && "$short_id" -le 36 ]]; then
        batch1+=("$pair")
    fi
done

echo "Processing batch 1 (shorts 31-36): ${#batch1[@]} shorts"

# Process in batches of 5
batch_size=5
for ((i=0; i<${#batch1[@]}; i+=batch_size)); do
    echo "Starting sub-batch $((i/batch_size + 1))"
    pids=()
    for ((j=i; j<i+batch_size && j<${#batch1[@]}; j++)); do
        IFS='|' read -r short_id video_id <<< "${batch1[$j]}"
        process_short "$short_id" "$video_id" &
        pids+=($!)
    done
    
    # Wait for all processes in this sub-batch
    for pid in "${pids[@]}"; do
        wait $pid
    done
    echo "Sub-batch completed"
done

echo "All shorts 31-36 processed"