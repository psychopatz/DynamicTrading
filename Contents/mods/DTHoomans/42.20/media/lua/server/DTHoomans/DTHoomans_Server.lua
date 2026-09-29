DTHoomans = DTHoomans or {}

local Service = DTCommon and DTCommon.TraderService
local MAX_DEBUG_ROW_DIAGNOSTICS = 32
local MAX_REFERRAL_REQUESTS = 64
local ReferralRequests = {}

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
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

local function send(player, command, payload)
    payload = payload or {}
    -- In singleplayer the server-side command path does not reliably loop
    -- sendServerCommand back through OnServerCommand. Mirror the same local
    -- delivery contract used by Project Hoomans before falling back to the
    -- normal multiplayer transport.
    if isLocalPlayer(player) and type(triggerEvent) == "function" then
        triggerEvent("OnServerCommand", DTHoomans.MOD_ID, command, payload)
        return true
    end
    if player and type(sendServerCommand) == "function" then
        sendServerCommand(player, DTHoomans.MOD_ID, command, payload)
        return true
    end
    if type(triggerEvent) == "function"
        and (not isServer or not isServer())
    then
        triggerEvent("OnServerCommand", DTHoomans.MOD_ID, command, payload)
        return true
    end
    return false
end

local function number(value, fallback)
    value = tonumber(value)
    return value or fallback or 0
end

local function safeID(value, limit)
    value = tostring(value or "")
    limit = tonumber(limit) or 128
    if value == "" or #value > limit or string.find(value, "%c") then
        return nil
    end
    return value
end

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

local function playerKey(player)
    if player and type(player.getUsername) == "function" then
        return tostring(player:getUsername())
    end
    if player and type(player.getOnlineID) == "function" then
        return tostring(player:getOnlineID())
    end
    return tostring(player)
end

local function claimReferral(player, requestID)
    local key = playerKey(player) .. ":" .. tostring(requestID)
    if ReferralRequests[key] then return false end
    local count = 0
    local existing
    for existing, _ in pairs(ReferralRequests) do count = count + 1 end
    if count >= MAX_REFERRAL_REQUESTS then ReferralRequests = {} end
    ReferralRequests[key] = true
    return true
end

local function findCaravanForMember(memberNPCID, requestedTraderID)
    local selectedTraderID
    local selectedRecord
    local selectedLeaderID
    local otherTraderID
    if not Service or type(Service.ForEach) ~= "function" then
        return nil, nil, nil, "trader_service_unavailable"
    end
    Service.ForEach(function(traderID, record)
        if selectedRecord or type(record) ~= "table" then return end
        local members = type(record.m) == "table" and record.m or {}
        local isMember = tostring(record.p or record.l or "")
            == tostring(memberNPCID)
        local index
        if not isMember then
            for index = 1, #members do
                if tostring(members[index]) == tostring(memberNPCID) then
                    isMember = true
                    break
                end
            end
        end
        if isMember then
            if not requestedTraderID
                or tostring(traderID) == tostring(requestedTraderID)
            then
                selectedTraderID = tostring(traderID)
                selectedRecord = record
                selectedLeaderID = tostring(record.p or record.l or "")
            else
                otherTraderID = tostring(traderID)
            end
        end
    end)
    if selectedRecord then
        return selectedTraderID, selectedRecord, selectedLeaderID
    end
    if otherTraderID then return nil, nil, nil, "trader_mismatch" end
    return nil, nil, nil, "caravan_member_not_found"
end

