local T = require "tests/support/test"

local registered = {}
local calls = {}
local seen = {}

DTCommon = {
    Storage = { IsAuthority = function() return true end },
    TraderService = {
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
        },
    },
    Travel = { Arrivals = { StrictActionTypes = {} } },
}
DTHoomans = {}

local Settlement = T.load(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
T.truthy(registered[Settlement.ARRIVAL_ACTION],
    "Hoomans arrival handler is registered")
T.truthy(PNC.Travel.Arrivals.StrictActionTypes[Settlement.ARRIVAL_ACTION],
    "settlement arrival action is strict")
T.equal(Settlement.SettlementIDForFaction("faction_target"),
    "community_target", "active Hoomans community is canonical settlement ID")

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
