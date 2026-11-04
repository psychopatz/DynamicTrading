DTHoomans = DTHoomans or {}
DTHoomans.Client = DTHoomans.Client or {}

local Client = DTHoomans.Client
Client.TraderByNPC = Client.TraderByNPC or {}
Client.ReferralRequests = Client.ReferralRequests or {}

local MAX_REFERRAL_REQUESTS = 64
local MAX_CONVERSATION_REQUESTS = 64
Client.PendingTraderConversations =
    Client.PendingTraderConversations or {}

local function showTraderToast(id, traderID, message, fallbackName)
    local toast = PsychopatzCore
        and PsychopatzCore.ActorNotifications
    if not toast then
        local ok, value = pcall(
            require,
            "PsychopatzCore/UI/PsychopatzActorNotificationToast"
        )
        if ok then toast = value end
    end
    if not toast or type(toast.Show) ~= "function" then return false end

    local view
    local presentation = DTCommon and DTCommon.TraderPresentation
    if presentation and type(presentation.GetTraderView) == "function" then
        view = presentation.GetTraderView(traderID, false)
    end
    local factionBadge
    if view and type(view.factionPresentation) == "table" then
        local faction = view.factionPresentation
        factionBadge = faction.badge or faction
    end
    toast.Show({
        id = id,
        actorID = view and view.actorID or nil,
        name = view and view.name or fallbackName or traderID
            or "Dynamic Trading",
        message = message,
        portraitSpec = view and view.portraitSpec or nil,
        factionBadge = factionBadge,
    })
    return true
end

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function traderConversationView(traderID)
    local presentation = DTCommon and DTCommon.TraderPresentation
    if presentation and type(presentation.GetTraderView) == "function" then
        return presentation.GetTraderView(traderID, false)
    end
    return nil
end

local function traderActorID(traderID, hintedActorID)
    if hintedActorID and tostring(hintedActorID) ~= "" then
        return tostring(hintedActorID)
    end
    local view = traderConversationView(traderID)
    if view and view.actorID then return tostring(view.actorID) end
    local service = DTCommon and DTCommon.TraderService
    local record = service and service.GetRecord
        and service.GetRecord(tostring(traderID or "")) or nil
    local ca = record and record.ca or nil
    return ca and ca.actorID and tostring(ca.actorID) or nil
end

function Client.RequestTraderConversation(traderID, options)
    traderID = tostring(traderID or "")
    options = type(options) == "table" and options or {}
    if traderID == "" then return false, "trader_required" end
    local current = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not current or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    local actorID = traderActorID(traderID, options.actorID)
    local stamp = getTimeInMillis and getTimeInMillis() or 0
    local requestID = "dthoomans:conversation:"
        .. traderID .. ":" .. tostring(stamp)
    local count = 0
    for _ in pairs(Client.PendingTraderConversations) do count = count + 1 end
    if count >= MAX_CONVERSATION_REQUESTS then
        Client.PendingTraderConversations = {}
    end
    Client.PendingTraderConversations[requestID] = {
        requestID = requestID,
        traderID = traderID,
        actorID = actorID,
        displayName = options.displayName,
        mode = options.mode or "physical",
        npcID = options.npcID,
    }
    sendClientCommand(current, DTHoomans.MOD_ID,
        "ConversationAccessRequest", {
            requestID = requestID,
            traderID = traderID,
            actorID = actorID,
            npcID = options.npcID,
            mode = options.mode or "physical",
        })
    return true, "access_requested"
end

function Client.HandleTraderConversationResult(args)
    args = type(args) == "table" and args or {}
    local requestID = tostring(args.requestID or "")
    local pending = Client.PendingTraderConversations[requestID]
    if not pending then
        local traderID = tostring(args.traderID or "")
        for key, value in pairs(Client.PendingTraderConversations) do
            if value.traderID == traderID then
                requestID = key
                pending = value
                break
            end
        end
    end
    if requestID ~= "" then
        Client.PendingTraderConversations[requestID] = nil
    end
    if args.accepted ~= true then
        Client.LastConversationResult = {
            accepted = false,
            reason = args.reason or "conversation_access_denied",
            traderID = args.traderID or pending and pending.traderID,
        }
        return false, Client.LastConversationResult.reason
    end

    local traderID = tostring(
        args.traderID or pending and pending.traderID or "")
    local actorID = traderActorID(
        traderID,
        args.actorID or pending and pending.actorID
    )
    if traderID == "" or not actorID then
        return false, "core_actor_required"
    end
    local Conversation = DTCommon and DTCommon.TraderConversation
    if not Conversation then
        local ok, value = pcall(
            require,
            "DTCommon/DTCommon_TraderConversation"
        )
        if ok then Conversation = value end
    end
    if not Conversation or type(Conversation.Open) ~= "function" then
        return false, "shared_conversation_unavailable"
    end
    local view = traderConversationView(traderID)
    local opened, reason = Conversation.Open(
        traderID,
        actorID,
        {
            mode = args.mode or pending and pending.mode or "physical",
            provider = "DTHoomans",
            providerState = "materialized",
            displayName = pending and pending.displayName
                or view and view.name,
        }
    )
    Client.LastConversationResult = {
        accepted = opened ~= nil,
        reason = opened and "conversation_opened" or reason,
        traderID = traderID,
        actorID = actorID,
        view = opened,
    }
    return opened ~= nil, Client.LastConversationResult.reason
