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
local genericHandlers = {}
local legacyHandlers = {}
local outboundRequest
local returnRequest
local exchangeCalls = 0
local followOwned = false

local communityHome = {
    id = "community_m10d_home",
    factionID = "faction_m10d_resident",
    name = "M10D Home",
    mode = "settled",
    status = "active",
    siteID = "site_m10d_home",
    home = { x = 10, y = 10, z = 0, radius = 12 },
    memberIDs = { npc_m10d_trader = true },
}
local communityMarket = {
    id = "community_m10d_market",
    factionID = "faction_m10d_market",
    name = "M10D Market",
    mode = "settled",
    status = "active",
    siteID = "site_m10d_market",
    home = { x = 110, y = 110, z = 0, radius = 12 },
    memberIDs = {},
}
local communityAltMarket = {
    id = "community_m10d_market_alt",
    factionID = "faction_m10d_market_alt",
    name = "M10D Market Alt",
    mode = "settled",
    status = "active",
    siteID = "site_m10d_market_alt",
    home = { x = 200, y = 200, z = 0, radius = 12 },
    memberIDs = {},
}
local residentFaction = {
    id = communityHome.factionID,
    status = "active",
    archetypeID = "settler",
    tags = { settlementType = "farm" },
    memberIDs = { npc_m10d_trader = true },
}
local marketFaction = {
    id = communityMarket.factionID,
    status = "active",
    archetypeID = "settler",
    memberIDs = {},
}
local traderNPC = {
    id = "npc_m10d_trader",
    alive = true,
    x = 10,
    y = 10,
    affiliation = {
        factionID = residentFaction.id,
        communityID = communityHome.id,
        role = "trader",
        rank = "member",
        membershipStatus = "member",
    },
    runtime = {},
}
local factions = {
    [residentFaction.id] = residentFaction,
    [marketFaction.id] = marketFaction,
}

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
    DEFAULT_TRADER_NAME = "Settlement Trader",
    DEFAULT_TRADER_ROLE = "trader",
    DEFAULT_CARAVAN_ID = "debug_caravan",
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() end,
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

PNC = {
    Core = { DeepCopy = copy, IsAuthority = function() return authority end },
    FactionConstants = {
        ID_MAX_LENGTH = 192,
        TAG_VALUE_MAX_LENGTH = 192,
        EXCURSION_SCHEMA_VERSION = 1,
        EXCURSION_STATE_AT_HOME = "AT_HOME",
        EXCURSION_STATE_PREPARING = "PREPARING",
        EXCURSION_STATE_OUTBOUND = "OUTBOUND",
        EXCURSION_STATE_VISITING = "VISITING",
        EXCURSION_STATE_RETURNING_HOME = "RETURNING_HOME",
        EXCURSION_STATE_FAILED = "FAILED",
        EXCURSION_STATES = {
            AT_HOME = true,
            PREPARING = true,
            OUTBOUND = true,
            VISITING = true,
            RETURNING_HOME = true,
            FAILED = true,
        },
        EXCURSION_MAX_PARTICIPANTS = 24,
        EXCURSION_MAX_ITINERARY = 16,
        EXCURSION_MAX_PURPOSE_LENGTH = 96,
        EXCURSION_MAX_REASON_LENGTH = 128,
        EXCURSION_MAX_INTENT_LENGTH = 96,
        MOBILE_SETTLEMENT_VISIT_INTENT_GENERAL = "general",
        MOBILE_SETTLEMENT_VISIT_INTENT_COMMERCIAL = "commercial",
        MOBILE_SETTLEMENT_VISIT_INTENT_MAX_LENGTH = 96,
    },
    FactionTypes = {},
}
PNC.FactionTypes.Internal = {}
PNC.FactionTypes.IsValidNPCID = function(value)
    return type(value) == "string" and value ~= ""
end
PNC.FactionTypes.Internal.NormalizeTargetPoint = function(value)
    if type(value) ~= "table" or tonumber(value.x) == nil
        or tonumber(value.y) == nil
    then
        return nil
    end
    local output = copy(value)
    output.kind = output.kind or "location"
    output.x = tonumber(output.x)
    output.y = tonumber(output.y)
    output.z = tonumber(output.z) or 0
    output.locationID = output.locationID or output.communityID
    return output
