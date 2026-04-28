-- ==============================================================================
-- DTNPC_WaveHiAutoTalkPatch.lua
-- Wraps the vanilla Wave Hi emote to simulate the closest valid NPC talk action.
-- ==============================================================================

if isServer() and not isClient() then
    return
end

DTNPC_WaveHiAutoTalkPatch = DTNPC_WaveHiAutoTalkPatch or {}

local Patch = DTNPC_WaveHiAutoTalkPatch

if Patch.Loaded then
    return
end

Patch.Loaded = true

pcall(require, "ISUI/ISEmoteRadialMenu")
pcall(require, "DT/V2/NPC/UI/DTNPC_TraderDialogue_Hub")
pcall(require, "DT/V2/NPC/UI/DTNPC_WaveHiInteraction")
pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")
pcall(require, "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient")
pcall(require, "Utils/DT_CoreUtils")

local PLAYER_FLAVOR_DELAY_MS = 350
local NPC_REPLY_DELAY_MS = 1250
local AUTO_OPEN_DELAY_MS = 4000
local EMOTE_COOLDOWN_MS = 4500
local GIFT_STOCK_TIMEOUT_MS = 7000

local INTERCEPTED_EMOTES = {
    wavehi = true,
    thankyou = true,
    thumbsup = true,
    insult = true,
    thumbsdown = true,
}

local function getNPCData(zombie)
    if not zombie then
        return nil
    end

    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end

    local modData = zombie:getModData()
    return modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
end

local function getNPCKey(zombie, npcData)
    local uuid = npcData and npcData.uuid or nil
    if uuid and uuid ~= "" then
        return tostring(uuid)
    end

    local persistentID = zombie and zombie:getPersistentOutfitID() or nil
    if persistentID then
        return tostring(persistentID)
    end

    local fallbackID = zombie and zombie:getID() or nil
    return fallbackID and tostring(fallbackID) or nil
end

local function normalizeEmoteID(emote)
    return string.lower(tostring(emote or ""))
end

local function getCooldownKey(npcKey, emoteID)
    local safeNPCKey = tostring(npcKey or "")
    local safeEmote = normalizeEmoteID(emoteID)
    if safeNPCKey == "" or safeEmote == "" then
        return nil
    end

    return safeNPCKey .. ":" .. safeEmote
end

local function isEmoteOnCooldown(npcKey, emoteID)
    local key = getCooldownKey(npcKey, emoteID)
    if not key then
        return false
    end

    Patch.EmoteCooldowns = Patch.EmoteCooldowns or {}
    local expiresAt = tonumber(Patch.EmoteCooldowns[key] or 0) or 0
    return expiresAt > (getTimeInMillis and getTimeInMillis() or 0)
end

local function stampEmoteCooldown(npcKey, emoteID)
    local key = getCooldownKey(npcKey, emoteID)
    if not key then
        return
    end

    Patch.EmoteCooldowns = Patch.EmoteCooldowns or {}
    Patch.EmoteCooldowns[key] = (getTimeInMillis and getTimeInMillis() or 0) + EMOTE_COOLDOWN_MS
end

local function getConversationTargetID(ui)
    if not ui or not ui.target then
        return nil
    end

    local target = ui.target
    local id = target.uuid or target.traderID or target.id or nil
    return id and tostring(id) or nil
end

local function isConversationAlreadyOpenForTarget(npcKey)
    local openUI = DT_ConversationUI and DT_ConversationUI.instance or nil
    if not openUI or not openUI.getIsVisible or not openUI:getIsVisible() then
        return false
    end

    local currentTargetID = getConversationTargetID(openUI)
    return currentTargetID and currentTargetID == tostring(npcKey) or false
end

local function isValidTalkCandidate(player, zombie, npcData)
    if not player or not zombie or zombie:isDead() or type(npcData) ~= "table" then
        return false
    end

    if (tonumber(player:getZ()) or 0) ~= (tonumber(zombie:getZ()) or 0) then
        return false
    end

    if not (DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.CheckInteractionValid) then
        return false
    end

    local valid = DynamicTrading.Utils.CheckInteractionValid(zombie, player, npcData)
    if valid ~= true then
        return false
    end

    return true
end

