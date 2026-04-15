-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_RosterData.lua
-- Logic: Trader and roster data synchronization handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE

    -- [TRADER DATA REQUEST]
    Handlers.RequestTrader = function(player, args)
        local traderID = args.traderID
        local traderData = DynamicTrading_Roster.GetTrader(traderID)
        if traderData then
            local response = {
                id = traderID,
                visuals = traderData.visuals,
                factionID = traderData.factionID,
                homeCoords = traderData.homeCoords,
                isSpawned = traderData.isPhysicallySpawned
            }
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncTrader", response)
        end
    end

    -- [ROSTER DATA REQUEST (FOR RADAR)]
    Handlers.RequestRoster = function(player, args)
        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        local factionData = ModData.get("DynamicTrading_Factions") or {}
        local engineData = DynamicTrading_Engine.GetEngineData()

        -- Optimize Radar Roster: Only send souls that are currently Trading
        local minimalSouls = {}
        if rosterData.Souls then
            for uuid, soul in pairs(rosterData.Souls) do
                if soul.status == "Trading" then
                    minimalSouls[uuid] = soul
                end
            end
        end

        local minimalRoster = {
            FactionMembers = rosterData.FactionMembers,
            Souls = minimalSouls,
            Traders = rosterData.Traders
        }

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncRoster", {
            roster = minimalRoster,
            factions = factionData,
            globalEvents = engineData and engineData.EventSystem and engineData.EventSystem.activeEvents or {}
        })
    end
end
