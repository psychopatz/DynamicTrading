-- DIRECTORY STRUCTURE:
-- media/textures/Portraits/[ArchetypeID]/Male/1.png, 2.png...
-- media/textures/Portraits/[ArchetypeID]/Female/1.png, 2.png...
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Portraits = DynamicTrading.Portraits or {}
DynamicTrading.Portraits.Counts = DynamicTrading.Portraits.Counts or {}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

--- Checks if a specific Archetype has custom photos defined.
--- @param archetype string
--- @return boolean

function DynamicTrading.Portraits.HasCustom(archetype)
    if not archetype then return false end
local data = DynamicTrading.Portraits.Counts[archetype]
return data ~= nil
end

--- Returns the max photo count for a specific Archetype + Gender combo.
--- Falls back to "General" if the specific archetype is empty or missing.
--- @param archetype string
--- @param gender string "Male" or "Female"
--- @return number The max index (e.g. 4), or 0 if totally missing.
function DynamicTrading.Portraits.GetMaxCount(archetype, gender)
local target = archetype


-- 1. Check if Archetype exists in our table
if not DynamicTrading.Portraits.Counts[target] then
    target = "General"
end

-- 2. Check if the specific entry has valid counts
local data = DynamicTrading.Portraits.Counts[target]

-- 3. If "Chef" exists but has 0 photos, fallback to "General"
if (not data[gender]) or (data[gender] <= 0) then
    target = "General"
    data = DynamicTrading.Portraits.Counts[target]
end

-- 4. Return count (or 0 if even General is broken)
if data and data[gender] then
    return data[gender]
end

return 0

end

--- Returns the path string prefix for the UI to use later.
--- e.g., "Portraits/Chef/Male/" or "Portraits/General/Male/"
--- @param archetype string
--- @param gender string
--- @return string
function DynamicTrading.Portraits.GetPathFolder(archetype, gender)
local target = archetype


-- Logic mirrors GetMaxCount to ensure we point to the folder that actually has the file
if not DynamicTrading.Portraits.Counts[target] then
    target = "General"
else
    local data = DynamicTrading.Portraits.Counts[target]
    if (not data[gender]) or (data[gender] <= 0) then
        target = "General"
    end
end

-- NOTE: In texture paths, use forward slashes.
-- NOTE: In texture paths, use forward slashes.
return "media/ui/Portraits/" .. target .. "/" .. gender .. "/"


end

print("[DynamicTrading] Portrait Registry Complete.")