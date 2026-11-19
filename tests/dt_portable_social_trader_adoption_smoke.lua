local T = require "tests/support/test"
T.addPackagePaths()

local modDataStore = {}
ModData = {
    getOrCreate = function(key)
        modDataStore[key] = modDataStore[key] or {}
        return modDataStore[key]
    end,
    transmit = function() end,
}
Events = {
    OnInitGlobalModData = { Add = function() end },
    OnSave = { Add = function() end },
}
isServer = function() return true end
isClient = function() return false end

-- Explicitly keep Project Hoomans absent (Core + DTCommon + DTAbstract only)
PNC = nil

local CoreActors = require "PsychopatzCore/Actors/PsychopatzActors"
local Social = CoreActors.Social
local dtPolicyReg = require "DTCommon/SocialPolicy/Registry"
CoreActors.SocialPolicy.RegisterRegistry(dtPolicyReg)

local registry = CoreActors.NewRegistry()
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = CoreActors
PsychopatzCore.Actors.DefaultRegistry = registry

local worldHours = 120
getGameTime = function()
    return {
        getWorldAgeHours = function() return worldHours end,
    }
end

dofile(T.path("DTCommon", "shared", "DTCommon/00_DTCommon_Init.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_Storage.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_TraderSupport.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua"))
dofile(T.path("DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua"))

local Policy = DTCommon.CoreActorPolicy
local Service = DTCommon.TraderService
local Pricing = DTCommon.MarketPricing

-- 1. Create two abstract traders with different personalities & social history
local trustedActor = assert(registry:Create({
    actorId = "actor:dt:trusted",
    identitySeed = "dt-trusted-seed",
    providerLease = { leaseID = "lease:dt:trusted", provider = "DTAbstract", owner = "DTAbstract" },
    social = Social.NewState({ personality = { greed = 0.2, sociability = 0.85, forgiveness = 0.7 } }),
}))
local guardedActor = assert(registry:Create({
    actorId = "actor:dt:guarded",
    identitySeed = "dt-guarded-seed",
    providerLease = { leaseID = "lease:dt:guarded", provider = "DTAbstract", owner = "DTAbstract" },
    social = Social.NewState({ personality = { greed = 0.85, sociability = 0.2, forgiveness = 0.1 } }),
}))

