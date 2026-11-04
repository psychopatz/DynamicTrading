local T = require "tests/support/test"
T.addPackagePaths()

local actorRefreshes = 0
local discoveryRefreshes = 0
local selectedActor
local highlightedActor
local trackedActor
local actorEntry = {
    actorID = "actor:map:test1",
    label = "Canonical Trader Actor",
    provider = "DTAbstract",
    providerState = "abstract",
    groupID = "group:map:test1",
    communityID = "community:map:home",
    factionID = "faction:map:test1",
    role = "leader",
    position = { x = 10633, y = 9980, z = 0 },
    canonicalPosition = { x = 10630, y = 9980, z = 0 },
    positionSource = "group",
    portrait = {
        schemaVersion = 1,
        actorID = "actor:map:test1",
        gender = "male",
        face = { hairModel = "Short" },
        policy = {},
    },
    journey = {
        journeyID = "journey:map:1",
        state = "en_route",
        progress = 0.5,
        eta = 12,
        distanceTotal = 200,
        distanceTravelled = 100,
        route = {
            points = {
                { x = 10630, y = 9980, z = 0 },
                { x = 11900, y = 6900, z = 0 },
            },
        },
    },
}
local discoverySnapshot = {
    state = "known",
    playerKey = "player:map",
    revision = 3,
    entities = {
        {
            entityID = "community:map:home",
            kind = "community",
            phase = 3,
            phaseName = "CONTACTED",
            name = "Canonical Haven",
            x = 10630,
            y = 9980,
            z = 0,
        },
        {
            entityID = "group:map:test1",
            kind = "group",
            phase = 3,
            phaseName = "CONTACTED",
            name = "Trader Caravan",
            x = 10630,
            y = 9980,
            z = 0,
        },
        {
            entityID = "signal:map:test1",
            kind = "signal",
            phase = 1,
            phaseName = "RUMORED",
            x = 11000,
            y = 9000,
            z = 0,
            approximate = true,
        },
    },
}
local CoreClient
CoreClient = {
    Selection = { selectedActorID = nil },
    RequestActorsIfDue = function(interval)
        actorRefreshes = actorRefreshes + 1
        T.equal(interval, 500,
            "DT map actor refresh cadence changed")
        return true
    end,
    RequestDiscoveryIfDue = function(interval)
        discoveryRefreshes = discoveryRefreshes + 1
        T.equal(interval, 5000,
            "DT map discovery refresh cadence changed")
        return true
    end,
    ListActors = function(raw)
        if raw == true then
            local rawEntry = {}
            for key, value in pairs(actorEntry) do
                rawEntry[key] = value
            end
            rawEntry.position = actorEntry.canonicalPosition
            return { rawEntry }
        end
        return { actorEntry }
    end,
    GetDiscoverySnapshot = function()
        return discoverySnapshot
    end,
    SetSelected = function(actorID)
        selectedActor = actorID
        CoreClient.Selection.selectedActorID = actorID
        return { selectedActorID = actorID }
    end,
    SetHighlighted = function(actorID)
        highlightedActor = actorID
        return { highlightedActorID = actorID }
    end,
    SetTracked = function(actorID)
        trackedActor = actorID
        return { trackedActorID = actorID }
    end,
    GetTracked = function()
        return trackedActor == actorEntry.actorID
            and actorEntry or nil
    end,
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return CoreClient
end

local hoverUpdates = 0
local hoverHides = 0
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldMapHover"
] = function()
    return {
        Update = function(_, entry)
            hoverUpdates = hoverUpdates + 1
            T.equal(entry.actorID, actorEntry.actorID,
                "hover used wrong canonical actor")
            return true
        end,
        Hide = function()
            hoverHides = hoverHides + 1
            return true
        end,
    }
end

local registered = {
    overlays = {},
    events = {},
    contexts = {},
}
local MapHost = {
    Overlays = {
        Register = function(id, def)
            registered.overlays[id] = def
            return true
        end,
    },
    Events = {
        Register = function(id, def)
            registered.events[id] = def
            return true
        end,
    },
    Contexts = {
        Register = function(id, def)
            registered.contexts[id] = def
            return true
        end,
    },
}
package.preload[
    "PsychopatzCore/UI/Map/PsychopatzMapHost"
] = function()
    return MapHost