end
PNC.FactionTypes.Internal.NormalizeExcursion = function(value)
    if type(value) ~= "table" then return nil end
    local output = copy(value)
    output.schemaVersion = 1
    output.state = output.state or "AT_HOME"
    output.purpose = output.purpose or "general"
    output.visitIntent = output.visitIntent or output.intent or "general"
    output.participants = output.participants or {}
    output.itinerary = output.itinerary or {}
    output.currentLeg = tonumber(output.currentLeg) or 0
    output.destination = output.destination
        and PNC.FactionTypes.Internal.NormalizeTargetPoint(output.destination)
        or nil
    output.createdAt = tonumber(output.createdAt) or 0
    output.stateAt = tonumber(output.stateAt) or 0
    output.preparedAt = tonumber(output.preparedAt) or 0
    output.departedAt = tonumber(output.departedAt) or 0
    output.visitedAt = tonumber(output.visitedAt) or 0
    output.returnStartedAt = tonumber(output.returnStartedAt) or 0
    output.expectedReturnAt = tonumber(output.expectedReturnAt) or 0
    output.completedAt = tonumber(output.completedAt) or 0
    output.revision = tonumber(output.revision) or 0
    return output
end

PNC.Factions = {
    Registry = { byID = factions },
    EnsureLoaded = function() end,
    Get = function(id) return factions[id] end,
    IsMember = function(factionID, npcID)
        return factions[factionID]
            and factions[factionID].memberIDs[npcID] == true
    end,
    GetMembers = function(id)
        if id ~= residentFaction.id then return {} end
        return { { npcID = traderNPC.id, affiliation = traderNPC.affiliation } }
    end,
    GetRelation = function() return nil end,
    IsMobileGroup = function() return false end,
    Internal = {
        registryRecord = function(id) return factions[id] end,
        touchFaction = function(record)
            record.revision = (tonumber(record.revision) or 0) + 1
        end,
        touchRegistry = function() end,
    },
}
PNC.Communities = {
    Get = function(id)
        if id == communityHome.id then return communityHome end
        if id == communityMarket.id then return communityMarket end
        if id == communityAltMarket.id then return communityAltMarket end
        return nil
    end,
    GetForFaction = function(id)
        return id == residentFaction.id and { communityHome } or {}
    end,
}
PNC.Registry = {
    Get = function(id)
        return tostring(id) == traderNPC.id and traderNPC or nil
    end,
}
PNC.SettlementTraderStaffing = {
    TraderMember = function(id)
        return id == residentFaction.id and traderNPC.id or nil
    end,
}
PNC.MobileSettlementVisitService = {
    IsSettlementVisitEligible = function(_, target)
        return target and target.communityID == communityMarket.id,
            target and target.communityID == communityMarket.id
                and "eligible" or "target_not_eligible"
    end,
    RegisterArrivalListener = function() return true end,
}
PNC.CommercialMobilityService = {
    SelectDestination = function(_, _, options)
        return {
            kind = "settlement",
            communityID = communityMarket.id,
            locationID = "location_m10d_market",
            siteID = communityMarket.siteID,
            x = communityMarket.home.x,
            y = communityMarket.home.y,
            z = communityMarket.home.z,
            score = 8,
            options = options,
        }, "bounded_test_opportunity"
    end,
}
PNC.Travel = {
    Arrivals = {
        StrictActionTypes = {},
        RegisterHandler = function(id, handler)
            genericHandlers[id] = handler
            return true
        end,
    },
    Service = {
        IsFollowOwned = function() return followOwned end,
    },
}
PNC.API = {
    Travel = {
        RegisterArrivalHandler = function(id, handler)
            legacyHandlers[id] = handler
            return true
        end,
        Start = function(npcID, request)
            traderNPC.travel = {
                state = "planned",
                request = copy(request),
            }
            if request.arrivalAction
                and request.arrivalAction.type == "community_excursion_settlement"
            then
                outboundRequest = copy(request)
            elseif request.arrivalAction
                and request.arrivalAction.type == "community_excursion_home"
            then
                returnRequest = copy(request)
            end
            return {
                journeyId = "journey_m10d_" .. tostring(npcID),
                destination = copy(request.destination),
                arrivalAction = copy(request.arrivalAction),
                arrivedWorldHour = currentTime,
            }, "travel_started"
        end,
    },
}

