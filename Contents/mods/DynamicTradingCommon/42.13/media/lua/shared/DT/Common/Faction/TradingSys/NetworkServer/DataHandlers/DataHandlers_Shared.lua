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

    function DataHandlers.SendPriceConfigToPlayer(player)
        Helpers.SendPriceConfigToPlayer(player)
    end

    function DataHandlers.SyncOwnedFactionStatus(player)
        Helpers.SyncOwnedFactionStatus(player)
    end
end
