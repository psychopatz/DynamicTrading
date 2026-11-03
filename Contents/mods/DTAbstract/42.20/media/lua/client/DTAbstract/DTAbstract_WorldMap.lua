-- World-map adapter for the canonical Core SurvivorWorld.
--
-- DTAbstract contributes trader/commercial labels only. Actor position, group
-- route, overlap spreading, portrait, discovery, selection/highlight/tracking
-- identity all come from PsychopatzCore SurvivorWorld.

DTAbstract = DTAbstract or {}
DTAbstract.WorldMap = DTAbstract.WorldMap or {}

local WorldMap = DTAbstract.WorldMap
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
local MapHover = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldMapHover"
local MapHost = require "PsychopatzCore/UI/Map/PsychopatzMapHost"
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

WorldMap.Enabled = true
WorldMap.ShowAll = false
WorldMap.MarkerSize = 10
WorldMap.SelectedActorID = WorldMap.SelectedActorID or nil
WorldMap.LastScreenMarkers = WorldMap.LastScreenMarkers or {}

local COLORS = {
    settlement = { r = 0.2, g = 0.65, b = 0.95, a = 1.0 },
    group = { r = 0.85, g = 0.55, b = 0.2, a = 0.9 },
    signal = { r = 0.72, g = 0.45, b = 0.95, a = 0.9 },
    trader = { r = 0.95, g = 0.75, b = 0.15, a = 1.0 },
    selected = { r = 1.0, g = 0.95, b = 0.45, a = 1.0 },
    tracked = { r = 0.45, g = 1.0, b = 0.55, a = 1.0 },
}

local function canUseDebug()
    local player = getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    return false
end

local function currentWorldHour()
    local gameTime = getGameTime and getGameTime() or nil
    return gameTime
        and type(gameTime.getWorldAgeHours) == "function"
        and tonumber(gameTime:getWorldAgeHours())
        or 0
end

local function debugMode(showAll)
    return showAll == true
        or WorldMap.ShowAll == true
        or canUseDebug()
end

local function refresh()
    if CoreClient.RequestActorsIfDue then
        CoreClient.RequestActorsIfDue(500)
    end
    if CoreClient.RequestDiscoveryIfDue then
        CoreClient.RequestDiscoveryIfDue(5000)
    end
end

local function actorIndex(spread)
    local output = {}
    for _, entry in ipairs(
        CoreClient.ListActors(spread ~= true) or {}
    ) do
        output[tostring(entry.actorID or "")] = entry
    end
    return output
end

local function discoveryLabel(entity)
    if entity.name and entity.name ~= "" then
        return tostring(entity.name)
    end
    local phase = tostring(entity.phaseName or "DISCOVERED")
    if entity.kind == "community" then
        return phase .. " settlement"
    end
    if entity.kind == "group" then
        return phase .. " survivor group"
    end
    return phase .. " signal"
end

