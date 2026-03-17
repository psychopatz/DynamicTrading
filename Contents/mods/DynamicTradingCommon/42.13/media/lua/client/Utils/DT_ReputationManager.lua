if isServer() then return end

DT_ReputationManager = DT_ReputationManager or {}

DT_ReputationManager.VERSION = 1
DT_ReputationManager.CHARACTER_KEY_MODDATA = "DT_ReputationCharacterKey"
DT_ReputationManager.REP_MODDATA_KEY = "DT_ReputationState"
DT_ReputationManager.REP_MIN = -100
DT_ReputationManager.REP_MAX = 100
DT_ReputationManager.TRADE_THRESHOLD = 500
DT_ReputationManager.TRADE_REP_GAIN = 2
DT_ReputationManager.KILL_PENALTY = -30
DT_ReputationManager.INCAP_PENALTY = -25
DT_ReputationManager.RECRUIT_PENALTY = -15
DT_ReputationManager.HIT_ATTRIBUTION_MS = 15000
DT_ReputationManager.FAST_KILL_CONFIRM_MS = 2500
DT_ReputationManager.SAVE_DEBOUNCE_MS = 1500
DT_ReputationManager.SHOW_HALO_DEBUG = false
DT_ReputationManager.AUTO_DEBUG = false

DT_ReputationManager.state = DT_ReputationManager.state or {
    characterKey = nil,
    loaded = false,
    dirty = false,
    saveDueAt = nil,
    personalRep = {},
    factionBias = {},
    tradeProgress = {},
    totalBought = {},
    totalSold = {},
    factionRepCache = {},
    recentHits = {},
}

local function log(category, text)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Rep", category, text)
    end
end

local function getLocalPlayer()
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

local function showHalo(text, isPositive)
    if not DT_ReputationManager.SHOW_HALO_DEBUG then return end
    if not HaloTextHelper then return end

    local player = getLocalPlayer()
    if not player then return end

    local color = isPositive and HaloTextHelper.getColorGreen() or HaloTextHelper.getColorRed()
    HaloTextHelper.addTextWithArrow(player, text, isPositive, color)
end
local function sanitizeKey(text)
    return tostring(text or "unknown"):gsub("[^%w_%-]", "_")
end

local function getSafeSteamID(player)
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

local function getReputationStore(modData)
    if not modData then return nil end
    if type(modData[DT_ReputationManager.REP_MODDATA_KEY]) ~= "table" then
        modData[DT_ReputationManager.REP_MODDATA_KEY] = {}
    end
    return modData[DT_ReputationManager.REP_MODDATA_KEY]
end

local function cloneTable(src)
    local out = {}
    for k, v in pairs(src or {}) do
        out[k] = v
    end
    return out
end

local function invalidateFactionCache(factionID)
    if not factionID then return end
    DT_ReputationManager.state.factionRepCache[factionID] = nil
end

local function invalidateAllFactionCache()
    DT_ReputationManager.state.factionRepCache = {}
end

local function queueSave(delayMs)
    local state = DT_ReputationManager.state
    state.dirty = true
    state.saveDueAt = getTimeInMillis() + (delayMs or DT_ReputationManager.SAVE_DEBOUNCE_MS)
end

local function isSoulAlive(soul)
    if not soul then
        return true
    end

    return soul.status ~= "Dead"
end

local function resetState(characterKey)
    DT_ReputationManager.state.characterKey = characterKey
    DT_ReputationManager.state.loaded = true
    DT_ReputationManager.state.dirty = false
    DT_ReputationManager.state.saveDueAt = nil
    DT_ReputationManager.state.personalRep = {}
    DT_ReputationManager.state.factionBias = {}
    DT_ReputationManager.state.tradeProgress = {}
    DT_ReputationManager.state.totalBought = {}
    DT_ReputationManager.state.totalSold = {}
    DT_ReputationManager.state.factionRepCache = {}
    DT_ReputationManager.state.recentHits = {}
end

