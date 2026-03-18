require "DT/UI/Labour/DT_LabourWindow"
require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Network"

DT_LabourUI = DT_LabourUI or {}

local LabourUI = DT_LabourUI
LabourUI.recruitResultCache = LabourUI.recruitResultCache or {}
local Config = (DT_Labour and DT_Labour.Config) or {}

local function getCommandModule()
    local config = (DT_Labour and DT_Labour.Config) or Config or nil
    if type(config) == "table" and config.COMMAND_MODULE and config.COMMAND_MODULE ~= "" then
        return config.COMMAND_MODULE
    end
    return "DynamicTrading_V2"
end

local function getLocalPlayer()
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    if getPlayer then
        return getPlayer()
    end
    return nil
end

function LabourUI.CanUseDebug(player)
    local playerObj = player or getLocalPlayer()

    if DynamicTrading and DynamicTrading.Debug then
        return true
    end

    if isDebugEnabled and isDebugEnabled() then
        return true
    end

    if playerObj and playerObj.getAccessLevel then
        local accessLevel = playerObj:getAccessLevel()
        if accessLevel and accessLevel ~= "" and accessLevel ~= "None" then
            return true
        end
    end

    return false
end

function LabourUI.ToggleWindow()
    if DT_LabourWindow and DT_LabourWindow.ToggleWindow then
        DT_LabourWindow.ToggleWindow()
    end
end

function LabourUI.OpenWindow()
    if DT_LabourWindow and DT_LabourWindow.Open then
        DT_LabourWindow.Open()
    elseif DT_LabourWindow and DT_LabourWindow.ToggleWindow then
        DT_LabourWindow.ToggleWindow()
    end
end

