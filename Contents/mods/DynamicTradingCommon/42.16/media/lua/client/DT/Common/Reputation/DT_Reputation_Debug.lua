if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

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

function DT_Reputation.GetDebugSnapshot(traderUUID, factionID)
    if not DT_Reputation.EnsureLoaded() then return nil end

    return {
        characterKey = DT_Reputation.state.characterKey,
        modDataKey = DT_Reputation.CHARACTER_KEY_MODDATA,
        traderUUID = traderUUID,
        traderName = getTraderDebugName(traderUUID),
        factionID = factionID,
        factionName = getFactionDebugName(factionID),
        personalRep = traderUUID and DT_Reputation.GetPersonalRep(traderUUID, factionID) or 0,
        factionBias = factionID and DT_Reputation.GetFactionBias(factionID) or 0,
        effectiveRep = traderUUID and DT_Reputation.GetEffectiveRep(traderUUID, factionID) or 0,
        factionRep = factionID and DT_Reputation.GetFactionRep(factionID) or 0,
        tradeProgress = traderUUID and DT_Reputation.GetTradeProgress(traderUUID) or 0,
        totalBought = traderUUID and DT_Reputation.GetTotalBought(traderUUID) or 0,
        totalSold = traderUUID and DT_Reputation.GetTotalSold(traderUUID) or 0,
        totalGifted = traderUUID and DT_Reputation.GetTotalGifted(traderUUID) or 0,
    }
end

function DT_Reputation.DebugDump(traderUUID, factionID, reason)
    local snapshot = DT_Reputation.GetDebugSnapshot(traderUUID, factionID)
    if not snapshot then return nil end

    Internal.Log(
        "Debug",
        "[" .. tostring(reason or "manual") .. "] modDataKey=" .. tostring(snapshot.modDataKey) ..
            " modDataValue=" .. tostring(snapshot.characterKey) ..
            " trader=" .. tostring(snapshot.traderName) .. " (" .. tostring(snapshot.traderUUID) .. ")" ..
            " faction=" .. tostring(snapshot.factionName) .. " (" .. tostring(snapshot.factionID) .. ")" ..
            " personal=" .. tostring(snapshot.personalRep) ..
            " factionBias=" .. tostring(snapshot.factionBias) ..
            " effective=" .. tostring(snapshot.effectiveRep) ..
            " factionRep=" .. tostring(snapshot.factionRep) ..
            " progress=" .. tostring(snapshot.tradeProgress) .. "/" .. tostring(DT_Reputation.TRADE_THRESHOLD) ..
            " bought=" .. tostring(snapshot.totalBought) ..
                " sold=" .. tostring(snapshot.totalSold) ..
                " gifted=" .. tostring(snapshot.totalGifted)
    )

    return snapshot
end

function DT_Reputation.DebugDumpCurrent(reason)
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

    return DT_Reputation.DebugDump(traderUUID, factionID, reason or "current")
end
