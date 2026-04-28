if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

function DT_Reputation.AddTradeValue(traderUUID, factionID, amount, isBuy, transactionKind)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local tradeValue = math.max(0, math.floor((tonumber(amount) or 0) + 0.5))
    if tradeValue <= 0 then return 0 end

    local state = DT_Reputation.state
    local oldEffectiveRep = nil
    if factionID then
        oldEffectiveRep = DT_Reputation.GetEffectiveRep(traderUUID, factionID)
    else
        oldEffectiveRep = state.personalRep[traderUUID] or 0
    end

    local kind = tostring(transactionKind or "")

    if kind == "gift" then
        state.totalGifted[traderUUID] = (state.totalGifted[traderUUID] or 0) + tradeValue
    elseif isBuy == true then
        state.totalBought[traderUUID] = (state.totalBought[traderUUID] or 0) + tradeValue
    elseif isBuy == false then
        state.totalSold[traderUUID] = (state.totalSold[traderUUID] or 0) + tradeValue
    end

    local progress = (state.tradeProgress[traderUUID] or 0) + tradeValue
    local gained = 0

    while progress >= DT_Reputation.TRADE_THRESHOLD do
        progress = progress - DT_Reputation.TRADE_THRESHOLD
        state.personalRep[traderUUID] = DT_Reputation.Clamp((state.personalRep[traderUUID] or 0) + DT_Reputation.TRADE_REP_GAIN)
        gained = gained + DT_Reputation.TRADE_REP_GAIN
    end

    state.tradeProgress[traderUUID] = progress
    Internal.InvalidateFactionCache(factionID)
    Internal.QueueSave()

    if gained > 0 then
        Internal.Log(
            "Trade",
            "Trader [" .. tostring(traderUUID) .. "] gained +" .. tostring(gained) ..
                " personal rep from combined trade volume. Faction=" .. tostring(factionID or "None")
        )
        local newEffectiveRep = nil
        if factionID then
            newEffectiveRep = DT_Reputation.GetEffectiveRep(traderUUID, factionID)
        else
            newEffectiveRep = state.personalRep[traderUUID] or 0
        end

        Internal.ShowTraderHalo(
            traderUUID,
            Internal.BuildRepHaloText("Rep +" .. tostring(gained), factionID, oldEffectiveRep, newEffectiveRep),
            true,
            true
        )
    end

    if DT_Reputation.AUTO_DEBUG then
        DT_Reputation.DebugDump(traderUUID, factionID, "trade")
    end

    return gained
end

-- Shared V1/V2 helper: apply trade result to reputation and optionally update trader fields.
function DT_Reputation.ApplyTradeResult(args, trader, isBuy)
    if not DT_Reputation then return end

    local traderID = nil
    if args and args.traderID then
        traderID = args.traderID
    elseif trader then
        traderID = trader.traderID or trader.uuid or trader.id
    end

    if not traderID then return end

    local factionID = (args and args.factionID) or (trader and trader.factionID) or nil
    local transactionKind = args and tostring(args.transactionKind or "") or ""
    local tradeValue = (args and (args.repValue or args.price)) or 0
    local effectiveIsBuy = (transactionKind == "gift") and false or (isBuy == true)

    DT_Reputation.AddTradeValue(traderID, factionID, tradeValue, effectiveIsBuy, transactionKind)

    if trader then
        trader.personalRep = DT_Reputation.GetPersonalRep(traderID, factionID)
        trader.factionRep = DT_Reputation.GetFactionRep(factionID)
        trader.reputation = DT_Reputation.GetEffectiveRep(traderID, factionID)
        trader.reputationStage = DT_Reputation.GetStageData(trader.reputation).label
        trader.totalGifted = DT_Reputation.GetTotalGifted(traderID)
    end
end