function DT_ReputationManager.Clamp(value)
    local n = tonumber(value) or 0
    if n < DT_ReputationManager.REP_MIN then
        return DT_ReputationManager.REP_MIN
    end
    if n > DT_ReputationManager.REP_MAX then
        return DT_ReputationManager.REP_MAX
    end
    return math.floor(n + (n >= 0 and 0.5 or -0.5))
end

function DT_ReputationManager.GetStageData(rep)
    local value = DT_ReputationManager.Clamp(rep)

    if value >= 80 then
        return { label = "Exalted", color = { r = 1.0, g = 0.8, b = 0.0 } }
    elseif value >= 40 then
        return { label = "Honored", color = { r = 0.2, g = 1.0, b = 0.2 } }
    elseif value >= 10 then
        return { label = "Friendly", color = { r = 0.5, g = 1.0, b = 0.5 } }
    elseif value > -10 then
        return { label = "Neutral", color = { r = 0.8, g = 0.8, b = 0.8 } }
    elseif value > -40 then
        return { label = "Unfriendly", color = { r = 1.0, g = 0.5, b = 0.2 } }
    elseif value > -80 then
        return { label = "Hostile", color = { r = 1.0, g = 0.2, b = 0.2 } }
    end

    return { label = "Nemesis", color = { r = 0.8, g = 0.0, b = 0.0 } }
end

local function generateCharacterKey(player)
    local desc = player and player:getDescriptor()
    local first = desc and desc:getForename() or "Survivor"
    local last = desc and desc:getSurname() or "Unknown"
    local username = (player and player.getUsername and player:getUsername()) or "local"
    local steamID = getSafeSteamID(player)
    local mode = (isClient() and not isServer()) and "MP" or "SP"
    return table.concat({
        mode,
        sanitizeKey(username),
        sanitizeKey(steamID),
        sanitizeKey(first),
        sanitizeKey(last),
    }, "_")
end

local function getTraderDebugName(traderUUID)
    if not traderUUID then return "Unknown Trader" end

    local npcClient = rawget(_G, "DTNPCClient")
    if npcClient and npcClient.NPCCache and npcClient.NPCCache[traderUUID] and npcClient.NPCCache[traderUUID].npcData then
        return npcClient.NPCCache[traderUUID].npcData.name or traderUUID
    end

    local roster = ModData.get("DynamicTrading_Roster") or {}
    local soul = roster.Souls and roster.Souls[traderUUID]
    if soul and soul.name then
        return soul.name
    end

    return tostring(traderUUID)
end

local function getFactionDebugName(factionID)
    if not factionID then return "NoFaction" end

    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local faction = factionData[factionID]
    if faction and faction.name then
        return faction.name
    end

    return tostring(factionID)
end

function DT_ReputationManager.EnsureCharacterKey(player)
    if not player then return nil end

    local modData = player:getModData()
    if not modData then return nil end

    local keyName = DT_ReputationManager.CHARACTER_KEY_MODDATA
    local stableKey = generateCharacterKey(player)
    local oldKey = modData[keyName]
    if oldKey and oldKey ~= "" and oldKey ~= stableKey then
        local store = getReputationStore(modData)
        if store and store[oldKey] and not store[stableKey] then
            store[stableKey] = store[oldKey]
            store[oldKey] = nil
            log("Init", "Migrated reputation data from legacy key " .. tostring(oldKey) .. " to " .. tostring(stableKey))
        end
    end

    if oldKey ~= stableKey then
        modData[keyName] = stableKey
        log("Init", "Assigned stable reputation character key: " .. tostring(modData[keyName]))
        if isClient() and player.transmitModData then
            player:transmitModData()
        end
    end

    return modData[keyName]
end

function DT_ReputationManager.Save()
    local state = DT_ReputationManager.state
    if not state.loaded or not state.characterKey then return false end

    local player = getLocalPlayer()
    if not player then return false end
    local modData = player:getModData()
    if not modData then return false end

    local store = getReputationStore(modData)
    if not store then return false end

    store[state.characterKey] = {
        version = DT_ReputationManager.VERSION,
        personalRep = cloneTable(state.personalRep),
        factionBias = cloneTable(state.factionBias),
        tradeProgress = cloneTable(state.tradeProgress),
        totalBought = cloneTable(state.totalBought),
        totalSold = cloneTable(state.totalSold),
    }

    if isClient() and player.transmitModData then
        player:transmitModData()
    end

    state.dirty = false
    state.saveDueAt = nil
    return true
