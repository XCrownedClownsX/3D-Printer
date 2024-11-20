# Klipper CSV Processing and Archiving Script

This repository contains a Bash script designed for automating the processing, conversion, and archiving of CSV files on a Raspberry Pi or Linux-based system. The script is versatile, modular, and includes detailed logging and error handling to ensure reliable execution.

The Script is based on this documentation: https://www.klipper3d.org/Measuring_Resonances.html#input-shaper-auto-calibration

---

## Features
- **CSV File Processing:**
  - Filters CSV files matching specific patterns: `calibration_data_x_*.csv` and `calibration_data_y_*.csv`.
  - Processes these files using a Python script (`calibrate_shaper.py`).
  - Generates PNG graphs and renames the output files to `calibration_data_x_*.png` and `calibration_data_y_*.png`.
  - Outputs PNG files to a designated directory.

- **Archiving CSV Files:**
  - Moves processed CSV files to an archive directory organized by date.
  - Archive directories are named in the `MM-DD-YYYY` format based on file creation or last modification date.
  - Automatically creates archive directories if they don't already exist.

- **Error Handling:**
  - Verifies successful execution of every step (e.g., Python script processing, file moves, directory creation).
  - Logs detailed success and error messages for troubleshooting.

- **Reusable Functionality:**
  - Encapsulated in a function (`process_csv_files`) for easy integration with other scripts or automated workflows.

---

## Requirements

### System Requirements
- Raspberry Pi or any Linux-based system.
- **Python 3** installed (accessible via `python3` command).
- Bash shell.

### Python Script
The script relies on a Python script (`calibrate_shaper.py`) that performs the actual processing of the CSV files and generates PNG files. Ensure:
- The Python script accepts two arguments:
  1. Path to the input CSV file.
  2. Path to the output PNG file.
- Example usage of the Python script:
  ```bash
  python3 calibrate_shaper.py input_file.csv -o output_file.png

## Directory Structure
Below is the recommended directory structure for the script to function properly:
```
/home/pi/                    # Directory containing the processing script and Python script
/home/pi/csv/                # Directory for new CSV files to be processed
/home/pi/png/                # Directory for output PNG files
/home/pi/archive/            # Directory for archiving processed CSV files
```

## Installation
Clone the repository:
```
git clone https://github.com/xcrownedclownsx/process_csv.git
```
Make the script executable:
```
chmod +x process_csv.sh
```
Ensure the required Python script (calibrate_shaper.py) is present in the scripts directory.

## Script Workflow
**1. Process CSV Files:**
- Filters CSV files matching patterns: calibration_data_x_*.csv and calibration_data_y_*.csv in the /tmp directory.
- Processes files using the Python script, generating PNG outputs.
- Outputs PNG files to /home/pi/png/:
  - calibration_data_x_*.csv → calibration_data_x_*.png
  - calibration_data_y_*.csv → calibration_data_y_*.png

**2. Archive Processed Files:**
- Retrieves each file’s creation or last modification date.
- Converts the date to MM-DD-YYYY format.
- Moves files to /home/pi/archive/MM-DD-YYYY/.

**3. Error Handling:**
- Logs the success or failure of each step.
- Terminates the script if a critical step fails.

## Example Directory Changes
Before Running the Script
```
/tmp/
    calibration_data_x_001.csv
    calibration_data_y_002.csv

/home/pi/png/            (empty)
/home/pi/archive/        (empty)
```
After Running the Script
```
/tmp/            (empty)

/home/pi/png/
    calibration_data_x_001.png
    calibration_data_y_002.png

/home/pi/archive/
    11-16-2024/
        calibration_data_x_001.csv
        calibration_data_y_002.csv
```

## Script Details
`process_csv_files` Function
This function performs the main tasks of the script and can be reused in other scripts. Below is the flow:

Steps:
**1. File Filtering:**
- Searches for files matching calibration_data_x_*.csv and calibration_data_y_*.csv.
**2. CSV Processing:**
- Runs calibrate_shaper.py for each file and generates PNG outputs.
- Renames PNG outputs to graphed_data_x.png and graphed_data_y.png.
**3. File Archiving:**
- Archives all CSV files into a date-based folder under /home/pi/data/archive/.

**Error Handling:**
If any step fails, the function logs an error message and exits with a non-zero code.

## Customization
You can modify the script as needed:
**1. Change Directory Paths:**
  - Update the csv_dir, output_dir, and archive_dir variables to fit your environment.
**2. Process Additional File Patterns:**
  - Extend the logic to handle other CSV file patterns.

## Troubleshooting
**1. No PNG Files Generated:**
  - Ensure the Python script is in the correct location and accepts the expected arguments.
  - Check the script logs for error messages.
