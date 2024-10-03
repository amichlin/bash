#!/bin/bash

# Starting directory
start_dir="/home"

# File extensions to search for
extensions=("*.txt" "*.mp3" "*.mp4" "*.wav" "*.zip" "*.csv")

# Loop through each extension and find matching files
echo "Searching for files in $start_dir with the following extensions: ${extensions[*]}"
for ext in "${extensions[@]}"; do
    echo "Searching for $ext files..."
    sudo find "$start_dir" -type f -name "$ext"
done

echo "Search complete."