end

local function mapDebugRows(rows)
    if type(rows) ~= "table" then return end
    for _, row in ipairs(rows) do
        if type(row) == "table" then
            Client.BindTrader(
                row.traderID,
                row.leaderNPCID,
                row.memberNPCIDs
            )
        end
    end
end

local function activeConversationView(npcID)
    local semantic = PNC and PNC.Semantics
        and PNC.Semantics.DialogueInput or nil
    local view = semantic and semantic.ActiveView or nil
    if view and tostring(view.spec and view.spec.npcID or "")
        == tostring(npcID or "")
    then
        return view
    end
    local group = semantic and semantic.groupConversation or nil
    if group and type(group.ViewFor) == "function" then
        view = group:ViewFor(npcID)
        if view then return view end
    end
    view = PsychopatzCore and PsychopatzCore.Conversation
        and PsychopatzCore.Conversation.instance or nil
    if view and tostring(view.spec and view.spec.npcID or "")
        == tostring(npcID or "")
    then
        return view
    end
    return nil
end

local function activeConversationToken(npcID)
    local view = activeConversationView(npcID)
    local context = view and view.spec and view.spec.context or nil
    local lifecycle = context and context.conversationLifecycleState or nil
    return lifecycle and tostring(lifecycle.token or "")
        or context and tostring(context.conversationToken or context.token or "")
        or nil
end

local function rememberReferralRequest(requestID)
    requestID = tostring(requestID or "")
    if requestID == "" then return true end
    if Client.ReferralRequests[requestID] then return false end
    local count = 0
    local key
    for key, _ in pairs(Client.ReferralRequests) do count = count + 1 end
    if count >= MAX_REFERRAL_REQUESTS then Client.ReferralRequests = {} end
    Client.ReferralRequests[requestID] = true
    return true
end

local function queueReferralMessage(args)
    local npcID = tostring(args.guardNPCID or "")
    local merchantName = tostring(args.merchantName or "the caravan trader")
    local view = activeConversationView(npcID)
    local session = view and view.session or nil
    if not session or type(session.queueMessage) ~= "function" then
        return false, "conversation_session_unavailable"
    end
    local template = DTCommon and DTCommon.T
        and DTCommon.T(
            "DTHoomans_GuardTraderReferral",
            "Our trader is %s. Ask %s to trade."
        ) or "Our trader is %s. Ask %s to trade."
    local message
    local formatted, formatResult = pcall(
        string.format, template, merchantName, merchantName)
    message = formatted and formatResult or (
        "Our trader is " .. merchantName .. ". Ask " .. merchantName
        .. " to trade."
    )
    session:queueMessage("npc", { text = message }, {
        source = "dynamic_trading",
        kind = "caravan_referral",
        traderID = args.traderID,
        merchantNPCID = args.merchantNPCID,
        knowledgeLearned = args.knowledgeLearned == true,
    })
    return true
end

