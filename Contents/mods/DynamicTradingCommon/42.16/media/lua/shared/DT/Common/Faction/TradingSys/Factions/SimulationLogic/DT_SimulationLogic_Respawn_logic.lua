-- ==============================================================================
-- Simulation/Simulation_Respawn_logic.lua
-- Logic: Handles dead faction cleanup and instantiating dynamic new factions.
-- ==============================================================================

local RespawnLogic = {}

local function normalizeTownKey(value)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

function RespawnLogic.Process(data, factionsToRemove, Sandbox)
    -- Cleanup Dead Factions
    for _, deadID in ipairs(factionsToRemove) do
        data[deadID] = nil
        DynamicTrading_Roster.ClearSouls(deadID) -- Remove their souls from Roster too
    end

    -- DYNAMIC RESPAWNING (Long game stability)
    if DT_FactionLocations then
        local respawnChance = Sandbox.FactionRespawnChance or 10
        local maxFactions = Sandbox.MaxFactionsPerTown or 2

        for townID, townData in pairs(DT_FactionLocations) do
            local spawnTown = (type(townData) == "table" and townData.name) or townID
            local factionSeed = (type(townData) == "table" and townData.id) or townID
            local spawnTownKey = normalizeTownKey(spawnTown) or normalizeTownKey(townID)

            -- Count existing factions in this town
            local count = 0
            for _, f in pairs(data) do
                if f
                    and f.excludeFromPopulationPool ~= true
                    and f.excludeFromFactionCap ~= true
                    and f.isSystemFaction ~= true
                    and f.systemFaction ~= true
                    and normalizeTownKey(f.town) == spawnTownKey then
                    count = count + 1
                end
            end
            
            if count < maxFactions and ZombRand(100) < respawnChance then
                -- New faction arrives!
                local factionID = tostring(factionSeed) .. "_" .. tostring(100000 + ZombRand(900000))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = spawnTown,
                    memberCount = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.FactionStartPop or 10
                })
                DynamicTrading.Log("DTCommons", "Faction", "Sim", "A new faction has moved into " .. tostring(spawnTown))
            end
        end
    end
end

return RespawnLogic
