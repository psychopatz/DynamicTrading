0<0# : ^
''' 
@echo off
:: =========================================================
:: BATCH LOADER
:: =========================================================
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH.
    pause
    exit /b
)
:: Run the python code below
python -x "%~f0"
echo.
echo Process complete.
pause
exit /b 
'''

# =========================================================
# PYTHON SCRIPT
# =========================================================
import os
import re

# We are looking for this specific file now, not the DTItems folder
TARGET_FILENAME = 'DynamicTrading_Archetypes.lua'
OUTPUT_FILENAME = 'archetypes.txt'

def find_target_file(start_dir):
    """Recursively search for the DynamicTrading_Archetypes.lua file."""
    print(f"Searching for '{TARGET_FILENAME}' inside '{os.path.abspath(start_dir)}'...")
    for root, dirs, files in os.walk(start_dir):
        if TARGET_FILENAME in files:
            found_path = os.path.join(root, TARGET_FILENAME)
            print(f"Found target file: {found_path}")
            return found_path
    return None

def main():
    # 1. Locate the file
    target_path = find_target_file('.')
    
    if not target_path:
        print(f"Error: Could not find file '{TARGET_FILENAME}' in any subdirectories.")
        return

    results = []
    
    # Regex Breakdown:
    # DynamicTrading\.RegisterArchetype  -> Matches the function name literally
    # \s*\(\s*                           -> Matches open parenthesis with optional whitespace
    # ["']                               -> Matches either a double or single quote
    # ([^"']+)                           -> CAPTURE GROUP 1: Matches text that is NOT a quote (the ID)
    # ["']                               -> Matches the closing quote
    archetype_pattern = re.compile(r'DynamicTrading\.RegisterArchetype\s*\(\s*["\']([^"\']+)["\']')

    try:
        count = 0
        with open(target_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
            # Find all matches
            matches = archetype_pattern.findall(content)
            
            for archetype_id in matches:
                # Add to results list
                results.append(archetype_id)
                count += 1
                print(f"Found ID: {archetype_id}")

        # 2. Save results to archetypes.txt
        if results:
            with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as f:
                f.write("Extracted Archetype IDs:\n")
                f.write("========================\n")
                for item in results:
                    f.write(f'{item}\n')
            
            print(f"\nSuccess! Extracted {count} archetypes.")
            print(f"Saved output to: {os.path.abspath(OUTPUT_FILENAME)}")
        else:
            print("No archetypes found in the file.")

    except Exception as e:
        print(f"Error processing file: {e}")

if __name__ == "__main__":
    main()