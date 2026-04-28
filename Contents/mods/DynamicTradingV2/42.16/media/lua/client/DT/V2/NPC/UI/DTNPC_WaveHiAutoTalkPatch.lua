-- ==============================================================================
-- DTNPC_WaveHiAutoTalkPatch.lua
-- Wraps the vanilla Wave Hi emote to open the closest valid trader conversation.
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
pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")
pcall(require, "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient")
pcall(require, "DT/Common/FlavorText/DT_FlavorText_TraderSignals")
pcall(require, "Utils/DT_CoreUtils")

local EXCLUDED_HANDLER_IDS = {
    TravelCompanion = true,
    BanditDemand = true,
}
local TRADER_REPLY_DELAY_MS = 280
local AUTO_OPEN_DELAY_MS = 820

local function formatPlaceholders(text, ...)
    local args = { ... }
    return (tostring(text or ""):gsub("%%(%d+)", function(index)
        local value = args[tonumber(index)]
        if value == nil then
            return "%" .. index
        end
        return tostring(value)
    end))
end

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

local function getNPCName(zombie, npcData)
    return tostring(
        npcData and npcData.name
            or zombie and zombie.getDescriptor and zombie:getDescriptor() and zombie:getDescriptor():getForename()
            or "Trader"
    )
end

local function getFlavorText(category, kind, ...)
    local text = DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom(category, kind)
        or ""

    if text == "" then
        return ""
    end

    return formatPlaceholders(text, ...)
end

local function isExcludedByNPCData(npcData)
    if type(npcData) ~= "table" then
        return true
    end

    if npcData.isBandit == true
        or npcData.isHostile == true
        or npcData.raidHostileFaction == true
        or npcData.banditGroupID ~= nil
        or tostring(npcData.factionID or "") == "Bandits" then
        return true
    end

    return false
end

local function isValidTraderCandidate(player, zombie, npcData)
    if not player or not zombie or zombie:isDead() or type(npcData) ~= "table" then
        return false
    end

    if (tonumber(player:getZ()) or 0) ~= (tonumber(zombie:getZ()) or 0) then
        return false
    end

    if isExcludedByNPCData(npcData) then
        return false
    end

    if not (DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.CheckInteractionValid) then
        return false
    end

    local valid = DynamicTrading.Utils.CheckInteractionValid(zombie, player, npcData)
    if valid ~= true then
        return false
    end

    local handler = DTNPCJobUI and DTNPCJobUI.Resolve and DTNPCJobUI.Resolve(nil, zombie, player, npcData) or nil
    if handler and EXCLUDED_HANDLER_IDS[tostring(handler.id or "")] then
        return false
    end

    return true
end

local function resolveClosestTrader(player)
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

            if isValidTraderCandidate(player, zombie, npcData) then
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

local function validatePendingTrader(player, npc, npcKey)
    if not player or not npc or player:isDead() or npc:isDead() then
        return false, nil
    end

    local npcData = getNPCData(npc)
    if not npcData or getNPCKey(npc, npcData) ~= tostring(npcKey) then
        return false, nil
    end

    if not isValidTraderCandidate(player, npc, npcData) then
        return false, nil
    end

    return true, npcData
end

local function queueTraderConversation(player, npc, npcKey, npcData)
    local now = getTimeInMillis()
    local traderName = getNPCName(npc, npcData)
    local playerLine = getFlavorText("TraderSignals", "WaveHiPlayer", traderName)
    local traderLine = getFlavorText("TraderSignals", "WaveHiTrader", traderName)

    if playerLine == "" then
        playerLine = traderName .. ", got a minute?"
    end
    if traderLine == "" then
        traderLine = "I'm listening."
    end

    if playerLine ~= "" and player.Say then
        player:Say(playerLine)
    end

    Patch.PendingOpen = {
        player = player,
        npc = npc,
        npcKey = tostring(npcKey),
        traderLine = traderLine,
        traderSpeechSent = false,
        traderSpeechAt = now + TRADER_REPLY_DELAY_MS,
        openAt = now + AUTO_OPEN_DELAY_MS,
    }
end

local function tryQueueClosestTraderConversation(character)
    local player = character
    if not player or not instanceof or not instanceof(player, "IsoPlayer") or player:isDead() then
        return
    end

    local npc, npcKey = resolveClosestTrader(player)
    if not npc or not npcKey or isConversationAlreadyOpenForTarget(npcKey) then
        return
    end

    local npcData = getNPCData(npc)
    if not npcData then
        return
    end

    queueTraderConversation(player, npc, npcKey, npcData)
end

local function onTick()
    local pending = Patch.PendingOpen
    if not pending then
        return
    end

    local valid, npcData = validatePendingTrader(pending.player, pending.npc, pending.npcKey)
    if not valid then
        Patch.PendingOpen = nil
        return
    end

    if isConversationAlreadyOpenForTarget(pending.npcKey) then
        Patch.PendingOpen = nil
        return
    end

    local now = getTimeInMillis()
    if not pending.traderSpeechSent and now >= (pending.traderSpeechAt or 0) then
        if pending.traderLine ~= "" and DTNPCClient and DTNPCClient.QueueAmbientSpeechForNPC then
            DTNPCClient.QueueAmbientSpeechForNPC(
                pending.npc,
                pending.traderLine,
                "neutral",
                pending.player and pending.player.getPlayerNum and pending.player:getPlayerNum() or 0
            )
        end
        pending.traderSpeechSent = true
    end

    if now < (pending.openAt or 0) then
        return
    end

    if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
        DTNPC_TraderDialogue_Hub.Init(nil, pending.npc, pending.player)
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
        local baseEmote = emote
        local result = Patch.OriginalEmote(self, emote)

        if baseEmote == "wavehi" then
            tryQueueClosestTraderConversation(self and self.character or nil)
        end

        return result
    end

    Patch.EmotePatched = true
end

patchWaveHiEmote()
Events.OnTick.Remove(onTick)
Events.OnTick.Add(onTick)
