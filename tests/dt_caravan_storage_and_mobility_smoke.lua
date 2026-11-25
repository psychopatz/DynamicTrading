-- Smoke test for standalone mod-agnostic DTCommon.CaravanStorage (DTAbstract & DTHoomans),
-- non-player settlement restock gating, and optimized caravan travel scoring.
local dtCommon = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DTCommon/42.20/media/lua/shared/?.lua"
local dtHoomans = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DTHoomans/42.20/media/lua/server/?.lua"
package.path = dtCommon .. ";" .. dtHoomans .. ";" .. package.path

local function assertEqual(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected=%s actual=%s", msg, tostring(expected), tostring(actual)), 2)
    end
end
local function assertTruthy(v, msg)
    if not v then error(msg .. ": expected truthy", 2) end
end

-- 1. Standalone DTCommon.CaravanStorage (ZERO ProjectHoomans loaded — DTAbstract safe!)
local Storage = require "DTCommon/DTCommon_CaravanStorage"
local trader = {
    id = "trader_1",
    s = { ["Base.Bandage"] = 10, ["Base.TinnedBeans"] = 6 },
}
Storage.SetMemberProfile(trader, "trader_a", {
    rootMax = 16,
    bags = {
        { id = "pack_a", maxWeight = 20, weightReduction = 80, usedWeight = 0, equipped = true },
        { id = "loose_bag", maxWeight = 20, weightReduction = 80, usedWeight = 0, equipped = false },
    },
})
Storage.SetMemberProfile(trader, "guard_b", {
    rootMax = 16,
    bags = {
        { id = "pack_b", maxWeight = 28, weightReduction = 85, usedWeight = 0, equipped = true },
    },
})

local used, maxW = Storage.GetCapacity(trader)
-- Root (16+16=32) + pack_a (20*1.8=36) + pack_b (28*1.85=51.8) = 119.8; loose_bag excluded!
assertTruthy(maxW > 119 and maxW < 120.5, "sums member roots + equipped backpacks only, factoring weightReduction")

-- Distribute stock across members (guard_b's higher weightReduction pack gets filled first)
local placements = Storage.DistributeStock(trader, {
    { fullType = "Base.Bandage", qty = 10, weight = 0.2 },
    { fullType = "Base.TinnedBeans", qty = 6, weight = 0.8 },
})
assertTruthy(#placements >= 2, "distributes items across member storage")
assertEqual(placements[1].memberID, "guard_b", "prefers member with best weight-reduction equipped backpack")

-- Pull 2 bandages for trader/guard self-use -> decrements sellable stock cleanly
local pulled = Storage.PullStock(trader, "Base.Bandage", 2, { memberID = "guard_b" })
assertEqual(pulled, 2, "pulls 2 bandages from carrier")
assertEqual(trader.s["Base.Bandage"], 8, "decrements sellable stock without duplication")

-- When guard_b dies, ONLY guard_b's carried stock is deducted from sellable stock
local lost = Storage.OnMemberDied(trader, "guard_b")
assertEqual(lost["Base.Bandage"], 8, "records exact remaining bandages carried by dead guard")
assertEqual(trader.s["Base.Bandage"], nil, "sellable stock reflects loss of dead guard's carried bandages")

-- 2. Optimized DTHoomans_CommercialMobility travel scoring (distance decay, revisit cooldown, low-stock restock bias, cache)
local listCalls = 0
DTCommon.SettlementMarket = {
    Get = function()
        return { categories = { Food = { demand = 0.7, supply = 0.3 } } }
    end,
}
DTCommon.MarketEvents = {
    ListActive = function()
        listCalls = listCalls + 1
        return {}, { activeEventCount = 1 }
    end,
}
local Mobility = require "DTHoomans/DTHoomans_CommercialMobility"
local faction = { id = "f1", mobile = { x = 0, y = 0, recentSettlements = { "town_recent" } } }
local ctx = { at = 50, stockRatio = 0.2 }

local scoreNearNPC = Mobility.OpportunityScore(faction, { communityID = "town_near", x = 100, y = 0, playerOwned = false }, ctx)
local scoreFarNPC = Mobility.OpportunityScore(faction, { communityID = "town_far", x = 5000, y = 0, playerOwned = false }, ctx)
local scoreRecentNPC = Mobility.OpportunityScore(faction, { communityID = "town_recent", x = 100, y = 0, playerOwned = false }, ctx)
local scoreNearPlayer = Mobility.OpportunityScore(faction, { communityID = "player_base", x = 100, y = 0, playerOwned = true }, ctx)

assertTruthy(scoreNearNPC > scoreFarNPC, "distance decay favors nearby settlements over distant ones")
assertTruthy(scoreNearNPC > scoreRecentNPC, "revisit cooldown penalizes recently visited settlement")
assertTruthy(scoreNearNPC > scoreNearPlayer, "low-stock caravan prefers non-player NPC settlement to restock")

-- Cache hit on repeated score in same pump
local callsBefore = listCalls
Mobility.OpportunityScore(faction, { communityID = "town_near", x = 100, y = 0, playerOwned = false }, ctx)
assertEqual(listCalls, callsBefore, "per-pump cache avoids redundant MarketEvents lookups")

print("dt_caravan_storage_and_mobility_smoke: ok")
