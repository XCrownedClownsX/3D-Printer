#!/bin/bash

# Set paths
SCRIPT_DIR="/home/username/klipper/scripts"
CSV_DIR="/tmp"
OUTPUT_DIR="/home/username"
ARCHIVE_DIR="/home/username/calibration_data_archive"
PYTHON_SCRIPT="calibrate_shaper.py"

# Prepare directories
prepare_directories() {
    for dir in "$CSV_DIR" "$OUTPUT_DIR" "$ARCHIVE_DIR"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        fi
    done
}

# Progress bar function
progress_bar() {
    local progress=$1
    local total=$2
    local percent=$((progress * 100 / total))
    local bar_width=50
    local filled=$((progress * bar_width / total))
    local empty=$((bar_width - filled))

    printf "\r[%-${bar_width}s] %d%% (%d/%d)" "$(printf '#%.0s' $(seq 1 $filled))" $percent $progress $total
}

# Process files with progress bar
process_files() {
    local file_pattern=$1
    local file_label=$2
    local files=( "$CSV_DIR"/$file_pattern )
    local total_files=${#files[@]}

    if [ $total_files -eq 0 ]; then
        echo "No $file_label files found."
        return
    fi

    echo "Processing $file_label files..."
    progress_bar 0 $total_files  # Initialize progress bar at 0%
    local count=0
    for file in "${files[@]}"; do
        [ -f "$file" ] || continue
        count=$((count + 1))
        output_file="${file##*/}"
        output_file="${output_file%.*}.png"
        python3 "$SCRIPT_DIR/$PYTHON_SCRIPT" "$file" -o "$OUTPUT_DIR/$output_file" > /dev/null
        if [ $? -eq 0 ]; then
            progress_bar $count $total_files
        else
            echo -e "\nError: Failed to process $file."
            exit 1
        fi
    done
    echo -e "\nFinished processing $file_label files."
}

# Archive CSV files by date
archive_files() {
    echo "Archiving CSV files..."
    for file in "$CSV_DIR"/*.csv; do
        [ -f "$file" ] || continue
        file_date=$(stat --format='%y' "$file" | cut -d ' ' -f 1)
        archive_date=$(date -d "$file_date" +%m-%d-%Y)
        archive_path="$ARCHIVE_DIR/$archive_date"
        if [ ! -d "$archive_path" ]; then
            mkdir -p "$archive_path"
            echo "Created archive directory: $archive_path"
        fi
        mv "$file" "$archive_path" && echo "Moved $file to $archive_path"
    done
    echo "Archiving completed."
}

# Main script execution
prepare_directories
process_files "calibration_data_x_*.csv" "calibration_data_y_*.csv"
archive_files
echo "Script Completed Sucessfully! You can now download the PNG files."

# End of Script
