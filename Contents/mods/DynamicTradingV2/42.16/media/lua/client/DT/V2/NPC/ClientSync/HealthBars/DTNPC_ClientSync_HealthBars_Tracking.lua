-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Tracking.lua
-- Tracking lifecycle and public health bar APIs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Tracking then
    return
end

modules.Tracking = true

local Constants = HealthBars.Constants
local Helpers = HealthBars.Helpers
local State = HealthBars.State

local function touchTrackedEntry(entry, zombie, npcData, bodyInstanceID, currentTime)
    if zombie then
        entry.zombie = zombie
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    end

    if bodyInstanceID then
        entry.bodyInstanceID = bodyInstanceID
    end

    if npcData then
        entry.npcData = npcData
        entry.isIncapacitated = Helpers.isIncapacitatedState(npcData) or false
        entry.isWeakened = Helpers.isWeakenedState(npcData) or false
        entry.hasActiveBandage = Helpers.hasActiveBandage(npcData) or false
        entry.bandageIconTexture = entry.hasActiveBandage and Helpers.getBandageIconTexture(npcData) or nil
        Helpers.cacheNameMetrics(entry, npcData.name)
        entry.currentHp, entry.maxHp = Helpers.resolveHealth(npcData, zombie or entry.zombie, entry.maxHp)
        entry.staminaCurrent = tonumber(npcData.staminaCurrent) or entry.staminaCurrent or 0
        entry.staminaMax = tonumber(npcData.staminaMax) or entry.staminaMax or 0
        entry.staminaState = npcData.staminaState or entry.staminaState

        if Helpers.isCombatState(npcData) then
            entry.visibleUntil = currentTime + Constants.COMBAT_SHOW_DURATION
        end
        if (tonumber(npcData._dtStaminaVisibleUntil) or 0) > currentTime then
            entry.visibleUntil = math.max(entry.visibleUntil or 0, tonumber(npcData._dtStaminaVisibleUntil) or 0)
        end
    elseif zombie then
        entry.currentHp, entry.maxHp = Helpers.resolveHealth(nil, zombie, entry.maxHp)
    end

    entry.lastSeenAt = currentTime
end

local function getTrackedEntry(uuid)
    local entry = DTNPCClient.HealthBarTracked[uuid]
    if entry then
        return entry
    end

    entry = {
        uuid = uuid,
        name = "Unknown",
        nameWidth = State.textManager:MeasureStringX(Constants.FONT_NAME, "Unknown"),
        currentHp = 1,
        maxHp = 1,
        staminaCurrent = 0,
        staminaMax = 0,
        staminaState = "fresh",
        isIncapacitated = false,
        isWeakened = false,
        hasActiveBandage = false,
        bandageIconTexture = nil,
        visibleUntil = 0,
        lastSeenAt = getTimeInMillis(),
        nextResolveAt = 0,
    }

    DTNPCClient.HealthBarTracked[uuid] = entry
    return entry
end

HealthBars.touchTrackedEntry = touchTrackedEntry
HealthBars.getTrackedEntry = getTrackedEntry

function DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, bodyInstanceID)
    local resolvedUUID = Helpers.deriveUUID(zombie, npcData, uuid)
    if not resolvedUUID then return nil end

    local entry = getTrackedEntry(resolvedUUID)
    touchTrackedEntry(entry, zombie, npcData, bodyInstanceID, getTimeInMillis())
    return entry
end

function DTNPCClient.MarkNPCCombatForHealthBars(uuid, zombie, npcData, bodyInstanceID)
    local entry = DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, bodyInstanceID)
    if entry then
        entry.visibleUntil = getTimeInMillis() + Constants.COMBAT_SHOW_DURATION
    end
    return entry
end

function DTNPCClient.UntrackNPCForHealthBars(uuid, bodyInstanceID)
    local resolvedUUID = uuid

    if not resolvedUUID and bodyInstanceID and DTNPCClient.BodyInstanceIDToUUID then
        resolvedUUID = DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID]
    end
    if not resolvedUUID then return end

    DTNPCClient.HealthBarTracked[resolvedUUID] = nil

    for _, manager in pairs(DTNPCClient.HealthBarManagers or {}) do
        if manager then
            manager.barList[resolvedUUID] = nil
            manager.damageTexts[resolvedUUID] = nil
        end
    end
end