-- One canonical name resolver for the whole bridge:
-- DTHoomans.Caravan.ResolveNPCName reads the Project Hoomans record. The inline
-- chain below only runs when the caravan service did not load.
local function npcDisplayName(npcID)
    local caravan = DTHoomans and DTHoomans.Caravan or nil
    local name
    if caravan and type(caravan.ResolveNPCName) == "function" then
        name = caravan.ResolveNPCName(npcID)
    else
        local record = PNC and PNC.Registry and PNC.Registry.Get
            and PNC.Registry.Get(npcID) or nil
        local identity = PNC and PNC.Identity or nil
        local summary = identity
            and type(identity.GetCharacterSummary) == "function"
            and identity.GetCharacterSummary(record) or nil
        name = summary and summary.displayName
            or record and record.identity and record.identity.displayName
            or record and (record.displayName or record.name)
    end
    name = tostring(name or "")
    return name ~= "" and name or tostring(npcID or "the caravan trader")
end

local function discoverMerchantKnowledge(
    player, guardNPCID, merchantNPCID, requestID, choiceID,
    conversationToken
)
    local api = PNC and PNC.NPCKnowledgeAPI or nil
    if not api or type(api.DiscloseRelatedForPlayer) ~= "function" then
        return false, "related_knowledge_api_unavailable"
    end
    local result, reason = api.DiscloseRelatedForPlayer(
        player,
        guardNPCID,
        merchantNPCID,
        {
            topicID = "identity_name",
            requestID = requestID,
            conversationRequestID = requestID,
            requiredChoiceID = choiceID,
            conversationToken = conversationToken,
            origin = "conversation",
            worldAgeHours = worldAge(),
        }
    )
    if not result then return false, reason or "knowledge_discovery_failed" end
    if result.snapshot and PNC.Network
        and type(PNC.Network.SendNPCKnowledge) == "function"
    then
        PNC.Network.SendNPCKnowledge(
            player,
            result.snapshot,
            "dynamic_trading:caravan_referral"
        )
    end
    local learned = #(result.revealed or {}) > 0
    return learned, learned and "learned" or "already_known"
end

local function canUseDebug(player)
    local router = PNC and PNC.ServerCommandRouter
    return router and type(router.CanUseDebug) == "function"
        and router.CanUseDebug(player) == true
end

local function countMembers(faction, record)
    local count = 0
    local _
    if faction and type(faction.memberIDs) == "table" then
        for _, _ in pairs(faction.memberIDs) do count = count + 1 end
    elseif record and type(record.m) == "table" then
        count = #record.m
    end
    return count
end

local function leaderState(npcID)
    local record
    local body
    local x
    local y
    local z
    if not npcID or not PNC or not PNC.Registry then return {} end
    record = type(PNC.Registry.Get) == "function"
        and PNC.Registry.Get(npcID) or nil
    if not record then return {} end
    body = type(PNC.Registry.GetLiveZombie) == "function"
        and PNC.Registry.GetLiveZombie(npcID) or nil
    x = body and body.getX and body:getX() or record.x
    y = body and body.getY and body:getY() or record.y
    z = body and body.getZ and body:getZ() or record.z
    return {
        npcID = tostring(record.id or npcID),
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        z = tonumber(z) or 0,
        presence = tostring(record.presenceState or "unknown"),
        alive = record.alive ~= false,
    }
end

