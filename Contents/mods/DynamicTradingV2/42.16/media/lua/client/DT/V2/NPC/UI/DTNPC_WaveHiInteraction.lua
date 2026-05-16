-- ==============================================================================
-- DTNPC_WaveHiInteraction.lua
-- Shared wave-hi talk resolver for nearby NPC interactions.
-- ==============================================================================

if isServer() and not isClient() then
    return
end

pcall(require, "DT/Common/FlavorText/DT_FlavorText_WaveHi")
pcall(require, "DT/Common/FlavorText/DT_FlavorText_ThankYou")
pcall(require, "DT/Common/FlavorText/DT_FlavorText_ThumbsUp")
pcall(require, "DT/Common/FlavorText/DT_FlavorText_Insult")
pcall(require, "DT/Common/FlavorText/DT_FlavorText_ThumbsDown")
pcall(require, "DT/Common/Reputation/DT_Reputation")
pcall(require, "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Config")
pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")

DTNPC_WaveHiInteraction = DTNPC_WaveHiInteraction or {}

local WaveHi = DTNPC_WaveHiInteraction

WaveHi.POST_ACTION_NONE = "none"
WaveHi.POST_ACTION_OPEN_HUB = "openHub"
WaveHi.POST_ACTION_OPEN_GIFT_TRADE = "openGiftTrade"
WaveHi.POST_ACTION_APPLY_REP_DELTA = "applyRepDelta"

WaveHi.EMOTE_DEFINITIONS = {
    wavehi = {
        flavorFamilies = { "WaveHi" },
        postAction = WaveHi.POST_ACTION_OPEN_HUB,
        playerSentiment = "auto",
        npcSentiment = "auto",
        defaultPlayerLine = function(npcName)
            return "Hey, " .. tostring(npcName or "there") .. "."
        end,
        defaultNPCLine = function()
            return "Yeah?"
        end,
    },
    thankyou = {
        flavorFamilies = { "ThankYou", "WaveHi" },
        postAction = WaveHi.POST_ACTION_OPEN_GIFT_TRADE,
        playerSentiment = "friendly",
        npcSentiment = "friendly",
        defaultPlayerLine = function(npcName)
            return "Thanks, " .. tostring(npcName or "there") .. "."
        end,
        defaultNPCLine = function()
            return "I appreciate that."
        end,
    },
    thumbsup = {
        flavorFamilies = { "ThumbsUp", "ThankYou", "WaveHi" },
        postAction = WaveHi.POST_ACTION_OPEN_GIFT_TRADE,
        playerSentiment = "friendly",
        npcSentiment = "friendly",
        defaultPlayerLine = function(npcName)
            return "You have my thanks, " .. tostring(npcName or "there") .. "."
        end,
        defaultNPCLine = function()
            return "Good to hear."
        end,
    },
    insult = {
        flavorFamilies = { "Insult", "WaveHi" },
        postAction = WaveHi.POST_ACTION_APPLY_REP_DELTA,
        repDelta = -3,
        repReason = "emote_insult",
        playerSentiment = "angry",
        npcSentiment = "angry",
        defaultPlayerLine = function(npcName)
            return "I've heard enough from you, " .. tostring(npcName or "you") .. "."
        end,
        defaultNPCLine = function()
            return "Watch your mouth."
        end,
    },
    thumbsdown = {
        flavorFamilies = { "ThumbsDown", "Insult", "WaveHi" },
        postAction = WaveHi.POST_ACTION_APPLY_REP_DELTA,
        repDelta = -1,
        repReason = "emote_thumbsdown",
        playerSentiment = "warning",
        npcSentiment = "warning",
        defaultPlayerLine = function(npcName)
            return "Not impressed, " .. tostring(npcName or "friend") .. "."
        end,
        defaultNPCLine = function()
            return "Then move along."
        end,
    },
}

