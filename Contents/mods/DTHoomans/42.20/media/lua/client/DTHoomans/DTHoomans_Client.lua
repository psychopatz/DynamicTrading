DTHoomans = DTHoomans or {}
DTHoomans.Client = DTHoomans.Client or {}

local Client = DTHoomans.Client
Client.TraderByNPC = Client.TraderByNPC or {}
Client.ReferralRequests = Client.ReferralRequests or {}

local MAX_REFERRAL_REQUESTS = 64

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
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
    if command == "TraderDebugList" then
        Client.RefreshTraderMap()
        mapDebugRows(args.traders)
        log("INFO", "debug_list_received traders="
            .. tostring(type(args.traders) == "table" and #args.traders or 0)
            .. " pending="
            .. tostring(type(args.pending) == "table" and #args.pending or 0)
            .. " notice=" .. tostring(args.notice))
        if DTHoomans.DebugTraderWindow then
            DTHoomans.DebugTraderWindow.SetData(
                args.traders, args.pending, args.notice)
        end
        return
    end
    if command == "TraderDebugActionResult" then
        log("INFO", "debug_action action=" .. tostring(args.action)
            .. " accepted=" .. tostring(args.accepted)
            .. " reason=" .. tostring(args.reason)
            .. " trader=" .. tostring(args.traderID))
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
    elseif args.accepted == false then
        log("WARN", "spawn_failed reason=" .. tostring(args.reason))
    end
end

-- Project Hoomans owns conversation authority and NPC presentation. The
-- merchant's native `trade` choice opens DynamicTrading's commerce window;
-- a guard's separate referral choice only requests the authoritative name
-- disclosure path and can never open that window.
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
    local opened
    local reason
    if module ~= pncModule or command ~= outcomeCommand then return end
    args = type(args) == "table" and args or {}
    choiceID = tostring(args.choiceID or "")
    if args.success ~= true
        or (choiceID ~= "trade" and choiceID ~= "trader_referral")
    then
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
        log("WARN", "conversation_trade_unmapped npc=" .. npcID)
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
    if choiceID ~= "trade" then
        log("WARN", "conversation_referral_invalid_merchant npc=" .. npcID)
        return
    end
    if not DTCommon or not DTCommon.Client
        or type(DTCommon.Client.OpenTrader) ~= "function"
    then
        log("WARN", "conversation_trade_unavailable trader=" .. traderID)
        return
    end
    opened, reason = DTCommon.Client.OpenTrader(traderID, {
        mode = "trade",
        npcID = merchantNPCID,
    })
    if opened ~= true and reason then
        log("WARN", "conversation_trade_open_failed trader=" .. traderID
            .. " reason=" .. tostring(reason))
    end
end

local function onFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test or not context then return end
    if DTHoomans.DebugSpawnMenu then
        DTHoomans.DebugSpawnMenu.Add(context, playerNum, worldObjects)
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
then
    Events.OnServerCommand.Add(onServerCommand)
    Events.OnServerCommand.Add(onConversationOutcome)
end
if Events and Events.OnFillWorldObjectContextMenu
    and type(Events.OnFillWorldObjectContextMenu.Add) == "function"
then
    Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
end
if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
then
    Events.OnGameStart.Add(Client.RefreshTraderMap)
end

return Client
