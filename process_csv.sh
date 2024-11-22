#!/bin/bash

# Set paths
SCRIPT_DIR="/home/username/klipper/scripts"
CSV_DIR="/tmp"
OUTPUT_DIR="/home/username"
ARCHIVE_DIR="/home/username/calibration_data_archive"
PYTHON_SCRIPT="calibrate_shaper.py"
FILE_PATTERN="calibration_data_*.csv"

# Prepare directories
prepare_directories() {
    for dir in "$CSV_DIR" "$OUTPUT_DIR" "$ARCHIVE_DIR"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        fi
    done
}

# Progress bar function (per file)
progress_bar_per_file() {
    local percent=$1
    local bar_width=50
    local filled=$((percent * bar_width / 100))
    local empty=$((bar_width - filled))

    # Generate the progress bar
    printf "[%-${bar_width}s] %d%%" "$(printf '#%.0s' $(seq 1 $filled))" $percent
}

# Process files with a progress bar that resets per file
process_files() {
    echo "========== Processing Files =========="
    local files=( "$CSV_DIR"/$FILE_PATTERN )
    local total_files=${#files[@]}

    if [ $total_files -eq 0 ]; then
        echo "No files found matching calibration_data_*."
        return
    fi

    local count=0
    for file in "${files[@]}"; do
        [ -f "$file" ] || continue
        count=$((count + 1))
        output_file="${file##*/}"
        output_file="${output_file%.*}.png"

        # Show initial progress for the current file
        printf "\nProcessing File %d of %d: %-40s\n" "$count" "$total_files" "$(basename "$file")"
        printf "Progress: "
        progress_bar_per_file 0

        # Run the Python script for processing
        python3 "$SCRIPT_DIR/$PYTHON_SCRIPT" "$file" -o "$OUTPUT_DIR/$output_file" > /dev/null
        if [ $? -eq 0 ]; then
            # Update the progress bar to 100% after processing
            printf "\rProgress: "
            progress_bar_per_file 100
            printf "\nStatus: Successfully processed '%s'.\n" "$(basename "$file")"
        else
            printf "\nStatus: Error processing '%s'.\n" "$(basename "$file")"
            exit 1
        fi
        echo "----------------------------------------"
    done
    printf "\nAll files processed successfully.\n\n"
}

# Archive CSV files by date
archive_files() {
    echo "=========== Archiving Files ============"
    local archived=0
    for file in "$CSV_DIR"/*.csv; do
        [ -f "$file" ] || continue
        file_date=$(stat --format='%y' "$file" | cut -d ' ' -f 1)
        archive_date=$(date -d "$file_date" +%m-%d-%Y)
        archive_path="$ARCHIVE_DIR/$archive_date"
        if [ ! -d "$archive_path" ]; then
            mkdir -p "$archive_path"
            echo "Created archive directory: $archive_path"
        fi
        mv "$file" "$archive_path" && echo "Moved $(basename "$file") to $archive_path"
        archived=$((archived + 1))
    done
    if [ $archived -eq 0 ]; then
        echo "No files to archive."
    else
        echo -e "\nArchiving completed. Total files archived: $archived."
    fi
    echo -e "========================================\n"
}

# Main script execution
echo "========== Starting Script ==========="
prepare_directories
process_files
archive_files
echo "=============== Summary ================"
echo "Processed PNG files are available in: $OUTPUT_DIR"
echo "Archived CSV files are stored in: $ARCHIVE_DIR"
echo -e "\nScript Completed Successfully!"
echo "========================================"