function LabourUI.SendCommand(command, args)
    local player = getLocalPlayer()
    if not player then return false end

    if isClient() and not isServer() then
        sendClientCommand(player, getCommandModule(), command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end

function LabourUI.GetConversationSourceNPCID(ui)
    if not ui or ui.isRadio or not ui.interactionObj then
        return nil
    end

    local npc = ui.interactionObj
    local target = ui.target or {}
    local npcData = DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil

    if npcData and npcData.uuid then
        return tostring(npcData.uuid)
    end
    if target.id then
        return tostring(target.id)
    end
    if npc.getPersistentOutfitID then
        return tostring(npc:getPersistentOutfitID())
    end
    if npc.getID then
        return tostring(npc:getID())
    end

    return nil
end

function LabourUI.GetConversationTraderID(ui)
    local target = ui and ui.target or nil
    return target and (target.uuid or target.traderID or target.id) or nil
end

function LabourUI.GetConversationEffectiveReputation(ui)
    local traderID = LabourUI.GetConversationTraderID(ui)
    local factionID = ui and ui.target and ui.target.factionID or nil
    if not traderID or not DT_Reputation or not DT_Reputation.GetEffectiveRep then
        return 0
    end
    return DT_Reputation.GetEffectiveRep(traderID, factionID)
end

function LabourUI.GetCurrentDay()
    local gt = getGameTime and getGameTime() or nil
    local hours = gt and gt:getWorldAgeHours() or 0
    return math.floor((tonumber(hours) or 0) / (Config.HOURS_PER_DAY or 24))
end

function LabourUI.ResolveArchetype(trader)
    local rawRole = trader and (trader.archetype or trader.profession or trader.role) or ""
    local role = string.lower(tostring(rawRole))

    if string.find(role, "farm", 1, true) then
        return "Farmer"
    end

    if string.find(role, "angler", 1, true) or string.find(role, "fish", 1, true) then
        return "Angler"
    end

    return "General"
end

function LabourUI.BuildRecruitArgs(ui, archetypeID)
    if not ui or ui.isRadio or not ui.interactionObj then
        return nil
    end

    local npc = ui.interactionObj
    local target = ui.target or {}
    local npcData = DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
    local player = getLocalPlayer()

    local sourceNPCID = LabourUI.GetConversationSourceNPCID(ui)

    if not sourceNPCID then
        return nil
    end

    local x = nil
    local y = nil
    local z = 0
    if npc.getX and npc.getY then
        x = math.floor(npc:getX())
        y = math.floor(npc:getY())
        z = math.floor((npc.getZ and npc:getZ()) or 0)
    elseif player then
        x = math.floor(player:getX())
        y = math.floor(player:getY())
        z = math.floor(player:getZ())
    end

    local normalizedArchetype = Config.NormalizeArchetypeID(
        archetypeID or target.archetype or (npcData and (npcData.archetypeID or npcData.occupation)) or LabourUI.ResolveArchetype(target)
    )
    local defaultJobType = Config.GetDefaultJobForArchetype(normalizedArchetype)

    return {
        jobType = defaultJobType,
        profession = defaultJobType,
        name = target.name or (npcData and npcData.name) or "Worker",
        archetypeID = normalizedArchetype,
        traderUUID = LabourUI.GetConversationTraderID(ui),
        factionID = target.factionID,
        identitySeed = target.identitySeed or (npcData and npcData.identitySeed) or nil,
        isFemale = (npc.isFemale and npc:isFemale()) or target.gender == "Female",
        sourceNPCID = tostring(sourceNPCID),
        sourceNPCType = "ConversationUI",
        x = x,
        y = y,
        z = z
    }
end

function LabourUI.RecruitFromConversation(ui)
    local archetypeID = LabourUI.ResolveArchetype(ui and ui.target)
    local args = LabourUI.BuildRecruitArgs(ui, archetypeID)
    if not args then
        return false, "I can't add this NPC to labour from the current conversation."
    end

    if not LabourUI.SendCommand("DebugRecruitWorker", args) then
        return false, "The labour recruit command could not be sent."
    end

    LabourUI.OpenWindow()
    return true, "For testing, I'll join your labour roster as a " .. tostring(archetypeID) .. "."
end

function LabourUI.AttemptRecruitFromConversation(ui)
    local archetypeID = LabourUI.ResolveArchetype(ui and ui.target)
    local args = LabourUI.BuildRecruitArgs(ui, archetypeID)
    if not args then
        return false, "I can't work out who you're trying to recruit right now."
    end

    if DT_Reputation and DT_Reputation.Save then
        DT_Reputation.Save()
    end

    if not LabourUI.SendCommand("AttemptRecruitWorker", args) then
        return false, "The recruit request couldn't be sent."
    end

    return true, nil
end

local function buildRecruitOption(ui)
    if not ui or ui.isRadio or not ui.interactionObj then
        return nil
    end

    local reputation = LabourUI.GetConversationEffectiveReputation(ui)
    if reputation < (Config.RECRUIT_REQUIRED_REPUTATION or 100) then
        return nil
    end

    local sourceNPCID = LabourUI.GetConversationSourceNPCID(ui)
    local cached = sourceNPCID and LabourUI.recruitResultCache[tostring(sourceNPCID)] or nil
    local currentDay = LabourUI.GetCurrentDay()
    if cached and cached.nextAttemptDay and currentDay >= tonumber(cached.nextAttemptDay) then
        cached = nil
        LabourUI.recruitResultCache[tostring(sourceNPCID)] = nil
    end
    local buttonText = "Recruit To Labour (" .. tostring(Config.RECRUIT_DAILY_CHANCE or 0) .. "%)"

    if cached and cached.alreadyRecruited then
        buttonText = "Already In Labour Roster"
    elseif cached and (cached.reasonCode == "cooldown" or cached.reasonCode == "rolled_failed") then
        buttonText = "Recruit To Labour (Try Tomorrow)"
    end

    return {
        text = buttonText,
        message = "",
        onSelect = function(conversationUI)
            if cached and cached.alreadyRecruited then
                LabourUI.OpenWindow()
                conversationUI:updateOptions(conversationUI.baseOptions or {})
                return
            end

            if cached and (cached.reasonCode == "cooldown" or cached.reasonCode == "rolled_failed") then
                conversationUI:speak(cached.message or "Ask me again tomorrow.")
                conversationUI:updateOptions(conversationUI.baseOptions or {})
                return
            end

            local _, msg = LabourUI.AttemptRecruitFromConversation(conversationUI)
            if msg and msg ~= "" then
                conversationUI:speak(msg)
            end
        end
    }
end

function LabourUI.BuildConversationOptions(ui, options)
    local merged = {}
    for _, option in ipairs(options or {}) do
        merged[#merged + 1] = option
    end

    local recruitOption = buildRecruitOption(ui)
    if recruitOption then
        merged[#merged + 1] = recruitOption
    end

    if not ui or ui.isRadio or not ui.interactionObj or not LabourUI.CanUseDebug() then
        return merged
    end

    local archetypeID = LabourUI.ResolveArchetype(ui.target)

    merged[#merged + 1] = {
        text = "DEBUG: Recruit To Labour (" .. archetypeID .. ")",
        message = "",
        onSelect = function(conversationUI)
            local _, msg = LabourUI.RecruitFromConversation(conversationUI)
            if msg and msg ~= "" then
                conversationUI:speak(msg)
            end
            conversationUI:updateOptions(conversationUI.baseOptions or {})
        end
    }

    merged[#merged + 1] = {
        text = "DEBUG: Open Labour Management",
        message = "",
        onSelect = function(conversationUI)
            LabourUI.OpenWindow()
            conversationUI:updateOptions(conversationUI.baseOptions or {})
        end
    }

    return merged
end

local function onServerCommand(module, command, args)
    if module ~= getCommandModule() then
        return
    end

    if command ~= "SyncRecruitAttemptResult" then
        return
    end

    args = args or {}
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    if sourceNPCID then
        LabourUI.recruitResultCache[sourceNPCID] = args
    end

    local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
    if not ui then
        return
    end

    local currentSourceNPCID = LabourUI.GetConversationSourceNPCID(ui)
    if sourceNPCID and currentSourceNPCID and sourceNPCID ~= tostring(currentSourceNPCID) then
        return
    end

    if args.message and args.message ~= "" then
        ui:speak(args.message)
    end
    if args.success then
        LabourUI.OpenWindow()
    end
    ui:updateOptions(ui.baseOptions or {})
end

if not LabourUI.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    LabourUI.EventsAdded = true
end

return LabourUI
