import os
import re

ROOT_DIR = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/ArchetypeDefinitions/"

# Pattern to find the allocations block
ALLOC_BLOCK_RE = re.compile(r'allocations\s*=\s*\{([^\}]+)\}', re.DOTALL)
ALLOC_LINE_RE = re.compile(r'\["([^"]+)"\]\s*=\s*(\d+)')

def migrate_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    def replacer(match):
        inner = match.group(1)
        # Find all lines like ["Tag"] = X
        matches = ALLOC_LINE_RE.findall(inner)
        if not matches:
            return match.group(0)
            
        new_lines = []
        for tag, count in matches:
            new_lines.append(f'{{ tags = {{"{tag}"}}, count = {count} }}')
        
        # Apply specialized logic for Lumberjack (Foreman)
        if "Foreman" in filepath or "Lumberjack" in filepath:
             new_lines.append(f'{{ item = "Base.Axe", count = 1 }}')
             new_lines.append(f'{{ item = "Base.Woodglue", count = 2 }}')
        
        indent = "        "
        return "allocations = {\n" + ",\n".join([indent + line for line in new_lines]) + "\n    }"

    new_content = ALLOC_BLOCK_RE.sub(replacer, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        return True
    return False

count = 0
for root, dirs, files in os.walk(ROOT_DIR):
    for name in files:
        if name.startswith("DT_") and name.endswith(".lua"):
            if migrate_file(os.path.join(root, name)):
                print(f"Migrated: {os.path.relpath(os.path.join(root, name), ROOT_DIR)}")
                count += 1

print(f"Total files migrated: {count}")
