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
local CoreClient = {
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

local traders = WorldMap.GetTraderMarkers(10, false)
T.equal(#traders, 1, "canonical trader marker missing")
local trader = traders[1]
T.equal(trader.actorID, actorEntry.actorID,
    "trader marker actor identity changed")
T.equal(trader.position.x, 10633,
    "trader marker ignored Core overlap-spread position")
T.equal(trader.canonicalPosition.x, 10630,
    "canonical unspread actor position missing")
T.equal(trader.route.points[2].x, 11900,
    "Core group route missing from trader marker")
T.equal(trader.journeyProgress, 0.5,
    "Core group journey progress missing")
T.contains(trader.label, "Destination Camp",
    "commercial destination label was not retained")
T.equal(trader.positionSource, "group",
    "Core position source missing")

local lines = {}
local rects = {}
local texts = {}
local mockMap = {
    width = 1280,
    height = 720,
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
    drawTextCentre = function(_, text, x, y)
        texts[#texts + 1] = { text = text, x = x, y = y }
    end,
}

WorldMap.Render(mockMap)
T.truthy(#rects >= 4,
    "map did not render discovery entities plus trader")
T.equal(highlightedActor, actorEntry.actorID,
    "hover did not mirror Core highlighted actor")
T.equal(hoverUpdates, 1,
    "Core portrait hover was not used")

local event = registered.events[
    "DynamicTrading:DTAbstractActors"
]
T.truthy(event, "DTAbstract Core map event adapter missing")
local selected = event.onMouseDown(
    mockMap,
    1063.3,
    998
)
T.truthy(selected,
    "click on trader marker was not handled")
T.equal(selectedActor, actorEntry.actorID,
    "map selection did not mirror Core selection")

WorldMap.Render(mockMap)
T.truthy(#lines >= 1,
    "selected trader did not render Core group route")

local contextDef = registered.contexts[
    "DynamicTrading:DTAbstractActors"
]
T.truthy(
    contextDef.available(mockMap, 1063.3, 998),
    "trader context provider did not hit canonical marker"
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
    "trader context provider did not add actions"
)
T.equal(#options, 2,
    "select/track context actions missing")
options[2].callback()
T.equal(trackedActor, actorEntry.actorID,
    "track action did not mirror Core tracking")

local trackedMarkers = WorldMap.GetTraderMarkers(10, false)
T.truthy(trackedMarkers[1].tracked,
    "tracked actor state did not return through Core")
T.equal(trackedMarkers[1].size, 13,
    "tracked actor did not receive tracked presentation state")

-- Closing clears transient selection/highlight but not persistent tracking.
event.onClose(mockMap)
T.equal(selectedActor, nil,
    "map close did not clear Core selection")
T.equal(highlightedActor, nil,
    "map close did not clear Core highlight")
T.equal(trackedActor, actorEntry.actorID,
    "map close unexpectedly cleared tracking")
T.truthy(hoverHides >= 1,
    "map close did not hide Core hover portrait")

T.truthy(actorRefreshes >= 1,
    "map never refreshed Core actor projection")
T.truthy(discoveryRefreshes >= 1,
    "map never refreshed Core discovery projection")

T.finish("dt_abstract_map_smoke")
