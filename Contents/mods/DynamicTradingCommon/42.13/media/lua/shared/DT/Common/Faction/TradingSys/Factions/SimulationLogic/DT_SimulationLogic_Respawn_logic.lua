-- ==============================================================================
-- Simulation/Simulation_Respawn_logic.lua
-- Logic: Handles dead faction cleanup and instantiating dynamic new factions.
-- ==============================================================================

local RespawnLogic = {}

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
        
        for townName, _ in pairs(DT_FactionLocations) do
            -- Count existing factions in this town
            local count = 0
            for _, f in pairs(data) do
                if f.town == townName then count = count + 1 end
            end
            
            if count < maxFactions and ZombRand(100) < respawnChance then
                -- New faction arrives!
                local factionID = townName .. "_" .. tostring(100000 + ZombRand(900000))
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
