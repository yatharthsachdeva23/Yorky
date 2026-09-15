#!/usr/bin/env python3
import subprocess
import time
import os

# Read the shorts list file
list_file = '/tmp/shorts_list.txt'
shorts = []
with open(list_file, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        # Format: "1|       31 | durkT5BI9-0"
        parts = line.split('|')
        if len(parts) >= 3:
            short_id = parts[1].strip()
            video_id = parts[2].strip()
            shorts.append((short_id, video_id))

print(f"Found {len(shorts)} shorts to process.")

# Batch size
batch_size = 5
batches = [shorts[i:i+batch_size] for i in range(0, len(shorts), batch_size)]
print(f"Split into {len(batches)} batches of up to {batch_size} each.")

# Base directory
base_dir = r"C:/Desktop/Antigravity Projects/YouTube Manager"
scripts_dir = os.path.join(base_dir, "scripts")

for batch_idx, batch in enumerate(batches):
    print(f"\n=== Processing batch {batch_idx+1}/{len(batches)} ===")
    print(f"Short IDs: {[s[0] for s in batch]}")
    
    processes = []
    for short_id, video_id in batch:
        # Build the command to run the three scripts in sequence
        cmd_extract = f'python "{os.path.join(scripts_dir, "extract_short_pure_cdp.py")}" {short_id} "{video_id}"'
        cmd_build = f'python "{os.path.join(scripts_dir, "build_payload.py")}" {short_id} "{video_id}"'
        cmd_ingest = f'python "{os.path.join(scripts_dir, "ingest_short_forensic.py")}" {short_id} "{video_id}"'
        
        # Combine into a single command string with && so that if one fails, the chain stops.
        full_cmd = f'cd "{base_dir}" && {cmd_extract} && {cmd_build} && {cmd_ingest}'
        print(f"  Starting short {short_id}: {full_cmd}")
        
        # Start the process
        proc = subprocess.Popen(full_cmd, shell=True)
        processes.append(proc)
    
    # Wait for all processes in this batch to complete
    for proc in processes:
        proc.wait()
    
    print(f"=== Batch {batch_idx+1} completed ===")
    # Optional: wait a bit between batches
    time.sleep(2)

print("\nAll batches processed.")