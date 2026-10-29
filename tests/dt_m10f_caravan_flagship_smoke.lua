local T = require "tests/support/test"
local loadSource = T.load

local TYPE_BY_ID = {
    [1] = "Base.CannedBeans",
    [2] = "Base.Unrelated",
}
local ID_BY_TYPE = {
    ["Base.CannedBeans"] = 1,
    ["Base.Unrelated"] = 2,
}

local function cloneRow(row, quantity)
    return {
        [1] = row[1],
        [2] = quantity == nil and row[2] or quantity,
    }
end

local function newStore(rows)
    local store = { rows = {} }
    for index = 1, #(rows or {}) do
        store.rows[#store.rows + 1] = cloneRow(rows[index])
    end
    function store:iterate()
        local cursor = 0
        return function()
            cursor = cursor + 1
            local row = self.rows[cursor]
            return row and cloneRow(row) or nil
        end
    end
    function store:count(fullType)
        local typeID = ID_BY_TYPE[fullType]
        local total = 0
        for index = 1, #self.rows do
            if self.rows[index][1] == typeID then
                total = total + self.rows[index][2]
            end
        end
        return total
    end
    function store:add(row)
        for index = 1, #self.rows do
            if self.rows[index][1] == row[1] then
                self.rows[index][2] = self.rows[index][2] + row[2]
                return true
            end
        end
        self.rows[#self.rows + 1] = cloneRow(row)
        return true
    end
    return store
end

local function copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = copy(item) end
    return output
end

local authority = true
local currentTime = 10
local modData = {}
local locations = {}
local communities = {}
local factions = {}
local registry = {}
local group
local traversalStarts = 0
local exchangeCalls = 0
local arrivalRevisions = {}

local function addCommunity(id, factionID, x, y, tags)
    communities[id] = {
        id = id,
        factionID = factionID,
        status = "active",
        mode = "settled",
        siteID = "site_" .. id,
        home = { x = x, y = y, z = 0, radius = 12 },
        tags = tags,
    }
    factions[factionID] = {
        id = factionID,
        status = "active",
        archetypeID = "settler",
        memberIDs = {},
    }
end

addCommunity("community_m10f_a", "faction_m10f_a", 100, 100)
addCommunity("community_m10f_b", "faction_m10f_b", 200, 200)
addCommunity("community_m10f_c", "faction_m10f_c", 300, 300)
addCommunity("community_m10f_hostile", "faction_m10f_hostile", 50, 50)

local caravanFaction = {
    id = "faction_m10f_caravan",
    status = "active",
    archetypeID = "trader",
    tags = { dynamicTrading = true, mobileGroup = true },
    memberIDs = { npc_m10f_caravan = true },
    playerMemberKeys = {},
    mobile = {
        active = true,
        pathMode = "random",
        controlMode = "strategic",
        mobilityIntent = "commercial",
        activity = "street_roaming",
        site = {
            id = "site_m10f_origin",
            home = { x = 0, y = 0, z = 0, radius = 12 },
        },
        settlementHistory = {},
    },
}
factions[caravanFaction.id] = caravanFaction
local caravanNPC = {
    id = "npc_m10f_caravan",
    alive = true,
    x = 0,
    y = 0,
    affiliation = {
        factionID = caravanFaction.id,
        role = "trader",
        membershipStatus = "member",
    },
}
registry[caravanNPC.id] = caravanNPC

local Inventory = {
    getItemFullType = function(typeID) return TYPE_BY_ID[typeID] end,
}
Inventory.Serializer = {
    serialize = function(store)
        local rows = {}
        local iterator = store:iterate()
        local row = iterator()
        while row do
            rows[#rows + 1] = cloneRow(row)
            row = iterator()
        end
        return { rows = rows }
    end,
    deserialize = function(payload)
        return newStore(payload and payload.rows or {})
    end,
}
Inventory.createVirtualInventory = function() return newStore() end

DTCommon = {
    MODDATA_KEY = "DTCommon.Traders",
    MARKET_MODDATA_KEY = "DTCommon.SettlementMarkets",
    EVENT_MODDATA_KEY = "DTCommon.MarketEvents",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {},
    DEFAULT_TRADER_NAME = "Caravan Trader",
    DEFAULT_TRADER_ROLE = "trader",
    DEFAULT_CARAVAN_ID = "debug_caravan",
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
MarketSense = {
    GetAllKnownItems = function()
        return {
            ["Base.CannedBeans"] = {
                fullType = "Base.CannedBeans",
                category = "Food",
                availability = { status = "obtainable" },
            },
        }
    end,
    GetTags = function(fullType)
        return fullType == "Base.CannedBeans"
            and { category = "Food", tags = { "food" } } or nil
    end,
    GetItemAvailability = function()
        return { status = "obtainable" }
    end,
    GetPriceDetails = function(fullType)
        if fullType == "Base.CannedBeans" then return { price = 100 } end
        if fullType == "Base.Unrelated" then return { price = 25 } end
        return nil
    end,
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() end,
}

function isServer() return true end
function isClient() return false end
function getGameTime()
    return { getWorldAgeHours = function() return currentTime end }
end

-- Load the real Hoomans movement, destination, and settlement-visit services.
-- The fixture supplies only their documented world/faction stores.
PNC = {}
T.addPackagePaths({
    { "ProjectHoomans", "server" },
    { "ProjectHoomans", "shared" },
    { "DTHoomans", "server" },
    { "DTHoomans", "shared" },
    { "DTCommon", "shared" },
})
T.load("ProjectHoomans", "shared", "PNC/Core/Base/PNC_Core.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Base/PNC_Constants.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Relationships/PNC_EntityRef.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Factions/PNC_FactionConstants.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Communities/PNC_CommunityConstants.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Communities/PNC_CommunityMath.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Communities/PNC_CommunityTypes.lua")
T.load("ProjectHoomans", "shared", "PNC/Core/Director/PNC_DirectorConfig.lua")
PNC.DirectorConfig.MOBILE_SETTLEMENT_VISIT_HOURS = 12
PNC.Factions = {
    Registry = { byID = factions },
    Get = function(id) return factions[id] end,
    IsMobileGroup = function(faction)
        return faction and faction.mobile
            and faction.mobile.active == true
    end,
    GetFactionID = function(record)
        return record and record.affiliation
            and record.affiliation.factionID or nil
    end,
    GetRelation = function(sourceID, targetID)
        if targetID == "faction_m10f_hostile"
            or sourceID == "faction_m10f_hostile"
        then
            return { state = "war" }
        end
        return nil
    end,
    UpdateMobileGroup = function(id, patch)
        local faction = factions[id]
        if not faction then return false, "faction_not_found" end
        for key, value in pairs(patch or {}) do
            faction.mobile[key] = copy(value)
        end
        return true, "updated", copy(faction.mobile)
    end,
    GetMobileGroup = function(id)
        return factions[id] and factions[id].mobile or nil
    end,
    SetMobileGroup = function(id, mobile)
        if not factions[id] then return false, "faction_not_found" end
        factions[id].mobile = copy(mobile)
        return true, "updated", copy(factions[id].mobile)
    end,
}
PNC.Communities = {
    ListSites = function()
        local output = {}
        for id, community in pairs(communities) do
            if id ~= "community_m10f_hostile"
                or true
            then
                output[#output + 1] = {
                    id = community.siteID,
                    home = copy(community.home),
                    occupantCommunityID = id,
                    tags = id == "community_m10f_hostile"
                        and { HOSTILE = true } or nil,
                }
            end
        end
        table.sort(output, function(left, right)
            return left.id < right.id
        end)
        return output
    end,
    Get = function(id) return communities[id] end,
}
PNC.Registry = {
    Get = function(id) return registry[id] end,
}
PNC.AbstractLocations = {
    RegisterSite = function(site)
        local location = {
            id = "aloc_" .. tostring(site.id),
            type = "SETTLEMENT",
            x = site.home.x,
            y = site.home.y,
            z = site.home.z,
            tags = site.tags,
            sourceSite = site,
        }
        locations[location.id] = location
        return location, "registered"
    end,
    Get = function(id) return locations[id] end,
}
group = {
    id = "group_m10f_caravan",
    location = { id = "aloc_site_m10f_origin", x = 0, y = 0, z = 0 },
    state = "ARRIVED",
    memberIds = { caravanNPC.id },
}
PNC.AbstractGroups = {
    FindByFactionID = function() return group end,
    HasLiveMembers = function() return false end,
    SetState = function(value, state) value.state = state end,
    RefreshLOD = function() end,
}
PNC.AbstractGroupManagerInternal = { Touch = function() end }
PNC.Presence = { Abstract = function() end }
PNC.AbstractTraversal = {
    Begin = function(value, location)
        traversalStarts = traversalStarts + 1
        group.location = copy(location)
        group.state = "ARRIVED"
        return true, "travel_started"
    end,
}
PNC.AbstractWorldStore = {
    Registry = { encounters = {} },
    Emit = function() end,
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected dependency while loading DTCommon: " .. moduleName)
end
DTCommon.MarketSchema = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.TraderSupport = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderSupport.lua")
DTCommon.CoreActorPolicy = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.MarketCatalog = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
DTCommon.MarketCatalog.Reset()
DTCommon.SettlementMarket = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEvents = {
    ListActive = function() return {}, { activeEventCount = 0 } end,
}
savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected dependency while loading stock: " .. moduleName)
end
DTCommon.TraderStock = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
require = savedRequire
DTCommon.TraderStock.EncodeItem = function(fullType, quantity)
    local typeID = ID_BY_TYPE[fullType]
    return typeID and { [1] = typeID, [2] = quantity } or nil
end
DTCommon.TraderStock.SaveAndTransmit = function() return true end
savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected dependency while loading registry: " .. moduleName)
end
DTCommon.TraderService = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
require = savedRequire
savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return { TYPE_ID = 1, QUANTITY = 2 }
    end
    if moduleName == "PsychopatzCore/Economy/PsychopatzCurrency" then
        return {}
    end
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return DTCommon.CoreActorPolicy
    end
    error("unexpected dependency while loading service: " .. moduleName)
end
DTCommon.TraderService = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire

DTCommon.SettlementExchange = {
    Execute = function(traderID, settlementID)
        local record = DTCommon.TraderService.GetRecord(traderID)
        local market = DTCommon.SettlementMarket.Get(settlementID)
        exchangeCalls = exchangeCalls + 1
        record.v = (tonumber(record.v) or 0) + 1
        if market then
            DTCommon.SettlementMarket.ApplyDelta(settlementID, {
                categories = {
                    Food = { supplyDelta = -0.05, demandDelta = 0.05 },
                },
            }, { now = currentTime })
        end
        return { traderID = traderID, settlementID = settlementID }, "exchange"
    end,
}

-- The real Hoomans production services are now loaded. Arrival dispatch is
-- public Hoomans OnSettlementArrival; no DT private arrival handler is used.
T.load("ProjectHoomans", "server",
    "PNC/Director/MobileGroupDirector/PNC_MobileGroupDirector_Core.lua")
T.load("ProjectHoomans", "server",
    "PNC/Director/MobileGroupDirector/PNC_MobileGroupDirector_DepartureTargets.lua")
T.load("ProjectHoomans", "server",
    "PNC/Director/MobileGroupDirector/PNC_MobileGroupDirector_Departures.lua")
local MobileVisit = loadSource(
    "ProjectHoomans", "server",
    "PNC/Director/PNC_MobileSettlementVisitService.lua")
local Commercial = loadSource(
    "ProjectHoomans", "server",
    "PNC/Director/PNC_CommercialMobilityService.lua")
PNC.API = {
    Travel = {
        RegisterArrivalHandler = function() return true end,
    },
}
DTHoomans = {}
local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
local Mobility = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_CommercialMobility.lua")
T.truthy(Mobility.Registered,
    "Dynamic Trading registers only its bounded economic scorer")

local traderID, record = DTCommon.TraderService.Create({
    traderID = "dt_" .. caravanFaction.id,
    caravanID = "caravan_m10f",
    budget = 200,
    abstractAccessEnabled = true,
})
T.truthy(traderID, "base-less caravan merchant record exists")
T.truthy(DTCommon.TraderService.BindFaction(
    traderID,
    caravanFaction.id,
    caravanNPC.id,
    { caravanNPC.id }
), "caravan record preserves the Hoomans faction binding")
local stock = DTCommon.Storage.LoadInventory(record)
T.truthy(stock:add({ [1] = 1, [2] = 4 }), "seed caravan food stock")
T.truthy(stock:add({ [1] = 2, [2] = 2 }), "seed caravan unrelated stock")
T.truthy(DTCommon.Storage.SaveInventory(record, stock),
    "persist caravan stock before production travel")
local startingFood = stock:count("Base.CannedBeans")
local startingUnrelated = stock:count("Base.Unrelated")
local startingVersion = record.v

local function finishArrival(expectedCommunityID, now)
    local travel = copy(caravanFaction.mobile.travel)
    local target = copy(travel.destination)
    local arrived, reason = MobileVisit.OnSettlementArrival(
        caravanFaction,
        target,
        travel,
        now,
        group,
        {}
    )
    T.truthy(arrived, reason)
    T.equal(caravanFaction.mobile.visit.communityID, expectedCommunityID,
        "Hoomans records the temporary destination visit")
    local exchangeBeforeReplay = exchangeCalls
    local replayed, replayReason = MobileVisit.OnSettlementArrival(
        caravanFaction,
        target,
        travel,
        now,
        group,
        {}
    )
    T.truthy(replayed, replayReason)
    T.equal(exchangeCalls, exchangeBeforeReplay,
        "duplicate active arrival does not exchange twice")
    caravanFaction.mobile.travel = nil
    caravanFaction.mobile.activity =
        PNC.FactionConstants.MOBILE_ACTIVITY_STREET_ROAMING
    local expired, expireReason = MobileVisit.ExpireFaction(
        caravanFaction, now + 13)
    T.truthy(expired, expireReason)
    caravanFaction.mobile = copy(caravanFaction.mobile)
    return travel, target
end

local moved = Commercial.Pump(currentTime, 1)
T.equal(moved, 1, "production pump starts the base-less caravan")
T.equal(traversalStarts, 1, "Hoomans owns abstract caravan travel")
T.falsy(caravanFaction.homeCommunityID,
    "base-less caravan has no hidden home community")
T.falsy(caravanFaction.baseID,
    "base-less caravan has no hidden base")
T.equal(caravanFaction.mobile.travel.purpose,
    PNC.FactionConstants.MOBILE_TRAVEL_PURPOSE_SETTLEMENT_VISIT,
    "caravan uses generic temporary settlement visit purpose")
T.equal(caravanFaction.mobile.travel.intent,
    PNC.FactionConstants.MOBILE_SETTLEMENT_VISIT_INTENT_COMMERCIAL,
    "caravan persists the commercial visit intent")
local travelA, targetA = finishArrival("community_m10f_a", currentTime + 1)
T.equal(travelA.revision, 1,
    "first abstract travel receives a durable visit revision")
T.equal(record.ca.lastSettlementID, "community_m10f_a",
    "first commercial stop updates actual visit history")
T.equal(record.ca.visitCount, 1, "first stop has one authoritative exchange")
T.equal(exchangeCalls, 1, "first stop exchanges once")

currentTime = 24
T.equal(Commercial.Pump(currentTime, 1), 1,
    "production pump selects a different safe destination after A")
local travelB, targetB = finishArrival("community_m10f_b", currentTime + 1)
T.equal(travelB.revision, 2,
    "second abstract travel revision survives cleared travel state")
T.equal(record.ca.visitCount, 2, "second stop has one additional exchange")
T.equal(exchangeCalls, 2, "second stop exchanges once")
T.equal(caravanFaction.mobile.settlementHistory[1].communityID,
    "community_m10f_b", "recent visit ledger records the latest stop")
T.equal(caravanFaction.mobile.settlementHistory[2].communityID,
    "community_m10f_a", "recent visit ledger remains bounded and ordered")

currentTime = 38
T.equal(Commercial.Pump(currentTime, 1), 1,
    "production pump selects C instead of ping-ponging to A")
local travelC, targetC = finishArrival("community_m10f_c", currentTime + 1)
T.equal(travelC.revision, 3,
    "third abstract travel revision remains monotonic")
T.equal(record.ca.visitCount, 3, "third stop has one additional exchange")
T.equal(exchangeCalls, 3, "third stop exchanges once")
T.equal(caravanFaction.mobile.lastTravelRevision, 3,
    "travel revision ledger persists through save/reload copies")
T.truthy(DTCommon.SettlementMarket.Get("community_m10f_a"),
    "A market is provisioned through the real visit path")
T.truthy(DTCommon.SettlementMarket.Get("community_m10f_b"),
    "B market is provisioned through the real visit path")
T.truthy(DTCommon.SettlementMarket.Get("community_m10f_c"),
    "C market is provisioned through the real visit path")
T.equal(record.ca.homeSettlementID, nil,
    "base-less caravan never acquires resident home identity")
T.equal(DTCommon.Storage.LoadInventory(record):count("Base.CannedBeans"),
    startingFood, "caravan stock survives all three commercial legs")
T.equal(DTCommon.Storage.LoadInventory(record):count("Base.Unrelated"),
    startingUnrelated, "unrelated caravan stock survives all three legs")
T.equal(record.v, startingVersion + 3,
    "only the three authoritative destination exchanges advance stock version")
local firstMarket = DTCommon.SettlementMarket.Get("community_m10f_a")
local firstBaseline = DTCommon.MarketProfiles.Baseline(
    firstMarket.profileID, "Food")
T.truthy(DTCommon.SettlementMarket.Get("community_m10f_a").categories.Food.supply
    < firstBaseline.supply,
    "market pressure follows the first logistics exchange")

-- A hostile destination is rejected by the Hoomans safety contract before
-- DT receives an arrival notification.
local hostileTarget = {
    kind = "ai_settlement",
    communityID = "community_m10f_hostile",
    locationID = "aloc_site_community_m10f_hostile",
    x = 50,
    y = 50,
}
local hostileTravel = {
    kind = PNC.FactionConstants.MOBILE_TRAVEL_SETTLEMENT,
    purpose = PNC.FactionConstants.MOBILE_TRAVEL_PURPOSE_SETTLEMENT_VISIT,
    intent = "commercial",
    destination = hostileTarget,
    revision = 99,
}
local hostileOK, hostileReason = MobileVisit.OnSettlementArrival(
    caravanFaction, hostileTarget, hostileTravel, currentTime + 2, group, {})
T.falsy(hostileOK, "hostile destination is rejected by Hoomans")
T.equal(hostileReason, "hostile_settlement_relationship",
    "hostile rejection keeps a bounded reason")
T.equal(exchangeCalls, 3,
    "hostile destination cannot trigger a DT exchange")

-- Encounter-delayed arrival uses the same pending Hoomans handoff and then
-- forwards exactly one exchange once the encounter is resolved.
currentTime = 100
T.equal(Commercial.Pump(currentTime, 1), 1,
    "production pump can resume after the bounded route cooldown")
local delayedTravel = copy(caravanFaction.mobile.travel)
local delayedTarget = copy(delayedTravel.destination)
local encounterID = "encounter_m10f_delayed"
PNC.AbstractWorldStore.Registry.encounters = {
    { id = encounterID, outcome = "QUEUED" },
}
local delayed, delayedReason = MobileVisit.OnSettlementArrival(
    caravanFaction,
    delayedTarget,
    delayedTravel,
    currentTime + 1,
    group,
    { { id = encounterID } }
)
T.falsy(delayed, "encounter delays the Hoomans arrival")
T.equal(delayedReason, "encounter_pending",
    "encounter delay keeps the public pending-arrival reason")
T.truthy(caravanFaction.mobile.pendingSettlementArrival,
    "pending arrival is persisted by Hoomans")
PNC.AbstractWorldStore.Registry.encounters[1].outcome = "RESOLVED"
local resumed = MobileVisit.PumpPendingArrivals(currentTime + 2, 1)
T.equal(resumed, 1, "resolved encounter resumes the pending arrival")
T.equal(exchangeCalls, 4,
    "resolved delayed arrival performs one bounded exchange")
T.equal(record.ca.visitCount, 4,
    "delayed arrival increments the visit ledger once")

-- Replay after the Hoomans visit expires still reaches DT but the persistent
-- visit ledger rejects the duplicate exchange.
caravanFaction.mobile.travel = nil
caravanFaction.mobile.activity =
    PNC.FactionConstants.MOBILE_ACTIVITY_STREET_ROAMING
MobileVisit.ExpireFaction(caravanFaction, currentTime + 20)
local beforeReplay = exchangeCalls
local replayAfterExpiry, replayAfterExpiryReason = MobileVisit.OnSettlementArrival(
    caravanFaction,
    delayedTarget,
    delayedTravel,
    currentTime + 21,
    group,
    {}
)
T.truthy(replayAfterExpiry, replayAfterExpiryReason)
T.equal(exchangeCalls, beforeReplay,
    "replay after visit expiry remains DT-idempotent")

return T.finish("dt_m10f_caravan_flagship_smoke")