function isServer() return true end
function isClient() return false end
function getGameTime()
    return { getWorldAgeHours = function() return currentTime end }
end

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
DTCommon.MarketPricing = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")

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
        local exchangeRecord = DTCommon.TraderService.GetRecord(traderID)
        exchangeCalls = exchangeCalls + 1
        exchangeRecord.v = (tonumber(exchangeRecord.v) or 0) + 1
        return {
            traderID = traderID,
            settlementID = settlementID,
            bounded = true,
        }, "exchange"
    end,
}

-- A real Hoomans generic excursion service owns the policy pump and both
-- arrival handlers. The market visit itself is the only DT economic seam.
local Excursions = loadSource(
    "ProjectHoomans", "server",
    "PNC/Communities/PNC_CommunityExcursionService.lua")
DTHoomans = {}
local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementTrader.lua")
local Resident = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_ResidentExcursion.lua")
T.truthy(Resident.Registered, "resident policy registers with Hoomans")
T.truthy(genericHandlers.community_excursion_settlement,
    "Hoomans owns the resident settlement arrival handler")
T.truthy(genericHandlers.community_excursion_home,
    "Hoomans owns the exact-home arrival handler")

T.falsy(residentFaction.mobile,
    "resident faction starts without mobile conversion")
local bound, boundReason = Settlement.EnsureTraderForFaction(
    residentFaction.id)
T.truthy(bound, boundReason)
local traderID = Settlement.TraderIDFor(residentFaction.id)
local record = DTCommon.TraderService.GetRecord(traderID)
T.truthy(record, "resident trader is bound by normal staffing")
local stock = DTCommon.Storage.LoadInventory(record)
T.truthy(stock:add({ [1] = 1, [2] = 2 }), "seed exact merchant stock")
T.truthy(stock:add({ [1] = 2, [2] = 3 }), "seed unrelated merchant stock")
T.truthy(DTCommon.Storage.SaveInventory(record, stock),
    "persist exact merchant stock")
local startingVersion = record.v
local startingBudget = record.b
local startingBeans = stock:count("Base.CannedBeans")
local startingUnrelated = stock:count("Base.Unrelated")

-- The production policy pump, rather than a DT travel helper, starts the
-- purposeful excursion.
local started = Excursions.PumpPolicies(currentTime, 2)
T.equal(started, 1, "resident policy starts one bounded excursion")
local prepared = Excursions.Get(residentFaction.id)
T.equal(prepared.state, "OUTBOUND", "policy reaches outbound through Hoomans")
T.equal(prepared.purpose, "commercial_run", "purpose is generic commercial data")
T.equal(prepared.visitIntent, "commercial", "visit intent is extensible data")
T.equal(prepared.publicReason, "trading run", "public reason is social metadata")
T.falsy(residentFaction.mobile, "resident faction remains non-mobile")
T.equal(traderNPC.affiliation.factionID, residentFaction.id,
    "resident stays in original faction on departure")
T.equal(traderNPC.affiliation.communityID, communityHome.id,
    "resident stays in original community on departure")
T.equal(record.ca.homeSettlementID, communityHome.id,
    "home identity remains exact")
T.falsy(record.ca.currentSettlementID,
    "away resident has no fabricated current market context")
T.equal(record.ca.lastVisitAt, 0,
    "departure does not fabricate a commercial visit")
T.equal(record.v, startingVersion, "departure does not change stock version")
T.equal(record.b, startingBudget, "departure does not change budget")
T.equal(record.s, DTCommon.STATUS_AWAY,
    "resident is unavailable at home while outbound")
T.truthy(outboundRequest, "generic Hoomans travel request was started")
T.equal(outboundRequest.arrivalAction.intent, "commercial",
    "generic arrival carries the commercial intent")
T.equal(outboundRequest.arrivalAction.destinationCommunityID,
    communityMarket.id, "outbound target is bounded by Hoomans")