local function onServerCommand(module, command, args)
    if module ~= DTHoomans.MOD_ID then
        return
    end
    args = type(args) == "table" and args or {}
    if command == "ConversationAccessResult" then
        local opened, reason = Client.HandleTraderConversationResult(args)
        if opened ~= true then
            log("WARN", "conversation_open_failed trader="
                .. tostring(args.traderID)
                .. " reason=" .. tostring(reason))
        end
        return
    end
    if command == "TraderDebugList" then
        Client.RefreshTraderMap()
        mapDebugRows(args.traders)
        log("INFO", "debug_list_received traders="
            .. tostring(type(args.traders) == "table" and #args.traders or 0)
            .. " pending="
            .. tostring(type(args.pending) == "table" and #args.pending or 0)
            .. " notice=" .. tostring(args.notice))
        Client.LastDebugList = args
        if DTCommon and DTCommon.TraderManager
            and type(DTCommon.TraderManager.SetResult) == "function"
        then
            DTCommon.TraderManager.SetResult(
                tostring(args.notice or "Trader state refreshed"), args)
        end
        return
    end
    if command == "TraderDebugActionResult" then
        log("INFO", "debug_action action=" .. tostring(args.action)
            .. " accepted=" .. tostring(args.accepted)
            .. " reason=" .. tostring(args.reason)
            .. " trader=" .. tostring(args.traderID))
        if DTCommon and DTCommon.TraderManager
            and type(DTCommon.TraderManager.SetResult) == "function"
        then
            DTCommon.TraderManager.SetResult(
                tostring(args.action or "Trader action") .. ": "
                    .. tostring(args.reason or "completed"),
                args)
        end
        return
    end
    if command == "TraderReferral" then
        if args.accepted ~= true then
            log("WARN", "conversation_trade_referral_failed guard="
                .. tostring(args.guardNPCID)
                .. " reason=" .. tostring(args.reason))
            return
        end
        local appended, appendReason = queueReferralMessage(args)
        log("INFO", "conversation_trade_referral guard="
            .. tostring(args.guardNPCID)
            .. " trader=" .. tostring(args.traderID)
            .. " merchant=" .. tostring(args.merchantNPCID)
            .. " name=" .. tostring(args.merchantName)
            .. " knowledge=" .. tostring(args.knowledgeLearned == true)
            .. " appended=" .. tostring(appended == true))
        if appended ~= true then
            log("WARN", "conversation_trade_referral_ui_failed guard="
                .. tostring(args.guardNPCID)
                .. " reason=" .. tostring(appendReason))
        end
        return
    end
    if command == "TraderSpawnStarted" then
        log("INFO", "spawn_started request=" .. tostring(args.requestID)
            .. " faction=" .. tostring(args.factionID))
        showTraderToast(
            "dthoomans:spawn:" .. tostring(args.requestID or "unknown")
                .. ":started",
            args.traderID,
            "Trader caravan spawn queued.",
            "Trader caravan"
        )
        return
    end
    if command ~= "TraderSpawned" then return end
    if args.accepted == true and args.traderID and args.npcID then
        Client.BindTrader(args.traderID, args.npcID, args.memberNPCIDs)
        if args.snapshot and DTCommon and DTCommon.Client then
            DTCommon.Client.Snapshots[tostring(args.traderID)] = args.snapshot
        end
        log("INFO", "spawn_completed trader=" .. tostring(args.traderID)
            .. " merchant=" .. tostring(args.npcID)
            .. " faction=" .. tostring(args.factionID)
            .. " members=" .. tostring(#(args.memberNPCIDs or {})))
        showTraderToast(
            "dthoomans:spawn:" .. tostring(args.traderID or "unknown")
                .. ":completed",
            args.traderID,
            "Trader caravan arrived and is ready to trade.",
            "Trader caravan"
        )
    elseif args.accepted == false then
        log("WARN", "spawn_failed reason=" .. tostring(args.reason))
        showTraderToast(
            "dthoomans:spawn:failed:" .. tostring(args.reason or "unknown"),
            args.traderID,
            "Trader caravan spawn failed: "
                .. tostring(args.reason or "unknown"),
            "Trader caravan"
        )
    end
end

-- Project Hoomans owns conversation authority and NPC presentation. Dynamic
-- Trading trader leaders use the shared DTCommon opener before this native
-- outcome bridge; this listener retains only the Hoomans-only guard referral
-- disclosure path.
local function onConversationOutcome(module, command, args)
    local pncModule = PNC and PNC.Const and PNC.Const.MODULE
        or "ProjectHoomans"
    local outcomeCommand = PNC and PNC.Const
        and PNC.Const.CMD_CONVERSATION_OUTCOME or "ConversationOutcome"
    local npcID
    local traderID
    local merchantNPCID
    local conversationToken
    local current
    local requestID
    local choiceID
    if module ~= pncModule or command ~= outcomeCommand then return end
    args = type(args) == "table" and args or {}
    choiceID = tostring(args.choiceID or "")
    if args.success ~= true or choiceID ~= "trader_referral" then
        return
    end
    npcID = tostring(args.npcID or "")
    traderID = Client.GetConversationTraderID(npcID)
    merchantNPCID = Client.GetTraderLeaderID(traderID) or npcID
    log("INFO", "conversation_outcome npc=" .. npcID
        .. " trader=" .. tostring(traderID)
        .. " merchant=" .. tostring(merchantNPCID)
        .. " choice=" .. choiceID
        .. " success=" .. tostring(args.success))
    if not traderID then
        log("WARN", "conversation_referral_unmapped npc=" .. npcID)
        return
    end
    if merchantNPCID ~= npcID then
        log("INFO", "conversation_referral_redirected npc=" .. npcID
            .. " merchant=" .. merchantNPCID
            .. " trader=" .. tostring(traderID))
        requestID = tostring(args.requestID or "")
        if not rememberReferralRequest(requestID) then return end
        conversationToken = activeConversationToken(npcID)
        current = getSpecificPlayer and getSpecificPlayer(0) or nil
        if not current or type(sendClientCommand) ~= "function"
            or not conversationToken or conversationToken == ""
        then
            log("WARN", "conversation_trade_referral_request_failed guard="
                .. npcID .. " reason=conversation_token_unavailable")
            return
        end
        sendClientCommand(current, DTHoomans.MOD_ID,
            "TraderReferralRequest", {
                requestID = requestID,
                guardNPCID = npcID,
                traderID = traderID,
                choiceID = choiceID,
                conversationToken = conversationToken,
            })
        log("INFO", "conversation_referral_requested guard="
            .. npcID .. " trader=" .. tostring(traderID)
            .. " choice=" .. choiceID .. " request=" .. requestID)
        return
    end
    log("WARN", "conversation_referral_invalid_merchant npc=" .. npcID)
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
then
    Events.OnServerCommand.Add(onServerCommand)
    Events.OnServerCommand.Add(onConversationOutcome)
end
if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
then
    Events.OnGameStart.Add(Client.RefreshTraderMap)
end

return Client
