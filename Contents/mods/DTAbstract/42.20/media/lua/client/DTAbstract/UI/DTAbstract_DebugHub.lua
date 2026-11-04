-- Dedicated DTAbstract debug service registered in the shared Core Debug Hub.
-- The real window lives in DTAbstract_DebugTraderWindow.lua; all mutations
-- remain server-authoritative.

DTAbstract = DTAbstract or {}
DTAbstract.DebugHub = DTAbstract.DebugHub or {}

local DebugHub = DTAbstract.DebugHub
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"

DebugHub.LastResult = DebugHub.LastResult or nil
DebugHub.LastSpawn = DebugHub.LastSpawn or nil

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function canUseDebug()
    local current = player()
    if not current then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(current) == true
    end
    return false
end

local function sendCommand(command, args)
    local current = player()
    if not current or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    sendClientCommand(current, "DTAbstract", command, args or {})
    return true
end

function DebugHub.ListTraders()
    local list = {}
    if not DTCommon or not DTCommon.TraderService then return list end

    local current = player()
    local px = current and current.getX and tonumber(current:getX()) or nil
    local py = current and current.getY and tonumber(current:getY()) or nil

    for _, row in ipairs(Presentation.ListTraderRecords(true)) do
        local traderID = row.traderID
        local record = row.record
        local ca = record and record.ca or nil
        local provider = row.provider
        if ca and (ca.actorID) then
            local actorID = ca.actorID
            local projection = CoreClient.GetActor(actorID)
            local pos = projection and projection.position or nil
            local distance = nil
            if px and py and pos and pos.x and pos.y then
                local dx = px - pos.x
                local dy = py - pos.y
                distance = math.sqrt(dx * dx + dy * dy)
            end

            local journey = projection and projection.journey or nil
            local discovered = false
            if DTAbstract.NearbyDiscovery
                and type(DTAbstract.NearbyDiscovery.IsTraderDiscovered)
                    == "function"
            then
                discovered =
                    DTAbstract.NearbyDiscovery.IsTraderDiscovered(traderID)
            end

            list[#list + 1] = {
                traderID = traderID,
                displayName = record.n or traderID,
                actorID = actorID,
                provider = projection and projection.provider
                    or ca.provider or "PsychopatzCore",
                providerState = projection and projection.providerState
                    or ca.providerState or "abstract",
                budget = record.b or 0,
                stockVersion = record.v or 0,
                position = pos and {
                    x = pos.x, y = pos.y, z = pos.z or 0,
                } or nil,
                portrait = projection and projection.portrait or nil,
                distance = distance,
                discovered = discovered,
                homeSettlementID = ca.homeSettlementID,
                currentSettlementID = ca.currentSettlementID,
                originSettlementID = ca.originSettlementID,
                destinationSettlementID = ca.destinationSettlementID,
                journeyState = journey and journey.state
                    or ca.journeyState or ca.lifecycleState or "idle",
                journeyProgress = journey and journey.progress or 0,
                journeyETA = journey and journey.eta or nil,
            }
        end
    end

    table.sort(list, function(a, b)
        return tostring(a.traderID) < tostring(b.traderID)
    end)
    return list
end

function DebugHub.RefreshProjection()
    local actors, actorReason = CoreClient.RequestActors()
    local discovery, discoveryReason =
        CoreClient.RequestDiscovery()
    if actors or discovery then
        return true
    end
    return false, actorReason or discoveryReason
end

function DebugHub.SpawnNear(options)
    return sendCommand("SpawnAbstractTraderNearPlayer", options)
end

