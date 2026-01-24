@echo off & title PZ Wearable Extractor & python -x "%~f0" %* & pause & goto :eof
"""
Hybrid Script: Batch wrapper for Python.
"""

import re
import os
import sys

# --- Configuration ---
INPUT_FILE = "clothing.txt"
OUTPUT_FILE = "wearable.txt"

def extract_data(filename):
    if not os.path.exists(filename):
        print(f"\n[ERROR] '{filename}' not found.")
        print(f"Please place '{filename}' in the same folder as this script.")
        return

    print(f"Reading from: {filename}")
    print(f"Writing to:   {OUTPUT_FILE}...")

    # Regex to find "item ItemName"
    item_pattern = re.compile(r'^\s*item\s+([\w_]+)')

    current_id = None
    count = 0
    props = {
        "BodyLocation": "",
        "BloodLocation": ""
    }

    try:
        with open(filename, 'r', encoding='utf-8') as infile, \
             open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:
            
            # Write Header
            # Adjust spacing: ID(45) | Body(30) | Blood(Rest)
            header = f"{'ITEM ID':<45} | {'BODY LOCATION':<30} | {'BLOOD LOCATION'}"
            outfile.write(header + "\n")
            outfile.write("-" * 120 + "\n")

            for line in infile:
                raw_line = line.strip()
                
                # 1. Check for new item block start
                match = item_pattern.match(raw_line)
                if match:
                    # Save previous item if it wasn't closed properly
                    if current_id: 
                        write_row(outfile, current_id, props)
                        props = {k: "" for k in props} # Reset
                    
                    current_id = match.group(1)
                    continue

                # 2. Extract Data inside block
                if current_id:
                    # End of block found
                    if raw_line.startswith("}"):
                        write_row(outfile, current_id, props)
                        count += 1
                        current_id = None
                        props = {k: "" for k in props} # Reset
                    else:
                        # Extract Key=Value
                        if "=" in raw_line:
                            key, val = raw_line.split("=", 1)
                            key = key.strip()
                            # Remove trailing commas and whitespace
                            val = val.strip().rstrip(",")

                            # Only grab the keys we care about
                            if key in props:
                                props[key] = val

        print(f"\n[SUCCESS] Processed {count} items.")
        print(f"Data saved to: {os.path.abspath(OUTPUT_FILE)}")

    except Exception as e:
        print(f"\n[Error]: {e}")

def write_row(file_obj, item_id, props):
    # Formats the line and writes it to the text file
    line = f"{item_id:<45} | {props['BodyLocation']:<30} | {props['BloodLocation']}\n"
    file_obj.write(line)

if __name__ == "__main__":
    # Allow dragging and dropping a different file onto the script
    target = sys.argv[1] if len(sys.argv) > 1 else INPUT_FILE
    extract_data(target)