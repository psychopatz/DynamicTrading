-- ==============================================================================
-- DT_FactionBaseLedgerData.lua
-- Data builder for the Faction Base Ledger debug window.
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
pcall(require, "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState")

DT_FactionBaseLedgerData = DT_FactionBaseLedgerData or {}

DT_FactionBaseLedgerData.cachedFactions = DT_FactionBaseLedgerData.cachedFactions or nil
DT_FactionBaseLedgerData.cachedLedger = DT_FactionBaseLedgerData.cachedLedger or nil
DT_FactionBaseLedgerData.pendingCallback = nil

local function normalizeTownKey(value)
    if DT_FactionRespawnState and DT_FactionRespawnState.NormalizeTownKey then
        return DT_FactionRespawnState.NormalizeTownKey(value)
    end

    local normalized = tostring(value or ""):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end
    return normalized
end

local function buildHomeKey(homeCoords)
    if DT_FactionRespawnState and DT_FactionRespawnState.BuildHomeKey then
        return DT_FactionRespawnState.BuildHomeKey(homeCoords)
    end

    if type(homeCoords) ~= "table" then
        return nil
    end

    return tostring(homeCoords.name or "UnknownHome")
        .. "@"
        .. tostring(math.floor(tonumber(homeCoords.x) or 0))
        .. ","
        .. tostring(math.floor(tonumber(homeCoords.y) or 0))
        .. ","
        .. tostring(math.floor(tonumber(homeCoords.z) or 0))
end

local function getLedgerSnapshot()
    if DT_FactionRespawnState and DT_FactionRespawnState.GetDebugSnapshot then
        return DT_FactionRespawnState.GetDebugSnapshot()
    end
    return ModData.get("DynamicTrading_FactionRespawnState") or {}
end

local function getCoordsKey(x, y, z)
    return tostring(math.floor(tonumber(x) or 0))
        .. ","
        .. tostring(math.floor(tonumber(y) or 0))
        .. ","
        .. tostring(math.floor(tonumber(z) or 0))
end

local function getRecordMap(ledger)
    local byHomeKey = {}
    local byCoords = {}
    local history = ledger and ledger.baseHistory or nil
    if type(history) ~= "table" then
        return byHomeKey, byCoords
    end

    for _, rows in pairs(history) do
        if type(rows) == "table" then
            for _, row in ipairs(rows) do
                if type(row) == "table" then
                    if row.key then
                        byHomeKey[tostring(row.key)] = row
                    end
                    byCoords[getCoordsKey(row.x, row.y, row.z)] = row
                end
            end
        end
    end

    return byHomeKey, byCoords
end

local function findRecordForHome(homeCoords, byHomeKey, byCoords)
    if type(homeCoords) ~= "table" then
        return nil
    end

    local homeKey = buildHomeKey(homeCoords)
    if homeKey and byHomeKey[homeKey] then
        return byHomeKey[homeKey], homeKey
    end

    local coordsKey = getCoordsKey(homeCoords.x, homeCoords.y, homeCoords.z)
    return byCoords[coordsKey], homeKey
end

local function isActiveFaction(faction)
    if type(faction) ~= "table" then
        return false
    end
    if faction.collapsed == true or tostring(faction.state or "") == "Collapsed" then
        return false
    end
    return math.max(0, tonumber(faction.memberCount) or 0) > 0
end