local function resolveClosestTalkTarget(player)
    local cell = getCell and getCell() or nil
    if not cell then
        return nil, nil
    end

    local zombieList = cell:getZombieList()
    if not zombieList then
        return nil, nil
    end

    local seen = {}
    local bestZombie = nil
    local bestKey = nil
    local bestDistance = nil

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local npcData = getNPCData(zombie)
        local key = getNPCKey(zombie, npcData)

        if key and not seen[key] then
            seen[key] = true

            if isValidTalkCandidate(player, zombie, npcData) then
                local distance = IsoUtils.DistanceTo(player:getX(), player:getY(), zombie:getX(), zombie:getY())
                if not bestZombie
                    or distance < bestDistance
                    or (math.abs(distance - bestDistance) < 0.0001 and tostring(key) < tostring(bestKey or "")) then
                    bestZombie = zombie
                    bestKey = key
                    bestDistance = distance
                end
            end
        end
    end

    return bestZombie, bestKey
end

local function validatePendingTalkTarget(player, npc, npcKey)
    if not player or not npc or player:isDead() or npc:isDead() then
        return false, nil
    end

    local npcData = getNPCData(npc)
    if not npcData or getNPCKey(npc, npcData) ~= tostring(npcKey) then
        return false, nil
    end

    if not isValidTalkCandidate(player, npc, npcData) then
        return false, nil
    end

    return true, npcData
end

local function queueTalkConversation(player, npc, npcKey, npcData, emoteID)
    local now = getTimeInMillis()
    local safeEmoteID = normalizeEmoteID(emoteID)
    local plan = DTNPC_WaveHiInteraction and DTNPC_WaveHiInteraction.BuildPlanForEmote
        and DTNPC_WaveHiInteraction.BuildPlanForEmote(safeEmoteID, player, npc, npcData)
        or DTNPC_WaveHiInteraction and DTNPC_WaveHiInteraction.BuildPlan
        and DTNPC_WaveHiInteraction.BuildPlan(player, npc, npcData)
        or nil

    local playerLine = plan and plan.playerLine or "Hey, you."
    local npcLine = plan and plan.npcLine or "Yeah?"
    local npcSentiment = plan and plan.npcSentiment or "neutral"

    stampEmoteCooldown(npcKey, safeEmoteID)

    Patch.PendingOpen = {
        emoteID = safeEmoteID,
        player = player,
        npc = npc,
        npcKey = tostring(npcKey),
        playerLine = playerLine,
        initialPlayerMessage = plan and plan.playerMessage or nil,
        npcLine = npcLine,
        npcSentiment = npcSentiment,
        introGreeting = plan and plan.introGreeting or nil,
        postAction = plan and plan.postAction or "openHub",
        repDelta = plan and plan.repDelta or 0,
        repReason = plan and plan.repReason or nil,
        factionID = plan and plan.factionID or (npcData and npcData.factionID) or nil,
        playerSpeechSent = false,
        playerSpeechAt = now + PLAYER_FLAVOR_DELAY_MS,
        npcSpeechSent = false,
        npcSpeechAt = now + NPC_REPLY_DELAY_MS,
        openAt = now + AUTO_OPEN_DELAY_MS,
    }
end

local function tryQueueClosestTalkConversation(character, emoteID)
    local player = character
    if not player or not instanceof or not instanceof(player, "IsoPlayer") or player:isDead() then
        return
    end

    local npc, npcKey = resolveClosestTalkTarget(player)
    if not npc or not npcKey or isConversationAlreadyOpenForTarget(npcKey) then
        return
    end

    local npcData = getNPCData(npc)
    local safeEmoteID = normalizeEmoteID(emoteID)
    if not npcData or isEmoteOnCooldown(npcKey, safeEmoteID) then
        return
    end

    queueTalkConversation(player, npc, npcKey, npcData, safeEmoteID)
end

local function openConversationHub(pending)
    if not pending then
        return false
    end

    if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
        DTNPC_TraderDialogue_Hub.Init(nil, pending.npc, pending.player, {
            initialPlayerMessage = pending.initialPlayerMessage,
            initialGreeting = pending.introGreeting,
        })
        return true
    end

    return false
end

local function getStockCache()
    return (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks)
        or ModData.get("DynamicTrading_Stock")
end

local function buildGiftSessionContext(pending, npcData)
    local npcName = npcData and npcData.name or "Survivor"
    return {
        transactionKind = "gift",
        suppressIntroMessages = true,
        windowTitle = tostring(npcName) .. " - Gift",
    }
end

local function queuePendingGiftTrade(pending, traderID, archetype, npcData)
    local now = getTimeInMillis and getTimeInMillis() or 0
    Patch.PendingGiftTrade = {
        player = pending.player,
        npc = pending.npc,
        npcKey = tostring(traderID),
        traderID = tostring(traderID),
        archetype = tostring(archetype or "General"),
        expiresAt = now + GIFT_STOCK_TIMEOUT_MS,
        sessionContext = buildGiftSessionContext(pending, npcData),
    }
end

