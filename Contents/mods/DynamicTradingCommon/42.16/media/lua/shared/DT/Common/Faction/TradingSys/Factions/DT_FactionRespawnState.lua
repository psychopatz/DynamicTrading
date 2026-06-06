-- ==============================================================================
-- DT_FactionRespawnState.lua
-- Persistent state for town respawn cooldowns and abandoned home history.
-- ==============================================================================

DT_FactionRespawnState = DT_FactionRespawnState or {}

local Public = DT_FactionRespawnState
local MOD_DATA_KEY = "DynamicTrading_FactionRespawnState"

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

local function isLedgerDebugEnabled()
    return DynamicTrading and DynamicTrading.Debug == true
end

local function debugLog(stage, message)
    if isLedgerDebugEnabled() and DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "FactionBaseLedger", tostring(stage or "Debug"), tostring(message or ""))
    end
end

local function normalizeTownKey(value)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

local function getCurrentWorldDay()
    local gameTime = getGameTime and getGameTime() or nil
    local hours = gameTime and gameTime.getWorldAgeHours and gameTime:getWorldAgeHours() or 0
    return math.max(0, math.floor((tonumber(hours) or 0) / 24))
end

local function normalizeCoord(value)
    return math.floor(tonumber(value) or 0)
end

local function buildHomeKey(homeOrName, x, y, z)
    local name = homeOrName
    if type(homeOrName) == "table" then
        name = homeOrName.name
        x = homeOrName.x or (homeOrName.coords and homeOrName.coords.x)
        y = homeOrName.y or (homeOrName.coords and homeOrName.coords.y)
        z = homeOrName.z or (homeOrName.coords and homeOrName.coords.z)
    end

    return tostring(name or "UnknownHome")
        .. "@"
        .. tostring(normalizeCoord(x))
        .. ","
        .. tostring(normalizeCoord(y))
        .. ","
        .. tostring(normalizeCoord(z))
end

local function pruneTownHistoryEntries(townEntries)
    if type(townEntries) ~= "table" then
        return
    end

    local nowDay = getCurrentWorldDay()
    local keepDays = math.max(
        30,
        math.floor(tonumber(getSandbox().FactionRespawnBaseAvoidDays) or 45) * 4
    )

    for key, entry in pairs(townEntries) do
        local releasedDay = tonumber(entry and entry.lastReleasedDay) or -1
        if releasedDay >= 0 and (nowDay - releasedDay) > keepDays then
            townEntries[key] = nil
        end
    end
end

function Public.EnsureData()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {
            townCooldowns = {},
            baseHistory = {},
        })
    end

    local data = ModData.get(MOD_DATA_KEY) or {}
    data.townCooldowns = type(data.townCooldowns) == "table" and data.townCooldowns or {}
    data.baseHistory = type(data.baseHistory) == "table" and data.baseHistory or {}
    return data
end

function Public.NormalizeTownKey(value)
    return normalizeTownKey(value)
end

function Public.BuildHomeKey(homeOrName, x, y, z)
    return buildHomeKey(homeOrName, x, y, z)
end

function Public.GetRespawnCooldownDays()
    local sandbox = getSandbox()
    return math.max(0, math.floor(tonumber(sandbox.FactionRespawnDelayDays) or 30))
end

function Public.GetRecentBaseAvoidDays()
    local sandbox = getSandbox()
    return math.max(0, math.floor(tonumber(sandbox.FactionRespawnBaseAvoidDays) or 45))
end

function Public.GetRecentBaseReuseChance()
    local sandbox = getSandbox()
    return clamp(tonumber(sandbox.FactionRespawnBaseReuseChance) or 5, 0, 100)
end

function Public.IsDebugEnabled()
    return isLedgerDebugEnabled()
end

function Public.GetTownCooldownRemainingDays(townName)
    local townKey = normalizeTownKey(townName)
    if not townKey then
        return 0
    end

    local data = Public.EnsureData()
    local cooldownUntilDay = tonumber(data.townCooldowns[townKey]) or 0
    return math.max(0, cooldownUntilDay - getCurrentWorldDay())
end

function Public.IsTownOnCooldown(townName)
    return Public.GetTownCooldownRemainingDays(townName) > 0
end

function Public.RecordAbandonedHome(factionID, factionData, reason)
    if type(factionData) ~= "table" then
        return false
    end

    local data = Public.EnsureData()
    local nowDay = getCurrentWorldDay()
    local homeCoords = type(factionData.homeCoords) == "table" and factionData.homeCoords or nil
    local townName = (homeCoords and homeCoords.town) or factionData.town
    local townKey = normalizeTownKey(townName)

    if townKey then
        local cooldownDays = Public.GetRespawnCooldownDays()
        if cooldownDays > 0 then
            local currentUntil = tonumber(data.townCooldowns[townKey]) or 0
            data.townCooldowns[townKey] = math.max(currentUntil, nowDay + cooldownDays)
        end
    end

    if homeCoords and townKey then
        local townEntries = data.baseHistory[townKey]
        if type(townEntries) ~= "table" then
            townEntries = {}
            data.baseHistory[townKey] = townEntries
        end

        pruneTownHistoryEntries(townEntries)

        local homeKey = buildHomeKey(homeCoords)
        townEntries[homeKey] = {
            key = homeKey,
            name = homeCoords.name,
            x = normalizeCoord(homeCoords.x),
            y = normalizeCoord(homeCoords.y),
            z = normalizeCoord(homeCoords.z),
            town = townName,
            lastReleasedDay = nowDay,
            lastFactionID = tostring(factionID or ""),
            reason = tostring(reason or "unknown"),
        }

        debugLog(
            "Record",
            "Recorded abandoned base key="
                .. tostring(homeKey)
                .. " town="
                .. tostring(townName)
                .. " faction="
                .. tostring(factionID)
                .. " reason="
                .. tostring(reason or "unknown")
                .. " reuseChance="
                .. tostring(Public.GetRecentBaseReuseChance())
                .. "%"
        )
    end

    if ModData.transmit then
        ModData.transmit(MOD_DATA_KEY)
    end

    return true
