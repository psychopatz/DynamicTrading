-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_Shared.lua
-- Logic: Shared helpers for data handler modules
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local DataHandlers = context.DataHandlers
    local Helpers = context.Helpers
    local commandModule = context.COMMAND_MODULE

    function Helpers.SendPriceConfigToPlayer(player)
        local payload = DynamicTrading.PriceConfig.BuildSyncPayload(DynamicTrading.PriceConfig.GetData())
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "SyncPriceConfig", payload)
    end

    function Helpers.SendPriceConfigActionResult(player, success, message, warnings)
        DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "PriceConfigActionResult", {
            success = success == true,
            message = tostring(message or ""),
            warnings = warnings or {}
        })
    end

    function Helpers.SyncOwnedFactionStatus(player)
        if not player or not DynamicTrading_Factions or not DynamicTrading_Factions.GetOwnedFactionStatus then
            return
        end

        local status = DynamicTrading_Factions.GetOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncOwnedFactionStatus", {
            status = status
        })
    end

    function Helpers.FindOnlinePlayerByUsername(username)
        local target = tostring(username or "")
        if target == "" then
            return nil
        end

        local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
        if onlinePlayers then
            for index = 0, onlinePlayers:size() - 1 do
                local player = onlinePlayers:get(index)
                if player and player.getUsername and tostring(player:getUsername() or "") == target then
                    return player
                end
            end
        end
        return nil
    end

    function Helpers.SyncOwnedFactionStatusForUsername(username)
        local player = Helpers.FindOnlinePlayerByUsername(username)
        if player then
            Helpers.SyncOwnedFactionStatus(player)
        end
    end

    function Helpers.SyncOwnedFactionTargets(details)
        details = details or {}
        Helpers.SyncOwnedFactionStatusForUsername(details.targetUsername)
        Helpers.SyncOwnedFactionStatusForUsername(details.leaderUsername)
        Helpers.SyncOwnedFactionStatusForUsername(details.previousLeaderUsername)
    end

    function DataHandlers.SendPriceConfigToPlayer(player)
        Helpers.SendPriceConfigToPlayer(player)
    end

    function DataHandlers.SyncOwnedFactionStatus(player)
        Helpers.SyncOwnedFactionStatus(player)
    end
end
