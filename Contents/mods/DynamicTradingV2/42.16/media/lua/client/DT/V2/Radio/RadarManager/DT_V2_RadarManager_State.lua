-- ==============================================================================
-- DT_V2_RadarManager_State.lua
-- Player scan cooldown, channel capacity, and signal lock helpers.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

local STATE_KEY = "DT_V2_RadarState"

local COOLDOWN_BY_TYPE = {
    ["Base.WalkieTalkie1"] = 30,
    ["Base.WalkieTalkieMakeShift"] = 28,
    ["Base.WalkieTalkie2"] = 24,
    ["Base.WalkieTalkie3"] = 20,
    ["Base.WalkieTalkie4"] = 16,
    ["Base.WalkieTalkie5"] = 12,
    ["Base.HamRadioMakeShift"] = 18,
    ["Base.HamRadio1"] = 10,
    ["Base.HamRadio2"] = 6,
    ["Base.ManPackRadio"] = 8,
}

local function getStateData()
    local data = ModData.getOrCreate(STATE_KEY)
    data.players = data.players or {}
    return data
end

local function getPlayerKey(player)
    if player then
        if player.getUsername then
            local username = player:getUsername()
            if username and username ~= "" then
                return tostring(username)
            end
        end

        if player.getOnlineID then
            local onlineID = player:getOnlineID()
            if onlineID ~= nil and onlineID ~= -1 then
                return tostring(onlineID)
            end
        end
    end

    return "local"
end

local function getPlayerState(player)
    local data = getStateData()
    local key = getPlayerKey(player)
    data.players[key] = data.players[key] or {
        lastScanAt = 0,
        lastScanAtMs = 0,
        lastDeviceType = nil,
        lastCooldownMinutes = 0,
    }
    return data.players[key]
end

local function getCurrentHours()
    return getGameTime():getWorldAgeHours()
end

local function getSortedUnlockedSignals()
    local unlocked = {}

    for uuid, entry in pairs(RadarManager.FoundTraders or {}) do
        if entry and entry.locked ~= true then
            unlocked[#unlocked + 1] = {
                uuid = uuid,
                entry = entry,
                discoveredAt = tonumber(entry.discoveredAt) or 0,
            }
        end
    end

    table.sort(unlocked, function(a, b)
        if a.discoveredAt == b.discoveredAt then
            return tostring(a.uuid) < tostring(b.uuid)
        end
        return a.discoveredAt < b.discoveredAt
    end)

    return unlocked
end

function RadarManager.InitScanState()
    getStateData()
end

function RadarManager.GetDeviceCooldownMinutes(device)
    local typeID = type(device) == "string" and device or RadarManager.GetDeviceTypeID(device)
    if COOLDOWN_BY_TYPE[typeID] then
        return COOLDOWN_BY_TYPE[typeID]
    end

    local radioData = typeID and DynamicTrading.Config.GetRadioData(typeID) or nil
    local capacity = radioData and tonumber(radioData.capacity) or 1
    local power = radioData and tonumber(radioData.power) or 0.5
    local derivedCooldown = math.floor(32 - math.min(18, capacity) - (power * 3))
    if derivedCooldown < 5 then
        derivedCooldown = 5
    end
    return derivedCooldown
end

function RadarManager.GetDeviceCapacity(device)
    local profile = RadarManager.GetDeviceProfile and RadarManager.GetDeviceProfile(device) or nil
    local radioData = profile and profile.radioData or nil
    return math.max(1, tonumber(radioData and radioData.capacity) or 1)
end

function RadarManager.GetLockedCount()
    local count = 0
    for _, entry in pairs(RadarManager.FoundTraders or {}) do
        if entry and entry.locked == true then
            count = count + 1
        end
    end
    return count
end

function RadarManager.IsLocked(uuid)
    local entry = uuid and RadarManager.FoundTraders and RadarManager.FoundTraders[uuid] or nil
    return entry and entry.locked == true or false
end

