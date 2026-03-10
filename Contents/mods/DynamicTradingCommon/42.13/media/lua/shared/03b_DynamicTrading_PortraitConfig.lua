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


function DynamicTrading.Portraits.ScanTextures()
    if isServer() then return end
    
    print("[DynamicTrading] Beginning Portrait Texture Scan...")
    local archetypes = {
        "General", "Farmer", "Butcher", "Doctor", "Mechanic",
        "Survivalist", "Gunrunner", "Foreman", "Scavenger", "Tailor",
        "Electrician", "Welder", "Chef", "Herbalist", "Smuggler",
        "Librarian", "Angler", "Sheriff", "Bartender", "Teacher",
        "Hunter", "Quartermaster", "Musician", "Janitor", "Carpenter",
        "Pawnbroker", "Pyro", "Athlete", "Pharmacist", "Hiker",
        "Burglar", "Blacksmith", "Tribal", "Painter", "RoadWarrior",
        "Designer", "Office", "Geek", "Brewer", "Demo"
    }
    local genders = {"Male", "Female"}
    local totalFound = 0

    for _, arch in ipairs(archetypes) do
        DynamicTrading.Portraits.Counts[arch] = {}
        for _, gender in ipairs(genders) do
            local count = 0
            while true do
                local texPath = "media/ui/Portraits/" .. arch .. "/" .. gender .. "/" .. (count + 1) .. ".png"
                if getTexture(texPath) then
                    count = count + 1
                else
                    break
                end
            end
            DynamicTrading.Portraits.Counts[arch][gender] = count
            if count > 0 then
                print("[DynamicTrading] Portrait Scan: [" .. arch .. "][" .. gender .. "] Found " .. count)
                totalFound = totalFound + count
            end
        end
    end
    print("[DynamicTrading] Portrait Scan Complete. Total unique textures found: " .. totalFound)
end

--- Returns a random portrait seed (1-1000).
--- This is used by generators to store a persistent variety key.
--- @return number
-- Legacy alias: use identitySeed instead
function DynamicTrading.Portraits.RollPortraitSeed()
    if DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollIdentitySeed then
        return DT_NPC_Wardrobe.RollIdentitySeed()
    end
    return ZombRand(1000) + 1
end

--- Returns the actual texture ID relative to the folder by applying (seed % count) + 1.
--- This ensures server-client sync without the server needing texture access.
--- @param archetype string
--- @param gender string
--- @param seed number (1-1000)
--- @return number
function DynamicTrading.Portraits.GetMappedID(archetype, gender, seed)
    local target = archetype
    if not DynamicTrading.Portraits.Counts[target] then target = "General" end
    
    local data = DynamicTrading.Portraits.Counts[target]
    if (not data[gender]) or (data[gender] <= 0) then
        target = "General"
        data = DynamicTrading.Portraits.Counts[target]
    end

    if not data or not data[gender] or data[gender] <= 0 then return 1 end
    
    -- Formula: (seed % available) + 1
    -- We use seed-1 to handle modulo 0 correctly, then add 1 back.
    return ((seed - 1) % data[gender]) + 1
end

function DynamicTrading.Portraits.GetPathFolder(archetype, gender)
    local target = archetype
    local data = DynamicTrading.Portraits.Counts[target]
    
    if not data or (not data[gender]) or (data[gender] <= 0) then
        target = "General"
    end

    return "media/ui/Portraits/" .. target .. "/" .. gender .. "/"
end

-- Hook to main menu enter to ensure textures are loaded before use
Events.OnMainMenuEnter.Add(DynamicTrading.Portraits.ScanTextures)