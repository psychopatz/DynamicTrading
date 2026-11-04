-- Server-authoritative command handler and debug actions for DTAbstract.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

DTAbstract = DTAbstract or {}
DTAbstract.Server = DTAbstract.Server or {}

local Server = DTAbstract.Server
local TraderWorld = DTCommon and DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"
local TraderRuntime = DTCommon and DTCommon.TraderWorldRuntime
local Provider = DTAbstract.TraderWorldProvider
    or require "DTAbstract/DTAbstract_TraderWorldProvider"
local SurvivorRuntime = DTAbstract.SurvivorWorldRuntime
    or require "DTAbstract/DTAbstract_SurvivorWorldRuntime"

local function log(level, message)
    print("[DTAbstract][" .. tostring(level) .. "] " .. tostring(message))
end

local function canUseDebug(player)
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    if isServer and isServer() then
        if type(player.getAccessLevel) == "function" then
            local access = player:getAccessLevel()
            return access ~= nil and access ~= "" and access ~= "None"
        end
    end
    return true
end

local function isLocalPlayer(player)
    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer ~= nil and player == localPlayer then return true end
    if player and type(player.isLocalPlayer) == "function" then
        local ok, value = pcall(player.isLocalPlayer, player)
        return ok and value == true
    end
    return false
end

local function sendModule(player, module, command, payload)
    payload = payload or {}
    -- Singleplayer does not reliably loop a server command through
    -- OnServerCommand. Mirror the provider bridges so an authorized Talk
    -- request reaches the same shared Core conversation path immediately.
    if isLocalPlayer(player) and type(triggerEvent) == "function" then
        triggerEvent("OnServerCommand", module, command, payload)
        return true
    end
    if type(sendServerCommand) == "function" then
        sendServerCommand(player, module, command, payload)
        return true
    elseif type(triggerEvent) == "function" then
        triggerEvent("OnServerCommand", module, command, payload)
        return true
    end
    return false
end

local function send(player, command, payload)
    sendModule(player, "DTAbstract", command, payload)
end

local function conversationActorID(record, requestedID)
    local ca = record and record.ca or nil
    local leaderID = ca and tostring(ca.actorID or "") or ""
    requestedID = tostring(requestedID or "")
    if requestedID == "" then
        return leaderID ~= "" and leaderID or nil
    end
    if requestedID == leaderID then return requestedID end
    for _, memberID in ipairs(record and record.m or {}) do
        if tostring(memberID) == requestedID then return requestedID end
    end
    return nil
end


local function resolveTeleport()
    if PsychopatzCore and PsychopatzCore.Teleport then
        return PsychopatzCore.Teleport
    end
    local loaded, teleport = pcall(require, "PsychopatzCore/World/PsychopatzTeleport")
    if loaded and type(teleport) == "table" then return teleport end
    return nil
end

function Server.TeleportPlayerToTrader(player, traderID)
    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "not_authorized",
        })
        return false, "not_authorized"
    end

    traderID = tostring(traderID or "")
    local record = DTCommon and DTCommon.TraderService and DTCommon.TraderService.GetRecord(traderID)
    if not record or not record.ca then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "trader_not_found",
        })
        return false, "trader_not_found"
    end

    local pos, positionReason = Provider.getPosition(
        traderID,
        record
    )
    if not pos then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = positionReason or "trader_position_unavailable",
        })
        return false, positionReason or "trader_position_unavailable"
    end

    local teleport = resolveTeleport()
    if not teleport or type(teleport.ToCoordinates) ~= "function" then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "teleport_service_unavailable",
        })
        return false, "teleport_service_unavailable"
    end

    local ok, reason = teleport.ToCoordinates(player, pos.x + 1.5, pos.y + 1.5, pos.z)
    send(player, "TraderDebugActionResult", {
        accepted = ok == true,
        action = "teleport",
        reason = ok and "teleported" or (reason or "teleport_failed"),
        traderID = traderID,
    })
    return ok, reason
end

