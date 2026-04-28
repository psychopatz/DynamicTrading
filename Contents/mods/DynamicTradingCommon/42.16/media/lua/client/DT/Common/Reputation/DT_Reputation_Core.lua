if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

DT_Reputation.VERSION = 2
DT_Reputation.CHARACTER_KEY_MODDATA = "DT_ReputationCharacterKey"
DT_Reputation.REP_MODDATA_KEY = "DT_ReputationState"
DT_Reputation.REP_MIN = -100
DT_Reputation.REP_MAX = 100
DT_Reputation.TRADE_THRESHOLD = 1000
DT_Reputation.TRADE_REP_GAIN = 1
DT_Reputation.KILL_PENALTY = -30
DT_Reputation.INCAP_PENALTY = -25
DT_Reputation.RECRUIT_PENALTY = -15
DT_Reputation.DAMAGE_PENALTY = -10
DT_Reputation.DAMAGE_THRESHOLD_RATIO = 0.25
DT_Reputation.HIT_ATTRIBUTION_MS = 15000
DT_Reputation.FAST_KILL_CONFIRM_MS = 2500
DT_Reputation.SAVE_DEBOUNCE_MS = 1500
DT_Reputation.SHOW_HALO_DEBUG = false
DT_Reputation.AUTO_DEBUG = false

DT_Reputation.state = DT_Reputation.state or {
    characterKey = nil,
    loaded = false,
    dirty = false,
    saveDueAt = nil,
    personalRep = {},
    factionBias = {},
    tradeProgress = {},
    totalBought = {},
    totalSold = {},
    totalGifted = {},
    factionRepCache = {},
    recentHits = {},
    recentDamage = {},
}

function Internal.Log(category, text)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Rep", category, text)
    end
end

function Internal.GetLocalPlayer()
    if getPlayer then
        local player = getPlayer()
        if player then
            return player
        end
    end

    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end

    return nil
end

function Internal.ShowHalo(text, isPositive, target, alwaysShow)
    if not HaloTextHelper then return end
    local player = nil

    if target and target.getObjectName and target:getObjectName() == "Player" then
        player = target
    else
        player = Internal.GetLocalPlayer()
    end

    if not player then return end

    local color = isPositive and HaloTextHelper.getColorGreen() or HaloTextHelper.getColorRed()
    HaloTextHelper.addTextWithArrow(player, text, isPositive, color)
end

function Internal.ResolveTraderCharacter(traderUUID)
    if not traderUUID then return nil end

    local traderKey = tostring(traderUUID)

    if DT_ConversationUI and DT_ConversationUI.instance then
        local ui = DT_ConversationUI.instance
        local target = ui.target
        local targetID = target and (target.uuid or target.traderID or target.id)
        if ui.interactionObj and targetID and tostring(targetID) == traderKey then
            return ui.interactionObj
        end
    end

    local provider = rawget(_G, "V2_DataProvider")
    if provider and provider._currentNPC and provider._currentTraderID and tostring(provider._currentTraderID) == traderKey then
        return provider._currentNPC
    end

    local npcClient = rawget(_G, "DTNPCClient")
    if npcClient and npcClient.FindZombieByUUID then
        local zombie = npcClient.FindZombieByUUID(traderUUID)
        if zombie then
            return zombie
        end
    end

    return nil
end

function Internal.ShowTraderHalo(traderUUID, text, isPositive, alwaysShow)
    Internal.ShowHalo(text, isPositive, Internal.GetLocalPlayer(), alwaysShow)
end

function Internal.GetFactionDisplayName(factionID)
    if not factionID then
        return nil
    end

    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local faction = factionData[factionID]
    if faction and faction.name and faction.name ~= "" then
        return faction.name
    end

    return tostring(factionID)
end

function Internal.BuildRepHaloText(baseText, factionID, oldRepValue, newRepValue)
    local parts = { tostring(baseText or "") }
    local factionName = Internal.GetFactionDisplayName(factionID)

    if factionName then
        parts[#parts + 1] = factionName
    end

    if oldRepValue ~= nil and newRepValue ~= nil then
        local oldStage = DT_Reputation.GetStageData(oldRepValue).label
        local newStage = DT_Reputation.GetStageData(newRepValue).label
        if oldStage ~= newStage then
            parts[#parts + 1] = newStage
        end
    end

    return table.concat(parts, " | ")
end

function Internal.SanitizeKey(text)
    return tostring(text or "unknown"):gsub("[^%w_%-]", "_")
end

function Internal.GetSafeSteamID(player)
    if not player or not player.getSteamID then
        return "0"
    end

    local rawID = player:getSteamID()
    if not rawID or rawID == 0 or rawID == "0" then
        return "0"
    end

    if type(rawID) == "number" then
        return string.format("%.0f", rawID)
    end

    return tostring(rawID)
end

function Internal.GetReputationStore(modData)
    if not modData then return nil end
    if type(modData[DT_Reputation.REP_MODDATA_KEY]) ~= "table" then
        modData[DT_Reputation.REP_MODDATA_KEY] = {}
    end
    return modData[DT_Reputation.REP_MODDATA_KEY]
end

function Internal.CloneTable(src)
    local out = {}
    for key, value in pairs(src or {}) do
        out[key] = value
    end
    return out
end

function Internal.InvalidateFactionCache(factionID)
    if not factionID then return end
    DT_Reputation.state.factionRepCache[factionID] = nil
end

function Internal.InvalidateAllFactionCache()
    DT_Reputation.state.factionRepCache = {}
end

function Internal.QueueSave(delayMs)
    local state = DT_Reputation.state
    state.dirty = true
    state.saveDueAt = getTimeInMillis() + (delayMs or DT_Reputation.SAVE_DEBOUNCE_MS)
end

function Internal.IsSoulAlive(soul)
    if not soul then
        return true
    end

    return soul.status ~= "Dead"
end

function Internal.ResetState(characterKey)
    DT_Reputation.state.characterKey = characterKey
    DT_Reputation.state.loaded = true
    DT_Reputation.state.dirty = false
    DT_Reputation.state.saveDueAt = nil
    DT_Reputation.state.personalRep = {}
    DT_Reputation.state.factionBias = {}
    DT_Reputation.state.tradeProgress = {}
    DT_Reputation.state.totalBought = {}
    DT_Reputation.state.totalSold = {}
    DT_Reputation.state.totalGifted = {}
    DT_Reputation.state.factionRepCache = {}
    DT_Reputation.state.recentHits = {}
    DT_Reputation.state.recentDamage = {}
end
