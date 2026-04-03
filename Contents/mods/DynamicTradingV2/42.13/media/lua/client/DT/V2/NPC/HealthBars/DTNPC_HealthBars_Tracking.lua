-- ==============================================================================
-- DTNPC_HealthBars_Tracking.lua
-- Tracking lifecycle and public health bar APIs.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_HealthBars = DTNPC_HealthBars or {}

local HealthBars = DTNPC_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Tracking then
    return
end

modules.Tracking = true

local Constants = HealthBars.Constants
local Helpers = HealthBars.Helpers
local State = HealthBars.State

local function touchTrackedEntry(entry, zombie, npcData, outfitID, currentTime)
    if zombie then
        entry.zombie = zombie
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    end

    if outfitID then
        entry.outfitID = outfitID
    end

    if npcData then
        entry.npcData = npcData
        entry.isIncapacitated = Helpers.isIncapacitatedState(npcData) or false
        Helpers.cacheNameMetrics(entry, npcData.name)
        entry.currentHp, entry.maxHp = Helpers.resolveHealth(npcData, zombie or entry.zombie, entry.maxHp)

        if Helpers.isCombatState(npcData) then
            entry.visibleUntil = currentTime + Constants.COMBAT_SHOW_DURATION
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
        isIncapacitated = false,
        visibleUntil = 0,
        lastSeenAt = getTimeInMillis(),
        nextResolveAt = 0,
    }

    DTNPCClient.HealthBarTracked[uuid] = entry
    return entry
end

HealthBars.touchTrackedEntry = touchTrackedEntry
HealthBars.getTrackedEntry = getTrackedEntry

function DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, outfitID)
    local resolvedUUID = Helpers.deriveUUID(zombie, npcData, uuid)
    if not resolvedUUID then return nil end

    local entry = getTrackedEntry(resolvedUUID)
    touchTrackedEntry(entry, zombie, npcData, outfitID, getTimeInMillis())
    return entry
end

function DTNPCClient.MarkNPCCombatForHealthBars(uuid, zombie, npcData, outfitID)
    local entry = DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, outfitID)
    if entry then
        entry.visibleUntil = getTimeInMillis() + Constants.COMBAT_SHOW_DURATION
    end
    return entry
end

function DTNPCClient.UntrackNPCForHealthBars(uuid, outfitID)
    local resolvedUUID = uuid

    if not resolvedUUID and outfitID and DTNPCClient.OutfitIDToUUID then
        resolvedUUID = DTNPCClient.OutfitIDToUUID[outfitID]
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