local function authorizeConversation(player, args)
    args = type(args) == "table" and args or {}
    local traderID = tostring(args.traderID or "")
    local mode = tostring(args.mode or "radio")
    local service = DTCommon and DTCommon.TraderService or nil
    local record = service
        and type(service.GetRecord) == "function"
        and service.GetRecord(traderID) or nil
    local requestedActorID = args.actorID or args.npcID
    local actorID = conversationActorID(record, requestedActorID)
    local accepted = false
    local reason

    if traderID == "" or not record or not conversationActorID(record) then
        reason = "trader_not_found"
    elseif tostring(requestedActorID or "") ~= "" and not actorID then
        reason = "conversation_actor_invalid"
    elseif mode == "debug" then
        if not canUseDebug(player) then
            reason = "not_authorized"
        else
            accepted = true
        end
    elseif mode == "radio" or mode == "nearby" or mode == "map" then
        if not service
            or type(service.ValidateTalkAccess) ~= "function"
        then
            reason = "trader_access_service_unavailable"
        else
            accepted, reason =
                service.ValidateTalkAccess(
                    player,
                    traderID,
                    mode,
                    requestedActorID
                )
        end
    else
        reason = "conversation_mode_invalid"
    end

    -- Conversation presentation is Core-owned for DTAbstract. The server
    -- only authorizes the channel here; no ProjectHoomans runtime view,
    -- lease, body, or registry record is created.
    send(player, "ConversationAccessResult", {
        accepted = accepted == true,
        reason = accepted
            and "core_conversation_authorized"
            or (reason or "conversation_access_denied"),
        traderID = traderID,
        actorID = actorID,
        mode = mode,
    })
    return accepted == true, reason
end

local function onClientCommand(module, command, player, args)
    if module ~= "DTAbstract" then return end
    args = type(args) == "table" and args or {}

    if command == "ConversationAccessRequest" then
        authorizeConversation(player, args)
        return
    end
    -- Debug and RadioOS use the same server-authorized Core conversation
    -- bridge. DTAbstract never enters ProjectHoomans conversation authority.

    if command == "ForceTick" then
        local summary = TraderRuntime
            and type(TraderRuntime.Tick) == "function"
            and TraderRuntime.Tick(true, args.now)
            or TraderWorld.Tick(true, args.now)
            send(player, "TraderDebugActionResult", {
            accepted = summary ~= nil,
            action = "force_tick",
            reason = "ticked",
            summary = summary,
        })
        return
    end

    if command == "ForceArrival" then
        local traderID = args.traderID
        local record = DTCommon.TraderService.GetRecord(traderID)
        if not record or not record.ca then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "force_arrival",
                reason = "trader_not_found",
            })
            return
        end

        local group = SurvivorRuntime.FindGroupForActor(
            record.ca.actorID
        )
        local journey = group and group.journey
        if not journey or journey.state ~= "en_route" then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "force_arrival",
                reason = "journey_not_en_route",
            })
            return
        end

        -- Advance the canonical group journey past its ETA.
        local destTime = (tonumber(journey.eta) or 0) + 1
        local status = TraderWorld.AdvanceTrader(traderID, destTime)
            send(player, "TraderDebugActionResult", {
            accepted = status == "arrived",
            action = "force_arrival",
            reason = status == "arrived" and "arrived" or "arrival_failed",
            traderID = traderID,
        })
        return
    end

    if command == "TeleportToTrader" then
        Server.TeleportPlayerToTrader(player, args.traderID)
        return
    end

    if command == "MaterializeTrader" then
        -- DTAbstract's representation contract is permanently bodyless.
        -- Hoomans parity is provided by the transient logical runtime view,
        -- never by spawning a visible NPC.
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "materialize",
            reason = "abstract_provider_permanently_abstract",
            traderID = args.traderID,
        })
        return
    end

    if command == "DematerializeTrader" then
        send(player, "TraderDebugActionResult", {
            accepted = true,
            action = "dematerialize",
            reason = "already_abstract",
            traderID = args.traderID,
        })
        return
    end

    if command == "RemoveTrader" then
        local traderID = args.traderID
        local record = DTCommon.TraderService.GetRecord(traderID)
        if not record then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "remove_trader",
                reason = "trader_not_found",
            })
            return
        end

        local released, releaseReason = Provider.releaseTrader(
            traderID,
            record
        )
        if released == false then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "remove_trader",
                reason = releaseReason or "provider_release_failed",
                traderID = traderID,
            })
            return
        end

        DTCommon.TraderService.Remove(traderID)
        send(player, "TraderDebugActionResult", {
            accepted = true,
            action = "remove_trader",
            reason = "commercial_role_removed",
            traderID = traderID,
        })
        return
    end
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
    and not Server.CommandHookRegistered
then
    Server.CommandHookRegistered = true
    Events.OnClientCommand.Add(onClientCommand)
end

return Server