end

function Public.GetRecentHomeRecord(townName, homeEntry)
    local avoidDays = Public.GetRecentBaseAvoidDays()
    if avoidDays <= 0 then
        return nil
    end

    local townKey = normalizeTownKey(townName)
    if not townKey then
        return nil
    end

    local data = Public.EnsureData()
    local townEntries = data.baseHistory[townKey]
    if type(townEntries) ~= "table" then
        return nil
    end

    pruneTownHistoryEntries(townEntries)

    local entryKey = buildHomeKey(homeEntry)
    local record = townEntries[entryKey]
    if not record and type(homeEntry) == "table" then
        for _, candidate in pairs(townEntries) do
            if candidate
                and tostring(candidate.name or "") == tostring(homeEntry.name or "")
                and normalizeCoord(candidate.x) == normalizeCoord(homeEntry.x or (homeEntry.coords and homeEntry.coords.x))
                and normalizeCoord(candidate.y) == normalizeCoord(homeEntry.y or (homeEntry.coords and homeEntry.coords.y))
                and normalizeCoord(candidate.z) == normalizeCoord(homeEntry.z or (homeEntry.coords and homeEntry.coords.z)) then
                record = candidate
                break
            end
        end
    end

    if not record then
        return nil
    end

    local ageDays = math.max(0, getCurrentWorldDay() - (tonumber(record.lastReleasedDay) or 0))
    if ageDays > avoidDays then
        return nil
    end

    record.ageDays = ageDays
    return record
end

function Public.GetDebugSnapshot()
    local data = Public.EnsureData()
    local snapshot = {
        nowDay = getCurrentWorldDay(),
        avoidDays = Public.GetRecentBaseAvoidDays(),
        reuseChance = Public.GetRecentBaseReuseChance(),
        cooldownDays = Public.GetRespawnCooldownDays(),
        townCooldowns = {},
        baseHistory = {},
    }

    for townKey, cooldownUntilDay in pairs(data.townCooldowns or {}) do
        snapshot.townCooldowns[townKey] = {
            cooldownUntilDay = tonumber(cooldownUntilDay) or 0,
            remainingDays = math.max(0, (tonumber(cooldownUntilDay) or 0) - snapshot.nowDay),
        }
    end

    for townKey, townEntries in pairs(data.baseHistory or {}) do
        local rows = {}
        if type(townEntries) == "table" then
            pruneTownHistoryEntries(townEntries)
            for homeKey, entry in pairs(townEntries) do
                if type(entry) == "table" then
                    local ageDays = math.max(0, snapshot.nowDay - (tonumber(entry.lastReleasedDay) or 0))
                    rows[#rows + 1] = {
                        key = tostring(homeKey),
                        name = tostring(entry.name or "Unknown"),
                        x = normalizeCoord(entry.x),
                        y = normalizeCoord(entry.y),
                        z = normalizeCoord(entry.z),
                        town = tostring(entry.town or townKey),
                        lastReleasedDay = tonumber(entry.lastReleasedDay) or 0,
                        ageDays = ageDays,
                        lastFactionID = tostring(entry.lastFactionID or ""),
                        reason = tostring(entry.reason or "unknown"),
                        eligibleForAvoidance = ageDays <= snapshot.avoidDays,
                    }
                end
            end
        end
        snapshot.baseHistory[townKey] = rows
    end

    return snapshot
end

function Public.DumpDebug(maxRows, force)
    if not DynamicTrading or not DynamicTrading.Log then
        return false
    end
    if force ~= true and not isLedgerDebugEnabled() then
        return false
    end

    local snapshot = Public.GetDebugSnapshot()
    local limit = math.max(1, math.floor(tonumber(maxRows) or 40))
    local printed = 0

    DynamicTrading.Log(
        "DTCommons",
        "FactionBaseLedger",
        "Dump",
        "nowDay="
            .. tostring(snapshot.nowDay)
            .. " avoidDays="
            .. tostring(snapshot.avoidDays)
            .. " reuseChance="
            .. tostring(snapshot.reuseChance)
            .. "%"
            .. " cooldownDays="
            .. tostring(snapshot.cooldownDays)
    )

    for townKey, rows in pairs(snapshot.baseHistory or {}) do
        for _, entry in ipairs(rows or {}) do
            if printed >= limit then
                return true
            end
            printed = printed + 1
            DynamicTrading.Log(
                "DTCommons",
                "FactionBaseLedger",
                "Dump",
                "town="
                    .. tostring(townKey)
                    .. " base="
                    .. tostring(entry.name)
                    .. " coords="
                    .. tostring(entry.x)
                    .. ","
                    .. tostring(entry.y)
                    .. ","
                    .. tostring(entry.z)
                    .. " ageDays="
                    .. tostring(entry.ageDays)
                    .. " faction="
                    .. tostring(entry.lastFactionID)
                    .. " reason="
                    .. tostring(entry.reason)
            )
        end
    end

    if printed == 0 then
        DynamicTrading.Log("DTCommons", "FactionBaseLedger", "Dump", "No abandoned faction base records.")
    end
    return true
end
