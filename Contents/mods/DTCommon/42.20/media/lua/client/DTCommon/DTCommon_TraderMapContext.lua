-- Shared Dynamic Trading map interaction surface.
-- Core owns the actor marker and hover card; DTCommon adds trader actions.

DTCommon = DTCommon or {}

local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"
local Manager = DTCommon.TraderManager
    or require "DTCommon/DTCommon_TraderManager"
local ActorMap = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
local Host = require "PsychopatzCore/UI/Map/PsychopatzMapHost"

local Interaction = DTCommon.TraderMapContext
    or {}
DTCommon.TraderMapContext = Interaction

local function viewAt(x, y)
    local hit = ActorMap and ActorMap.FindMarkerAt
        and ActorMap.FindMarkerAt(x, y, 3) or nil
    if not hit then return nil, nil end
    local metadata = hit.marker
        and type(hit.marker.hoverMetadata) == "table"
        and hit.marker.hoverMetadata or {}
    local traderID = metadata.traderID
    local view
    if Presentation.GetTraderViewForActor then
        view = Presentation.GetTraderViewForActor(hit.actorID, false)
    end
    if not view and traderID and Presentation.GetTraderView then
        view = Presentation.GetTraderView(traderID, false)
    end
    return view, hit
end

local function player()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function request(action, view)
    if not view or not Manager or type(Manager.Request) ~= "function" then
        return false, "trader_manager_unavailable"
    end
    local ok, reason = Manager.Request(action, view.traderID, {
        mode = "nearby",
        player = player(),
        actorID = view.actorID,
    })
    if not ok and Manager.SetNotice then Manager.SetNotice(reason) end
    return ok, reason
end

local function addOption(context, title, callback)
    if not context or type(context.addOption) ~= "function" then
        return false
    end
    context:addOption(title, nil, callback)
    return true
end

if Host and Host.Contexts and type(Host.Contexts.Register) == "function" then
    Host.Contexts.Register("DTCommon:TraderInteraction", {
        order = 70,
        available = function(_, x, y)
            local view = viewAt(x, y)
            return view ~= nil
        end,
        augment = function(_, context, x, y)
            local view = viewAt(x, y)
            if not view or not context then return false end
            local added = false
            if view.talkAvailable ~= false then
                added = addOption(
                    context,
                    "Talk to " .. tostring(view.name or view.traderID),
                    function() request("talk", view) end
                ) or added
            end
            if view.tradeAvailable ~= false then
                added = addOption(
                    context,
                    "Trade with " .. tostring(view.name or view.traderID),
                    function() request("trade", view) end
                ) or added
            end
            return added
        end,
    })
end

return Interaction
