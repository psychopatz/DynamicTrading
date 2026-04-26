if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

function DT_Reputation.ModifyFactionBias(factionID, amount, reason)
    if not factionID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local state = DT_Reputation.state
    local delta = tonumber(amount) or 0
    local oldFactionRep = DT_Reputation.GetFactionRep(factionID)
    local newValue = DT_Reputation.Clamp((state.factionBias[factionID] or 0) + delta)

    state.factionBias[factionID] = newValue
    Internal.InvalidateFactionCache(factionID)
    Internal.QueueSave()

    Internal.Log("Faction", "Faction [" .. tostring(factionID) .. "] bias changed to " .. tostring(newValue) .. " reason=" .. tostring(reason or "n/a"))
    if delta ~= 0 then
        local prefix = delta > 0 and "+" or ""
        local newFactionRep = DT_Reputation.GetFactionRep(factionID)
        Internal.ShowHalo(
            Internal.BuildRepHaloText("Faction Rep " .. prefix .. tostring(amount), factionID, oldFactionRep, newFactionRep),
            delta > 0
        )
    end
    if DT_Reputation.AUTO_DEBUG then
        DT_Reputation.DebugDump(nil, factionID, "faction_" .. tostring(reason or "change"))
    end

    return newValue
end

function DT_Reputation.ModifyPersonalRep(traderUUID, factionID, amount, reason)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local state = DT_Reputation.state
    local delta = tonumber(amount) or 0
    local oldEffectiveRep = nil
    if factionID then
        oldEffectiveRep = DT_Reputation.GetEffectiveRep(traderUUID, factionID)
    else
        oldEffectiveRep = state.personalRep[traderUUID] or 0
    end
    local newValue = DT_Reputation.Clamp((state.personalRep[traderUUID] or 0) + delta)

    state.personalRep[traderUUID] = newValue
    Internal.InvalidateFactionCache(factionID)
    Internal.QueueSave()

    Internal.Log("Personal", "Trader [" .. tostring(traderUUID) .. "] personal rep changed to " .. tostring(newValue) .. " reason=" .. tostring(reason or "n/a"))
    local newEffectiveRep = nil
    if factionID then
        newEffectiveRep = DT_Reputation.GetEffectiveRep(traderUUID, factionID)
    else
        newEffectiveRep = newValue
    end

    if delta > 0 then
        Internal.ShowTraderHalo(
            traderUUID,
            Internal.BuildRepHaloText("Rep +" .. tostring(amount), factionID, oldEffectiveRep, newEffectiveRep),
            true,
            true
        )
    elseif delta < 0 then
        Internal.ShowTraderHalo(
            traderUUID,
            Internal.BuildRepHaloText("Rep " .. tostring(amount), factionID, oldEffectiveRep, newEffectiveRep),
            false,
            true
        )
    end
    if DT_Reputation.AUTO_DEBUG then
        DT_Reputation.DebugDump(traderUUID, factionID, "personal_" .. tostring(reason or "change"))
    end

    return newValue
end

function DT_Reputation.ApplyRosterPersonalRepSync(memberUUIDs, factionID, mode, value, reason)
    if type(memberUUIDs) ~= "table" or #memberUUIDs <= 0 then
        return 0
    end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local state = DT_Reputation.state
    local syncMode = tostring(mode or "add")
    local delta = tonumber(value) or 0
    local changedCount = 0
    local seen = {}
    local resetFactionBias = (syncMode == "set" and delta <= DT_Reputation.REP_MIN and factionID ~= nil)

    for _, rawUUID in ipairs(memberUUIDs) do
        local traderUUID = rawUUID and tostring(rawUUID) or nil
        if traderUUID and not seen[traderUUID] then
            local currentValue = state.personalRep[traderUUID] or 0
            local nextValue = currentValue

            if syncMode == "set" then
                nextValue = DT_Reputation.Clamp(delta)
            else
                nextValue = DT_Reputation.Clamp(currentValue + delta)
            end

            if nextValue ~= currentValue then
                state.personalRep[traderUUID] = nextValue
                changedCount = changedCount + 1
            end

            seen[traderUUID] = true
        end
    end

    if resetFactionBias and (state.factionBias[factionID] or 0) ~= 0 then
        state.factionBias[factionID] = 0
        changedCount = math.max(changedCount, 1)
    end

    if changedCount > 0 then
        Internal.InvalidateFactionCache(factionID)
        Internal.QueueSave()
        Internal.Log(
            "RosterSync",
            "Applied roster reputation sync faction=" .. tostring(factionID)
                .. " mode=" .. tostring(syncMode)
                .. " value=" .. tostring(delta)
                .. " members=" .. tostring(changedCount)
                .. " reason=" .. tostring(reason or "n/a")
        )
    end

    return changedCount
end

function DT_Reputation.ApplyKillPenalty(factionID)
    return DT_Reputation.ModifyFactionBias(factionID, DT_Reputation.KILL_PENALTY, "kill")
end

function DT_Reputation.ApplyIncapPenalty(traderUUID, factionID)
    return DT_Reputation.ModifyPersonalRep(traderUUID, factionID, DT_Reputation.INCAP_PENALTY, "incap")
end

function DT_Reputation.ApplyRecruitPenalty(factionID)
    return DT_Reputation.ModifyFactionBias(factionID, DT_Reputation.RECRUIT_PENALTY, "recruit")
end
