-- ==============================================================================
-- DTNPC_ServerCoreCommands_TraderVisit.lua
-- Trader visit request handler for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Handlers = DTNPCServerCoreCommands.Handlers

Handlers.RequestTraderVisit = function(player, args)
    if not player or not args or not args.uuid then
        return
    end

    local uuid = tostring(args.uuid)
    local registry = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(uuid) or nil
    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or registry
    if not registry or not soul then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "RequestTraderVisit failed, unknown trader: " .. uuid)
        return
    end

    if tostring(registry.status or soul.status or "") ~= "Resting" then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "RequestTraderVisit denied, trader not resting: " .. uuid)
        return
    end

    local targetX = tonumber(args.x) or player:getX()
    local targetY = tonumber(args.y) or player:getY()
    local targetZ = tonumber(args.z) or player:getZ() or 0
    local walkHours = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
    local currentHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
    local username = player:getUsername()
    local onlineID = player.getOnlineID and player:getOnlineID() or nil
    local requestBackend = tostring(args.requestBackend or "")

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Command",
        "RequestTraderVisit received uuid=" .. tostring(uuid)
            .. " backend=" .. tostring(requestBackend ~= "" and requestBackend or "DynamicTradingV2")
            .. " requester=" .. tostring(username)
            .. " target=" .. tostring(targetX) .. "," .. tostring(targetY) .. "," .. tostring(targetZ)
    )

    soul.travelTarget = {
        x = targetX,
        y = targetY,
        z = targetZ,
        status = "Trading",
    }
    soul.lastContactRequester = player:getUsername()
    soul.contactVisitActive = true
    soul.contactVisitMode = "Departure"
    soul.contactVisitBackend = requestBackend ~= "" and requestBackend or nil
    soul.master = nil
    soul.masterID = nil
    soul.tasks = {}
    soul.requestedReturnStatus = nil
    soul.combatTargetID = nil
    soul.combatOrder = nil
    soul.guardCombatOrder = nil
    soul.guardAttackMode = nil
    soul.guardReturningToPost = nil
    soul.anchorX = nil
    soul.anchorY = nil
    soul.anchorZ = nil
    soul.stationaryPostX = nil
    soul.stationaryPostY = nil
    soul.stationaryPostZ = nil
    soul.stationaryPostState = nil
    soul.contactVisitRequestedBy = username
    soul.contactVisitRequestedByID = onlineID
    soul.contactVisitTargetX = targetX
    soul.contactVisitTargetY = targetY
    soul.contactVisitTargetZ = targetZ
    soul.contactVisitStartedAt = currentHours
    soul.contactVisitReturnStatus = "Resting"
    DynamicTrading_Roster.SaveSoul(uuid, soul)

    if DTNPCManager and DTNPCManager.SetNPCStatus then
        DTNPCManager.SetNPCStatus(uuid, "Away", currentHours + walkHours, "Trading")
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Logic",
            "RequestTraderVisit queued away->trading for " .. tostring(soul.name or uuid)
                .. " backend=" .. tostring(soul.contactVisitBackend or "DynamicTradingV2")
                .. " etaHours=" .. tostring(walkHours)
        )
    end
end
