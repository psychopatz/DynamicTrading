-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_OwnedFaction.lua
-- Logic: Player-owned faction state and action handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local Helpers = context.Helpers
    local commandModule = context.COMMAND_MODULE
    local coloniesRequiredMessage = "Dynamic Colonies is required for player-made colony factions."

    local function coloniesAvailable()
        return DynamicTrading_Factions
            and DynamicTrading_Factions.IsDynamicColoniesEnabled
            and DynamicTrading_Factions.IsDynamicColoniesEnabled()
    end

    local function sendActionResult(player, ok, message, extra)
        extra = extra or {}
        extra.success = ok == true
        extra.message = message or (ok and "Faction action complete." or "Faction action failed.")
        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "OwnedFactionActionResult", extra)
    end

    local function runColonyAction(player, callback, fallbackMessage)
        if not coloniesAvailable() then
            Helpers.SyncOwnedFactionStatus(player)
            sendActionResult(player, false, coloniesRequiredMessage)
            return
        end

        local ok, message, _, details = callback()
        Helpers.SyncOwnedFactionStatus(player)
        Helpers.SyncOwnedFactionTargets(details)
        sendActionResult(player, ok, message or fallbackMessage)
    end

    Handlers.RequestOwnedFactionStatus = function(player, args)
        if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
            DynamicTrading_Factions.ResumeLeadership(player)
        end
        Helpers.SyncOwnedFactionStatus(player)
    end

    Handlers.CreatePlayerFaction = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.CreatePlayerFaction(player, args.name)
        end, "Faction creation failed.")
    end

    Handlers.RenamePlayerFaction = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.RenamePlayerFaction(player, args.name)
        end, "Faction rename failed.")
    end

    Handlers.InvitePlayerToFaction = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.InvitePlayerToFaction(player, args.username)
        end, "Faction invite updated.")
    end

    Handlers.AcceptFactionInvite = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.AcceptFactionInvite(player, args.factionID)
        end, "Faction invite handled.")
    end

    Handlers.DeclineFactionInvite = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.DeclineFactionInvite(player, args.factionID)
        end, "Faction invite handled.")
    end

    Handlers.LeavePlayerFaction = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.LeavePlayerFaction(player)
        end, "Faction membership updated.")
    end

    Handlers.KickFactionMember = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.KickFactionMember(
                player,
                args.username,
                args.workerTransferAction or args.workerPolicy
            )
        end, "Faction membership updated.")
    end

    Handlers.TransferFactionLeadership = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.TransferFactionLeadership(player, args.username)
        end, "Leadership transfer updated.")
    end

    Handlers.AbandonFactionLeadership = function(player, args)
        args = args or {}
        runColonyAction(player, function()
            return DynamicTrading_Factions.AbandonLeadership(player)
        end, "Leadership abandoned.")
    end

    Handlers.SetFactionWorkerTradeEligibility = function(player, args)
        args = args or {}
        if not coloniesAvailable() then
            Helpers.SyncOwnedFactionStatus(player)
            sendActionResult(player, false, coloniesRequiredMessage)
            return
        end
        local ok, message = DynamicTrading_Factions.SetWorkerTradeEligibility(player, args.workerID, args.enabled == true)
        Helpers.SyncOwnedFactionStatus(player)
        sendActionResult(player, ok, message or "Trade access updated.")
    end

    Handlers.DispatchFactionTrade = function(player, args)
        args = args or {}
        if not coloniesAvailable() then
            Helpers.SyncOwnedFactionStatus(player)
            sendActionResult(player, false, coloniesRequiredMessage)
            return
        end
        local ok, message, _, details = DynamicTrading_Factions.DispatchTrade(player, args.workerID, false)
        Helpers.SyncOwnedFactionStatus(player)
        sendActionResult(player, ok, message or "Dispatch complete.", {
            traderID = details and details.traderID or nil,
            traderBackend = details and details.backend or nil,
            discoverTrader = details and details.discoverTrader == true or false
        })
    end

    Handlers.RecallFactionTrader = function(player, args)
        args = args or {}
        if not coloniesAvailable() then
            Helpers.SyncOwnedFactionStatus(player)
            sendActionResult(player, false, coloniesRequiredMessage)
            return
        end
        local ok, message, _, details = DynamicTrading_Factions.RecallTrade(player, args.workerID, false)
        Helpers.SyncOwnedFactionStatus(player)
        sendActionResult(player, ok, message or "Trader recalled.", {
            traderID = details and details.traderID or nil,
            traderBackend = details and details.backend or nil,
            discoverTrader = false
        })
    end
end
