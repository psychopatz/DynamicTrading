-- DTAbstract world-map adapter.
--
-- PsychopatzCore owns canonical per-NPC dots, hover, selection, tracking and
-- routes. DTAbstract contributes only commercial trader decoration plus
-- settlement/group/signal discovery presentation.

DTAbstract = DTAbstract or {}
DTAbstract.WorldMap = DTAbstract.WorldMap or {}

local WorldMap = DTAbstract.WorldMap
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
local ActorMap = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
local MapHost = require "PsychopatzCore/UI/Map/PsychopatzMapHost"
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

WorldMap.Enabled = WorldMap.Enabled ~= false
WorldMap.ShowAll = WorldMap.ShowAll == true
WorldMap.MarkerSize = tonumber(WorldMap.MarkerSize) or 10

local COLORS = {
    settlement = { r = 0.2, g = 0.65, b = 0.95, a = 1.0 },
    group = { r = 0.85, g = 0.55, b = 0.2, a = 0.9 },
    signal = { r = 0.72, g = 0.45, b = 0.95, a = 0.9 },
    trader = { r = 0.95, g = 0.75, b = 0.15, a = 1.0 },
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
                and "settlement" or kind
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

    -- Debug can show canonical settlement geography without creating discovery.
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
    return label
end

local function traderIndex()
    local output = {}
    for _, row in ipairs(
        Presentation.ListTraderRecords(false)
    ) do
        local record = row.record
        local ca = record and record.ca or nil
        if ca
            and (row.provider == "DTAbstract"
                or tostring(ca.returnProviderID or "") == "DTAbstract")
            and ca.actorID
        then
            output[tostring(ca.actorID)] = row
        end
    end
    return output
end

function WorldMap.GetTraderMarkers()
    refresh()
    local output = {}
    local traders = traderIndex()
    for _, entry in ipairs(CoreClient.ListActors(false) or {}) do
        local row = traders[tostring(entry.actorID or "")]
        if row and entry.position then
            local record = row.record
            local ca = record.ca or {}
            output[#output + 1] = {
                id = row.traderID,
                traderID = row.traderID,
                actorID = entry.actorID,
                position = entry.position,
                canonicalPosition = entry.canonicalPosition
                    or entry.position,
                label = commercialLabel(
                    row.traderID,
                    record,
                    ca,
                    entry.journey
                ),
                journey = entry.journey,
                route = entry.journey and entry.journey.route or nil,
                journeyProgress = entry.journey
                    and entry.journey.progress or 0,
                portrait = entry.portrait,
                coreEntry = entry,
                positionSource = entry.positionSource,
            }
        end
    end
    table.sort(output, function(left, right)
        return tostring(left.id) < tostring(right.id)
    end)
    return output
end

-- Compatibility query for existing callers. Actor dots are rendered by Core,
-- so this function is data-only and does not create a second marker system.
function WorldMap.GetMapMarkers(_, showAll)
    local combined = {}
    for _, marker in ipairs(
        WorldMap.GetDiscoveryMarkers(showAll)
    ) do
        combined[#combined + 1] = marker
    end
    for _, marker in ipairs(WorldMap.GetTraderMarkers()) do
        combined[#combined + 1] = marker
    end
    return combined
end

local function decorateTrader(entry, style)
    local row = traderIndex()[tostring(entry.actorID or "")]
    if not row then return style end
    local record = row.record
    local ca = record and record.ca or {}
    style.label = commercialLabel(
        row.traderID,
        record,
        ca,
        entry.journey
    )
    style.color = COLORS.trader
    style.size = 10
    return style
end

ActorMap.RegisterDecorator("DynamicTrading:DTAbstract", {
    priority = 100,
    decorate = decorateTrader,
})

function WorldMap.Render(map)
    if not WorldMap.Enabled or not map or not map.mapAPI then return end
    local markers = WorldMap.GetDiscoveryMarkers(false)
    for _, marker in ipairs(markers) do
        local x = marker.position and tonumber(marker.position.x)
        local y = marker.position and tonumber(marker.position.y)
        if x and y then
            local uiX = map.mapAPI:worldToUIX(x, y)
            local uiY = map.mapAPI:worldToUIY(x, y)
            if uiX and uiY then
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
                    map:drawTextCentre(
                        marker.label,
                        uiX,
                        uiY + size / 2 + 2,
                        color.r or 1,
                        color.g or 1,
                        color.b or 1,
                        color.a or 1,
                        UIFont and UIFont.Small or nil
                    )
                end
            end
        end
    end
end

MapHost.Overlays.Register("DynamicTrading:DTAbstractDiscovery", {
    order = 80,
    render = WorldMap.Render,
    enabled = function() return WorldMap.Enabled end,
    owner = "DynamicTrading",
})

return WorldMap