local function traderDebugRows()
    local output = {}
    local diagnosticCount = 0
    if not Service or type(Service.ForEach) ~= "function" then
        return output
    end
    Service.ForEach(function(traderID, record)
        local faction = record and record.g and PNC.Factions
            and PNC.Factions.Get(record.g) or nil
        local leaderID = record and (record.p or record.l)
            or faction and faction.leaderNPCID or nil
        local leader = leaderState(leaderID)
        local mobile = faction and faction.mobile or nil
        output[#output + 1] = {
            traderID = tostring(traderID),
            name = tostring(record and record.n or traderID),
            status = tostring(record and record.s or "UNKNOWN"),
            factionID = record and record.g and tostring(record.g) or nil,
            factionStatus = faction and tostring(faction.status) or "missing",
            leaderNPCID = leader.npcID or (leaderID and tostring(leaderID)),
            memberNPCIDs = type(record and record.m) == "table"
                and record.m or {},
            memberCount = countMembers(faction, record),
            x = leader.x or 0,
            y = leader.y or 0,
            z = leader.z or 0,
            presence = leader.presence or "unknown",
            alive = leader.alive ~= false,
            pathMode = mobile and tostring(mobile.pathMode) or "none",
            controlMode = mobile and tostring(mobile.controlMode) or "none",
            abstractAccess = record and record.a == 1 or false,
        }
        diagnosticCount = diagnosticCount + 1
        if diagnosticCount <= MAX_DEBUG_ROW_DIAGNOSTICS then
            log("INFO", "debug_trader_moddata trader=" .. tostring(traderID)
                .. " faction=" .. tostring(record and record.g)
                .. " leader=" .. tostring(record and record.l)
                .. " physical=" .. tostring(record and record.p)
                .. " members=" .. tostring(#((record and record.m) or {}))
                .. " factionStatus=" .. tostring(faction and faction.status)
                .. " mobile=" .. tostring(mobile ~= nil)
                .. " path=" .. tostring(mobile and mobile.pathMode)
                .. " control=" .. tostring(mobile and mobile.controlMode))
        end
    end)
    if diagnosticCount > MAX_DEBUG_ROW_DIAGNOSTICS then
        log("INFO", "debug_trader_moddata_truncated rows="
            .. tostring(diagnosticCount)
            .. " limit=" .. tostring(MAX_DEBUG_ROW_DIAGNOSTICS))
    end
    table.sort(output, function(left, right)
        return tostring(left.traderID) < tostring(right.traderID)
    end)
    return output
end

local function handleTraderReferral(player, args)
    local requestID = safeID(args and args.requestID, 160)
    local guardNPCID = safeID(args and args.guardNPCID)
    local conversationToken = safeID(args and args.conversationToken, 256)
    local requestedTraderID = safeID(args and args.traderID)
    local choiceID = safeID(args and args.choiceID)
    local traderID
    local record
    local merchantNPCID
    local reason
    local merchantName
    local learned
    local knowledgeReason
    if not requestID or not guardNPCID or not conversationToken
        or (choiceID ~= "trader_referral" and choiceID ~= "trade")
    then
        send(player, "TraderReferral", {
            accepted = false,
            guardNPCID = guardNPCID,
            reason = choiceID and "invalid_referral_choice"
                or "invalid_referral_request",
        })
        return true
    end
    if not claimReferral(player, requestID) then return true end
    traderID, record, merchantNPCID, reason = findCaravanForMember(
        guardNPCID, requestedTraderID)
    if not record then
        log("WARN", "conversation_referral_rejected guard=" .. guardNPCID
            .. " request=" .. requestID .. " reason=" .. tostring(reason))
        send(player, "TraderReferral", {
            accepted = false, guardNPCID = guardNPCID, reason = reason,
        })
        return true
    end
    if tostring(merchantNPCID) == tostring(guardNPCID) then
        reason = "merchant_has_no_referral"
        send(player, "TraderReferral", {
            accepted = false, guardNPCID = guardNPCID, reason = reason,
        })
        return true
    end
    learned, knowledgeReason = discoverMerchantKnowledge(
        player,
        guardNPCID,
        merchantNPCID,
        requestID,
        choiceID,
        conversationToken
    )
    if knowledgeReason ~= "learned" and knowledgeReason ~= "already_known" then
        log("WARN", "conversation_referral_rejected guard=" .. guardNPCID
            .. " request=" .. requestID .. " reason="
            .. tostring(knowledgeReason)
            .. " knowledgeReason=" .. tostring(knowledgeReason))
        send(player, "TraderReferral", {
            accepted = false,
            guardNPCID = guardNPCID,
            reason = knowledgeReason,
        })
        return true
    end
    merchantName = npcDisplayName(merchantNPCID)
    log("INFO", "conversation_referral_validated guard=" .. guardNPCID
        .. " trader=" .. tostring(traderID)
        .. " merchant=" .. tostring(merchantNPCID)
        .. " name=" .. merchantName
        .. " knowledge=" .. tostring(learned == true)
        .. " knowledgeReason=" .. tostring(knowledgeReason)
        .. " api=DiscloseRelatedForPlayer")
    send(player, "TraderReferral", {
        accepted = true,
        requestID = requestID,
        guardNPCID = guardNPCID,
        traderID = traderID,
        merchantNPCID = merchantNPCID,
        merchantName = merchantName,
        knowledgeLearned = learned == true,
        knowledgeReason = knowledgeReason,
    })
    return true
end

local function sendTraderDebugList(player, notice)
    local traders = traderDebugRows()
    local pending = DTHoomans.Caravan
        and DTHoomans.Caravan.GetPendingDebug
        and DTHoomans.Caravan.GetPendingDebug() or {}
    log("INFO", "debug_list_sent traders=" .. tostring(#traders)
        .. " pending=" .. tostring(#pending)
        .. " notice=" .. tostring(notice))
    send(player, "TraderDebugList", {
        traders = traders,
        pending = pending,
        notice = notice,
    })
end

local function teleportToTrader(player, traderID)
    local record
    local npcID
    local handler
    local internal
    local npc
    local x
    local y
    local z
    if not canUseDebug(player) then return false, "debug_denied" end
    traderID = tostring(traderID or "")
    record = Service and Service.GetRecord(traderID) or nil
    if not record then return false, "trader_not_found" end
    npcID = record.p or record.l
    if not npcID then return false, "trader_leader_missing" end

    handler = PNC and PNC.ServerDebugCommandHandler
    internal = handler and handler.Internal
    if internal and type(internal.TeleportPlayerToRecord) == "function" then
        if internal.TeleportPlayerToRecord(player, npcID) then
            return true
        end
    end

    npc = PNC and PNC.Registry and PNC.Registry.Get
        and PNC.Registry.Get(npcID) or nil
    if not npc then return false, "npc_not_found" end
    x = tonumber(npc.x) or 0
    y = tonumber(npc.y) or 0
    z = tonumber(npc.z) or 0
    if player.setX and player.setY and player.setZ then
        player:setX(x + 1.5)
        player:setY(y + 1.5)
        player:setZ(z)
        return true
    end
    return false, "teleport_unavailable"
end

local function spawnTrader(player, args, onComplete, onAccepted)
    local x
    local y
    local z
    if not canUseDebug(player) then
        return nil, "debug_denied"
    end
    if not DTHoomans.Caravan
        or type(DTHoomans.Caravan.Spawn) ~= "function"
    then
        return nil, "caravan_service_unavailable"
    end
    x = number(args and args.x, player and player:getX())
    y = number(args and args.y, player and player:getY())
    z = number(args and args.z, player and player:getZ())
    -- The debug request spawns a live caravan at the requested tile and marks it
    -- as a test caravan; the member count still comes from the sandbox option so
    -- debug and the roaming lifecycle cannot diverge.
    return DTHoomans.Caravan.Spawn(x, y, z, onComplete, onAccepted, {
        debug = true,
        presenceMode = "live",
    })
end

local function sendSpawnResult(player, ok, status, caravan)
    local snapshot
    local traderID = caravan and caravan.traderID or nil
    local npcID = caravan and caravan.leaderNPCID or nil
    if not ok or not traderID or not npcID then
        send(player, "TraderSpawned", {
            accepted = false,
            reason = status or "npc_spawn_failed",
        })
        return
    end
    snapshot = Service and Service.Snapshot
        and Service.Snapshot(traderID) or nil
    send(player, "TraderSpawned", {
        accepted = true,
        traderID = traderID,
        npcID = tostring(npcID),
        status = status,
        factionID = caravan.factionID,
        memberNPCIDs = caravan.memberIDs,
        snapshot = snapshot,
    })
    log("INFO", "spawn_completed trader=" .. tostring(traderID)
        .. " merchant=" .. tostring(npcID)
        .. " faction=" .. tostring(caravan.factionID)
        .. " members=" .. tostring(#(caravan.memberIDs or {})))
end

local function handleSpawn(player, args)
    local completed = false
    local function onAccepted(request)
        log("INFO", "spawn_request request=" .. tostring(request.requestID)
            .. " faction=" .. tostring(request.factionID)
            .. " status=" .. tostring(request.status))
        send(player, "TraderSpawnStarted", {
            accepted = true,
            requestID = request.requestID,
            factionID = request.factionID,
            status = request.status,
        })
    end
    local function onComplete(ok, status, caravan)
        if completed then return end
        completed = true
        if not ok then
            log("WARN", "spawn_failed reason=" .. tostring(status))
        end
        sendSpawnResult(player, ok, status, caravan)
    end
    local request, reason = spawnTrader(
        player, args, onComplete, onAccepted)
    if not request then
        log("WARN", "spawn_rejected reason=" .. tostring(reason))
        send(player, "TraderSpawned", {
            accepted = false,
            reason = reason,
        })
        return
    end
end

local function handleDebugCommand(player, command, args)
    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            reason = "debug_denied",
        })
        return true
    end
    if command == "DebugListTraders" then
        sendTraderDebugList(player, "refreshed")
        return true
    end
    if command == "DebugEnsureSettlementTraders" then
        local settlement = DTHoomans and DTHoomans.Settlement or nil
        local summary = settlement
            and type(settlement.EnsureBindings) == "function"
            and settlement.EnsureBindings() or nil
        log("INFO", "debug_ensure_settlement_traders bound="
            .. tostring(summary and summary.bound)
            .. " alreadyBound=" .. tostring(summary and summary.alreadyBound)
            .. " withoutTrader=" .. tostring(summary and summary.withoutTrader)
            .. " failed=" .. tostring(summary and summary.failed))
        send(player, "TraderDebugActionResult", {
            accepted = summary ~= nil,
            action = "ensure_settlement_traders",
            reason = summary ~= nil
                and "swept" or "settlement_service_unavailable",
        })
        sendTraderDebugList(player, "refreshed")
        return true
    end
    if command == "DebugRoamingTick" then
        local lifecycle = DTHoomans and DTHoomans.CaravanLifecycle or nil
        local summary = lifecycle
            and type(lifecycle.Tick) == "function"
            and lifecycle.Tick() or nil
        log("INFO", "debug_roaming_tick roaming="
            .. tostring(summary and summary.roaming)
            .. " spawned=" .. tostring(summary and summary.spawned)
            .. " skipped=" .. tostring(summary and summary.skipped))
        send(player, "TraderDebugActionResult", {
            accepted = summary ~= nil,
            action = "roaming_tick",
            reason = summary and "checked" or "lifecycle_unavailable",
        })
        sendTraderDebugList(player, "refreshed")
        return true
    end
    if command == "DebugTeleportTrader" then
        local ok
        local reason
        ok, reason = teleportToTrader(
            player, args and args.traderID or nil)
        send(player, "TraderDebugActionResult", {
            accepted = ok == true,
            action = "teleport",
            traderID = args and args.traderID or nil,
            reason = ok == true and "teleported" or reason,
        })
        return true
    end
    return false
end

local function onClientCommand(module, command, player, args)
    if module ~= DTHoomans.MOD_ID then return end
    args = type(args) == "table" and args or {}
    if command == DTHoomans.SPAWN_COMMAND then
        handleSpawn(player, args)
        return
    end
    if command == "TraderReferralRequest" then
        handleTraderReferral(player, args)
        return
    end
    handleDebugCommand(player, command, args)
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
then
    Events.OnClientCommand.Add(onClientCommand)
end

return DTHoomans
