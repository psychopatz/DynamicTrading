-- Dedicated DTAbstract Trader Manager for the PsychopatzCore Debug Hub.
--
-- Inspects authoritative abstract trader state and dispatches server-authoritative
-- debug actions (Spawn Near, Teleport, Force Tick, Force Arrival, Remove).

DTAbstract = DTAbstract or {}
DTAbstract.DebugHub = DTAbstract.DebugHub or {}

local DebugHub = DTAbstract.DebugHub

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

local function sendCommand(command, args)
    if sendClientCommand then
        sendClientCommand("DTAbstract", command, args or {})
        return true
    end
    return false, "send_command_unavailable"
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

function DebugHub.ListTraders(now)
    local list = {}
    if not DTCommon or not DTCommon.TraderService then return list end

    local player = getSpecificPlayer and getSpecificPlayer(0) or (getPlayer and getPlayer() or nil)
    local px = player and player.getX and tonumber(player:getX()) or nil
    local py = player and player.getY and tonumber(player:getY()) or nil

    local Actors = getActors()
    local World = Actors and Actors.World
    local reg = getActorRegistry()
    local Directory = DTCommon.SettlementDirectory
    now = tonumber(now) or (getGameTime and getGameTime():getWorldAgeHours() or 0)

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

            local distance = nil
            if px and py and pos and pos.x and pos.y then
                local dx = px - pos.x
                local dy = py - pos.y
                distance = math.sqrt(dx * dx + dy * dy)
            end

            local journey = world and world.journey
            local discovered = false
            if DTAbstract.NearbyDiscovery and type(DTAbstract.NearbyDiscovery.IsTraderDiscovered) == "function" then
                discovered = DTAbstract.NearbyDiscovery.IsTraderDiscovered(traderID)
            end

            list[#list + 1] = {
                traderID = traderID,
                displayName = record.n or traderID,
                actorID = actorID,
                provider = ca.provider or ca.coreProvider or "DTAbstract",
                providerState = ca.providerState or ca.coreProviderState or "abstract",
                budget = record.b or 0,
                stockVersion = record.v or 0,
                position = pos and { x = pos.x, y = pos.y, z = pos.z or 0 } or nil,
                distance = distance,
                discovered = discovered,
                homeSettlementID = ca.homeSettlementID,
                currentSettlementID = ca.currentSettlementID,
                destinationSettlementID = ca.destinationSettlementID,
                journeyState = journey and journey.state or "idle",
                journeyProgress = journey and journey.progress or 0,
                journeyETA = journey and journey.eta or nil,
            }
        end
    end)

    table.sort(list, function(a, b) return a.traderID < b.traderID end)
    return list
end

function DebugHub.SpawnNear(options)
    return sendCommand("SpawnAbstractTraderNearPlayer", options)
end

function DebugHub.SpawnAt(x, y, z, settlementID)
    return sendCommand("SpawnAbstractTraderNearPlayer", {
        position = { x = x, y = y, z = z or 0 },
        settlementID = settlementID,
    })
end

function DebugHub.ForceTick(now)
    return sendCommand("ForceTick", { now = now })
end

function DebugHub.ForceArrival(traderID)
    return sendCommand("ForceArrival", { traderID = traderID })
end

function DebugHub.TeleportToTrader(traderID)
    return sendCommand("TeleportToTrader", { traderID = traderID })
end

function DebugHub.RemoveTrader(traderID)
    return sendCommand("RemoveTrader", { traderID = traderID })
end

function DebugHub.LocateOnMap(traderID)
    local traders = DebugHub.ListTraders()
    for i = 1, #traders do
        if traders[i].traderID == traderID and traders[i].position then
            local pos = traders[i].position
            if ISWorldMap_ToggleMap then
                ISWorldMap_ToggleMap()
            end
            return true, pos
        end
    end
    return false, "trader_not_found"
end

function DebugHub.ResetDiscovery(traderID)
    if DTAbstract.NearbyDiscovery and type(DTAbstract.NearbyDiscovery.ResetDiscovery) == "function" then
        DTAbstract.NearbyDiscovery.ResetDiscovery(traderID)
        return true
    end
    return false
end

function DebugHub.Open()
    return true
end

-- Register in shared PsychopatzCore Debug Hub if present
local CoreDebugHub = PsychopatzCore and PsychopatzCore.DebugHub
if CoreDebugHub and type(CoreDebugHub.RegisterTool) == "function" then
    CoreDebugHub.RegisterTool({
        id = "dtabstract:traders",
        category = "dynamictrading",
        title = "Abstract Trader Manager",
        description = "Manage and inspect standalone abstract traders, world journeys and debug spawning.",
        available = canUseDebug,
        action = DebugHub.Open,
    })
end

return DebugHub
