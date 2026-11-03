-- World map presentation adapter for DTAbstract traders and settlements.
--
-- Renders authoritative settlement coordinates from DTCommon.SettlementDirectory
-- and moving trader markers from canonical PsychopatzCore projected journey positions.
-- Pure presentation: NEVER mutates simulation or market state.

DTAbstract = DTAbstract or {}
DTAbstract.WorldMap = DTAbstract.WorldMap or {}

local WorldMap = DTAbstract.WorldMap

WorldMap.Enabled = true
WorldMap.ShowAll = false -- set true in debug mode to reveal undiscovered traders
WorldMap.MarkerSize = 10

local function isFiniteNumber(value)
    if type(value) ~= "number" then return false end
    if value ~= value then return false end
    if value == math.huge or value == -math.huge then return false end
    return true
end

local function canUseDebug()
    local player = getSpecificPlayer and getSpecificPlayer(0) or (getPlayer and getPlayer() or nil)
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    return false
end

local function getActors()
    if PsychopatzCore and PsychopatzCore.Actors then
        return PsychopatzCore.Actors
    end
    local ok, actors = pcall(require, "PsychopatzCore/Actors/PsychopatzActors")
    if ok and actors then return actors end
    return nil
end

local function getActorRegistry()
    if DTAbstract.Lifecycle and type(DTAbstract.Lifecycle.GetActorRegistry) == "function" then
        return DTAbstract.Lifecycle.GetActorRegistry()
    end
    local actors = getActors()
    return actors and actors.DefaultRegistry or nil
end

function WorldMap.GetSettlementMarkers()
    local markers = {}
    local Directory = DTCommon and DTCommon.SettlementDirectory
    if not Directory then return markers end

    local settlements = Directory.List()
    for i = 1, #settlements do
        local s = settlements[i]
        if s and s.enabled ~= false and s.position then
            markers[#markers + 1] = {
                id = s.settlementID,
                name = s.name or s.settlementID,
                kind = "settlement",
                position = {
                    x = s.position.x,
                    y = s.position.y,
                    z = s.position.z or 0,
                },
                provider = s.provider or "DTCommon",
                label = s.name or s.settlementID,
                color = { r = 0.2, g = 0.65, b = 0.95, a = 1.0 },
                size = 12,
            }
        end
    end
    return markers
end

function WorldMap.GetTraderMarkers(now, showAll)
    local markers = {}
    if not DTCommon or not DTCommon.TraderService then return markers end

    local Actors = getActors()
    local World = Actors and Actors.World
    local reg = getActorRegistry()
    local Directory = DTCommon.SettlementDirectory
    local debugMode = showAll == true or WorldMap.ShowAll == true or canUseDebug()

    DTCommon.TraderService.ForEach(function(traderID, record)
        local ca = record and record.ca or nil
        if ca and (ca.provider == "DTAbstract" or ca.coreProvider == "DTAbstract") then
            local actorID = ca.actorID or ca.coreActorID
            local actor = reg and actorID and reg:Get(actorID)
            local world = actor and actor.world
            local pos = nil

            if world and World and type(World.ProjectPosition) == "function" then
                pos = World.ProjectPosition(world, now)
            elseif world and world.location and world.location.position then
                pos = world.location.position
            end

            if not pos and ca.currentSettlementID and Directory then
                pos = Directory.ResolvePosition(ca.currentSettlementID)
            end

            if pos and isFiniteNumber(pos.x) and isFiniteNumber(pos.y) then
                local journey = world and world.journey
                local isTraveling = journey and (journey.state == "en_route" or journey.state == "planned")
                local label = record.n or traderID

                if isTraveling and ca.destinationSettlementID then
                    local destName = ca.destinationSettlementID
                    if Directory then
                        local dest = Directory.Get(ca.destinationSettlementID)
                        if dest and dest.name then destName = dest.name end
                    end
                    label = label .. " -> " .. tostring(destName)
                elseif ca.currentSettlementID then
                    local currName = ca.currentSettlementID
                    if Directory then
                        local curr = Directory.Get(ca.currentSettlementID)
                        if curr and curr.name then currName = curr.name end
                    end
                    label = label .. " [" .. tostring(currName) .. "]"
                end

                local discovered = true
                if DTAbstract.NearbyDiscovery and type(DTAbstract.NearbyDiscovery.IsTraderDiscovered) == "function" then
                    discovered = DTAbstract.NearbyDiscovery.IsTraderDiscovered(traderID)
                end

                if debugMode or discovered then
                    markers[#markers + 1] = {
                        id = traderID,
                        actorID = actorID,
                        name = record.n or traderID,
                        kind = "trader",
                        position = { x = pos.x, y = pos.y, z = pos.z or 0 },
                        label = label,
                        isTraveling = isTraveling,
                        journeyProgress = journey and journey.progress or 0,
                        discovered = discovered,
                        color = { r = 0.95, g = 0.75, b = 0.15, a = 1.0 },
                        size = 10,
                    }
                end
            end
        end
    end)

    table.sort(markers, function(a, b) return a.id < b.id end)
    return markers
end

function WorldMap.GetMapMarkers(now, showAll)
    local settlements = WorldMap.GetSettlementMarkers()
    local traders = WorldMap.GetTraderMarkers(now, showAll)
    local combined = {}

    for i = 1, #settlements do
        combined[#combined + 1] = settlements[i]
    end
    for i = 1, #traders do
        combined[#combined + 1] = traders[i]
    end

    return combined
end

function WorldMap.Render(map)
    if not WorldMap.Enabled or not map or not map.mapAPI then return end

    local now = nil
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        now = gameTime:getWorldAgeHours()
    end

    local markers = WorldMap.GetMapMarkers(now)
    for i = 1, #markers do
        local m = markers[i]
        local uiX = map.mapAPI:worldToUIX(m.position.x, m.position.y)
        local uiY = map.mapAPI:worldToUIY(m.position.x, m.position.y)

        if uiX and uiY then
            local size = m.size or WorldMap.MarkerSize
            local c = m.color or { r = 1, g = 1, b = 1, a = 1 }

            if map.drawRect then
                map:drawRect(uiX - size / 2, uiY - size / 2, size, size, c.a or 1, c.r or 1, c.g or 1, c.b or 1)
            end

            if map.drawTextCentre and m.label then
                local font = UIFont and UIFont.Small or nil
                map:drawTextCentre(m.label, uiX, uiY + size / 2 + 2, c.r or 1, c.g or 1, c.b or 1, c.a or 1, font)
            end
        end
    end
end

-- Attach to map seam
if PsychopatzCore and PsychopatzCore.MapOverlayRegistry
    and type(PsychopatzCore.MapOverlayRegistry.Register) == "function"
then
    PsychopatzCore.MapOverlayRegistry.Register("DTAbstract", {
        id = "DTAbstract",
        order = 80,
        render = WorldMap.Render,
        enabled = function() return WorldMap.Enabled end,
    })
elseif ISWorldMap and not ISWorldMap._dtAbstractMapPatched then
    ISWorldMap._dtAbstractMapPatched = true
    local originalRender = ISWorldMap.render
    function ISWorldMap:render()
        if originalRender then originalRender(self) end
        WorldMap.Render(self)
    end
end

return WorldMap