function DebugHub.SpawnAt(x, y, z, settlementID)
    return sendCommand("SpawnAbstractTraderAtPosition", {
        position = {
            x = tonumber(x), y = tonumber(y), z = tonumber(z) or 0,
        },
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

function DebugHub.OpenDebugTalk(traderID)
    traderID = tostring(traderID or "")
    if traderID == "" then return false, "trader_required" end
    if not canUseDebug() then return false, "not_authorized" end

    local selected
    for _, item in ipairs(DebugHub.ListTraders()) do
        if item.traderID == traderID then
            selected = item
            break
        end
    end
    if not selected then return false, "trader_not_found" end

    local Bridge = DTAbstract.CoreConversation
        or require "DTAbstract/DTAbstract_CoreConversation"
    return Bridge.Request(
        traderID,
        "debug",
        {
            actorID = selected.actorID,
            displayName = selected.displayName,
        }
    )
end

function DebugHub.LocateOnMap(traderID)
    local traders = DebugHub.ListTraders()
    for index = 1, #traders do
        local item = traders[index]
        if item.traderID == traderID and item.position then
            pcall(require, "ISUI/Maps/ISWorldMap")
            if ISWorldMap and type(ISWorldMap.ShowWorldMap) == "function" then
                ISWorldMap.ShowWorldMap(
                    0, item.position.x, item.position.y, 18.0)
            elseif ISWorldMap_ToggleMap then
                ISWorldMap_ToggleMap()
            end
            return true, item.position
        end
    end
    return false, "trader_not_found"
end

function DebugHub.ResetDiscovery(traderID)
    if DTAbstract.NearbyDiscovery
        and type(DTAbstract.NearbyDiscovery.ResetDiscovery) == "function"
    then
        DTAbstract.NearbyDiscovery.ResetDiscovery(traderID)
        return true
    end
    return false
end

function DebugHub.MarkDiscovery(traderID)
    if DTAbstract.NearbyDiscovery
        and type(DTAbstract.NearbyDiscovery.MarkDiscovered) == "function"
    then
        return DTAbstract.NearbyDiscovery.MarkDiscovered(traderID)
    end
    return false
end

function DebugHub.DiscoverAll(scope)
    return CoreClient.DiscoveryAction(
        "debug_discover_all",
        {
            scope = tostring(scope or "all"),
        }
    )
end

function DebugHub.ResetAllDiscovery()
    return CoreClient.DiscoveryAction(
        "debug_reset",
        {}
    )
end

local function resultText(args)
    local action = tostring(args.action or "action")
    local reason = tostring(args.reason or "")
    local state = args.accepted == true and "OK" or "FAILED"
    local trader = args.traderID
        and (" trader=" .. tostring(args.traderID)) or ""
    return state .. " " .. action .. trader
        .. (reason ~= "" and (" (" .. reason .. ")") or "")
end

local function publishDebugFeedback(args)
    local message = resultText(args)
    local manager = DTAbstract.DebugTraderWindow
    if manager and type(manager.SetResult) == "function" then
        manager.SetResult(message, args)
    end
    if PsychopatzCore and PsychopatzCore.Notifications
        and type(PsychopatzCore.Notifications.Show) == "function"
    then
        PsychopatzCore.Notifications.Show({
            id = "dtabstract_debug:"
                .. tostring(args.action or "action")
                .. ":" .. tostring(args.traderID or "global"),
            title = "DTAbstract Debug",
            message = message,
            text = message,
        })
    end
end

local function onServerCommand(module, command, args)
    if module ~= "DTAbstract" then return end
    args = type(args) == "table" and args or {}

    if command == "TraderSpawned" then
        DebugHub.LastSpawn = args
        if args.accepted ~= false then
            DebugHub.RefreshProjection()
        end
        if DTAbstract.DebugTraderWindow
            and DTAbstract.DebugTraderWindow.SetResult
        then
            DTAbstract.DebugTraderWindow.SetResult(
                "Spawned " .. tostring(args.traderID or "trader"), args)
        end
        return
    end

    if command == "ConversationAccessResult"
        and tostring(args.mode or "") == "debug"
    then
        local feedback = {
            accepted = args.accepted == true,
            action = "debug_talk",
            reason = args.reason,
            traderID = args.traderID,
            actorID = args.actorID,
        }
        DebugHub.LastResult = feedback
        publishDebugFeedback(feedback)
        return
    end

    if command == "TraderDebugActionResult" then
        DebugHub.LastResult = args
        if args.accepted == true then
            DebugHub.RefreshProjection()
        end
        publishDebugFeedback(args)
    end
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not DebugHub._serverCommandHook
then
    DebugHub._serverCommandHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

local Manager = require "DTAbstract/UI/DTAbstract_DebugTraderWindow"

function DebugHub.Open()
    return Manager.Open()
end

-- Register in shared PsychopatzCore Debug Hub if present.
local CoreDebugHub = PsychopatzCore and PsychopatzCore.DebugHub
if CoreDebugHub and type(CoreDebugHub.RegisterTool) == "function" then
    CoreDebugHub.RegisterTool({
        id = "dtabstract:traders",
        source = "Dynamic Trading",
        order = 220,
        category = "dynamictrading",
        title = "Abstract Trader Manager",
        description = "Manage standalone abstract traders and journeys.",
        available = canUseDebug,
        action = DebugHub.Open,
    })
end

return DebugHub
