-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_FactionData.lua
-- Logic: Faction data synchronization handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE

    -- [FACTION DATA REQUEST]
    -- Shared by the player-facing Faction Intelligence window and the admin debug UI.
    Handlers.RequestFactionData = function(player, args)
        if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
            DynamicTrading_Factions.ResumeLeadership(player)
        end

        local factionData = ModData.get("DynamicTrading_Factions") or {}
        local rosterData = ModData.get("DynamicTrading_Roster") or {}

        -- Keep the initial payload light: member registries plus only actively trading souls.
        local filteredSouls = {}
        if rosterData.Souls then
            for uuid, soul in pairs(rosterData.Souls) do
                if soul.status == "Trading" then
                    filteredSouls[uuid] = soul
                end
            end
        end

        local minimalRoster = {
            FactionMembers = rosterData.FactionMembers or {},
            Souls = filteredSouls
        }

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionDebugData", {
            factions = factionData,
            roster = minimalRoster,
            ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
        })
    end

    -- [ON-DEMAND ROSTER REQUEST]
    -- Shared by Radar/Common UIs when they need a faction's full soul list.
    Handlers.RequestFactionRoster = function(player, args)
        local factionID = args.factionID
        if not factionID then
            return
        end

        local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
        if faction and faction.playerOwned then
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionRoster", {
                factionID = factionID,
                members = {},
                souls = {},
                ownedStatus = DynamicTrading_Factions.GetOwnedFactionStatus(player)
            })
            return
        end

        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID] or {}

        local factionSouls = {}
        if rosterData.Souls then
            for _, uuid in ipairs(members) do
                if rosterData.Souls[uuid] then
                    factionSouls[uuid] = rosterData.Souls[uuid]
                end
            end
        end

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionRoster", {
            factionID = factionID,
            members = members,
            souls = factionSouls,
            ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
        })
    end
end
