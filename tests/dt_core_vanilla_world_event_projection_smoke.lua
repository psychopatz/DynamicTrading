local T = require "tests/support/test"
T.addPackagePaths()

local coreRepo = os.getenv("PZ_TEST_CORE_REPOSITORY") or "../psychopatzCore"
package.path = coreRepo .. "/Contents/mods/PsychopatzCore/42.20/media/lua/shared/?.lua;"
    .. coreRepo .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] = function() return {} end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] = function() return {} end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] = function() return {} end

local mockHours = 120
local modData = {}
local hooks = {
    OnGameStart = {},
    OnInitGlobalModData = {},
    OnSave = {},
    OnElectricityChanged = {},
    EveryHours = {},
    EveryTenMinutes = {},
    OnAmbientSound = {},
    OnWorldSound = {},
    OnThunderEvent = {},
    OnNewFire = {},
    LoadChunk = {},
    OnSpawnVehicleEnd = {},
    OnSeeNewRoom = {},
}

isClient = function() return false end
isServer = function() return true end
getGameTime = function()
    return {
        getWorldAgeDaysSinceBegin = function() return mockHours / 24 end,
        getWorldAgeHours = function() return mockHours end,
    }
end
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    get = function(key) return modData[key] end,
    transmit = function() return true end,
}
Events = {}
for k, v in pairs(hooks) do
    Events[k] = {
        Add = function(fn) v[#v + 1] = fn end,
    }
end

-- Explicitly prove standalone Core + DynamicTrading integration WITHOUT ProjectHoomans (PNC = nil).
PNC = nil
DTHoomans = nil
DTCommon = {}
PsychopatzCore = {
    RuntimeRole = {
        AllowsServerCode = function() return true end,
    },
}

local Core = require "PsychopatzCore/00_PsychopatzCore_Init"
local ScopedEvents = Core.ScopedWorldEvents
local Observer = Core.VanillaEventObserver
local PZAdapter = Core.WorldEventAdapter
local DiscoveryAdapter = Core.VanillaDiscoveryAdapter
local Location = Core.WorldEventLocation
local CoreWKG = require "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"

ScopedEvents.Reset({ nowHours = mockHours })
Observer.Reset()
DiscoveryAdapter.Reset()
CoreWKG.Reset({ maxFacts = 64, maxRefs = 8, now = mockHours })

-- Load standalone DTCommon pipeline via DTCommon modules (zero DTHoomans loaded).
local dtRecords = {}

T.load("DTCommon", "shared", "DTCommon/DTCommon_Constants.lua")
DTCommon.MarketSchema = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = T.load("DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
local settlements = {
    comm_rosewood = {
        settlementID = "comm_rosewood",
        regionID = "region_south",
        name = "Rosewood Haven",
        status = "active",
    },
    comm_muldraugh = {
        settlementID = "comm_muldraugh",
        regionID = "region_central",
        name = "Muldraugh Outpost",
        status = "active",
    },
}
local listCalls = 0
DTCommon.SettlementDirectory = {
    Get = function(id) return settlements[id] end,
    List = function()
        listCalls = listCalls + 1
        return { settlements.comm_rosewood, settlements.comm_muldraugh }
    end,
}
DTCommon.CoreActorPolicy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.MarketEvents = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEventDefinitions = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketEventDefinitions.lua")
DTCommon.MarketEventPresentation = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketEventPresentation.lua")
DTCommon.SettlementMarket = T.load("DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEventProducer = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketEventProducer.lua")
DTCommon.TraderService = {
    GetRecord = function(id) return dtRecords[id] end,
}
DTCommon.CoreWorldEventProjection = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreWorldEventProjection.lua")
DTCommon.WorldKnowledge = T.load("DTCommon", "shared", "DTCommon/DTCommon_WorldKnowledge.lua")

DTCommon.SettlementMarket.GetOrCreate("comm_rosewood", "default")
DTCommon.SettlementMarket.GetOrCreate("comm_muldraugh", "default")

DTCommon.MarketSenseGateway = {
    Get = function(fullType)
        if fullType == "Base.CannedBeans" then return { fullType = fullType, category = "Food" } end
        if fullType == "Base.PetrolCan" then return { fullType = fullType, category = "Fuel" } end
        if fullType == "Base.Bandage" then return { fullType = fullType, category = "Medical" } end
        if fullType == "Base.Shotgun" then return { fullType = fullType, category = "Weapon" } end
        return nil
    end,
}
MarketSense = {
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}
local Pricing = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
local Stock = T.load("DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")

local rosewoodTrader = {
    id = "trader_rosewood",
    g = "faction_traders",
    ca = DTCommon.CoreActorPolicy.New({
        actorID = "actor:dt:rosewood",
        currentSettlementID = "comm_rosewood",
    }),
}
local muldraughTrader = {
    id = "trader_muldraugh",
    g = "faction_traders",
    ca = DTCommon.CoreActorPolicy.New({
        actorID = "actor:dt:muldraugh",
        currentSettlementID = "comm_muldraugh",
    }),
}
dtRecords[rosewoodTrader.id] = rosewoodTrader
dtRecords[muldraughTrader.id] = muldraughTrader

Location.ClearProviders()
Location.RegisterProvider("dt_settlements", function(x, y)
    if x >= 8000 and x <= 8300 and y >= 11400 and y <= 11700 then
        return {
            settlementID = "comm_rosewood",
            regionID = "region_south",
            localAreaID = "area_rosewood_main",
            label = "Rosewood Haven",
            kind = "settlement",
        }
    elseif x >= 10500 and x <= 10800 and y >= 9900 and y <= 10200 then
        return {
            settlementID = "comm_muldraugh",
            regionID = "region_central",
            localAreaID = "area_muldraugh_main",
            label = "Muldraugh Outpost",
            kind = "settlement",
        }
    end
    return nil
end, 10)

local baseFuelQuote = Stock.Quote("Base.PetrolCan", DTCommon.OP_BUY, nil, Pricing.BuildContext(rosewoodTrader, nil, { now = mockHours })).unitPrice
local baseMedQuote = Stock.Quote("Base.Bandage", DTCommon.OP_BUY, nil, Pricing.BuildContext(rosewoodTrader, nil, { now = mockHours })).unitPrice

-- 1. Global utility cutoffs (electricity + water) project directly without ProjectHoomans.
PZAdapter.ObserveUtilities(mockHours, { powerOn = true, waterOn = true })
mockHours = mockHours + 2
PZAdapter.ObserveUtilities(mockHours, { powerOn = false, waterOn = false })

local elecEvent = DTCommon.MarketEvents.Get("core-world-event:core:utility:electricity_cutoff")
local waterEvent = DTCommon.MarketEvents.Get("core-world-event:core:utility:water_cutoff")
T.truthy(elecEvent, "global electricity cutoff projects into DTCommon.MarketEvents")
T.truthy(waterEvent, "global water cutoff projects into DTCommon.MarketEvents")
T.equal(elecEvent.scope.kind, "global", "electricity cutoff keeps global market scope")

local fuelAfterCutoff = Stock.Quote("Base.PetrolCan", DTCommon.OP_BUY, nil, Pricing.BuildContext(rosewoodTrader, nil, { now = mockHours })).unitPrice
T.truthy(fuelAfterCutoff > baseFuelQuote, "electricity cutoff raises Fuel buy price pressure (" .. baseFuelQuote .. " -> " .. fuelAfterCutoff .. ")")

-- 2. Regional helicopter affects region_south traders only, never region_central.
PZAdapter.ObserveHelicopter(mockHours, {
    helicopter = {
        isActive = function() return true end,
        x = 8150,
        y = 11520,
    },
})
local rosewoodHeliCtx = Pricing.BuildContext(rosewoodTrader, nil, { now = mockHours })
local muldraughHeliCtx = Pricing.BuildContext(muldraughTrader, nil, { now = mockHours })
local rwGun = Stock.Quote("Base.Shotgun", DTCommon.OP_BUY, nil, rosewoodHeliCtx).unitPrice
local mdGun = Stock.Quote("Base.Shotgun", DTCommon.OP_BUY, nil, muldraughHeliCtx).unitPrice
T.truthy(rwGun > mdGun, "regional helicopter raises Weapon/CaravanRisk pressure in Rosewood only")

-- 3. Economically relevant discoveries (Ambulance Crash + Bandit Road) project; Dog Bark & Campsite do not.
PZAdapter.OnAmbientSound("MetaDogBark", 8150, 11520, { hours = mockHours })
for _, fn in ipairs(hooks.LoadChunk) do
    fn({
        vehicleStorySpawnData = {
            story = { getName = function() return "Ambulance Crash" end },
            spawnX = 8160,
            spawnY = 11530,
        },
        zones = {
            {
                type = "ZoneStory",
                pickedRzStory = { getName = function() return "Campsite" end },
                pickedXForZoneStory = 8170,
                pickedYForZoneStory = 11540,
            },
        },
    })
end
local disc = DiscoveryAdapter.DiscoverNearPoint(8160, 11530, { radius = 80, nowHours = mockHours })
T.equal(#disc, 2, "discovery adapter finds ambulance crash and campsite locally")

local ambEvents = DTCommon.MarketEvents.ListActive("comm_rosewood", rosewoodTrader, { now = mockHours })
local foundAmb = false
local foundCamp = false
for _, ev in ipairs(ambEvents) do
    if string.find(ev.eventID, "ambulance", 1, true) then foundAmb = true end
    if string.find(ev.eventID, "campsite", 1, true) then foundCamp = true end
end
T.truthy(foundAmb, "ambulance crash discovery projects economically onto comm_rosewood")
T.falsy(foundCamp, "non-economic campsite discovery does NOT clutter market events")
T.equal(listCalls, 0, "DTCore projection never scans SettlementDirectory.List()")

-- 4. DT native market event never recurses into Core ScopedWorldEvents.
local coreActiveBeforeDT = ScopedEvents.GetStats().activeCount
DTCommon.SettlementMarket.ApplyDelta("comm_rosewood", {
    categories = { Food = { supplyDelta = -0.35, demandDelta = 0.35 } },
}, { now = mockHours })
local prod = DTCommon.MarketEventProducer.Evaluate("comm_rosewood", { now = mockHours })
T.truthy(prod and prod.changed, "DT MarketEventProducer emits native dt-market-condition event")
T.equal(ScopedEvents.GetStats().activeCount, coreActiveBeforeDT,
    "DT market-native event NEVER recurses back into Core ScopedWorldEvents")

-- 5. Save / Reload reconciliation: expired Core events prune on load and disappear from DTCommon.MarketEvents cleanly.
local ambCoreID = ScopedEvents.QueryActive({ eventType = "discovery_vehicle_story_ambulance_crash" }, mockHours)[1].eventID
ScopedEvents.SaveToModData({ nowHours = mockHours })

-- Advance time past local discovery expiry (12+ hours) and reload Core ModData -> OnStateLoaded removes expired DT projection!
local reloadHours = mockHours + 72
ScopedEvents.Reset({ nowHours = 0 })
ScopedEvents.LoadFromModData({ nowHours = reloadHours })
local afterReloadEvents = DTCommon.MarketEvents.ListActive("comm_rosewood", rosewoodTrader, { now = reloadHours })
local stillAmbAfterReload = false
for _, ev in ipairs(afterReloadEvents) do
    if string.find(ev.eventID, ambCoreID, 1, true) then
        stillAmbAfterReload = true
    end
end
T.falsy(stillAmbAfterReload, "expired discovery pruned on Core reload also clears projected DT market event")
T.truthy(DTCommon.MarketEvents.Get("core-world-event:core:utility:electricity_cutoff"),
    "durable historical electricity cutoff survives reload in DTCommon.MarketEvents")

-- 6. DTCommon.WorldKnowledge renders Core vanilla world facts standalone.
local elecFactID = "fact:core:utility.electricity_cutoff:global"
local acquired = DTCommon.WorldKnowledge.Acquire(rosewoodTrader.id, elecFactID, {
    authorized = true,
    provenance = "witnessed",
    learnedAt = reloadHours,
})
T.truthy(acquired, "trader acquires Core utility fact directly")
local dtCtx = DTCommon.WorldKnowledge.BuildConversationContext(rosewoodTrader.id, { max = 6, now = reloadHours })
local foundPowerLine = false
for _, stmt in ipairs(dtCtx.npcGossip.statements or {}) do
    local s = tostring(stmt or "")
    if string.find(string.lower(s), "power grid", 1, true) or string.find(string.lower(s), "grid's out", 1, true) then
        foundPowerLine = true
    end
end
T.truthy(foundPowerLine, "DTCommon.WorldKnowledge renders Core utility fact standalone")

DTCommon.CoreWorldEventProjection.Unsubscribe()
T.finish("dt_core_vanilla_world_event_projection_smoke")
