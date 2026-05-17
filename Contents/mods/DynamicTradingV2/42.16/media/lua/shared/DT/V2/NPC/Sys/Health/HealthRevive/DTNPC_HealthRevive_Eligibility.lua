-- ==============================================================================
-- DTNPC_HealthRevive_Eligibility.lua
-- Shared revive eligibility and deterministic cost preparation helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function ensureReviveDataTable(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    if type(npcData.reviveData) ~= "table" then
        npcData.reviveData = {}
    end

    return npcData.reviveData
end

internal.ensureReviveDataTable = ensureReviveDataTable

local function isReviveExcludedNPC(npcData)
    if not npcData then
        return true
    end

    if npcData.isHostile == true or npcData.isBandit == true or npcData.raidHostileFaction == true then
        return true
    end

    if tostring(npcData.factionID or "") == "Bandits" then
        return true
    end

    if tostring(npcData.tradeCycleMode or "") == "hostile_bribe" then
        return true
    end

    return npcData.banditGroupID ~= nil
end

internal.isReviveExcludedNPC = isReviveExcludedNPC

local function prepareIncapacitatedReviveData(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local reviveData = ensureReviveDataTable(npcData)
    if not reviveData then
        return nil
    end

    local requiredCount = tonumber(reviveData.requiredItemCount) or 0
    if requiredCount <= 0 then
        requiredCount = DTNPCHealth.RollReviveCost()
        reviveData.requiredItemCount = requiredCount
    else
        reviveData.requiredItemCount = math.max(1, math.floor(requiredCount))
    end

    if reviveData.generatedAt == nil and internal.nowMillis then
        reviveData.generatedAt = internal.nowMillis()
    end

    return reviveData
end

internal.prepareIncapacitatedReviveData = prepareIncapacitatedReviveData

function DTNPCHealth.CanPlayerRevive(playerObj, npcData, options)
    options = type(options) == "table" and options or {}

    if type(npcData) ~= "table" then
        return false, { reason = "invalid_target" }
    end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return false, { reason = "dead_target" }
    end

    local healthState = DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(npcData) or nil
    if healthState ~= "Incapacitated" then
        return false, {
            reason = "not_incapacitated",
            healthState = healthState,
        }
    end

    if isReviveExcludedNPC(npcData) then
        return false, {
            reason = "excluded_target",
            healthState = healthState,
        }
    end

    local reviveData = type(npcData.reviveData) == "table" and npcData.reviveData or nil
    local requiredCount = tonumber(reviveData and reviveData.requiredItemCount) or nil
    if (not requiredCount or requiredCount <= 0) and not (internal.isRemoteClient and internal.isRemoteClient()) then
        reviveData = prepareIncapacitatedReviveData(npcData)
        requiredCount = tonumber(reviveData and reviveData.requiredItemCount) or nil
    end
    if requiredCount and requiredCount > 0 then
        requiredCount = math.max(1, math.floor(requiredCount))
    else
        requiredCount = nil
    end

    local requiredFullType = options.requiredFullType ~= nil and tostring(options.requiredFullType) or nil
    local availableCount = playerObj and DTNPCHealth.CountReviveItems and DTNPCHealth.CountReviveItems(playerObj, requiredFullType) or 0
    local ignoreItems = options.ignoreItems == true

    if playerObj and not ignoreItems and requiredCount and availableCount < requiredCount then
        return false, {
            reason = "need_supplies",
            healthState = healthState,
            requiredCount = requiredCount,
            availableCount = availableCount,
            requiredFullType = requiredFullType,
        }
    end

    return true, {
        reason = "ok",
        healthState = healthState,
        requiredCount = requiredCount,
        availableCount = availableCount,
        requiredFullType = requiredFullType,
    }
end
