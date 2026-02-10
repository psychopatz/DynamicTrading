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

# We are looking for this folder name specifically
TARGET_FOLDER_NAME = 'DTItems'
OUTPUT_FILENAME = 'tags.txt'

def find_target_directory(start_dir):
    """Recursively search for the DTItems folder."""
    print(f"Searching for '{TARGET_FOLDER_NAME}' inside '{os.path.abspath(start_dir)}'...")
    for root, dirs, files in os.walk(start_dir):
        if TARGET_FOLDER_NAME in dirs:
            found_path = os.path.join(root, TARGET_FOLDER_NAME)
            print(f"Found target: {found_path}")
            return found_path
    return None

def main():
    # 1. Locate the folder
    target_path = find_target_directory('.')
    
    if not target_path:
        print(f"Error: Could not find a folder named '{TARGET_FOLDER_NAME}' in any subdirectories.")
        return

    results = []
    
    # Regex: Finds "tags = { content }" and captures "content"
    tag_pattern = re.compile(r'tags\s*=\s*\{([^\}]+)\}')

    # 2. Iterate through files in the found directory
    files_processed = 0
    for filename in os.listdir(target_path):
        if not filename.endswith(".lua"):
            continue

        filepath = os.path.join(target_path, filename)
        file_tags = set()
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                # Find all tag definitions in the file
                matches = tag_pattern.findall(content)
                
                for raw_str in matches:
                    # Raw string is like: "Luxury", "Rare"
                    parts = raw_str.split(',')
                    for p in parts:
                        # Clean whitespace and quotes (" or ')
                        clean = p.strip().strip('"').strip("'")
                        if clean:
                            file_tags.add(clean)

            # 3. Format the output string
            # Sort alphabetically
            sorted_tags = sorted(list(file_tags))
            
            # Create JSON-style string: "Tag1", "Tag2"
            tags_str = ', '.join([f'"{t}"' for t in sorted_tags])
            
            entry = (
                "{\n"
                f'filename ="{filename}",\n'
                f'tags =[{tags_str}]\n'
                "}"
            )
            results.append(entry)
            files_processed += 1

        except Exception as e:
            print(f"Error reading {filename}: {e}")

    # 4. Save results to tags.txt at the root (where this script is)
    if results:
        try:
            with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as f:
                f.write('\n'.join(results))
            print(f"Success! Scanned {files_processed} files.")
            print(f"Saved output to: {os.path.abspath(OUTPUT_FILENAME)}")
        except Exception as e:
            print(f"Error writing file: {e}")
    else:
        print("No tags found or no Lua files processed.")

if __name__ == "__main__":
    main()