residentFaction.excursion = copy(residentFaction.excursion)
T.equal(Excursions.ReconcileAll(currentTime, 2), 1,
    "save/reload reconciliation sees the outbound resident excursion")
T.equal(Excursions.Get(residentFaction.id).state, "OUTBOUND",
    "outbound reload does not duplicate active travel")

-- Complete the normal Hoomans-owned arrival lifecycle. Clearing the durable
-- journey mirrors the travel service's arrival finalization.
traderNPC.travel = nil
local arrivalHandler = genericHandlers.community_excursion_settlement
local arrived, arrivalReason = arrivalHandler(
    traderNPC,
    {
        destination = copy(outboundRequest.destination),
        arrivedWorldHour = currentTime + 12,
    },
    copy(outboundRequest.arrivalAction)
)
T.truthy(arrived, arrivalReason)
local visiting = Excursions.Get(residentFaction.id)
T.equal(visiting.state, "VISITING", "arrival enters temporary visit state")
T.equal(record.ca.lastSettlementID, communityMarket.id,
    "one commercial arrival records the actual destination")
T.equal(record.ca.visitCount, 1,
    "one commercial arrival records exactly one DT visit")
T.equal(exchangeCalls, 1,
    "one commercial arrival triggers exactly one DT exchange")
T.equal(record.v, startingVersion + 1,
    "the one exchange advances the merchant version once")
T.equal(record.s, DTCommon.STATUS_AWAY,
    "resident remains unavailable while visiting")
T.equal(record.ca.homeSettlementID, communityHome.id,
    "commercial visit does not replace exact home identity")
residentFaction.excursion = copy(residentFaction.excursion)
T.equal(Excursions.Get(residentFaction.id).state, "VISITING",
    "save/reload preserves the visiting resident phase")
local afterVisitStock = DTCommon.Storage.LoadInventory(record)
T.equal(afterVisitStock:count("Base.CannedBeans"), startingBeans,
    "exchange keeps exact seeded stock in this bounded fixture")
T.equal(afterVisitStock:count("Base.Unrelated"), startingUnrelated,
    "exchange keeps unrelated exact stock")

-- Replaying the same authoritative arrival action is idempotent.
local duplicate, duplicateReason = arrivalHandler(
    traderNPC,
    {
        destination = copy(outboundRequest.destination),
        arrivedWorldHour = currentTime + 12,
    },
    copy(outboundRequest.arrivalAction)
)
T.truthy(duplicate, duplicateReason)
T.equal(exchangeCalls, 1, "duplicate arrival does not exchange twice")
T.equal(record.ca.visitCount, 1, "duplicate arrival does not increment visits")

-- Reconciliation starts the exact-home leg from persisted VISITING state.
currentTime = currentTime + 24
local reconciled = Excursions.ReconcileAll(currentTime, 1)
T.equal(reconciled, 1, "reconciliation processes the persisted excursion")
local returning = Excursions.Get(residentFaction.id)
T.equal(returning.state, "RETURNING_HOME", "expiry starts exact-home return")
T.falsy(returning.destination, "returning state has no fuzzy destination")
T.truthy(returnRequest, "Hoomans starts the return travel")
T.equal(returnRequest.arrivalAction.destinationCommunityID,
    communityHome.id, "return action targets the exact original community")
residentFaction.excursion = copy(residentFaction.excursion)
T.equal(Excursions.ReconcileAll(currentTime, 2), 1,
    "save/reload reconciliation sees the returning resident excursion")
T.equal(Excursions.Get(residentFaction.id).state, "RETURNING_HOME",
    "returning reload does not choose an alternate settlement")
T.equal(record.s, DTCommon.STATUS_AWAY,
    "resident remains unavailable during return")

traderNPC.travel = nil
local returned, returnReason = genericHandlers.community_excursion_home(
    traderNPC,
    {
        destination = copy(returnRequest.destination),
        arrivedWorldHour = currentTime + 1,
    },
    copy(returnRequest.arrivalAction)
)
T.truthy(returned, returnReason)
local homeAgain = Excursions.Get(residentFaction.id)
T.equal(homeAgain.state, "AT_HOME", "exact-home arrival restores home state")
T.equal(record.ca.currentSettlementID, communityHome.id,
    "home context is restored after return")
