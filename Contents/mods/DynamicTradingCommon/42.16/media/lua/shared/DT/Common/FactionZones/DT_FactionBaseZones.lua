-- ==============================================================================
-- DT_FactionBaseZones.lua
-- Lightweight, shared base-zone geometry for AI faction housekeeping and debug UI.
-- ==============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionBaseZones = DynamicTrading.FactionBaseZones or {}
pcall(require, "DT/Common/GeolocatorSystem/DT_GeolocatorSystem")

local Zones = DynamicTrading.FactionBaseZones

Zones.DEFAULT_BASE_RADIUS = Zones.DEFAULT_BASE_RADIUS or 18
Zones.MIN_BASE_RADIUS = Zones.MIN_BASE_RADIUS or 10
Zones.MAX_BASE_RADIUS = Zones.MAX_BASE_RADIUS or 32
Zones.DEFAULT_GRAVEYARD_ZONE_SIZE = Zones.DEFAULT_GRAVEYARD_ZONE_SIZE or 5
Zones.CACHE_TTL_MS = Zones.CACHE_TTL_MS or 5000
Zones.cache = Zones.cache or {}

local function nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end
    return 0
end

local function floorNumber(value)
    if tonumber(value) == nil then
        return nil
    end
    return math.floor(tonumber(value) or 0)
end

local function clamp(value, minValue, maxValue)
    local number = tonumber(value) or minValue
    if number < minValue then
        return minValue
    end
    if number > maxValue then
        return maxValue
    end
    return number
end

local function buildPoint(source)
    if type(source) ~= "table" then
        return nil
    end

    local x = floorNumber(source.x)
    local y = floorNumber(source.y)
    if x == nil or y == nil then
        return nil
    end

    return {
        x = x,
        y = y,
        z = floorNumber(source.z) or 0,
    }
end

local function copyRect(rect)
    if type(rect) ~= "table" then
        return nil
    end
    return {
        floorNumber(rect[1]) or 0,
        floorNumber(rect[2]) or 0,
        floorNumber(rect[3]) or 0,
        floorNumber(rect[4]) or 0,
        floorNumber(rect[5]) or 0,
    }
end

local function normalizeRect(x1, y1, x2, y2, z)
    local minX = math.min(floorNumber(x1) or 0, floorNumber(x2) or 0)
    local maxX = math.max(floorNumber(x1) or 0, floorNumber(x2) or 0)
    local minY = math.min(floorNumber(y1) or 0, floorNumber(y2) or 0)
    local maxY = math.max(floorNumber(y1) or 0, floorNumber(y2) or 0)
    return { minX, minY, maxX, maxY, floorNumber(z) or 0 }
end

local function getFactionData()
    local data = ModData and ModData.get and ModData.get("DynamicTrading_Factions") or nil
    return type(data) == "table" and data or {}
end

local function getFactionByID(factionID)
    local id = tostring(factionID or "")
    if id == "" then
        return nil
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(id)
        if type(faction) == "table" then
            return faction
        end
    end

    local data = getFactionData()
    if type(data[id]) == "table" then
        return data[id]
    end
    if type(data.Factions) == "table" and type(data.Factions[id]) == "table" then
        return data.Factions[id]
    end
    return nil
end

local function getFactionKey(factionOrID)
    if type(factionOrID) == "table" then
        return tostring(factionOrID.id or factionOrID.factionID or "")
    end
    return tostring(factionOrID or "")
end

local function getHomePoint(factionOrID)
    local faction = type(factionOrID) == "table" and factionOrID or getFactionByID(factionOrID)
    local home = faction and faction.homeCoords or nil
    return buildPoint(home)
end

local function isNomadicFaction(faction)
    if type(faction) ~= "table" then
        return true
    end

    local factionID = tostring(faction.id or "")
    local factionType = tostring(faction.factionType or "")
    local homeName = tostring(faction.homeCoords and faction.homeCoords.name or "")
    return faction.isNomadic == true
        or factionID == "Independent"
        or factionID == "Factionless"
        or factionType == "independent"
        or homeName == "Nomadic"
        or homeName == "Nomadic Route"
end

local function getBaseRadius(faction)
    local home = faction and faction.homeCoords or nil
    local configured = tonumber(faction and (faction.baseRadius or faction.baseCoverageRadius))
        or tonumber(home and (home.baseRadius or home.radius or home.baseCoverageRadius))
    if configured ~= nil then
        return math.floor(clamp(configured, Zones.MIN_BASE_RADIUS, Zones.MAX_BASE_RADIUS))
    end

    local members = math.max(0, tonumber(faction and faction.memberCount) or 0)
    local derived = Zones.DEFAULT_BASE_RADIUS + math.floor(math.min(12, members) / 4)
    return math.floor(clamp(derived, Zones.MIN_BASE_RADIUS, Zones.MAX_BASE_RADIUS))
