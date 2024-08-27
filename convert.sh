#!/bin/bash

convert_epoch() {
    local timestamp="$1"
    local readable_date=$(date -d "@$timestamp" +"%Y-%m-%d %H:%M:%S" 2>/dev/null)
    if [[ -z "$readable_date" ]]; then
        echo "Invalid epoch: $timestamp"
        return 1
    fi
    echo "$readable_date"
    return 0
}

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 input_file output_file"
    exit 1
fi

input_file="$1"
output_file="$2"

awk -F, -v OFS=, '
BEGIN {
    cmd = "date -d \"@0\" +\"%Y-%m-%d %H:%M:%S\" 2>/dev/null"
    ignore_case = 1
}
NR == 1 {
    for (i = 1; i <= NF; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", $i)  # Trim spaces
        if (tolower($i) == "creationdate") {
            creationdate_idx = i
            break
        }
    }
    if (!creationdate_idx) {
        print "Error: creationdate column not found" > "/dev/stderr"
        exit 1
    }
}
NR > 1 {
    cmd = "date -d \"@" $creationdate_idx "\" +\"%Y-%m-%d %H:%M:%S\" 2>/dev/null"
    cmd | getline $creationdate_idx
    close(cmd)
}
{ print $0 }
' "$input_file" > "$output_file"