T.equal(record.ca.homeSettlementID, communityHome.id,
    "home identity remains exact after return")
T.equal(record.ca.lastSettlementID, communityMarket.id,
    "last commercial visit remains distinct from home")
T.equal(record.ca.visitCount, 1, "return does not count as a market visit")
T.equal(record.s, DTCommon.STATUS_READY,
    "home availability is restored after return")
T.equal(DTCommon.Storage.LoadInventory(record):count("Base.CannedBeans"),
    startingBeans, "returned stock keeps the seeded food row")
T.equal(DTCommon.Storage.LoadInventory(record):count("Base.Unrelated"),
    startingUnrelated, "returned stock keeps the seeded unrelated row")

-- Hoomans' guard is consulted before policy creation: Follow Player prevents
-- a new departure after the commercial cooldown has elapsed.
local cooldownStart = Excursions.PumpPolicies(currentTime + 1, 2)
T.equal(cooldownStart, 0,
    "resident cooldown prevents an immediate repeat departure")
T.equal(Excursions.Get(residentFaction.id).state, "AT_HOME",
    "cooldown does not leave a PREPARING ghost")
followOwned = true
currentTime = currentTime + 60
local blockedStart = Excursions.PumpPolicies(currentTime, 2)
T.equal(blockedStart, 0, "Follow Player blocks resident policy departure")
T.equal(Excursions.Get(residentFaction.id).state, "AT_HOME",
    "blocked policy does not leave a PREPARING ghost")
followOwned = false
traderNPC.orderSpec = { kind = "work" }
local protectedStart = Excursions.PumpPolicies(currentTime + 1, 2)
T.equal(protectedStart, 0,
    "protected work blocks resident policy departure")
T.equal(Excursions.Get(residentFaction.id).state, "AT_HOME",
    "protected work does not leave a PREPARING ghost")
traderNPC.orderSpec = nil

-- =========================================================================
-- P20A: FAILED Excursion Semantics and Lifecycle Regressions
-- =========================================================================

local targetMarket = {
    kind = "settlement",
    locationID = "location_m10d_market",
    communityID = communityMarket.id,
    siteID = communityMarket.siteID,
    x = communityMarket.home.x,
    y = communityMarket.home.y,
    z = communityMarket.home.z,
}
local targetAltMarket = {
    kind = "settlement",
    locationID = "location_m10d_market_alt",
    communityID = communityAltMarket.id,
    siteID = communityAltMarket.siteID,
    x = communityAltMarket.home.x,
    y = communityAltMarket.home.y,
    z = communityAltMarket.home.z,
}

-- Case 1: FAILED before departure (PREPARING -> FAILED)
local prepOK = Excursions.SetPhase(residentFaction.id, "PREPARING", {
    destination = copy(targetMarket),
}, currentTime)
T.truthy(prepOK, "transition to PREPARING succeeds")
T.equal(record.ca.currentSettlementID, communityHome.id, "preparing current is home")
T.equal(record.ca.originSettlementID, communityHome.id, "preparing origin is home")
T.equal(record.ca.destinationSettlementID, communityMarket.id, "preparing destination is set")

local failBeforeDepartOK = Excursions.Fail(residentFaction.id, "road_blocked_early", currentTime)
T.truthy(failBeforeDepartOK, "fail before departure succeeds")
local excFail1 = Excursions.Get(residentFaction.id)
T.equal(excFail1.state, "FAILED", "excursion is FAILED")
T.equal(excFail1.departedAt, 0, "excursion did not depart")
T.equal(excFail1.completedAt, 0, "excursion did not complete")
T.equal(record.ca.currentSettlementID, communityHome.id, "failure before departure keeps trader home")
T.equal(record.ca.originSettlementID, communityHome.id, "failure before departure keeps origin home")
T.falsy(record.ca.destinationSettlementID, "failure before departure clears destination")
T.equal(record.ca.homeSettlementID, communityHome.id, "home identity preserved")
T.equal(record.s, DTCommon.STATUS_READY, "trader remains available at home after pre-departure failure")