function WorldMap.GetDiscoveryMarkers(showAll)
    refresh()
    local markers = {}
    local seen = {}
    local snapshot = CoreClient.GetDiscoverySnapshot() or {}
    for _, entity in ipairs(snapshot.entities or {}) do
        local x = tonumber(entity.x)
        local y = tonumber(entity.y)
        if x and y and (tonumber(entity.phase) or 0) > 0 then
            local kind = tostring(entity.kind or "")
            local markerKind = kind == "community"
                and "settlement"
                or kind
            local color = COLORS[markerKind] or COLORS.signal
            markers[#markers + 1] = {
                id = tostring(entity.entityID),
                entityID = tostring(entity.entityID),
                discoveryKind = kind,
                kind = markerKind,
                phase = tonumber(entity.phase) or 0,
                phaseName = entity.phaseName,
                position = {
                    x = x,
                    y = y,
                    z = tonumber(entity.z) or 0,
                },
                name = entity.name,
                label = discoveryLabel(entity),
                approximate = entity.approximate == true,
                color = color,
                size = markerKind == "settlement" and 12 or 8,
            }
            seen[kind .. ":" .. tostring(entity.entityID)] = true
        end
    end

    -- Debug raw settlement geography stays read-only and never creates
    -- discovery. Groups/signals remain Core discovery entities rather than a
    -- second DTAbstract raw-world registry.
    if debugMode(showAll) then
        local Directory = DTCommon and DTCommon.SettlementDirectory
        for _, settlement in ipairs(
            Directory and Directory.List and Directory.List() or {}
        ) do
            local key = "community:"
                .. tostring(settlement.settlementID or "")
            if settlement.enabled ~= false
                and settlement.position
                and not seen[key]
            then
                markers[#markers + 1] = {
                    id = tostring(settlement.settlementID),
                    entityID = tostring(settlement.settlementID),
                    discoveryKind = "community",
                    kind = "settlement",
                    rawDebug = true,
                    position = {
                        x = settlement.position.x,
                        y = settlement.position.y,
                        z = settlement.position.z or 0,
                    },
                    name = settlement.name,
                    label = tostring(
                        settlement.name or settlement.settlementID
                    ) .. " [raw]",
                    color = COLORS.settlement,
                    size = 10,
                }
            end
        end
    end

    table.sort(markers, function(left, right)
        if tostring(left.kind) ~= tostring(right.kind) then
            return tostring(left.kind) < tostring(right.kind)
        end
        return tostring(left.id) < tostring(right.id)
    end)
    return markers
end