local function appendActiveRows(rows, seenKeys, factions, ledger)
    local byHomeKey, byCoords = getRecordMap(ledger)

    for factionID, faction in pairs(factions or {}) do
        local homeCoords = type(faction) == "table" and faction.homeCoords or nil
        if type(homeCoords) == "table" and tonumber(homeCoords.x) and tonumber(homeCoords.y) then
            local record, homeKey = findRecordForHome(homeCoords, byHomeKey, byCoords)
            local active = isActiveFaction(faction)
            local row = {
                id = tostring(factionID),
                status = active and "Active" or "Inactive",
                active = active,
                source = active and "current" or "faction_record",
                currentFactionID = tostring(factionID),
                currentFactionName = tostring(faction.name or factionID),
                currentName = tostring(homeCoords.name or "Unknown Base"),
                formerName = record and tostring(record.name or "") or "",
                formerFactionID = record and tostring(record.lastFactionID or "") or "",
                reason = record and tostring(record.reason or "") or tostring(faction.collapseReason or ""),
                ageDays = record and tonumber(record.ageDays) or nil,
                state = tostring(faction.state or "Unknown"),
                memberCount = tonumber(faction.memberCount) or 0,
                x = tonumber(homeCoords.x) or 0,
                y = tonumber(homeCoords.y) or 0,
                z = tonumber(homeCoords.z) or 0,
                town = tostring(homeCoords.town or faction.town or "Unknown"),
                county = tostring(homeCoords.county or faction.county or ""),
                homeKey = homeKey or buildHomeKey(homeCoords),
            }
            rows[#rows + 1] = row
            if row.homeKey then
                seenKeys[tostring(row.homeKey)] = true
            end
            seenKeys[getCoordsKey(row.x, row.y, row.z)] = true
        end
    end
end

local function appendLedgerRows(rows, seenKeys, ledger)
    local history = ledger and ledger.baseHistory or nil
    if type(history) ~= "table" then
        return
    end

    for townKey, entries in pairs(history) do
        if type(entries) == "table" then
            for _, entry in ipairs(entries) do
                if type(entry) == "table" then
                    local coordsKey = getCoordsKey(entry.x, entry.y, entry.z)
                    local homeKey = tostring(entry.key or "")
                    if seenKeys[coordsKey] ~= true and (homeKey == "" or seenKeys[homeKey] ~= true) then
                        rows[#rows + 1] = {
                            id = homeKey ~= "" and homeKey or coordsKey,
                            status = "Inactive",
                            active = false,
                            source = "ledger",
                            currentFactionID = "",
                            currentFactionName = "",
                            currentName = tostring(entry.name or "Former Base"),
                            formerName = tostring(entry.name or "Former Base"),
                            formerFactionID = tostring(entry.lastFactionID or ""),
                            reason = tostring(entry.reason or "unknown"),
                            ageDays = tonumber(entry.ageDays) or 0,
                            state = "Abandoned",
                            memberCount = 0,
                            x = tonumber(entry.x) or 0,
                            y = tonumber(entry.y) or 0,
                            z = tonumber(entry.z) or 0,
                            town = tostring(entry.town or townKey),
                            county = "",
                            homeKey = homeKey,
                        }
                    end
                end
            end
        end
    end
end

function DT_FactionBaseLedgerData.BuildRows(factions, ledger)
    local rows = {}
    local seenKeys = {}
    appendActiveRows(rows, seenKeys, factions or {}, ledger or {})
    appendLedgerRows(rows, seenKeys, ledger or {})

    table.sort(rows, function(a, b)
        if a.active ~= b.active then
            return a.active == true
        end
        local townA = tostring(a.town or "")
        local townB = tostring(b.town or "")
        if townA ~= townB then
            return townA < townB
        end
        return tostring(a.currentName or "") < tostring(b.currentName or "")
    end)

    return rows
end

function DT_FactionBaseLedgerData.Refresh(callback)
    if isClient() and not isServer() then
        DT_FactionBaseLedgerData.pendingCallback = callback
        DT_DebugNetworkAdapter.requestFactionData({ includeBaseLedger = true })
        return
    end

    DT_FactionBaseLedgerData.cachedFactions = ModData.get("DynamicTrading_Factions") or {}
    DT_FactionBaseLedgerData.cachedLedger = getLedgerSnapshot()
    local rows = DT_FactionBaseLedgerData.BuildRows(DT_FactionBaseLedgerData.cachedFactions, DT_FactionBaseLedgerData.cachedLedger)
    if callback then
        callback(rows, DT_FactionBaseLedgerData.cachedLedger)
    end
end

function DT_FactionBaseLedgerData.HandleServerResponse(command, args)
    if command ~= "SyncFactionDebugData" then
        return false
    end

    args = type(args) == "table" and args or {}
    DT_FactionBaseLedgerData.cachedFactions = args.factions or {}
    DT_FactionBaseLedgerData.cachedLedger = args.baseLedger or {}
    local rows = DT_FactionBaseLedgerData.BuildRows(DT_FactionBaseLedgerData.cachedFactions, DT_FactionBaseLedgerData.cachedLedger)

    if DT_FactionBaseLedgerData.pendingCallback then
        DT_FactionBaseLedgerData.pendingCallback(rows, DT_FactionBaseLedgerData.cachedLedger)
        DT_FactionBaseLedgerData.pendingCallback = nil
    end

    if DT_FactionBaseLedgerWindow and DT_FactionBaseLedgerWindow.instance and DT_FactionBaseLedgerWindow.instance:getIsVisible() then
        DT_FactionBaseLedgerWindow.instance:setRows(rows, DT_FactionBaseLedgerData.cachedLedger)
    end

    return true
end

DT_DebugNetworkAdapter.registerServerCommandHandler(function(command, args)
    DT_FactionBaseLedgerData.HandleServerResponse(command, args)
end)

return DT_FactionBaseLedgerData