-- Case 2: FAILED after departure (OUTBOUND -> FAILED with departedAt > 0, completedAt = 0)
local prep2OK = Excursions.SetPhase(residentFaction.id, "PREPARING", {
    destination = copy(targetMarket),
}, currentTime)
T.truthy(prep2OK, "transition to PREPARING succeeds")
local outOK = Excursions.StartOutbound(residentFaction.id, copy(targetMarket), currentTime + 2, currentTime + 14)
T.truthy(outOK, "transition to OUTBOUND succeeds")
T.falsy(record.ca.currentSettlementID, "outbound trader has no current settlement")
T.equal(record.ca.destinationSettlementID, communityMarket.id, "outbound destination is set")
T.equal(record.ca.originSettlementID, communityHome.id, "outbound origin is home")
T.equal(record.s, DTCommon.STATUS_AWAY, "outbound trader is away")

local failAfterDepartOK = Excursions.Fail(residentFaction.id, "ambush_on_road", currentTime + 4)
T.truthy(failAfterDepartOK, "fail after departure succeeds")
local excFail2 = Excursions.Get(residentFaction.id)
T.equal(excFail2.state, "FAILED", "excursion is FAILED")
T.truthy(excFail2.departedAt > 0, "departedAt > 0 verified")
T.equal(excFail2.completedAt, 0, "completedAt == 0 verified")
-- Mandatory assertion: trader is NOT fabricated as home!
T.falsy(record.ca.currentSettlementID, "FAILED after departure must NOT fabricate current settlement as home")
T.falsy(record.ca.destinationSettlementID, "stale destination cleared after departure failure")
T.equal(record.ca.originSettlementID, communityHome.id, "origin remains home community")
T.equal(record.s, DTCommon.STATUS_AWAY, "failed away trader is NOT available at home")

-- Direct production-handler reproduction of fifth-audit defect:
-- Explicit payload with departedAt = 12, completedAt = 0 must not fabricate home
record.ca.currentSettlementID = nil
record.ca.originSettlementID = communityHome.id
record.ca.destinationSettlementID = communityMarket.id
record.s = DTCommon.STATUS_AWAY

local directResult, directReason = Resident.OnExcursion({
    factionID = residentFaction.id,
    purpose = "commercial_run",
    state = "FAILED",
    homeCommunityID = communityHome.id,
    departedAt = 12,
    completedAt = 0,
})
T.truthy(directResult, directReason)
T.falsy(record.ca.currentSettlementID, "audit reproduction: departedAt=12, completedAt=0 does not set current to home")
T.falsy(record.ca.destinationSettlementID, "audit reproduction: destination is cleared")
T.equal(record.s, DTCommon.STATUS_AWAY, "audit reproduction: availability remains away")

-- Case 3: FAILED while visiting (VISITING -> FAILED)
local prep3OK = Excursions.SetPhase(residentFaction.id, "PREPARING", {
    destination = copy(targetMarket),
}, currentTime)
T.truthy(prep3OK)
Excursions.StartOutbound(residentFaction.id, copy(targetMarket), currentTime + 6, currentTime + 18)
Excursions.StartVisiting(residentFaction.id, currentTime + 8, {
    destination = copy(targetMarket),
})
T.equal(record.ca.currentSettlementID, communityMarket.id, "visiting sets current to market")
T.equal(record.s, DTCommon.STATUS_AWAY, "visiting is away")

local failVisitingOK = Excursions.Fail(residentFaction.id, "market_emergency", currentTime + 10)
T.truthy(failVisitingOK)
local excFail3 = Excursions.Get(residentFaction.id)
T.equal(excFail3.state, "FAILED")
T.truthy(excFail3.visitedAt > 0, "visitedAt > 0")
T.equal(excFail3.completedAt, 0, "completedAt == 0")
T.equal(record.ca.currentSettlementID, communityMarket.id, "FAILED while visiting reflects last authoritative location")
T.falsy(record.ca.destinationSettlementID, "FAILED while visiting clears destination")
T.equal(record.s, DTCommon.STATUS_AWAY, "trader failed while visiting is not available at home")

