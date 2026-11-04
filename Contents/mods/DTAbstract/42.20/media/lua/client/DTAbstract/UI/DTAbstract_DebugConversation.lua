require "PsychopatzCore/UI/Conversation/PsychopatzConversation"
require "PsychopatzCore/UI/Conversation/Parts/PsychopatzConversationLLMInput"

DTAbstract = DTAbstract or {}
DTAbstract.DebugConversation = DTAbstract.DebugConversation or {}

local Manager = DTAbstract.DebugConversation
Manager.active = Manager.active or nil

local function client()
    return DTCommon and DTCommon.Client or nil
end

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function portraitSpec(item)
    local portrait = type(item and item.portrait) == "table"
        and item.portrait or nil
    local face = portrait and type(portrait.face) == "table"
        and portrait.face or {}
    local gender = portrait and tostring(portrait.gender or "") or ""
    return {
        id = tostring(item and item.actorID or item and item.traderID or "trader"),
        identitySeed = tostring(
            item and item.actorID or item and item.traderID or "trader"
        ),
        isFemale = gender == "female" or gender == "Female",
        faceOnly = true,
        preferDescriptor = true,
        appearance = {
            skinTexture = face.skinTexture,
            skinColor = face.skinColor,
            hairModel = face.hairModel,
            hairColor = face.hairColor,
            beardModel = face.beardModel,
        },
    }
end

local function refreshInput(view)
    local input = view
        and view.extensionParts
        and view.extensionParts.llmInput or nil
    if input and type(input.refreshControls) == "function" then
        input:refreshControls()
    end
end

local function stateFor(view)
    local active = Manager.active
    if not active or active.view ~= view then
        return {
            visible = true,
            enabled = false,
            statusText = "Remote debug session unavailable.",
            sendTitle = "SEND",
        }
    end
    if active.pending == true then
        return {
            visible = true,
            enabled = false,
            statusText = "Waiting for trader response...",
            sendTitle = "SEND",
        }
    end
    if not active.sessionID or active.sessionID == "" then
        return {
            visible = true,
            enabled = false,
            statusText = "Opening remote debug conversation...",
            sendTitle = "SEND",
        }
    end
    return {
        visible = true,
        enabled = true,
        statusText =
            "DEBUG REMOTE TALK — proximity/radio access simulated",
        sendTitle = "SEND",
    }
end

local function appendTraderResponses(active, result)
    local view = active and active.view or nil
    local session = view and view.session or nil
    if not session or type(result) ~= "table" then return false end

    local responses = type(result.responses) == "table"
        and result.responses or {}
    local appended = false
    for index = 1, #responses do
        local row = responses[index]
        local text = type(row) == "table"
            and (row.text or row.fallback) or row
        if text and tostring(text) ~= "" then
            session:queueMessage("npc", tostring(text), {
                source = "dynamictrading_debug",
            })
            appended = true
        end
    end
    if not appended and result.text and tostring(result.text) ~= "" then
        session:queueMessage("npc", tostring(result.text), {
            source = "dynamictrading_debug",
        })
        appended = true
    end
    return appended
end

local function submit(view, value)
    local active = Manager.active
    local api = client()
    if not active or active.view ~= view
        or not active.sessionID or active.sessionID == ""
        or active.pending == true
        or not api or type(api.SubmitTalk) ~= "function"
    then
        return false
    end

    value = tostring(value or "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return false end

    local accepted = api.SubmitTalk(
        active.traderID,
        active.sessionID,
        value,
        active.mode
    )
    if accepted ~= true then return false end

    if view.session and type(view.session.append) == "function" then
        view.session:append("player", value, {
            source = "dynamictrading_debug",
        })
    end
    active.pending = true
    refreshInput(view)
    return true
end

local function createInput(bounds, options)
    options = options or {}
    local definition = options.definition or {}
    return PsychopatzConversationLLMInput:new(
        bounds.x,
        bounds.y,
        bounds.width,
        bounds.height,
        {
            owner = options.owner,
            partID = options.partID or "llmInput",
            title = definition.title or {
                fallback = "TYPE TO TALK",
            },
            submit = submit,
            getState = stateFor,
            maxInputLength = 800,
            submitOnEnter = true,
            multiline = true,
            sendTitle = "SEND",
        }
    )
end

local function closeRemote(active)
    local api = client()
    if active and active.sessionID and active.sessionID ~= ""
        and api and type(api.CloseTalk) == "function"
    then
        api.CloseTalk(
            active.traderID,
            active.sessionID,
            active.mode
        )
    end
end

local function lifecycle()
    return {
        finish = function(view)
            local active = Manager.active
            if active and active.view == view then
                closeRemote(active)
                Manager.active = nil
            end
        end,
    }
end

function Manager.Open(item)
    item = type(item) == "table" and item or {}
    local traderID = tostring(item.traderID or "")
    if traderID == "" then return nil, "trader_required" end

    if Manager.active and Manager.active.view then
        local previous = Manager.active.view
        if previous.close then previous:close("debug_talk_replaced") end
    end

    local current = player()
    local displayName = tostring(item.displayName or traderID)
    local spec = {
        namespace = "DTAbstractDebugTalk",
        npcID = tostring(item.actorID or traderID),
        npcName = displayName,
        persistHistory = false,
        activeMessageLimit = 64,
        animateOpening = true,
        screenVariant = "subtle",
        choicePartVisible = false,
        portrait = portraitSpec(item),
        backgroundID = "twilight",
        context = {
            npcName = displayName,
            playerName = current and current.getDisplayName
                and current:getDisplayName() or nil,
            traderID = traderID,
            actorID = item.actorID,
            debugRemoteTalk = true,
        },
        extensionParts = {
            {
                partID = "llmInput",
                visible = true,
                title = {
                    fallback = "TYPE TO TALK",
                },
                factory = createInput,
            },
        },
        lifecycle = lifecycle(),
        start = "start",
        nodes = {
            start = {
                choices = {},
            },
        },
    }

    local conversation = PsychopatzCore
        and PsychopatzCore.Conversation or nil
    if not conversation or type(conversation.Open) ~= "function" then
        return nil, "conversation_ui_unavailable"
    end

    local view = conversation.Open(spec)
    if not view then return nil, "conversation_open_failed" end
    Manager.active = {
        view = view,
        traderID = traderID,
        actorID = item.actorID,
        displayName = displayName,
        mode = "radio",
        sessionID = nil,
        pending = false,
        debugAccess = false,
    }
    refreshInput(view)
    return view
end

function Manager.HandleTalkResult(args)
    args = type(args) == "table" and args or {}
    local active = Manager.active
    if not active
        or tostring(args.traderID or "") ~= active.traderID
    then
        return false
    end

    active.pending = false
    if args.accepted ~= true then
        active.lastError = tostring(args.reason or "talk_rejected")
        refreshInput(active.view)
        return false
    end

    if args.sessionID ~= nil then
        active.sessionID = tostring(args.sessionID)
    end
    active.debugAccess = args.debugAccess == true
    appendTraderResponses(active, args.result)
    refreshInput(active.view)
    return true
end

local function onServerCommand(module, command, args)
    if module ~= (DTCommon and DTCommon.MOD_ID or "DynamicTrading")
        or command ~= "TalkResult"
    then
        return
    end
    Manager.HandleTalkResult(args)
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not Manager._serverHook
then
    Manager._serverHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

return Manager