end

local function pointsNear(ax, ay, bx, by, tolerance)
    local tx = tonumber(ax)
    local ty = tonumber(ay)
    local ux = tonumber(bx)
    local uy = tonumber(by)
    if tx == nil or ty == nil or ux == nil or uy == nil then
        return false
    end
    local range = tonumber(tolerance) or 2
    return math.abs(tx - ux) <= range and math.abs(ty - uy) <= range
end

local function buildingNameMatches(building, home)
    local homeName = tostring(home and home.name or "")
    if homeName == "" then
        return false
    end
    return tostring(building and building.name or "") == homeName
end

local function findHomeBuilding(home)
    if type(home) ~= "table" or not DT_GeolocatorSystem then
        return nil
    end

    if DT_GeolocatorSystem.EnsureBuildingsLoaded then
        pcall(function()
            DT_GeolocatorSystem.EnsureBuildingsLoaded(false, false)
        end)
    end

    local buildings = DT_GeolocatorSystem.Buildings
    if type(buildings) ~= "table" then
        return nil
    end

    local best = nil
    local bestScore = nil
    for _, building in ipairs(buildings) do
        if type(building) == "table" then
            local centerMatch = pointsNear(home.x, home.y, building.cx or building.x, building.cy or building.y, 2)
            local nameMatch = buildingNameMatches(building, home)
            if centerMatch or nameMatch then
                local dx = (tonumber(home.x) or 0) - (tonumber(building.cx or building.x) or 0)
                local dy = (tonumber(home.y) or 0) - (tonumber(building.cy or building.y) or 0)
                local score = (dx * dx) + (dy * dy)
                if centerMatch then
                    score = score - 100000
                elseif nameMatch then
                    score = score - 1000
                end
                if bestScore == nil or score < bestScore then
                    best = building
                    bestScore = score
                end
            end
        end
    end

    return best
end

local function getBuildingRect(home)
    local building = findHomeBuilding(home)
    if type(building) ~= "table" then
        return nil, nil
    end

    local x = floorNumber(building.x)
    local y = floorNumber(building.y)
    local w = math.max(1, floorNumber(building.w) or 0)
    local h = math.max(1, floorNumber(building.h) or 0)
    if x == nil or y == nil then
        return nil, building
    end

    return normalizeRect(x, y, x + w - 1, y + h - 1, home.z), building
end

local function makeZone(id, zoneType, label, rect, point, color)
    return {
        id = id,
        zoneType = zoneType,
        label = label,
        rects = { copyRect(rect) },
        point = buildPoint(point),
        color = color or { r = 1, g = 1, b = 1, a = 0.35 },
    }
end

local function buildGraveyardZone(home, radius)
    local size = math.max(3, math.floor(tonumber(Zones.DEFAULT_GRAVEYARD_ZONE_SIZE) or 5))
    local half = math.floor(size / 2)
    local offset = math.max(4, math.min(radius - half - 2, 8))
    local centerX = home.x + offset
    local centerY = home.y + offset
    local rect = normalizeRect(centerX - half, centerY - half, centerX + half, centerY + half, home.z)
    return rect, {
        x = centerX,
        y = centerY,
        z = home.z,
    }
end

local function buildSnapshot(factionOrID)
    local faction = type(factionOrID) == "table" and factionOrID or getFactionByID(factionOrID)
    if type(faction) ~= "table" or isNomadicFaction(faction) then
        return nil
    end

    local factionID = getFactionKey(faction)
    local home = getHomePoint(faction)
    if not home then
        return nil
    end

    local radius = getBaseRadius(faction)
    local baseRect, building = getBuildingRect(home)
    if not baseRect then
        baseRect = normalizeRect(home.x - radius, home.y - radius, home.x + radius, home.y + radius, home.z)
    else
        local width = math.abs((baseRect[3] or home.x) - (baseRect[1] or home.x)) + 1
        local height = math.abs((baseRect[4] or home.y) - (baseRect[2] or home.y)) + 1
        radius = math.floor(math.max(radius, math.max(width, height) / 2))
    end
    local graveRect, gravePoint = buildGraveyardZone(home, radius)
    local zones = {
        makeZone(
            "base",
            "base",
            "Base Coverage",
            baseRect,
            home,
            { r = 0.25, g = 0.72, b = 1.0, a = 0.28 }
        ),
        makeZone(
            "graveyard",
            "graveyard",
            "Graveyard",
            graveRect,
            gravePoint,
            { r = 0.58, g = 0.44, b = 0.24, a = 0.42 }
        ),
    }

    return {
        factionID = factionID,
        factionName = tostring(faction.name or factionID),
        home = home,
        resetPoint = buildPoint(home),
        baseRadius = radius,
        baseSource = building and "building" or "radius",
        building = building and {
            name = building.name,
            x = floorNumber(building.x),
            y = floorNumber(building.y),
            w = floorNumber(building.w),
            h = floorNumber(building.h),
            cx = floorNumber(building.cx),
            cy = floorNumber(building.cy),
        } or nil,
        zones = zones,
    }