local function clamp01(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        return fallback
    end
    if numeric < 0 then
        return 0
    end
    if numeric > 1 then
        return 1
    end
    return numeric
end

local function mixColor(left, right, blend)
    local t = clamp01(blend, 0.5) or 0.5
    local inverse = 1 - t
    return {
        r = ((left and left.r or 1) * inverse) + ((right and right.r or 1) * t),
        g = ((left and left.g or 1) * inverse) + ((right and right.g or 1) * t),
        b = ((left and left.b or 1) * inverse) + ((right and right.b or 1) * t),
        a = ((left and left.a or 1) * inverse) + ((right and right.a or 1) * t),
    }
end

local function brighten(color, amount, alpha)
    local lift = tonumber(amount) or 0
    return {
        r = clamp01((color and color.r or 1) + lift, 1) or 1,
        g = clamp01((color and color.g or 1) + lift, 1) or 1,
        b = clamp01((color and color.b or 1) + lift, 1) or 1,
        a = clamp01(alpha, color and color.a or 1) or (color and color.a or 1),
    }
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function normalizeVariantKey(value)
    local raw = tostring(value or "")
    if raw == "" then
        return nil
    end

    local parts = {}
    for token in string.gmatch(raw, "[%w]+") do
        parts[#parts + 1] = string.upper(string.sub(token, 1, 1)) .. string.lower(string.sub(token, 2))
    end

    local combined = table.concat(parts, "")
    if combined == "" then
        return nil
    end

    return combined
end

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

local function getPlayerName(player)
    if not player then
        return "there"
    end

    if player.getDescriptor and player:getDescriptor() and player:getDescriptor().getForename then
        local forename = player:getDescriptor():getForename()
        if forename and forename ~= "" then
            return tostring(forename)
        end
    end

    if player.getUsername then
        local username = player:getUsername()
        if username and username ~= "" then
            return tostring(username)
        end
    end

    return "there"
end

local function getNPCName(npc, npcData)
    return tostring(
        npcData and npcData.name
            or npc and npc.getDescriptor and npc:getDescriptor() and npc:getDescriptor():getForename()
            or "Survivor"
    )
end

local function getNPCKey(npc, npcData)
    if npcData and npcData.uuid then
        return tostring(npcData.uuid)
    end

    local persistentID = npc and npc:getPersistentOutfitID() or nil
    if persistentID then
        return tostring(persistentID)
    end

    local id = npc and npc:getID() or nil
    return id and tostring(id) or nil
end

local function getNPCFactionID(npcData)
    local factionID = npcData and npcData.factionID or nil
    if factionID == nil or factionID == "" then
        return nil
    end
    return tostring(factionID)
end

local function getEmoteDefinition(emoteID)
    local normalized = lower(emoteID)
    return WaveHi.EMOTE_DEFINITIONS[normalized] or WaveHi.EMOTE_DEFINITIONS.wavehi
end

local function getHandler(npc, player, npcData)
    if DTNPCJobUI and DTNPCJobUI.Resolve then
        return DTNPCJobUI.Resolve(nil, npc, player, npcData)
    end
    return nil
end

local function containsAny(blob, values)
    local target = lower(blob)
    if target == "" then
        return false
    end

    for i = 1, #values do
        if string.find(target, values[i], 1, true) then
            return true
        end
    end

    return false
end

function WaveHi.ResolveCategory(player, npc, npcData, handler)
    local handlerID = tostring(handler and handler.id or "")
    local stateBlob = table.concat({
        tostring(npcData and npcData.state or ""),
        tostring(npcData and npcData.status or ""),
        tostring(npcData and npcData.tradeCycleMode or ""),
        tostring(npcData and npcData.role or ""),
        tostring(npcData and npcData.occupation or ""),
    }, " ")

    if handlerID == "TravelCompanion"
        or npcData and (npcData.linkedWorkerID ~= nil or tostring(npcData.dcCompanionJob or "") == "TravelCompanion") then
        return "Companion"
    end

    if npcData and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits") then
        return "Bandit"
    end

    if handlerID == "BanditDemand"
        or npcData and (npcData.raidHostileFaction == true or tostring(npcData.tradeCycleMode or "") == "hostile_bribe") then
        return "Hostile"
    end

    if npcData and npcData.isHostile == true then
        return "Hostile"
    end

    if containsAny(stateBlob, { "trading", "trade", "merchant", "vendor" }) then
        return "Trading"
    end

    if containsAny(stateBlob, { "rest", "resting", "sleep", "recover", "idle", "home" }) then
        return "Resting"
    end

    if containsAny(stateBlob, { "working", "playerzone", "guard", "patrol", "watch", "protect", "lootnearby", "scavenge", "build", "farm", "fish" }) then
        return "Working"
    end

    return "Default"
end

function WaveHi.ResolveReputation(npc, npcData)
    local key = getNPCKey(npc, npcData)
    local factionID = npcData and npcData.factionID or nil

    if DT_Reputation and DT_Reputation.GetEffectiveRep and key then
        return tonumber(DT_Reputation.GetEffectiveRep(key, factionID) or 0) or 0
    end

    return tonumber(npcData and npcData.reputation or 0) or 0
end

function WaveHi.ResolveSentiment(category, reputation)
    if category == "Bandit" then
        return "hostile"
    end

    if category == "Hostile" then
        if reputation <= -40 then
            return "hostile"
        end
        return "angry"
    end

    if category == "Companion" then
        if reputation <= -10 then
            return "warning"
        end
        return "friendly"
    end

    if category == "Resting" then
        if reputation <= -10 then
            return "warning"
        end
        return "resting"
    end

    if category == "Working" then
        if reputation <= -10 then
            return "warning"
        end
        return "friendly"
    end

    if category == "Trading" then
        if reputation <= -40 then
            return "angry"
        end
        if reputation <= -10 then
            return "warning"
        end
        return "trading"
    end

    if reputation >= 10 then
        return "friendly"
    end
    if reputation <= -40 then
        return "angry"
    end
    if reputation <= -10 then
        return "warning"
    end
    return "neutral"
end

function WaveHi.ResolvePlayerSentiment(category, reputation)
    if category == "Bandit" or category == "Hostile" then
        return "warning"
    end

    if category == "Trading" then
        if reputation <= -10 then
            return "warning"
        end
        return "trading"
    end

    if category == "Resting" then
        if reputation <= -10 then
            return "warning"
        end
        return "resting"
    end

    if category == "Companion" then
        if reputation <= -10 then
            return "warning"
        end
        return "friendly"
    end

    if category == "Working" then
        if reputation <= -10 then
            return "warning"
        end
        if reputation >= 10 then
            return "friendly"
        end
    end

    if reputation <= -10 then
        return "warning"
    end
    if reputation >= 10 then
        return "friendly"
    end
    return "neutral"
end

function WaveHi.ResolveReputationStage(reputation)
    local stageData = DT_Reputation and DT_Reputation.GetStageData and DT_Reputation.GetStageData(reputation or 0) or nil
    return normalizeVariantKey(stageData and stageData.label or "Neutral") or "Neutral"
end

function WaveHi.ResolveBubbleStyle(sentiment, reputation, isPlayer)
    local sentimentApi = DTNPCClient and (DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig) or nil
    local sentimentColor = sentimentApi and sentimentApi.GetSentimentColor and sentimentApi.GetSentimentColor(sentiment) or { r = 1, g = 1, b = 1, a = 1 }
    local repColor = DT_Reputation and DT_Reputation.GetStageData and DT_Reputation.GetStageData(reputation or 0).color or { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    local accent = mixColor(sentimentColor, repColor, isPlayer and 0.22 or 0.38)
    local body = mixColor(accent, { r = 0.04, g = 0.05, b = 0.04, a = 1 }, isPlayer and 0.76 or 0.82)

    return {
        accentColor = brighten(accent, isPlayer and 0.02 or 0.04, 0.96),
        bodyColor = {
            r = clamp01(body.r, 0.08) or 0.08,
            g = clamp01(body.g, 0.08) or 0.08,
            b = clamp01(body.b, 0.08) or 0.08,
            a = isPlayer and 0.28 or 0.24,
        },
        textColor = brighten(accent, 0.26, 1.0),
    }
end

local function buildFlavorKeys(kind, category, sentiment, reputationStage)
    local safeKind = tostring(kind or "NPC")
    local safeCategory = tostring(category or "Default")
    local safeSentiment = normalizeVariantKey(sentiment)
    local safeStage = normalizeVariantKey(reputationStage)
    local keys = {}
    local seen = {}

    local function push(key)
        if not key or key == "" or seen[key] then
            return
        end

        seen[key] = true
        keys[#keys + 1] = key
    end

    push(safeKind .. safeCategory .. tostring(safeStage or ""))
    push(safeKind .. safeCategory .. tostring(safeSentiment or ""))
    push(safeKind .. safeCategory)
    push(safeKind .. "Default" .. tostring(safeStage or ""))
    push(safeKind .. "Default" .. tostring(safeSentiment or ""))
    push(safeKind .. "Default")

    return keys
end

local function getFlavorLine(families, kind, category, sentiment, reputationStage, ...)
    local keys = buildFlavorKeys(kind, category, sentiment, reputationStage)
    local familyList = type(families) == "table" and families or { tostring(families or "WaveHi") }

    for familyIndex = 1, #familyList do
        local family = tostring(familyList[familyIndex] or "")
        if family ~= "" then
            for i = 1, #keys do
                local key = keys[i]
                local line = DynamicTrading
                    and DynamicTrading.FlavorText
                    and DynamicTrading.FlavorText.GetRandom
                    and DynamicTrading.FlavorText.GetRandom(family, key)
                    or ""

                if line ~= "" then
                    return formatPlaceholders(line, ...)
                end
            end
        end
    end

    return ""
end

local function resolvePlanSentiment(definitionValue, fallbackValue)
    if definitionValue == nil or definitionValue == "auto" then
        return fallbackValue
    end
    return tostring(definitionValue)
end

local function resolveDefaultLine(definition, fieldName, primaryName, secondaryName, fallbackText)
    local factory = definition and definition[fieldName] or nil
    if type(factory) == "function" then
        local text = factory(primaryName, secondaryName)
        if text and text ~= "" then
            return tostring(text)
        end
    elseif type(factory) == "string" and factory ~= "" then
        return factory
    end

    return fallbackText
end

function WaveHi.BuildPlanForEmote(emoteID, player, npc, npcData)
    local handler = getHandler(npc, player, npcData)
    local category = WaveHi.ResolveCategory(player, npc, npcData, handler)
    local reputation = WaveHi.ResolveReputation(npc, npcData)
    local npcName = getNPCName(npc, npcData)
    local playerName = getPlayerName(player)
    local definition = getEmoteDefinition(emoteID)
    local npcSentiment = resolvePlanSentiment(definition.npcSentiment, WaveHi.ResolveSentiment(category, reputation))
    local playerSentiment = resolvePlanSentiment(definition.playerSentiment, WaveHi.ResolvePlayerSentiment(category, reputation))
    local reputationStage = WaveHi.ResolveReputationStage(reputation)
    local families = definition.flavorFamilies or { "WaveHi" }
    local playerLine = getFlavorLine(families, "Player", category, playerSentiment, reputationStage, npcName, playerName)
    local npcLine = getFlavorLine(families, "NPC", category, npcSentiment, reputationStage, playerName, npcName)

    if playerLine == "" then
        playerLine = resolveDefaultLine(definition, "defaultPlayerLine", npcName, playerName, "Hey, " .. npcName .. ".")
    end
    if npcLine == "" then
        npcLine = resolveDefaultLine(definition, "defaultNPCLine", playerName, npcName, "Yeah?")
    end

    return {
        emoteID = lower(emoteID),
        category = category,
        reputation = reputation,
        handlerID = handler and handler.id or nil,
        flavorFamilies = families,
        postAction = definition.postAction or WaveHi.POST_ACTION_OPEN_HUB,
        repDelta = tonumber(definition.repDelta or 0) or 0,
        repReason = tostring(definition.repReason or "emote_interaction"),
        repTargetID = getNPCKey(npc, npcData),
        factionID = getNPCFactionID(npcData),
        playerLine = playerLine,
        playerSentiment = playerSentiment,
        playerMessage = {
            text = playerLine,
            author = "Me",
            style = WaveHi.ResolveBubbleStyle(playerSentiment, reputation, true),
        },
        npcLine = npcLine,
        npcSentiment = npcSentiment,
        introGreeting = {
            text = npcLine,
            author = npcName,
            delay = 18,
            style = WaveHi.ResolveBubbleStyle(npcSentiment, reputation, false),
        },
    }
end

function WaveHi.BuildPlan(player, npc, npcData)
    return WaveHi.BuildPlanForEmote("wavehi", player, npc, npcData)
end