end

function DT_ReputationManager.LoadForCharacter(characterKey)
    resetState(characterKey)

    local player = getLocalPlayer()
    if not player then return false end
    local modData = player:getModData()
    if not modData then return false end

    local store = getReputationStore(modData)
    if not store then return false end

    local entry = store[characterKey]
    if not entry then
        DT_ReputationManager.Save()
        return true
    end

    for key, value in pairs(entry.personalRep or {}) do
        DT_ReputationManager.state.personalRep[key] = DT_ReputationManager.Clamp(value)
    end
    for key, value in pairs(entry.factionBias or {}) do
        DT_ReputationManager.state.factionBias[key] = DT_ReputationManager.Clamp(value)
    end
    for key, value in pairs(entry.tradeProgress or {}) do
        DT_ReputationManager.state.tradeProgress[key] = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    end
    for key, value in pairs(entry.totalBought or {}) do
        DT_ReputationManager.state.totalBought[key] = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    end
    for key, value in pairs(entry.totalSold or {}) do
        DT_ReputationManager.state.totalSold[key] = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    end

    DT_ReputationManager.state.dirty = false
    return true
end

function DT_ReputationManager.EnsureLoaded()
    local player = getLocalPlayer()
    if not player then return false end

    local characterKey = DT_ReputationManager.EnsureCharacterKey(player)
    if not characterKey then return false end

    local state = DT_ReputationManager.state
    if state.loaded and state.characterKey == characterKey then
        return true
    end

    return DT_ReputationManager.LoadForCharacter(characterKey)
end

function DT_ReputationManager.GetPersonalRep(traderUUID)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    return DT_ReputationManager.state.personalRep[traderUUID] or 0
end

function DT_ReputationManager.GetFactionBias(factionID)
    if not factionID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    return DT_ReputationManager.state.factionBias[factionID] or 0
end

function DT_ReputationManager.GetEffectiveRep(traderUUID, factionID)
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    local personal = traderUUID and (DT_ReputationManager.state.personalRep[traderUUID] or 0) or 0
    local bias = factionID and (DT_ReputationManager.state.factionBias[factionID] or 0) or 0
    return DT_ReputationManager.Clamp(personal + bias)
end

