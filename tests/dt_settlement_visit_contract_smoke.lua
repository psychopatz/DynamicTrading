local T = require "tests/support/test"
local loadSource = T.load

local registered = {}
local calls = {}
local seen = {}
local travelStarts = {}

DTCommon = {
    Storage = { IsAuthority = function() return true end },
    TraderService = {
        GetRecord = function(traderID)
            if traderID == "dt_caravan_1" then
                return { p = "npc_trader_1", g = "faction_caravan_1" }
            end
            return nil
        end,
        ForEach = function(callback)
            callback("dt_caravan_1", {
                p = "npc_trader_1",
                g = "faction_caravan_1",
                m = { "npc_trader_1", "npc_guard_1" },
            })
        end,
        MarkSettlementVisit = function(traderID, options)
            calls[#calls + 1] = { traderID = traderID, options = options }
            if seen[options.visitID] then return nil, "duplicate_visit" end
            seen[options.visitID] = true
            return {
                traderID = traderID,
                visitCount = #calls,
            }
        end,
    },
}

PNC = {
    Communities = {
        Get = function(id)
            if id == "community_target" then
                return { id = id, status = "active", siteID = "community_site_target" }
            end
            return nil
        end,
        GetForFaction = function(id)
            if id == "faction_target" then
                return {
                    { id = "community_target", status = "active", siteID = "community_site_target" },
                }
            end
            return {}
        end,
    },
    API = {
        Travel = {
            RegisterArrivalHandler = function(id, handler)
                registered[id] = handler
                return true
            end,
            Start = function(npcID, request)
                travelStarts[#travelStarts + 1] = {
                    npcID = npcID,
                    request = request,
                }
                return { journeyId = "journey:started" }, "started"
            end,
        },
    },
    Travel = { Arrivals = { StrictActionTypes = {} } },
}
DTHoomans = {}

local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
T.truthy(registered[Settlement.ARRIVAL_ACTION],
    "Hoomans arrival handler is registered")
T.truthy(PNC.Travel.Arrivals.StrictActionTypes[Settlement.ARRIVAL_ACTION],
    "settlement arrival action is strict")
T.equal(Settlement.SettlementIDForFaction("faction_target"),
    "community_target", "active Hoomans community is canonical settlement ID")

local started, startedReason = Settlement.StartTraderTravel(
    "dt_caravan_1", "community_target", {
        destination = { x = 100, y = 200, z = 0 },
        metadata = { route = "test" },
    })
T.truthy(started, startedReason)
T.equal(#travelStarts, 1, "settlement travel delegates to Hoomans once")
T.equal(travelStarts[1].npcID, "npc_trader_1",
    "settlement travel uses the physical Hoomans NPC identity")
T.equal(travelStarts[1].request.ownerMod, "DynamicTrading",
    "travel action identifies DynamicTrading as the owner")
T.equal(travelStarts[1].request.ownerRef, "dt_caravan_1",
    "travel action keeps the DT trader reference")
T.equal(travelStarts[1].request.arrivalAction.type,
    Settlement.ARRIVAL_ACTION, "travel action uses the strict DT type")
T.equal(travelStarts[1].request.arrivalAction.settlementID,
    "community_target", "travel action uses canonical settlement identity")
T.equal(travelStarts[1].request.arrivalAction.exchange, true,
    "travel action defaults to partial exchange")
local noExchange = Settlement.StartTraderTravel(
    "dt_caravan_1", "community_target", {
        destination = { x = 300, y = 400, z = 0 },
        exchange = false,
    })
T.truthy(noExchange, "travel action can explicitly disable exchange")
T.equal(travelStarts[2].request.arrivalAction.exchange, false,
    "travel action preserves explicit exchange opt-out")

local handler = registered[Settlement.ARRIVAL_ACTION]
local handled, handledReason = handler(
    { id = "npc_trader_1" },
    {
        state = "arrived",
        journeyId = "journey:one",
        arrivedWorldHour = 42,
    },
    {
        type = Settlement.ARRIVAL_ACTION,
        settlementID = "community_target",
        exchange = true,
    },
    "route_complete"
)
T.truthy(handled, handledReason)
T.equal(handledReason, "settlement_visit", "arrival forwards one visit")
T.equal(#calls, 1, "one DT visit call is made")
T.equal(calls[1].traderID, "dt_caravan_1", "arrival resolves trader by NPC")
T.equal(calls[1].options.authority, "server", "arrival is server-authoritative")
T.equal(calls[1].options.atSettlement, true, "arrival carries settlement context")
T.equal(calls[1].options.settlementID, "community_target",
    "arrival uses canonical community identity")
T.equal(calls[1].options.exchange, true,
    "arrival forwards bounded exchange intent")
T.contains(calls[1].options.visitID, "journey:one",
    "arrival visit ID is derived from the journey")

local duplicate, duplicateReason = handler(
    { id = "npc_trader_1" },
    {
        state = "arrived",
        journeyId = "journey:one",
        arrivedWorldHour = 42,
    },
    {
        type = Settlement.ARRIVAL_ACTION,
        settlementID = "community_target",
    },
    "arrival_recovery"
)
T.truthy(duplicate, "duplicate arrival is treated as handled")
T.equal(duplicateReason, "duplicate_visit",
    "duplicate arrival preserves the DT idempotency reason")

local invalid, invalidReason = handler(
    { id = "npc_trader_1" },
    { state = "arrived", journeyId = "journey:two" },
    { type = Settlement.ARRIVAL_ACTION },
    "route_complete"
)
T.equal(invalid, false, "arrival without settlement context is rejected")
T.equal(invalidReason, "settlement_required",
    "arrival context failure is explicit")

T.finish("dt_settlement_visit_contract")
