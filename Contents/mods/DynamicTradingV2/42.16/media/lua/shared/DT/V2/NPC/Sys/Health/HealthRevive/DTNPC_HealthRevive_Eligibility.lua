-- ==============================================================================
-- DTNPC_HealthRevive_Eligibility.lua
-- Shared revive eligibility and deterministic cost preparation helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function shouldRequireReviveItems(npcData)
    if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
        local ok, result = pcall(DTNPCRoles.ShouldRequireItems, npcData, "revive")
        if ok then
            return result == true
        end
    end

    return true
end

local function isPlayerReviveLeaseHeldByAnotherPlayer(npcData, playerObj)
    local reviveData = type(npcData) == "table" and type(npcData.reviveData) == "table" and npcData.reviveData or nil
    if not reviveData then
        return false
    end

    local now = internal.nowMillis and internal.nowMillis() or 0
    local leaseUntil = tonumber(reviveData.playerReviveLeaseUntil) or 0
    if leaseUntil <= now then
        return false
    end

    if not playerObj then
        return true
    end

    local username = playerObj.getUsername and playerObj:getUsername() or nil
    local onlineID = playerObj.getOnlineID and playerObj:getOnlineID() or nil
    if reviveData.playerReviveLeaseUsername ~= nil
        and username ~= nil
        and tostring(reviveData.playerReviveLeaseUsername) ~= tostring(username) then
        return true
    end
    if reviveData.playerReviveLeaseOnlineID ~= nil
        and onlineID ~= nil
        and tonumber(reviveData.playerReviveLeaseOnlineID) ~= tonumber(onlineID) then
        return true
    end

    return false
end

local function hasTerminalDeathRequest(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return true
    end

    local combatHealth = type(npcData.combatHealth) == "table" and npcData.combatHealth or nil
    return (tonumber(combatHealth and combatHealth.incapFinalKillRequestedAt) or 0) > 0
end

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

function DTNPCHealth.CanReviveTarget(npcData, options)
    options = type(options) == "table" and options or {}

    if type(npcData) ~= "table" then
        return false, { reason = "invalid_target" }
    end
    if hasTerminalDeathRequest(npcData) then
        return false, { reason = "dead_target" }
    end

    local healthState = DTNPCHealth.GetHealthState and DTNPCHealth.GetHealthState(npcData) or nil
    if healthState ~= "Incapacitated" then
        return false, {
            reason = "not_incapacitated",
            healthState = healthState,
        }
    end

    if options.allowExcludedTarget ~= true and isReviveExcludedNPC(npcData) then
        return false, {
            reason = "excluded_target",
            healthState = healthState,
        }
    end

    if isPlayerReviveLeaseHeldByAnotherPlayer(npcData, options.playerObj) then
        return false, {
            reason = "already_helped",
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
    local playerObj = options.playerObj
    local ignoreItems = options.ignoreItems == true
    local requireItems = shouldRequireReviveItems(npcData) and not ignoreItems
    local availableCount = requireItems and playerObj and DTNPCHealth.CountReviveItems
        and DTNPCHealth.CountReviveItems(playerObj, requiredFullType)
        or 0

    if requireItems and playerObj and requiredCount and availableCount < requiredCount then
        return false, {
            reason = "need_supplies",
            healthState = healthState,
            requiredCount = requiredCount,
            availableCount = availableCount,
            requiredFullType = requiredFullType,
            requiresItems = true,
        }
    end

    return true, {
        reason = "ok",
        healthState = healthState,
        requiredCount = requiredCount,
        availableCount = availableCount,
        requiredFullType = requiredFullType,
        requiresItems = requireItems,
    }
end

function DTNPCHealth.CanPlayerRevive(playerObj, npcData, options)
    options = type(options) == "table" and options or {}

    local canRevive, info = DTNPCHealth.CanReviveTarget(npcData, {
        allowExcludedTarget = false,
        ignoreItems = options.ignoreItems == true,
        requiredFullType = options.requiredFullType,
        playerObj = playerObj,
    })
    if not canRevive then
        return false, info
    end

    return true, {
        reason = "ok",
        healthState = info and info.healthState or nil,
        requiredCount = info and info.requiredCount or nil,
        availableCount = info and info.availableCount or 0,
        requiredFullType = info and info.requiredFullType or nil,
        requiresItems = info and info.requiresItems or false,
    }
end
