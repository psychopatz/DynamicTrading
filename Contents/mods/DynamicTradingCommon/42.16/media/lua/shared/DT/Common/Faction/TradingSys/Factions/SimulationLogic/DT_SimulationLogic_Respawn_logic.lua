-- ==============================================================================
-- Simulation/Simulation_Respawn_logic.lua
-- Logic: Handles dead faction cleanup and instantiating dynamic new factions.
-- ==============================================================================

local RespawnLogic = {}

require "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState"

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

local function resolveCountyKeyForFaction(faction)
    if type(faction) ~= "table" then
        return nil
    end

    local homeCoords = type(faction.homeCoords) == "table" and faction.homeCoords or nil
    local countyName = (homeCoords and homeCoords.county) or nil
    if (not countyName or countyName == "")
        and homeCoords
        and DT_GeolocatorSystem
        and DT_GeolocatorSystem.GetCountyName then
        countyName = DT_GeolocatorSystem.GetCountyName(homeCoords.x, homeCoords.y)
    end

    return normalizeTownKey(countyName)
end

function RespawnLogic.Process(data, factionsToRemove, Sandbox)
    -- Cleanup Dead Factions
    for _, deadID in ipairs(factionsToRemove) do
        local deadFaction = data[deadID]
        if deadFaction
            and deadFaction.playerOwned ~= true
            and deadID ~= "Independent"
            and DT_FactionRespawnState
            and DT_FactionRespawnState.RecordAbandonedHome then
            DT_FactionRespawnState.RecordAbandonedHome(deadID, deadFaction, "faction_wiped")
        end
        data[deadID] = nil
        DynamicTrading_Roster.ClearSouls(deadID) -- Remove their souls from Roster too
    end

    -- DYNAMIC RESPAWNING (Long game stability)
    if DT_FactionLocations then
        local respawnChance = Sandbox.FactionRespawnChance or 10
        local maxCountyFactions = Sandbox.MaxFactionsPerCounty or 9999

        for townID, townData in pairs(DT_FactionLocations) do
            local spawnTown = (type(townData) == "table" and townData.name) or townID
            local factionSeed = (type(townData) == "table" and townData.id) or townID
            local spawnCountyKey = normalizeTownKey(type(townData) == "table" and townData.county or nil)
            local spawnTownKey = normalizeTownKey(spawnTown) or normalizeTownKey(townID)
            local townBlocked = DT_FactionRespawnState
                and DT_FactionRespawnState.IsTownOnCooldown
                and DT_FactionRespawnState.IsTownOnCooldown(spawnTown)

            if not townBlocked then
                -- Count existing factions in this county.
                local countyCount = 0
                for _, f in pairs(data) do
                    if f
                        and f.excludeFromPopulationPool ~= true
                        and f.excludeFromFactionCap ~= true
                        and f.isSystemFaction ~= true
                        and f.systemFaction ~= true then
                        if spawnCountyKey and resolveCountyKeyForFaction(f) == spawnCountyKey then
                            countyCount = countyCount + 1
                        end
                    end
                end

                if (not spawnCountyKey or countyCount < maxCountyFactions)
                    and ZombRand(100) < respawnChance then
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
end

return RespawnLogic