end

local mapPlayer = {}
getSpecificPlayer = function() return mapPlayer end
getPlayer = function() return mapPlayer end

PsychopatzCore = {
    Debug = {
        CanUse = function() return false end,
    },
}

local record = {
    n = "Traveling Merchant",
    b = 500,
    v = 1,
    ca = {
        actorID = actorEntry.actorID,
        provider = "DTAbstract",
        providerState = "abstract",
        currentSettlementID = "community:map:home",
        destinationSettlementID = "community:map:destination",
    },
}
DTCommon = {
    SettlementDirectory = {
        List = function()
            return {
                {
                    settlementID = "community:map:home",
                    name = "Canonical Haven",
                    enabled = true,
                    position = { x = 10630, y = 9980, z = 0 },
                },
                {
                    settlementID = "community:raw:hidden",
                    name = "Raw Hidden",
                    enabled = true,
                    position = { x = 12000, y = 10000, z = 0 },
                },
            }
        end,
        Get = function(id)
            if id == "community:map:home" then
                return { name = "Canonical Haven" }
            end
            if id == "community:map:destination" then
                return { name = "Destination Camp" }
            end
        end,
    },
    TraderPresentation = {
        ListTraderRecords = function()
            return {
                {
                    traderID = "trader:map:1",
                    record = record,
                    provider = "DTAbstract",
                },
            }
        end,
    },
}
DTAbstract = {
    NearbyDiscovery = {
        IsTraderDiscovered = function(traderID)
            return traderID == "trader:map:1"
        end,
    },
}

local WorldMap = T.load(
    "DTAbstract",
    "client",
    "DTAbstract/DTAbstract_WorldMap.lua"
)
T.truthy(WorldMap, "DTAbstract.WorldMap loaded")

local discoveryMarkers = WorldMap.GetDiscoveryMarkers(false)
T.equal(#discoveryMarkers, 3,
    "Core community/group/signal discovery markers missing")
local byKind = {}
for _, marker in ipairs(discoveryMarkers) do
    byKind[marker.kind] = marker
end
T.truthy(byKind.settlement,
    "Core community did not render as settlement")
T.truthy(byKind.group,
    "Core group discovery marker missing")
T.truthy(byKind.signal,
    "Core signal discovery marker missing")
T.equal(byKind.settlement.id, "community:map:home",
    "settlement identity changed")
T.equal(byKind.signal.approximate, true,
    "rumored signal approximation flag lost")

local settlements = WorldMap.GetSettlementMarkers(false)
T.equal(#settlements, 1,
    "undiscovered raw settlement leaked in normal map mode")