end

function Zones.GetFaction(factionID)
    return getFactionByID(factionID)
end

function Zones.IsAIFactionBase(factionOrID)
    local faction = type(factionOrID) == "table" and factionOrID or getFactionByID(factionOrID)
    if type(faction) ~= "table" or isNomadicFaction(faction) then
        return false
    end
    if faction.playerOwned == true then
        return false
    end
    return getHomePoint(faction) ~= nil
end

function Zones.GetSnapshot(factionOrID, forceRefresh)
    local factionID = getFactionKey(factionOrID)
    if factionID == "" then
        return nil
    end

    local now = nowMillis()
    local cached = Zones.cache[factionID]
    if forceRefresh ~= true and type(cached) == "table" and (tonumber(cached.expiresAt) or 0) > now then
        return cached.snapshot
    end

    local snapshot = buildSnapshot(factionOrID)
    Zones.cache[factionID] = {
        snapshot = snapshot,
        expiresAt = now + math.max(500, tonumber(Zones.CACHE_TTL_MS) or 5000),
    }
    return snapshot
end

function Zones.GetSnapshotForNPC(npcData, forceRefresh)
    if type(npcData) ~= "table" then
        return nil
    end
    local factionID = tostring(npcData.factionID or "")
    if factionID == "" then
        return nil
    end
    return Zones.GetSnapshot(factionID, forceRefresh)
end

function Zones.GetZone(snapshotOrFaction, zoneType)
    local snapshot = snapshotOrFaction and snapshotOrFaction.zones and snapshotOrFaction or Zones.GetSnapshot(snapshotOrFaction)
    local wanted = tostring(zoneType or "")
    for _, zone in ipairs(snapshot and snapshot.zones or {}) do
        if tostring(zone.zoneType or "") == wanted or tostring(zone.id or "") == wanted then
            return zone
        end
    end
    return nil
end

function Zones.GetResetPoint(factionOrID)
    local snapshot = Zones.GetSnapshot(factionOrID)
    return snapshot and buildPoint(snapshot.resetPoint) or nil
end

function Zones.GetCorpseDumpPoint(factionOrID)
    local snapshot = Zones.GetSnapshot(factionOrID)
    local zone = snapshot and Zones.GetZone(snapshot, "graveyard") or nil
    return zone and buildPoint(zone.point) or nil
end

function Zones.GetGraveyardPoint(factionOrID)
    local snapshot = Zones.GetSnapshot(factionOrID)
    local zone = snapshot and Zones.GetZone(snapshot, "graveyard") or nil
    return zone and buildPoint(zone.point) or nil
end

function Zones.IsPointInZone(zone, x, y, z)
    local px = floorNumber(x)
    local py = floorNumber(y)
    local pz = floorNumber(z) or 0
    if px == nil or py == nil or type(zone) ~= "table" then
        return false
    end

    for _, rect in ipairs(zone.rects or {}) do
        local x1 = floorNumber(rect and rect[1]) or 0
        local y1 = floorNumber(rect and rect[2]) or 0
        local x2 = floorNumber(rect and rect[3]) or x1
        local y2 = floorNumber(rect and rect[4]) or y1
        local rz = floorNumber(rect and rect[5]) or 0
        if px >= x1 and px <= x2 and py >= y1 and py <= y2 and pz == rz then
            return true
        end
    end
    return false
end

function Zones.GetDebugRows(factionOrID)
    local snapshot = Zones.GetSnapshot(factionOrID)
    local rows = {}
    for _, zone in ipairs(snapshot and snapshot.zones or {}) do
        local rect = zone.rects and zone.rects[1] or nil
        rows[#rows + 1] = {
            id = zone.id,
            zoneType = zone.zoneType,
            label = zone.label,
            rect = copyRect(rect),
            point = buildPoint(zone.point),
            color = zone.color,
        }
    end
    return rows
end

return Zones