local _, trustedRec = Service.Create({
    traderID = "trader:dt:trusted",
    displayName = "Friendly Hal",
    actorID = trustedActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
T.truthy(trustedRec, "trustedRec created")
local _, guardedRec = Service.Create({
    traderID = "trader:dt:guarded",
    displayName = "Grumpy Vance",
    actorID = guardedActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
T.truthy(guardedRec, "guardedRec created")

-- 2. Verify BindFaction populates missing ca.actorID for settlement traders
local _, settlementRec = Service.Create({
    traderID = "trader:settlement:test",
    displayName = "Settlement Sue",
    abstractAccessEnabled = false,
})
T.truthy(settlementRec, "settlementRec created")
T.equal(settlementRec.ca.actorID, nil, "settlement record starts without actorID")
T.truthy(Service.BindFaction("trader:settlement:test", "faction:settlement:1", "npc:settlement:sue", { "npc:settlement:sue" }))
T.equal(Service.GetRecord("trader:settlement:test").ca.actorID, "npc:settlement:sue",
    "BindFaction repairs missing ca.actorID automatically")

local playerModData = { PNC_CharacterUUID = "char_dt_adopt" }
if CoreActors.PlayerIdentity and CoreActors.PlayerIdentity.RegisterIssuedIdentity then
    CoreActors.PlayerIdentity.RegisterIssuedIdentity(
        "char_dt_adopt", "SurvivorOne", { source = "test_issued" }
    )
end
local player = {
    getUsername = function() return "SurvivorOne" end,
    getOnlineID = function() return 77 end,
    getModData = function() return playerModData end,
}

-- 3. Trusted trader accumulates 5 routine trades (consolidated) + 1 high-value trade
for i = 1, 5 do
    worldHours = worldHours + 1
    assert(Policy.RecordTradeEvent(trustedRec, player, {
        requestID = "trusted-routine-" .. i,
        totalValue = 50,
    }))
end
assert(Policy.RecordTradeEvent(trustedRec, player, {
    requestID = "trusted-high",
    totalValue = 400,
}))

-- Guarded trader receives a price grievance
assert(Policy.RecordTradeEvent(guardedRec, player, {
    requestID = "guarded-grievance",
    totalValue = 20,
    grievance = true,
    approvalDelta = -20,
    respectDelta = -10,
}))

local tProj = assert(Policy.QuerySocialProjection(trustedRec, player, { worldAgeHours = worldHours }))
local gProj = assert(Policy.QuerySocialProjection(guardedRec, player, { worldAgeHours = worldHours }))

T.equal(tProj.activeMemoryCount, 2, "5 routine + 1 high-value trades occupy only 2 consolidated slots")
T.equal(tProj.commercial.totalTrades, 6, "totalTrades tracked across trades")
T.equal(tProj.willingnessTier, "high", "trusted trader reaches high willingnessTier")
T.equal(gProj.willingnessTier, "guarded", "aggrieved trader enters guarded willingnessTier")

-- 4. Relationship pricing context reflects distinct modifiers and revision without owning market prices
local tPriceCtx = Pricing.BuildContext(trustedRec, player)
local gPriceCtx = Pricing.BuildContext(guardedRec, player)
T.truthy(tPriceCtx.relationshipModifier > 0, "trusted trader gives positive discount modifier")
T.truthy(gPriceCtx.relationshipModifier < 0, "guarded trader gives negative penalty modifier")
T.truthy(tPriceCtx.relationshipRevision > 0, "relationshipRevision surfaced in price context")
T.truthy(string.find(tPriceCtx.quoteContextRevision, ":" .. tostring(tPriceCtx.relationshipRevision), 1, true) ~= nil,
    "ContextRevision includes relationshipRevision")

-- 5. Trader conversation differentiates responses for two traders without an LLM
package.preload["PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"] = function()
    return {
        GetActor = function(actorID)
            local a = registry:Get(actorID)
            if not a then return nil end
            local p = Policy.QuerySocialProjection(
                actorID == trustedActor.actorId and trustedRec or guardedRec,
                player
            )
            return {
                actorID = a.actorId,
                displayName = actorID == trustedActor.actorId and "Friendly Hal" or "Grumpy Vance",
                personality = a.social.personality,
                relationship = p,
            }
        end,
        Resolve = function(actorID)
            local a = registry:Get(actorID)
            if not a then return nil, "actor_not_found" end
            local p = Policy.QuerySocialProjection(
                actorID == trustedActor.actorId and trustedRec or guardedRec,
                player
            )
            return {
                actorID = a.actorId,
                displayName = actorID == trustedActor.actorId and "Friendly Hal" or "Grumpy Vance",
                personality = a.social.personality,
                relationship = p,
            }, { canonicalActorID = a.actorId, aliasKind = "canonical" }
        end,
        GetPortraitSpec = function(proj)
            return {
                actorID = proj.actorID,
                appearance = { hairModel = "Short" },
                equipment = { worn = {} },
            }
        end,
    }
end
getModFileReader = function(modID, path)
    if modID ~= "PsychopatzCore" then return nil end
    local file = io.open(T.path("PsychopatzCore", "common_mod", path), "r")
    if not file then return nil end
    return {
        readLine = function() return file:read("*l") end,
        close = function() file:close() end,
    }
end
PsychopatzCore.Conversation = PsychopatzCore.Conversation or {}
PsychopatzCore.Conversation.Open = function(spec) return { spec = spec } end
dofile(T.path("DTCommon", "client", "DTCommon/DTCommon_TraderConversation.lua"))

local tSpec = assert(DTCommon.TraderConversation.BuildSpec(
    "trader:dt:trusted", trustedActor.actorId, { mode = "radio", player = player }
))
local gSpec = assert(DTCommon.TraderConversation.BuildSpec(
    "trader:dt:guarded", guardedActor.actorId, { mode = "radio", player = player }
))
local tSvc = assert(tSpec.actorConversation.createService())
local gSvc = assert(gSpec.actorConversation.createService())
local tResult = assert(tSvc:Process("trade"))
local gResult = assert(gSvc:Process("trade"))
local tText = tResult.decision and tResult.decision.response and tResult.decision.response.text
local gText = gResult.decision and gResult.decision.response and gResult.decision.response.text
T.truthy(tResult.accepted and gResult.accepted and type(tText) == "string" and type(gText) == "string" and tText ~= gText,
    "Trusted and guarded traders produce distinct non-LLM commercial responses")

T.finish("dt_portable_social_trader_adoption_smoke")