-- Case 4: FAILED while returning home (RETURNING_HOME -> FAILED before exact-home completion)
local retryForRetOK = Excursions.Retry(residentFaction.id, currentTime + 11, {
    destination = copy(targetMarket),
})
T.truthy(retryForRetOK)
Excursions.StartOutbound(residentFaction.id, copy(targetMarket), currentTime + 12, currentTime + 24)
Excursions.StartVisiting(residentFaction.id, currentTime + 14, {
    destination = copy(targetMarket),
})
local retOK = Excursions.StartReturningHome(residentFaction.id, currentTime + 16)
T.truthy(retOK)
T.falsy(record.ca.currentSettlementID, "returning trader is en route (not home)")
T.equal(record.ca.originSettlementID, communityMarket.id, "returning origin is visited community")
T.equal(record.ca.destinationSettlementID, communityHome.id, "returning destination is home")
T.equal(record.s, DTCommon.STATUS_AWAY, "returning trader is away")

local failReturningOK = Excursions.Fail(residentFaction.id, "breakdown_on_return", currentTime + 18)
T.truthy(failReturningOK)
local excFail4 = Excursions.Get(residentFaction.id)
T.equal(excFail4.state, "FAILED")
T.truthy(excFail4.returnStartedAt > 0, "returnStartedAt > 0")
T.equal(excFail4.completedAt, 0, "completedAt == 0")
T.falsy(record.ca.currentSettlementID, "FAILED while returning does NOT mark home")
T.equal(record.ca.originSettlementID, communityMarket.id, "origin remains visited community")
T.falsy(record.ca.destinationSettlementID, "stale return destination cleared on failure")
T.equal(record.s, DTCommon.STATUS_AWAY, "failed returning trader is NOT available at home")

-- Case 5: Retry after FAILED (FAILED -> new PREPARING)
local retryOK, retryReason = Excursions.Retry(residentFaction.id, currentTime + 20, {
    destination = copy(targetAltMarket),
})
T.truthy(retryOK, retryReason)
local excRetry = Excursions.Get(residentFaction.id)
T.equal(excRetry.state, "PREPARING", "excursion retried into PREPARING")
T.equal(record.ca.currentSettlementID, communityHome.id, "retry PREPARING resets current to home")
T.equal(record.ca.originSettlementID, communityHome.id, "retry PREPARING resets origin to home")
T.equal(record.ca.destinationSettlementID, communityAltMarket.id, "new trip gets fresh destination")
T.truthy(record.ca.destinationSettlementID ~= communityMarket.id, "previous failed destination does not leak")

-- Case 6: Happy path regression after retry (PREPARING -> OUTBOUND -> VISITING -> RETURNING_HOME -> AT_HOME)
local happyOut = Excursions.StartOutbound(residentFaction.id, copy(targetAltMarket), currentTime + 22, currentTime + 34)
T.truthy(happyOut)
T.falsy(record.ca.currentSettlementID, "happy path outbound current is nil")
T.equal(record.ca.destinationSettlementID, communityAltMarket.id, "happy path outbound destination")

local happyVisit = Excursions.StartVisiting(residentFaction.id, currentTime + 24, {
    destination = copy(targetAltMarket),
})
T.truthy(happyVisit)
T.equal(record.ca.currentSettlementID, communityAltMarket.id, "happy path visiting current is alt market")

local happyRet = Excursions.StartReturningHome(residentFaction.id, currentTime + 26)
T.truthy(happyRet)
T.falsy(record.ca.currentSettlementID, "happy path returning current is nil")
T.equal(record.ca.originSettlementID, communityAltMarket.id, "happy path returning origin is alt market")

local happyHome = Excursions.SetPhase(residentFaction.id, "AT_HOME", nil, currentTime + 28)
T.truthy(happyHome)
local excHappy = Excursions.Get(residentFaction.id)
T.equal(excHappy.state, "AT_HOME", "excursion is AT_HOME")
T.truthy(excHappy.completedAt > 0, "completedAt > 0 on home arrival")
T.equal(record.ca.currentSettlementID, communityHome.id, "home context restored after happy path return")
T.falsy(record.ca.destinationSettlementID, "destination cleared on home arrival")
T.equal(record.s, DTCommon.STATUS_READY, "availability restored on home arrival")

return T.finish("dt_m10d_resident_excursion_smoke")