local function openGiftTrade(pending)
    if not pending or not pending.npc or not pending.player then
        return false
    end

    local npcData = getNPCData(pending.npc)
    if not npcData then
        return false
    end

    local traderID = pending.npcKey or getNPCKey(pending.npc, npcData)
    local archetype = npcData.archetypeID or npcData.archetype or "General"
    if not traderID then
        return false
    end

    local stockData = getStockCache()
    if stockData and stockData[traderID] and DT_TradingWindow and DT_TradingWindow.OpenGiftWindowV2 then
        DT_TradingWindow.OpenGiftWindowV2(traderID, archetype, pending.npc, buildGiftSessionContext(pending, npcData))
        return true
    end

    queuePendingGiftTrade(pending, traderID, archetype, npcData)
    sendClientCommand(pending.player, "DynamicTrading_V2", "GenerateStock", { traderID = traderID })
    return true
end

local function applyPendingRepDelta(pending)
    local repDelta = tonumber(pending and pending.repDelta or 0) or 0
    if repDelta == 0 or not (DT_Reputation and DT_Reputation.ModifyPersonalRep) then
        return false
    end

    DT_Reputation.ModifyPersonalRep(
        tostring(pending.npcKey or ""),
        pending.factionID and tostring(pending.factionID) or nil,
        repDelta,
        pending.repReason or ("emote_" .. tostring(pending.emoteID or "interaction"))
    )

    return true
end

local function processPendingGiftTrade()
    local pending = Patch.PendingGiftTrade
    if not pending then
        return
    end

    local valid = validatePendingTalkTarget(pending.player, pending.npc, pending.npcKey)
    if not valid then
        Patch.PendingGiftTrade = nil
        return
    end

    local now = getTimeInMillis and getTimeInMillis() or 0
    if now >= (pending.expiresAt or 0) then
        Patch.PendingGiftTrade = nil
        return
    end

    local stockData = getStockCache()
    if not (stockData and stockData[pending.traderID]) then
        return
    end

    if DT_TradingWindow and DT_TradingWindow.OpenGiftWindowV2 then
        DT_TradingWindow.OpenGiftWindowV2(pending.traderID, pending.archetype, pending.npc, pending.sessionContext)
    end
    Patch.PendingGiftTrade = nil
end

local function onTick()
    processPendingGiftTrade()

    local pending = Patch.PendingOpen
    if not pending then
        return
    end

    local valid, npcData = validatePendingTalkTarget(pending.player, pending.npc, pending.npcKey)
    if not valid then
        Patch.PendingOpen = nil
        return
    end

    if isConversationAlreadyOpenForTarget(pending.npcKey) then
        Patch.PendingOpen = nil
        return
    end

    local now = getTimeInMillis()
    if not pending.playerSpeechSent and now >= (pending.playerSpeechAt or 0) then
        if pending.playerLine ~= "" and pending.player and pending.player.Say then
            pending.player:Say(pending.playerLine)
        end
        pending.playerSpeechSent = true
    end

    if not pending.npcSpeechSent and now >= (pending.npcSpeechAt or 0) then
        if pending.npcLine ~= "" and DTNPCClient and DTNPCClient.QueueAmbientSpeechForNPC then
            DTNPCClient.QueueAmbientSpeechForNPC(
                pending.npc,
                pending.npcLine,
                pending.npcSentiment or "neutral",
                pending.player and pending.player.getPlayerNum and pending.player:getPlayerNum() or 0
            )
        end
        pending.npcSpeechSent = true
    end

    if now < (pending.openAt or 0) then
        return
    end

    local postAction = tostring(pending.postAction or "openHub")
    if postAction == "applyRepDelta" then
        applyPendingRepDelta(pending)
    elseif postAction == "openGiftTrade" then
        openGiftTrade(pending)
    else
        openConversationHub(pending)
    end
    Patch.PendingOpen = nil
end

local function patchWaveHiEmote()
    if not ISEmoteRadialMenu or type(ISEmoteRadialMenu.emote) ~= "function" then
        return
    end

    if Patch.EmotePatched == true then
        return
    end

    Patch.OriginalEmote = Patch.OriginalEmote or ISEmoteRadialMenu.emote

    ISEmoteRadialMenu.emote = function(self, emote)
        local baseEmote = normalizeEmoteID(emote)
        local result = Patch.OriginalEmote(self, emote)

        if INTERCEPTED_EMOTES[baseEmote] then
            tryQueueClosestTalkConversation(self and self.character or nil, baseEmote)
        end

        return result
    end

    Patch.EmotePatched = true
end

patchWaveHiEmote()
Events.OnTick.Remove(onTick)
Events.OnTick.Add(onTick)