local ActorMap = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
local traders = ActorMap.BuildMarkers()
T.equal(#traders, 1, "canonical trader actor marker missing")
local trader = traders[1]
T.equal(trader.actorID, actorEntry.actorID,
    "trader marker actor identity changed")
T.equal(trader.position.x, 10633,
    "trader marker ignored Core overlap-spread position")
T.equal(trader.entry.canonicalPosition.x, 10630,
    "canonical unspread actor position missing")
T.equal(trader.entry.journey.route.points[2].x, 11900,
    "Core group route missing from trader marker")
T.equal(trader.entry.journey.progress, 0.5,
    "Core group journey progress missing")
T.contains(trader.label, "Destination Camp",
    "shared commercial destination label was not retained")
T.equal(trader.entry.positionSource, "group",
    "Core position source missing")
T.equal(trader.icon.glyph, "T",
    "shared trader icon was not applied to Core marker")
T.equal(trader.badge.factionID, actorEntry.factionID,
    "shared faction badge was not applied to Core marker")

UIFont = { Small = {} }
local lines = {}
local rects = {}
local texts = {}
local mockMap = {
    width = 1280,
    height = 1200,
    mouseX = 1063.3,
    mouseY = 998,
    getMouseX = function(self) return self.mouseX end,
    getMouseY = function(self) return self.mouseY end,
    mapAPI = {
        worldToUIX = function(_, wx) return wx / 10 end,
        worldToUIY = function(_, _, wy) return wy / 10 end,
    },
    javaObject = {
        DrawLine = function(_, _, x1, y1, x2, y2)
            lines[#lines + 1] = { x1, y1, x2, y2 }
        end,
    },
    drawRect = function(_, x, y, w, h)
        rects[#rects + 1] = { x = x, y = y, w = w, h = h }
    end,
    drawRectBorder = function() end,
    drawTextCentre = function(_, text, x, y)
        texts[#texts + 1] = { text = text, x = x, y = y }
    end,
}

local discoveryOverlay = registered.overlays[
    "DynamicTrading:DTAbstractDiscovery"
]
T.truthy(discoveryOverlay,
    "DTAbstract discovery overlay was not registered")
local actorOverlay = registered.overlays[
    "PsychopatzCore:SurvivorWorldActors"
]
T.truthy(actorOverlay,
    "Core SurvivorWorld actor overlay was not registered")
T.falsy(registered.events["DynamicTrading:DTAbstractActors"],
    "DTAbstract retained a duplicate actor event system")
T.falsy(registered.contexts["DynamicTrading:DTAbstractActors"],
    "DTAbstract retained a duplicate actor context system")

discoveryOverlay.render(mockMap)
T.truthy(#rects >= 3,
    "DTAbstract discovery overlay did not render discovery entities")
local beforeActors = #rects
actorOverlay.render(mockMap)
T.truthy(#rects > beforeActors,
    "Core actor overlay did not render canonical NPC dot")
T.equal(highlightedActor, actorEntry.actorID,
    "Core actor hover did not mirror highlighted actor")
T.equal(hoverUpdates, 1,
    "Core actor overlay did not use Core portrait hover")

local event = registered.events[
    "PsychopatzCore:SurvivorWorldActors"
]
T.truthy(event, "Core actor map event adapter missing")
T.truthy(event.onMouseDown(mockMap, 1063.3, 998),
    "Core actor marker click was not handled")
T.equal(selectedActor, actorEntry.actorID,
    "Core actor selection did not preserve canonical actor ID")

mockMap.mouseX = 0
mockMap.mouseY = 0
actorOverlay.render(mockMap)
T.truthy(#lines >= 1,
    "selected Core actor did not render canonical group route")
local foundCommercialLabel = false
for _, text in ipairs(texts) do
    if tostring(text.text):find("Destination Camp", 1, true) then
        foundCommercialLabel = true
        break
    end
end
T.truthy(foundCommercialLabel,
    "DTAbstract trader decorator did not enrich Core actor label")

local contextDef = registered.contexts[
    "PsychopatzCore:SurvivorWorldActors"
]
T.truthy(contextDef,
    "Core actor tracking context was not registered")
T.truthy(
    contextDef.available(mockMap, 1063.3, 998),
    "Core actor tracking context did not hit canonical marker"
)
local options = {}
local context = {
    addOption = function(_, title, _, callback)
        options[#options + 1] = {
            title = title,
            callback = callback,
        }
    end,
}
T.truthy(
    contextDef.augment(
        mockMap,
        context,
        1063.3,
        998
    ),
    "Core actor tracking context did not add action"
)
T.equal(#options, 1,
    "Core actor tracking should expose one shared tracking action")
options[1].callback()
T.equal(trackedActor, actorEntry.actorID,
    "Core tracking action lost canonical actor identity")

event.onClose(mockMap)
T.equal(selectedActor, nil,
    "Core map close did not clear selection")
T.equal(highlightedActor, nil,
    "Core map close did not clear highlight")
T.equal(trackedActor, actorEntry.actorID,
    "Core map close unexpectedly cleared tracking")
T.truthy(hoverHides >= 1,
    "Core map close did not hide portrait hover")

T.truthy(actorRefreshes >= 1,
    "map never refreshed Core actor projection")
T.truthy(discoveryRefreshes >= 1,
    "map never refreshed Core discovery projection")

T.finish("dt_abstract_map_smoke")
