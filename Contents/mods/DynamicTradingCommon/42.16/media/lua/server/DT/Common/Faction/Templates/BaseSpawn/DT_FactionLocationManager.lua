-- ==============================================================================
-- media/lua/server/DT_FactionLocationManager.lua
-- Logic: Managing the assignment of physical bases to Factions.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"

DT_FactionLocationManager = {}

local function normalizeLocationKey(value)
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

local function resolveTownName(targetTown)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.ResolveLocationName then
        return DT_GeolocatorSystem.ResolveLocationName(targetTown)
    end

    return targetTown
end

local function matchesLocation(candidate, targetTown)
    local candidateKey = normalizeLocationKey(candidate)
    local targetKey = normalizeLocationKey(targetTown)
    if not candidateKey or not targetKey then
        return false
    end

    return candidateKey == targetKey
end

local function locationContainsPoint(location, x, y)
    if type(location) ~= "table" then
        return false
    end

    local tx = tonumber(x)
    local ty = tonumber(y)
    if not tx or not ty then
        return false
    end

    return tx >= (tonumber(location.startX) or math.huge)
        and tx <= (tonumber(location.endX) or -math.huge)
        and ty >= (tonumber(location.startY) or math.huge)
        and ty <= (tonumber(location.endY) or -math.huge)
end

local function buildingMatchesTarget(building, targetTown, resolvedTown, resolvedLocation)
    if not targetTown then
        return true
    end

    if matchesLocation(building.town, targetTown)
        or matchesLocation(building.town, resolvedTown)
        or matchesLocation(building.county, targetTown)
        or matchesLocation(building.county, resolvedTown) then
        return true
    end

    return locationContainsPoint(resolvedLocation, building.cx or building.x, building.cy or building.y)
end

local function buildAvailableEntry(building, takenLocations)
    local uniqueName = building.name or "Building"

    if takenLocations[uniqueName] then
        uniqueName = uniqueName .. " (" .. math.floor(building.cx) .. "," .. math.floor(building.cy) .. ")"
    end

    if takenLocations[uniqueName] then
        return nil
    end

    return {
        name = uniqueName,
        coords = { x = building.cx, y = building.cy, z = 0 },
        town = resolveTownName(building.town) or building.town or "Unknown"
    }
end

local function appendUniqueBuildings(target, seen, buildings)
    for _, building in ipairs(buildings or {}) do
        if building and not seen[building] then
            seen[building] = true
            target[#target + 1] = building
        end
    end
end

local function collectCandidateBuildings(targetTown, resolvedTown, resolvedLocation)
    local candidates = {}
    local seen = {}

    if DT_GeolocatorSystem and DT_GeolocatorSystem.GetBuildingsByName then
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByName(targetTown))
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByName(resolvedTown))
    end

    if DT_GeolocatorSystem and DT_GeolocatorSystem.GetBuildingsByTown then
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByTown(targetTown))
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByTown(resolvedTown))
    end

    if DT_GeolocatorSystem and DT_GeolocatorSystem.GetBuildingsByCounty then
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByCounty(targetTown))
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem.GetBuildingsByCounty(resolvedTown))
    end

    if resolvedLocation and DT_GeolocatorSystem and DT_GeolocatorSystem.GetBuildingsInBounds then
        appendUniqueBuildings(
            candidates,
            seen,
            DT_GeolocatorSystem.GetBuildingsInBounds(
                tonumber(resolvedLocation.startX) or 0,
                tonumber(resolvedLocation.startY) or 0,
                tonumber(resolvedLocation.endX) or 0,
                tonumber(resolvedLocation.endY) or 0
            )
        )
    end

    if #candidates == 0 then
        appendUniqueBuildings(candidates, seen, DT_GeolocatorSystem and DT_GeolocatorSystem.Buildings or {})
    end

    return candidates
end

local function collectAvailableBuildings(candidateBuildings, targetTown, resolvedTown, resolvedLocation, minArea, takenLocations)
    local available = {}

    for _, building in ipairs(candidateBuildings or {}) do
        local area = tonumber(building.area) or 0
        local meetsArea = (not minArea) or area >= minArea
        if meetsArea and buildingMatchesTarget(building, targetTown, resolvedTown, resolvedLocation) then
            local entry = buildAvailableEntry(building, takenLocations)
            if entry then
                table.insert(available, entry)
            end
        end
    end

    return available
end

