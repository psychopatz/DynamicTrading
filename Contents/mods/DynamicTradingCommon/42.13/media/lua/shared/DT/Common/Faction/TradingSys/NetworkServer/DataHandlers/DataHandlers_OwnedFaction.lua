-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_OwnedFaction.lua
-- Logic: Player-owned faction state and action handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local Helpers = context.Helpers
    local commandModule = context.COMMAND_MODULE

    Handlers.RequestOwnedFactionStatus = function(player, args)
        if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
            DynamicTrading_Factions.ResumeLeadership(player)
        end
        Helpers.SyncOwnedFactionStatus(player)
    end

    Handlers.CreatePlayerFaction = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.CreatePlayerFaction(player, args.name)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or (ok and "Faction created." or "Faction creation failed.")
        })
    end

    Handlers.InvitePlayerToFaction = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.InvitePlayerToFaction(player, args.username)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Faction invite updated."
        })
    end

    Handlers.AcceptFactionInvite = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.AcceptFactionInvite(player, args.factionID)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Faction invite handled."
        })
    end

    Handlers.DeclineFactionInvite = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.DeclineFactionInvite(player, args.factionID)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Faction invite handled."
        })
    end

    Handlers.LeavePlayerFaction = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.LeavePlayerFaction(player)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Faction membership updated."
        })
    end

    Handlers.KickFactionMember = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.KickFactionMember(player, args.username)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Faction membership updated."
        })
    end

    Handlers.SetFactionWorkerTradeEligibility = function(player, args)
        args = args or {}
        local ok, message = DynamicTrading_Factions.SetWorkerTradeEligibility(player, args.workerID, args.enabled == true)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Trade access updated."
        })
    end

    Handlers.DispatchFactionTrade = function(player, args)
        args = args or {}
        local ok, message, _, details = DynamicTrading_Factions.DispatchTrade(player, args.workerID, false)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Dispatch complete.",
            traderID = details and details.traderID or nil,
            traderBackend = details and details.backend or nil,
            discoverTrader = details and details.discoverTrader == true or false
        })
    end

    Handlers.RecallFactionTrader = function(player, args)
        args = args or {}
        local ok, message, _, details = DynamicTrading_Factions.RecallTrade(player, args.workerID, false)
        Helpers.SyncOwnedFactionStatus(player)
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", {
            success = ok == true,
            message = message or "Trader recalled.",
            traderID = details and details.traderID or nil,
            traderBackend = details and details.backend or nil,
            discoverTrader = false
        })
    end
end
