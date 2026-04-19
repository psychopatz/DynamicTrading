-- ==============================================================================
-- Simulation/Simulation_Respawn_logic.lua
-- Logic: Handles dead faction cleanup and instantiating dynamic new factions.
-- ==============================================================================

require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"

local RespawnLogic = {}

local function buildTownFactionID(townName)
    local prefix = tostring(townName or "Town")
    prefix = prefix:gsub("%s+", "")
    prefix = prefix:gsub("[^%w_]", "")
    if prefix == "" then
        prefix = "Town"
    end
    return prefix .. "_" .. tostring(100000 + ZombRand(900000))
end

function RespawnLogic.Process(data, factionsToRemove, Sandbox)
    -- Cleanup Dead Factions
    for _, deadID in ipairs(factionsToRemove) do
        data[deadID] = nil
        DynamicTrading_Roster.ClearSouls(deadID) -- Remove their souls from Roster too
    end

    -- DYNAMIC RESPAWNING (Long game stability)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.LoadBuildings and DT_GeolocatorSystem.GetSeedTowns then
        local respawnChance = Sandbox.FactionRespawnChance or 10
        local maxFactions = Sandbox.MaxFactionsPerTown or 2

        DT_GeolocatorSystem.LoadBuildings()
        for _, townName in ipairs(DT_GeolocatorSystem.GetSeedTowns()) do
            -- Count existing factions in this town
            local count = 0
            for _, f in pairs(data) do
                if f.town == townName then count = count + 1 end
            end
            
            if count < maxFactions and ZombRand(100) < respawnChance then
                -- New faction arrives!
                local factionID = buildTownFactionID(townName)
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.FactionStartPop or 10
                })
                DynamicTrading.Log("DTCommons", "Faction", "Sim", "A new faction has moved into " .. townName)
            end
        end
    end
end

return RespawnLogic