function DT_FactionLocationManager.AssignHome(factionID, targetTown)
    if factionID == "Independent" or factionID == "Factionless" then
        return nil
    end

    if not DT_GeolocatorSystem
        or not DT_GeolocatorSystem.EnsureBuildingsLoaded
        or not DT_GeolocatorSystem.EnsureBuildingsLoaded(true, true) then
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "AssignHome deferred: geolocator building cache is not ready yet.")
        return nil
    end

    local takenLocations = {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    for _, data in pairs(factionData) do
        if data.homeCoords and data.homeCoords.name then
            takenLocations[data.homeCoords.name] = true
        end
    end

    local minSize = (DT_GeolocatorSystem.Config and DT_GeolocatorSystem.Config.MinBuildingArea) or 60
    local forcedBuilding = nil
    local resolvedTown = resolveTownName(targetTown)
    local resolvedLocation = DT_GeolocatorSystem and DT_GeolocatorSystem.FindLocationByName
        and DT_GeolocatorSystem.FindLocationByName(resolvedTown or targetTown) or nil
    local candidateBuildings = collectCandidateBuildings(targetTown, resolvedTown, resolvedLocation)

    for _, building in ipairs(candidateBuildings) do
        if matchesLocation(building.name, targetTown) or matchesLocation(building.name, resolvedTown) then
            forcedBuilding = building
            break
        end
    end

    if forcedBuilding then
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction [" .. factionID .. "] forcing to specific building: " .. forcedBuilding.name)
        return {
            name = forcedBuilding.name,
            x = forcedBuilding.cx,
            y = forcedBuilding.cy,
            z = 0,
            town = resolveTownName(forcedBuilding.town) or forcedBuilding.town
        }
    end

    local available = collectAvailableBuildings(candidateBuildings, targetTown, resolvedTown, resolvedLocation, minSize, takenLocations)

    if #available == 0 and targetTown then
        available = collectAvailableBuildings(candidateBuildings, targetTown, resolvedTown, resolvedLocation, nil, takenLocations)
        if #available > 0 then
            DynamicTrading.Log("DTCommons", "Faction", "Warn", "No large buildings found in " .. tostring(resolvedTown or targetTown) .. ". Falling back to smaller valid structures.")
        end
    end

    if #available == 0 then
        local townLog = resolvedTown and (" in " .. tostring(resolvedTown)) or ""
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "No suitable buildings found" .. townLog .. "! Faction [" .. factionID .. "] is nomadic.")
        return nil
    end

    local choice = available[ZombRand(#available) + 1]
    DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction [" .. factionID .. "] dynamically assigned to: " .. choice.name)

    return {
        name = choice.name,
        x = choice.coords.x,
        y = choice.coords.y,
        z = choice.coords.z,
        town = choice.town
    }
end

function DT_FactionLocationManager.GetDynamicAvailableBases(targetTown, takenLocations)
    local available = {}
    if not DT_GeolocatorSystem or not DT_GeolocatorSystem.Buildings then
        return available
    end

    local resolvedTown = resolveTownName(targetTown)
    local resolvedLocation = DT_GeolocatorSystem and DT_GeolocatorSystem.FindLocationByName
        and DT_GeolocatorSystem.FindLocationByName(resolvedTown or targetTown) or nil
    local candidateBuildings = collectCandidateBuildings(targetTown, resolvedTown, resolvedLocation)

    for _, building in ipairs(candidateBuildings) do
        if buildingMatchesTarget(building, targetTown, resolvedTown, resolvedLocation) then
            table.insert(available, {
                name = building.name or "Building",
                coords = { x = building.cx, y = building.cy, z = 0 },
                town = resolveTownName(building.town) or building.town
            })
        end
    end

    return available
end

function DT_FactionLocationManager.GetOwnerOfLocation(locationName)
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    for id, data in pairs(factionData) do
        if data.homeCoords and data.homeCoords.name == locationName then
            return id
        end
    end
    return nil
end

DT_FactionLocations = DT_FactionLocations or {}

function DT_FactionLocationManager.RegisterDynamicTowns()
    DynamicTrading.Log("DTCommons", "Faction", "Logic", "Registering Towns for Faction Spawning...")

    if DT_GeolocatorSystem and DT_GeolocatorSystem.InitCache then
        DT_GeolocatorSystem.InitCache()
    end

    for key in pairs(DT_FactionLocations) do
        DT_FactionLocations[key] = nil
    end

    local count = 0
    local sourceLocations = (DT_GeolocatorSystem and DT_GeolocatorSystem.ActiveLocations) or {}
    for _, location in ipairs(sourceLocations) do
        if location.id and not DT_FactionLocations[location.id] then
            DT_FactionLocations[location.id] = {
                id = location.id,
                name = location.shortName or location.id,
                longName = location.longName,
                isDynamic = true,
            }
            count = count + 1
        end
    end

    DynamicTrading.Log("DTCommons", "Faction", "Logic", "Successfully registered " .. count .. " spawnable town regions.")
end

DynamicTrading.Log("DTCommons", "Init", "Faction", "Faction Location Manager Initialized (Dynamic Mode)")
DT_FactionLocationManager.RegisterDynamicTowns()

if Events and Events.OnServerStarted then
    Events.OnServerStarted.Add(DT_FactionLocationManager.RegisterDynamicTowns)
end
if Events and Events.OnGameStart then
    Events.OnGameStart.Add(DT_FactionLocationManager.RegisterDynamicTowns)
end