function RadarManager.ToggleLock(uuid)
    if not uuid or not RadarManager.FoundTraders or not RadarManager.FoundTraders[uuid] then
        return false
    end

    local entry = RadarManager.FoundTraders[uuid]
    entry.locked = entry.locked ~= true
    entry.lockedAt = entry.locked and getCurrentHours() or nil
    return entry.locked
end

function RadarManager.GetScanStatus(device, player)
    local playerObj = player or getSpecificPlayer(0)
    local state = getPlayerState(playerObj)
    local cooldownMinutes = RadarManager.GetDeviceCooldownMinutes(device)
    local cooldownHours = cooldownMinutes / 60
    local elapsedHours = math.max(0, getCurrentHours() - (tonumber(state.lastScanAt) or 0))
    local elapsedMs = elapsedHours * 60 * 60 * 1000
    local cooldownMs = cooldownHours * 60 * 60 * 1000
    local remainingMs = math.max(0, cooldownMs - elapsedMs)
    local remainingMinutes = remainingMs / (60 * 1000)
    local foundCount = RadarManager.GetCount and RadarManager.GetCount() or 0
    local lockedCount = RadarManager.GetLockedCount()
    local capacity = RadarManager.GetDeviceCapacity(device)
    local availableSlots = math.max(0, capacity - foundCount)
    local unlockedCount = math.max(0, foundCount - lockedCount)
    local replaceableSlots = foundCount >= capacity and unlockedCount or 0
    local cooldownProgress = cooldownHours <= 0 and 1 or math.min(1, elapsedHours / cooldownHours)
    local profile = RadarManager.GetDeviceProfile and RadarManager.GetDeviceProfile(device) or nil

    return {
        canScan = remainingMs <= 0,
        remainingMinutes = remainingMinutes,
        remainingMs = remainingMs,
        cooldownMinutes = cooldownMinutes,
        cooldownProgress = cooldownProgress,
        foundCount = foundCount,
        lockedCount = lockedCount,
        unlockedCount = unlockedCount,
        capacity = capacity,
        availableSlots = availableSlots,
        replaceableSlots = replaceableSlots,
        deviceTypeID = profile and profile.typeID or nil,
        deviceDesc = profile and profile.description or nil,
        devicePower = profile and profile.power or nil,
    }
end

function RadarManager.CanScan(player, device)
    local status = RadarManager.GetScanStatus(device, player)
    return status.canScan, status.remainingMinutes, status
end

function RadarManager.SetScanTimestamp(player, device)
    local state = getPlayerState(player or getSpecificPlayer(0))
    state.lastScanAt = getCurrentHours()
    state.lastScanAtMs = 0
    state.lastDeviceType = RadarManager.GetDeviceTypeID and RadarManager.GetDeviceTypeID(device) or nil
    state.lastCooldownMinutes = RadarManager.GetDeviceCooldownMinutes(device)
    return state
end

function RadarManager.RemoveSignal(uuid, releasedName)
    if not uuid or not RadarManager.FoundTraders or not RadarManager.FoundTraders[uuid] then
        return nil
    end

    local entry = RadarManager.FoundTraders[uuid]
    if releasedName and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddPlayerRadioEvent then
        local pObj = getSpecificPlayer(0)
        DynamicTrading.GameplayLogs.AddPlayerRadioEvent(pObj, DynamicTrading.GameplayEvents.SIGNAL_RELEASED, {releasedName, "channel reallocated"})
    end

    RadarManager.FoundTraders[uuid] = nil
    return entry
end

function RadarManager.ReleaseOldestUnlockedSignal(releasedName)
    local unlocked = getSortedUnlockedSignals()
    local target = unlocked[1]
    if not target then
        return nil, nil
    end

    local entry = RadarManager.RemoveSignal(target.uuid, releasedName)
    return target.uuid, entry
end

function RadarManager.GetOldestUnlockedSignal()
    local unlocked = getSortedUnlockedSignals()
    return unlocked[1]
end