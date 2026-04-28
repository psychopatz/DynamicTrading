if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

local function restoreAccumulatedValue(value)
    return math.max(0, math.floor((tonumber(value) or 0) + 0.5))
end

function DT_Reputation.Save()
    local state = DT_Reputation.state
    if not state.loaded or not state.characterKey then return false end

    local player = Internal.GetLocalPlayer()
    if not player then return false end

    local modData = player:getModData()
    if not modData then return false end

    local store = Internal.GetReputationStore(modData)
    if not store then return false end

    store[state.characterKey] = {
        version = DT_Reputation.VERSION,
        personalRep = Internal.CloneTable(state.personalRep),
        factionBias = Internal.CloneTable(state.factionBias),
        tradeProgress = Internal.CloneTable(state.tradeProgress),
        totalBought = Internal.CloneTable(state.totalBought),
        totalSold = Internal.CloneTable(state.totalSold),
        totalGifted = Internal.CloneTable(state.totalGifted),
    }

    if isClient() and player.transmitModData then
        player:transmitModData()
    end

    state.dirty = false
    state.saveDueAt = nil
    return true
end

function DT_Reputation.LoadForCharacter(characterKey)
    Internal.ResetState(characterKey)

    local player = Internal.GetLocalPlayer()
    if not player then return false end

    local modData = player:getModData()
    if not modData then return false end

    local store = Internal.GetReputationStore(modData)
    if not store then return false end

    local entry = store[characterKey]
    if not entry then
        DT_Reputation.Save()
        return true
    end

    for key, value in pairs(entry.personalRep or {}) do
        DT_Reputation.state.personalRep[key] = DT_Reputation.Clamp(value)
    end
    for key, value in pairs(entry.factionBias or {}) do
        DT_Reputation.state.factionBias[key] = DT_Reputation.Clamp(value)
    end
    for key, value in pairs(entry.tradeProgress or {}) do
        DT_Reputation.state.tradeProgress[key] = restoreAccumulatedValue(value)
    end
    for key, value in pairs(entry.totalBought or {}) do
        DT_Reputation.state.totalBought[key] = restoreAccumulatedValue(value)
    end
    for key, value in pairs(entry.totalSold or {}) do
        DT_Reputation.state.totalSold[key] = restoreAccumulatedValue(value)
    end
    for key, value in pairs(entry.totalGifted or {}) do
        DT_Reputation.state.totalGifted[key] = restoreAccumulatedValue(value)
    end

    DT_Reputation.state.dirty = false
    return true
end

function DT_Reputation.EnsureLoaded()
    local player = Internal.GetLocalPlayer()
    if not player then return false end

    local characterKey = DT_Reputation.EnsureCharacterKey(player)
    if not characterKey then return false end

    local state = DT_Reputation.state
    if state.loaded and state.characterKey == characterKey then
        return true
    end

    return DT_Reputation.LoadForCharacter(characterKey)
end