function WorldMap.GetSettlementMarkers(showAll)
    local output = {}
    for _, marker in ipairs(
        WorldMap.GetDiscoveryMarkers(showAll)
    ) do
        if marker.kind == "settlement" then
            output[#output + 1] = marker
        end
    end
    return output
end

local function commercialLabel(traderID, record, ca, journey)
    local Directory = DTCommon and DTCommon.SettlementDirectory
    local label = record.n or traderID
    local active = journey
        and (journey.state == "en_route"
            or journey.state == "planned"
            or journey.state == "waiting")
    if active and ca.destinationSettlementID then
        local destination = Directory and Directory.Get
            and Directory.Get(ca.destinationSettlementID) or nil
        label = label .. " -> " .. tostring(
            destination and destination.name
                or ca.destinationSettlementID
        )
    elseif ca.currentSettlementID then
        local current = Directory and Directory.Get
            and Directory.Get(ca.currentSettlementID) or nil
        label = label .. " [" .. tostring(
            current and current.name
                or ca.currentSettlementID
        ) .. "]"
    end
    return label, active == true
end

function WorldMap.GetTraderMarkers(_, showAll)
    refresh()
    local markers = {}
    local actors = actorIndex(true)
    local rawActors = actorIndex(false)
    local show = debugMode(showAll)
    local tracked = CoreClient.GetTracked
        and CoreClient.GetTracked() or nil
    local trackedID = tracked
        and tostring(tracked.actorID or "") or nil

    for _, row in ipairs(
        Presentation.ListTraderRecords(false)
    ) do
        local record = row.record
        local ca = record and record.ca or nil
        if ca
            and (row.provider == "DTAbstract"
                or tostring(ca.returnProviderID or "")
                    == "DTAbstract")
        then
            local actorID = tostring(
                ca.actorID or ""
            )
            local entry = actors[actorID]
            local rawEntry = rawActors[actorID] or entry
            if entry and entry.position then
                local discovered = DTAbstract.NearbyDiscovery
                    and DTAbstract.NearbyDiscovery.IsTraderDiscovered
                    and DTAbstract.NearbyDiscovery.IsTraderDiscovered(
                        row.traderID
                    )
                    or false
                if show or discovered then
                    local journey = entry.journey
                    local label, traveling = commercialLabel(
                        row.traderID,
                        record,
                        ca,
                        journey
                    )
                    local selected =
                        WorldMap.SelectedActorID == actorID
                    local isTracked = trackedID == actorID
                    markers[#markers + 1] = {
                        id = row.traderID,
                        traderID = row.traderID,
                        actorID = actorID,
                        name = record.n or row.traderID,
                        kind = "trader",
                        position = {
                            x = entry.position.x,
                            y = entry.position.y,
                            z = entry.position.z or 0,
                        },
                        canonicalPosition =
                            entry.canonicalPosition
                            or rawEntry.position,
                        label = label,
                        isTraveling = traveling,
                        journeyProgress = journey
                            and journey.progress or 0,
                        route = journey and journey.route or nil,
                        journey = journey,
                        discovered = discovered,
                        selected = selected,
                        tracked = isTracked,
                        portrait = entry.portrait,
                        coreEntry = entry,
                        positionSource = entry.positionSource,
                        color = isTracked and COLORS.tracked
                            or selected and COLORS.selected
                            or COLORS.trader,
                        size = isTracked and 13
                            or selected and 12
                            or 10,
                    }
                end
            end
        end
    end

    table.sort(markers, function(a, b)
        return tostring(a.id) < tostring(b.id)
    end)
    return markers
end

function WorldMap.GetMapMarkers(now, showAll)
    local combined = {}
    for _, marker in ipairs(
        WorldMap.GetDiscoveryMarkers(showAll)
    ) do
        combined[#combined + 1] = marker
    end
    for _, marker in ipairs(
        WorldMap.GetTraderMarkers(now, showAll)
    ) do
        combined[#combined + 1] = marker
    end
    return combined
end

local function drawLine(map, a, b, color, alpha)
    if not map or not map.mapAPI
        or not map.javaObject
        or not map.javaObject.DrawLine
        or not a or not b
    then
        return
    end
    map.javaObject:DrawLine(
        nil,
        map.mapAPI:worldToUIX(a.x, a.y),
        map.mapAPI:worldToUIY(a.x, a.y),
        map.mapAPI:worldToUIX(b.x, b.y),
        map.mapAPI:worldToUIY(b.x, b.y),
        2,
        color.r,
        color.g,
        color.b,
        alpha or 0.8
    )
end

local function drawRoute(map, marker)
    local points = marker
        and marker.route
        and marker.route.points or nil
    if type(points) ~= "table" or #points < 2 then return end
    local color = marker.tracked
        and COLORS.tracked
        or marker.selected
            and COLORS.selected
            or COLORS.trader
    for index = 1, #points - 1 do
        drawLine(map, points[index], points[index + 1], color, 0.72)
    end
end

local function hitMarker(x, y, tradersOnly)
    local best
    local bestDistance = math.huge
    for _, item in ipairs(WorldMap.LastScreenMarkers or {}) do
        local marker = item.marker
        if not tradersOnly or marker.actorID then
            local dx = (tonumber(x) or 0) - item.x
            local dy = (tonumber(y) or 0) - item.y
            local distance = math.sqrt(dx * dx + dy * dy)
            local radius = math.max(
                7,
                (tonumber(marker.size) or WorldMap.MarkerSize) * 0.8
            )
            if distance <= radius and distance < bestDistance then
                best = item
                bestDistance = distance
            end
        end
    end
    return best
end

local function mousePosition(map)
    local x = map and map.getMouseX
        and tonumber(map:getMouseX()) or nil
    local y = map and map.getMouseY
        and tonumber(map:getMouseY()) or nil
    return x, y
end

function WorldMap.Render(map)
    if not WorldMap.Enabled or not map or not map.mapAPI then return end

    local markers = WorldMap.GetMapMarkers(
        currentWorldHour()
    )
    WorldMap.LastScreenMarkers = {}

    for _, marker in ipairs(markers) do
        if marker.actorID
            and (marker.selected or marker.tracked)
        then
            drawRoute(map, marker)
        end
    end

    for _, marker in ipairs(markers) do
        local uiX = map.mapAPI:worldToUIX(
            marker.position.x,
            marker.position.y
        )
        local uiY = map.mapAPI:worldToUIY(
            marker.position.x,
            marker.position.y
        )

        if uiX and uiY then
            WorldMap.LastScreenMarkers[#WorldMap.LastScreenMarkers + 1] = {
                marker = marker,
                x = uiX,
                y = uiY,
            }
            local size = marker.size or WorldMap.MarkerSize
            local color = marker.color
                or { r = 1, g = 1, b = 1, a = 1 }
            if map.drawRect then
                map:drawRect(
                    uiX - size / 2,
                    uiY - size / 2,
                    size,
                    size,
                    color.a or 1,
                    color.r or 1,
                    color.g or 1,
                    color.b or 1
                )
            end
            if map.drawTextCentre and marker.label then
                local font = UIFont and UIFont.Small or nil
                map:drawTextCentre(
                    marker.label,
                    uiX,
                    uiY + size / 2 + 2,
                    color.r or 1,
                    color.g or 1,
                    color.b or 1,
                    color.a or 1,
                    font
                )
            end
        end
    end

    local mouseX, mouseY = mousePosition(map)
    local hovered = mouseX and mouseY
        and hitMarker(mouseX, mouseY, true) or nil
    local actorID = hovered
        and hovered.marker.actorID or nil
    if CoreClient.SetHighlighted then
        CoreClient.SetHighlighted(actorID)
    end
    if hovered and hovered.marker.coreEntry then
        MapHover.Update(
            map,
            hovered.marker.coreEntry,
            hovered.x,
            hovered.y
        )
    else
        MapHover.Hide(map)
    end
end

function WorldMap.SelectActor(actorID)
    actorID = actorID and tostring(actorID) or nil
    WorldMap.SelectedActorID = actorID
    if CoreClient.SetSelected then
        CoreClient.SetSelected(actorID)
    end
    return actorID
end

function WorldMap.TrackActor(actorID)
    actorID = actorID and tostring(actorID) or nil
    if CoreClient.SetTracked then
        CoreClient.SetTracked(actorID)
    end
    return actorID
end

MapHost.Overlays.Register("DynamicTrading:DTAbstract", {
    order = 80,
    render = WorldMap.Render,
    enabled = function() return WorldMap.Enabled end,
    owner = "DynamicTrading",
})

MapHost.Events.Register("DynamicTrading:DTAbstractActors", {
    order = 80,
    onMouseDown = function(map, x, y)
        local hit = hitMarker(x, y, true)
        if not hit then return false end
        WorldMap.SelectActor(hit.marker.actorID)
        return true
    end,
    onClose = function(map)
        WorldMap.SelectActor(nil)
        if CoreClient.SetHighlighted then
            CoreClient.SetHighlighted(nil)
        end
        MapHover.Hide(map)
        return false
    end,
})

MapHost.Contexts.Register("DynamicTrading:DTAbstractActors", {
    order = 80,
    available = function(map, x, y)
        return hitMarker(x, y, true) ~= nil
    end,
    augment = function(map, context, x, y)
        local hit = hitMarker(x, y, true)
        if not hit or not context or not context.addOption then
            return false
        end
        local marker = hit.marker
        context:addOption(
            "Select " .. tostring(marker.name or "trader"),
            nil,
            function()
                WorldMap.SelectActor(marker.actorID)
            end
        )
        local tracked = CoreClient.GetTracked
            and CoreClient.GetTracked() or nil
        local trackedID = tracked
            and tostring(tracked.actorID or "") or ""
        local alreadyTracked =
            trackedID == tostring(marker.actorID)
        context:addOption(
            alreadyTracked and "Stop tracking"
                or ("Track " .. tostring(marker.name or "trader")),
            nil,
            function()
                WorldMap.TrackActor(
                    alreadyTracked and nil
                        or marker.actorID
                )
            end
        )
        return true
    end,
})

return WorldMap
