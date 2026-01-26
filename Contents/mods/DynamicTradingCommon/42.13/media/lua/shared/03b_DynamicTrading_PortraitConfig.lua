-- DIRECTORY STRUCTURE:
-- media/textures/Portraits/[ArchetypeID]/Male/1.png, 2.png...
-- media/textures/Portraits/[ArchetypeID]/Female/1.png, 2.png...
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Portraits = {}

-- CONFIGURATION TABLE
-- Update the numbers to match your actual file counts.
DynamicTrading.Portraits.Counts = {
-- Fallback Category (Used if an archetype has 0 or is missing)
["General"]         = { Male = 5, Female = 5 },
-- Essentials
["Farmer"]          = { Male = 5, Female = 5 },
["Butcher"]         = { Male = 5, Female = 5 },
["Doctor"]          = { Male = 5, Female = 5 },
["Mechanic"]        = { Male = 5, Female = 5 },

-- Survivors
["Survivalist"]     = { Male = 5, Female = 5 },
["Gunrunner"]       = { Male = 5, Female = 5 },
["Foreman"]         = { Male = 5, Female = 5 },
["Scavenger"]       = { Male = 5, Female = 5 },

-- Specialists
["Tailor"]          = { Male = 5, Female = 5 },
["Electrician"]     = { Male = 5, Female = 5 },
["Welder"]          = { Male = 5, Female = 5 },
["Chef"]            = { Male = 5, Female = 5 },
["Herbalist"]       = { Male = 5, Female = 5 },

-- Oddballs
["Smuggler"]        = { Male = 5, Female = 5 },
["Librarian"]       = { Male = 5, Female = 5 },
["Angler"]          = { Male = 5, Female = 5 },
["Sheriff"]         = { Male = 5, Female = 5 },
["Bartender"]       = { Male = 5, Female = 5 },
["Teacher"]         = { Male = 5, Female = 5 },

-- Extended
["Hunter"]          = { Male = 5, Female = 5 },
["Quartermaster"]   = { Male = 5, Female = 5 },
["Musician"]        = { Male = 5, Female = 5 },
["Janitor"]         = { Male = 5, Female = 5 },
["Carpenter"]       = { Male = 5, Female = 5 },
["Pawnbroker"]      = { Male = 5, Female = 5 },
["Pyro"]            = { Male = 5, Female = 5 },
["Athlete"]         = { Male = 5, Female = 5 },
["Pharmacist"]      = { Male = 5, Female = 5 },
["Hiker"]           = { Male = 5, Female = 5 },
["Burglar"]         = { Male = 5, Female = 5 },
["Blacksmith"]      = { Male = 5, Female = 5 },
["Tribal"]          = { Male = 5, Female = 5 },
["Painter"]         = { Male = 5, Female = 5 },
["RoadWarrior"]     = { Male = 5, Female = 5 },
["Designer"]        = { Male = 5, Female = 5 },
["Office"]          = { Male = 5, Female = 5 },
["Geek"]            = { Male = 5, Female = 5 },
["Brewer"]          = { Male = 5, Female = 5 },
["Demo"]            = { Male = 5, Female = 5 },
}

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