function DT_ReputationManager.GetFactionRep(factionID, rosterData)
    if not factionID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end

    local useCache = (rosterData == nil)
    if useCache then
        local cached = DT_ReputationManager.state.factionRepCache[factionID]
        if cached ~= nil then
            return cached
        end
    end

    local roster = rosterData or ModData.get("DynamicTrading_Roster") or {}
    local members = roster.FactionMembers and roster.FactionMembers[factionID]
    if (not members or #members == 0) and roster.Souls then
        members = {}
        for uuid, soul in pairs(roster.Souls) do
            if soul and soul.factionID == factionID then
                table.insert(members, uuid)
            end
        end
    end

    local souls = roster.Souls or {}
    local bias = DT_ReputationManager.state.factionBias[factionID] or 0

    if not members or #members == 0 then
        local result = DT_ReputationManager.Clamp(bias)
        if useCache then
            DT_ReputationManager.state.factionRepCache[factionID] = result
        end
        return result
    end

    local state = DT_ReputationManager.state
    local total = 0
    local count = 0
    for _, uuid in ipairs(members) do
        if isSoulAlive(souls[uuid]) then
            local personal = state.personalRep[uuid] or 0
            total = total + DT_ReputationManager.Clamp(personal + bias)
            count = count + 1
        end
    end

    if count <= 0 then
        local result = DT_ReputationManager.Clamp(bias)
        if useCache then
            DT_ReputationManager.state.factionRepCache[factionID] = result
        end
        return result
    end

    local result = DT_ReputationManager.Clamp(total / count)
    if useCache then
        DT_ReputationManager.state.factionRepCache[factionID] = result
    end
    return result
end

function DT_ReputationManager.AddTradeValue(traderUUID, factionID, amount, isBuy)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end

    local tradeValue = math.max(0, math.floor((tonumber(amount) or 0) + 0.5))
    if tradeValue <= 0 then return 0 end

    local state = DT_ReputationManager.state
    if isBuy == true then
        state.totalBought[traderUUID] = (state.totalBought[traderUUID] or 0) + tradeValue
    elseif isBuy == false then
        state.totalSold[traderUUID] = (state.totalSold[traderUUID] or 0) + tradeValue
    end
    local progress = (state.tradeProgress[traderUUID] or 0) + tradeValue
    local gained = 0

    while progress >= DT_ReputationManager.TRADE_THRESHOLD do
        progress = progress - DT_ReputationManager.TRADE_THRESHOLD
        state.personalRep[traderUUID] = DT_ReputationManager.Clamp((state.personalRep[traderUUID] or 0) + DT_ReputationManager.TRADE_REP_GAIN)
        gained = gained + DT_ReputationManager.TRADE_REP_GAIN
    end

    state.tradeProgress[traderUUID] = progress
    invalidateFactionCache(factionID)
    queueSave()

    if gained > 0 then
        log(
            "Trade",
            "Trader [" .. tostring(traderUUID) .. "] gained +" .. tostring(gained) ..
                " personal rep from combined trade volume. Faction=" .. tostring(factionID or "None")
        )
        showHalo("Rep +" .. tostring(gained), true)
    end

    if DT_ReputationManager.AUTO_DEBUG then
        DT_ReputationManager.DebugDump(traderUUID, factionID, "trade")
    end

    return gained
end

-- Shared V1/V2 helper: apply trade result to reputation and optionally update trader fields.
function DT_ReputationManager.ApplyTradeResult(args, trader, isBuy)
    if not DT_ReputationManager then return end

    local traderID = nil
    if args and args.traderID then
        traderID = args.traderID
    elseif trader then
        traderID = trader.traderID or trader.uuid or trader.id
    end

    if not traderID then return end

    local factionID = (args and args.factionID) or (trader and trader.factionID) or nil
    local price = (args and args.price) or 0

    DT_ReputationManager.AddTradeValue(traderID, factionID, price, isBuy == true)

    if trader then
        trader.personalRep = DT_ReputationManager.GetPersonalRep(traderID)
        trader.factionRep = DT_ReputationManager.GetFactionRep(factionID)
        trader.reputation = DT_ReputationManager.GetEffectiveRep(traderID, factionID)
        trader.reputationStage = DT_ReputationManager.GetStageData(trader.reputation).label
    end
end

function DT_ReputationManager.ModifyFactionBias(factionID, amount, reason)
    if not factionID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end

    local state = DT_ReputationManager.state
    local newValue = DT_ReputationManager.Clamp((state.factionBias[factionID] or 0) + (tonumber(amount) or 0))
    state.factionBias[factionID] = newValue
    invalidateFactionCache(factionID)
    queueSave()

    log("Faction", "Faction [" .. tostring(factionID) .. "] bias changed to " .. tostring(newValue) .. " reason=" .. tostring(reason or "n/a"))
    if (tonumber(amount) or 0) ~= 0 then
        local prefix = (tonumber(amount) or 0) > 0 and "+" or ""
        showHalo("Faction Rep " .. prefix .. tostring(amount), (tonumber(amount) or 0) > 0)
    end
    if DT_ReputationManager.AUTO_DEBUG then
        DT_ReputationManager.DebugDump(nil, factionID, "faction_" .. tostring(reason or "change"))
    end
    return newValue
end

function DT_ReputationManager.ModifyPersonalRep(traderUUID, factionID, amount, reason)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end

    local state = DT_ReputationManager.state
    local newValue = DT_ReputationManager.Clamp((state.personalRep[traderUUID] or 0) + (tonumber(amount) or 0))
    state.personalRep[traderUUID] = newValue
    invalidateFactionCache(factionID)
    queueSave()

    log("Personal", "Trader [" .. tostring(traderUUID) .. "] personal rep changed to " .. tostring(newValue) .. " reason=" .. tostring(reason or "n/a"))
    if (tonumber(amount) or 0) ~= 0 then
        local prefix = (tonumber(amount) or 0) > 0 and "+" or ""
        showHalo("Rep " .. prefix .. tostring(amount), (tonumber(amount) or 0) > 0)
    end
    if DT_ReputationManager.AUTO_DEBUG then
        DT_ReputationManager.DebugDump(traderUUID, factionID, "personal_" .. tostring(reason or "change"))
    end
    return newValue
end

function DT_ReputationManager.ApplyKillPenalty(factionID)
    return DT_ReputationManager.ModifyFactionBias(factionID, DT_ReputationManager.KILL_PENALTY, "kill")
end

function DT_ReputationManager.ApplyIncapPenalty(traderUUID, factionID)
    return DT_ReputationManager.ModifyPersonalRep(traderUUID, factionID, DT_ReputationManager.INCAP_PENALTY, "incap")
end

function DT_ReputationManager.ApplyRecruitPenalty(factionID)
    return DT_ReputationManager.ModifyFactionBias(factionID, DT_ReputationManager.RECRUIT_PENALTY, "recruit")
end

function DT_ReputationManager.RecordNPCHit(uuid, factionID)
    if not uuid then return end
    if not DT_ReputationManager.EnsureLoaded() then return end

    DT_ReputationManager.state.recentHits[uuid] = {
        factionID = factionID,
        at = getTimeInMillis(),
    }
end

local function isLocalPlayerKiller(killerUsername, killerOnlineID)
    local player = getLocalPlayer()
    if not player then return false end

    if killerOnlineID ~= nil and player.getOnlineID and player:getOnlineID() == killerOnlineID then
        return true
    end

    if killerUsername and player.getUsername and player:getUsername() == killerUsername then
        return true
    end

    return false
end

function DT_ReputationManager.TryApplyKillPenalty(uuid, factionID, zombie, killerUsername, killerOnlineID)
    if not uuid then return false end
    if not DT_ReputationManager.EnsureLoaded() then return false end

    local hit = DT_ReputationManager.state.recentHits[uuid]
    DT_ReputationManager.state.recentHits[uuid] = nil

    local confirmedDead = false
    if zombie and (zombie:isDead() or zombie:getHealth() <= 0) then
        confirmedDead = true
    elseif hit and (getTimeInMillis() - (hit.at or 0)) <= DT_ReputationManager.FAST_KILL_CONFIRM_MS then
        confirmedDead = true
    end

    if killerUsername ~= nil or killerOnlineID ~= nil then
        local resolvedFactionID = factionID or (hit and hit.factionID) or nil
        if resolvedFactionID and isLocalPlayerKiller(killerUsername, killerOnlineID) then
            DT_ReputationManager.ApplyKillPenalty(resolvedFactionID)
            if DT_ReputationManager.AUTO_DEBUG then
                DT_ReputationManager.DebugDump(uuid, resolvedFactionID, "kill_confirmed_server")
            end
            return true
        end
        return false
    end

    if not hit then
        return false
    end

    local elapsed = getTimeInMillis() - (hit.at or 0)
    if elapsed > DT_ReputationManager.HIT_ATTRIBUTION_MS then
        return false
    end

    if not confirmedDead then
        return false
    end

    local resolvedFactionID = factionID or hit.factionID
    if not resolvedFactionID then
        return false
    end

    DT_ReputationManager.ApplyKillPenalty(resolvedFactionID)
    if DT_ReputationManager.AUTO_DEBUG then
        DT_ReputationManager.DebugDump(uuid, resolvedFactionID, "kill_confirmed")
    end
    return true
end

function DT_ReputationManager.GetTradeProgress(traderUUID)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    return DT_ReputationManager.state.tradeProgress[traderUUID] or 0
end

function DT_ReputationManager.GetTotalBought(traderUUID)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    return DT_ReputationManager.state.totalBought[traderUUID] or 0
end

function DT_ReputationManager.GetTotalSold(traderUUID)
    if not traderUUID then return 0 end
    if not DT_ReputationManager.EnsureLoaded() then return 0 end
    return DT_ReputationManager.state.totalSold[traderUUID] or 0
end

function DT_ReputationManager.GetDebugSnapshot(traderUUID, factionID)
    if not DT_ReputationManager.EnsureLoaded() then return nil end

    return {
        characterKey = DT_ReputationManager.state.characterKey,
        modDataKey = DT_ReputationManager.CHARACTER_KEY_MODDATA,
        traderUUID = traderUUID,
        traderName = getTraderDebugName(traderUUID),
        factionID = factionID,
        factionName = getFactionDebugName(factionID),
        personalRep = traderUUID and DT_ReputationManager.GetPersonalRep(traderUUID) or 0,
        factionBias = factionID and DT_ReputationManager.GetFactionBias(factionID) or 0,
        effectiveRep = traderUUID and DT_ReputationManager.GetEffectiveRep(traderUUID, factionID) or 0,
        factionRep = factionID and DT_ReputationManager.GetFactionRep(factionID) or 0,
        tradeProgress = traderUUID and DT_ReputationManager.GetTradeProgress(traderUUID) or 0,
        totalBought = traderUUID and DT_ReputationManager.GetTotalBought(traderUUID) or 0,
        totalSold = traderUUID and DT_ReputationManager.GetTotalSold(traderUUID) or 0,
    }
end

function DT_ReputationManager.DebugDump(traderUUID, factionID, reason)
    local snapshot = DT_ReputationManager.GetDebugSnapshot(traderUUID, factionID)
    if not snapshot then return nil end

    log(
        "Debug",
        "[" .. tostring(reason or "manual") .. "] modDataKey=" .. tostring(snapshot.modDataKey) ..
            " modDataValue=" .. tostring(snapshot.characterKey) ..
            " trader=" .. tostring(snapshot.traderName) .. " (" .. tostring(snapshot.traderUUID) .. ")" ..
            " faction=" .. tostring(snapshot.factionName) .. " (" .. tostring(snapshot.factionID) .. ")" ..
            " personal=" .. tostring(snapshot.personalRep) ..
            " factionBias=" .. tostring(snapshot.factionBias) ..
            " effective=" .. tostring(snapshot.effectiveRep) ..
            " factionRep=" .. tostring(snapshot.factionRep) ..
            " progress=" .. tostring(snapshot.tradeProgress) .. "/" .. tostring(DT_ReputationManager.TRADE_THRESHOLD) ..
            " bought=" .. tostring(snapshot.totalBought) ..
            " sold=" .. tostring(snapshot.totalSold)
    )

    return snapshot
end

function DT_ReputationManager.DebugDumpCurrent(reason)
    local traderUUID = nil
    local factionID = nil

    if DT_ConversationUI and DT_ConversationUI.instance and DT_ConversationUI.instance.target then
        local target = DT_ConversationUI.instance.target
        traderUUID = target.uuid or target.traderID or target.id
        factionID = target.factionID
    elseif DT_TradingWindow and DT_TradingWindow.instance then
        local ui = DT_TradingWindow.instance
        traderUUID = ui.traderID
        if ui.dataProvider and ui.dataProvider.getTrader then
            local trader = ui.dataProvider:getTrader(ui.traderID, ui.archetype)
            factionID = trader and trader.factionID or nil
        end
    end

    return DT_ReputationManager.DebugDump(traderUUID, factionID, reason or "current")
end

local function onCreatePlayer()
    DT_ReputationManager.EnsureLoaded()
end

local function onGameStart()
    DT_ReputationManager.EnsureLoaded()
end

local function onReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Roster" then
        invalidateAllFactionCache()
    end
end

local function onTick()
    local state = DT_ReputationManager.state
    if not state.dirty or not state.saveDueAt then return end
    if getTimeInMillis() >= state.saveDueAt then
        DT_ReputationManager.Save()
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
Events.OnTick.Add(onTick)
