local T = require "tests/support/test"

local ROOT = "../psychopatzCore/Contents/mods/PsychopatzCore/common/media/lua/shared/"
package.path = ROOT .. "?.lua;" .. package.path

local CoreActors = require "PsychopatzCore/Actors/PsychopatzActors"
local Social = CoreActors.Social

-- Initialize test registry
local registry = CoreActors.NewRegistry()
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = CoreActors
PsychopatzCore.Actors.DefaultRegistry = registry

-- Create Core actor for trader
local actor, createErr = registry:Create({
    actorId = "actor:dt:merchant:one",
    identitySeed = "seed-merchant-one",
    archetypeID = "trader.general",
    providerLease = { leaseID = "lease:dt:1", provider = "DTAbstract", owner = "DynamicTrading" },
})
T.truthy(actor, createErr)

T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local Policy = DTCommon.CoreActorPolicy

local playerModData = { PNC_CharacterUUID = "char_alice_1" }
if CoreActors.PlayerIdentity and CoreActors.PlayerIdentity.RegisterIssuedIdentity then
    CoreActors.PlayerIdentity.RegisterIssuedIdentity("char_alice_1", "alice", { source = "hoom_created" })
end
local player = {
    getOnlineID = function() return 12 end,
    getUsername = function() return "alice" end,
    getModData = function() return playerModData end,
}

local keys = Policy.PlayerKeys(player)
T.equal(keys[1], "player:alice:char_alice_1", "canonical player key is primary")
local hasLegacyUser = false
local hasLegacyOnline = false
for _, k in ipairs(keys) do
    if k == "player:user:alice" then hasLegacyUser = true end
    if k == "player:online:12" then hasLegacyOnline = true end
end
T.truthy(hasLegacyUser, "legacy user key preserved as alias")
T.truthy(hasLegacyOnline, "legacy online key preserved as alias")

local traderRecord = {
    s = "READY",
    v = 1,
    b = 500,
    ca = {
        actorID = "actor:dt:merchant:one",
        relationshipPricing = true,
        priceBias = 0.0,
    },
}

-- Initial pricing context before trade
local initialPrice = Policy.PriceContext(traderRecord, player)
T.equal(initialPrice.relationshipModifier, 0.0, "initial modifier is 0")

-- Record a successful trade event
local updatedSocial, tradeErr = Policy.RecordTradeEvent(traderRecord, player, {
    requestID = "req-1001",
    totalValue = 150,
    approvalDelta = 10,
    familiarityDelta = 5,
})
T.truthy(updatedSocial, tradeErr)

-- Verify Core actor was updated in registry
local fetchedActor = registry:Get("actor:dt:merchant:one")
local rel = Social.Get(fetchedActor.social, "player:online:12")
T.truthy(rel, "relationship found")
T.equal(rel.approval, 10, "approval delta recorded in Core Social")
T.equal(rel.familiarity, 5, "familiarity delta recorded in Core Social")
T.equal(rel.memories[1].id, "dt:trade:req-1001", "trade memory recorded")

local ext = Social.GetExtension(fetchedActor.social, "player:online:12", "DynamicTrading")
T.truthy(ext, "DT commercial extension present")
T.equal(ext.totalTrades, 1, "first trade recorded in extension")
T.equal(ext.lastTradeValue, 150, "last trade value recorded")

-- New price context reflects the improved relationship!
local discountedPrice = Policy.PriceContext(traderRecord, player)
T.truthy(discountedPrice.relationshipModifier > 0, "relationship discount applied after trade")

T.finish("dt_trade_relationship_event_smoke")
