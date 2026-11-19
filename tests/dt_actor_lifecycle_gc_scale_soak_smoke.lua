local T = require "tests/support/test"
T.addPackagePaths()

local modDataStore = {}
ModData = {
    getOrCreate = function(k)
        modDataStore[k] = modDataStore[k] or {}
        return modDataStore[k]
    end,
    transmit = function() end,
}

local commandHandlers = {}
Events = {
    OnInitGlobalModData = { Add = function() end },
    OnServerStarted = { Add = function() end },
    OnGameStart = { Add = function() end },
    OnSave = { Add = function() end },
    EveryDays = { Add = function() end },
    OnClientCommand = {
        Add = function(fn) commandHandlers[#commandHandlers + 1] = fn end,
    },
}
isServer = function() return true end
isClient = function() return false end

local worldHours = 300
getGameTime = function()
    return { getWorldAgeHours = function() return worldHours end }
end
triggerEvent = function() end

-- Phase 1: PNC-disabled (Core + DTCommon + DTAbstract) scale soak across 200 actors
PNC = nil
local CoreActors = require "PsychopatzCore/Actors/PsychopatzActors"
local Social = CoreActors.Social
local GC = CoreActors.GC
local WKG = require "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = CoreActors
PsychopatzCore.WorldKnowledge = WKG
PsychopatzCore.RuntimeRole = { AllowsServerCode = function() return true end }

local registry = CoreActors.NewRegistry()
CoreActors.DefaultRegistry = registry
local dtPolicyReg = require "DTCommon/SocialPolicy/Registry"
CoreActors.SocialPolicy.RegisterRegistry(dtPolicyReg)

dofile(T.path("DTCommon", "shared", "DTCommon/00_DTCommon_Init.lua"))

local Service = DTCommon.TraderService
local Policy = DTCommon.CoreActorPolicy
local Generation = DTCommon.TraderGeneration
local LifecycleBridge = DTCommon.ActorLifecycle
LifecycleBridge.RegisterGCProvider(GC)
DTCommon.TraderProviders.Register("DTAbstract", {
    kind = "abstract",
    isAvailable = function() return true end,
})
DTCommon.TraderProviders.Register("DTHoomans", {
    kind = "physical",
    isAvailable = function() return true end,
})

WKG.Reset()
local soakFact = assert(WKG.Publish({
    factID = "fact:dt_soak:1",
    kind = "market_event",
    topic = "market",
    text = "Caravan routes open.",
}, { now = worldHours }))

-- Witness holding 20 STRONG betrayal anchors (actors 161..180)
local witnessMems = {}
local witnessRels = {}
for idx = 161, 180 do
    local id = string.format("actor:dt_soak:%04d", idx)
    witnessRels[id] = { target = id, trust = -60, approval = -60 }
    witnessMems[#witnessMems + 1] = {
        id = "mem:dt_soak:betray:" .. tostring(idx),
        aboutKey = id,
        type = "betrayed_player",
        retentionClass = "ANCHOR",
        refStrength = "STRONG",
        permanent = true,
        salience = 95,
        createdAt = worldHours,
    }
end
assert(registry:Create({
    actorId = "actor:dt_soak:witness",
    identitySeed = "dt-soak-witness",
    social = Social.NewState({ relationships = witnessRels, memoryBank = witnessMems }),
}))

-- 1..20: rollback HardDelete
for idx = 1, 20 do
    local id = string.format("actor:dt_soak:rb:%04d", idx)
    assert(registry:Create({ actorId = id, identitySeed = id }))
    assert(Generation.RemoveCanonicalGroup({ createdActorIDs = { id } }))
    T.equal(registry:GetLifecycleState(id), "FORGOTTEN")
end
T.equal(#registry:ListTombstones(), 0, "rollbacks create zero tombstones")

-- 21..40: commercial-role removal only
DTAbstract = {
    SurvivorWorldRuntime = {
        GetActorRegistry = function() return registry end,
        SetActorRegistry = function() end,
        GetRegistry = function() return nil end,
        FindGroupForActor = function() return nil end,
        SelectTraderCandidate = function() return nil end,
    },
    TraderWorldProvider = { releaseTrader = function() return true end },
}
T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")
T.load("DTAbstract", "server", "DTAbstract/DTAbstract_Server.lua")
for idx = 21, 40 do
    local id = string.format("actor:dt_soak:role:%04d", idx)
    assert(registry:Create({ actorId = id, identitySeed = id }))
    Service.Create({
        traderID = "trader:soak:role:" .. tostring(idx),
        actorID = id,
        provider = "DTAbstract",
        providerState = "abstract",
        abstractAccessEnabled = true,
    })
    for _, handler in ipairs(commandHandlers) do
        handler("DTAbstract", "RemoveTrader", {}, { traderID = "trader:soak:role:" .. tostring(idx) })
    end
    T.equal(registry:GetLifecycleState(id), "LIVE")
end
T.equal(#registry:ListTombstones(), 0, "commercial-role removals create zero tombstones")

-- 41..60: superseded migration (HardDelete)
local Import = require "DTAbstract/DTAbstract_PreSurvivorWorldImport"
for idx = 41, 60 do
    local oldID = string.format("actor:dt:world:soak_%04d", idx)
    local newID = string.format("actor:dt_soak:canon:%04d", idx)
    assert(registry:Create({
        actorId = oldID,
        identitySeed = oldID,
        social = Social.NewState({
            relationships = {
                ["player:user:alice"] = { target = "player:user:alice", approval = 25 },
            },
        }),
    }))
    WKG.Acquire(oldID, soakFact.factID, {
        authorized = true,
        provenance = "public",
        source = "soak",
        confidence = 1,
        learnedAt = worldHours,
    })
    assert(registry:Create({ actorId = newID, identitySeed = newID }))
    local rec = {
        b = 1000,
        ca = Policy.New({ actorID = oldID, provider = "DTAbstract", providerState = "abstract" }),
    }
    local cand = {
        actorID = newID,
        groupID = "grp_" .. tostring(idx),
        factionID = "fac_" .. tostring(idx),
        communityID = "comm:soak",
        memberActorIDs = { newID },
    }
    local rebound = assert(Import.Rebind("trader:mig:" .. tostring(idx), rec, worldHours, {
        registry = function() return registry end,
        actors = function() return CoreActors end,
        runtime = { SelectTraderCandidate = function() return cand end },
        directory = { Get = function() return { settlementID = "comm:soak" } end },
        service = Service,
        acquire = function() return { providerLease = { provider = "DTAbstract", state = "abstract", revision = 2 } } end,
        releaseAcquired = function() return true end,
    }))
    T.truthy(rebound)
    T.equal(registry:Get(oldID), nil, "superseded actor removed")
    T.truthy(Social.Get(registry:Get(newID).social, "player:user:alice"), "social migrated")
    T.equal(WKG.KnowledgeState.byActor[oldID], nil, "old knowledge bucket cleaned")
end
T.equal(#registry:ListTombstones(), 0, "migrations create zero tombstones")

-- 61..160: ordinary deaths (100 traders, kept briefly to test OnBeforePurge)
-- 161..180: betrayal-pinned deaths (20 traders)
-- 181..200: active obligation deaths (20 traders: 181..190 settled later, 191..200 stay active)
for idx = 61, 200 do
    local id = string.format("actor:dt_soak:%04d", idx)
    local tID = "trader:dt_soak:" .. tostring(idx)
    assert(registry:Create({ actorId = id, identitySeed = id }))
    local _, rec = Service.Create({
        traderID = tID,
        actorID = id,
        provider = "DTAbstract",
        providerState = "abstract",
        abstractAccessEnabled = true,
    })
    if idx >= 181 then
        rec.obligations = {
            { id = "ob_" .. tostring(idx), active = true, counterparty = "actor:dt_soak:witness" },
        }
    end
    assert(LifecycleBridge.RetireTraderActor(tID, {
        registry = registry,
        retiredAt = worldHours,
        graceHours = 12,
        keepCommercialRecord = (idx <= 160),
    }))
end

T.equal(#registry:ListTombstones(), 140, "all 140 retired traders create Core tombstones")

-- Advance time & sweep Gen 1 across budgeted slices (budget = 25)
worldHours = worldHours + 36
local stepSlices = 0
local stepOut
repeat
    stepOut = assert(GC.Step(registry, {
        authority = "server",
        budget = 25,
        now = worldHours,
        worldKnowledge = WKG,
    }))
    stepSlices = stepSlices + 1
    assert(stepSlices <= 100)
until stepOut.completed == true

-- Expected remaining after Gen 1: 20 betrayal anchors + 20 active obligations = 40 tombstones
T.equal(#registry:ListTombstones(), 40, "Gen 1 must retain only 20 betrayers + 20 obligors")

-- Settle obligations 181..190 & sweep Gen 2 -> 30 remain
for idx = 181, 190 do
    Service.GetRecord("trader:dt_soak:" .. tostring(idx)).obligations[1].active = false
end
worldHours = worldHours + 24
GC.RunFull(registry, { authority = "server", now = worldHours, worldKnowledge = WKG })
T.equal(#registry:ListTombstones(), 30, "Gen 2 must retain 20 betrayers + 10 active obligors")
T.equal(Service.GetRecord("trader:dt_soak:185"), nil, "settled obligor record cleaned")
T.truthy(Service.GetRecord("trader:dt_soak:195"), "active obligor record preserved")

-- Save/Load roundtrip under _G.next = nil
local savedNext = _G.next
_G.next = nil
local okS, ser = pcall(registry.Save, registry)
local reloaded = CoreActors.NewRegistry()
local okL, loadRes, loadErr = pcall(reloaded.Load, reloaded, ser)
_G.next = savedNext
T.truthy(okS and ser)
T.truthy(okL and loadRes, loadErr)
T.equal(#reloaded:ListTombstones(), 30, "reloaded DT soak tombstones preserved")

-- Phase 2: Combined DTHoomans continuity + physical death check
PNC = {
    Core = { IsAuthority = function() return true end },
    Registry = { Data = {}, DeathMarkers = {}, Get = function() return nil end },
    Persistence = {},
}
T.load(T.path("ProjectHoomans", "shared", "PNC/Core/") .. "Persistence/PNC_Persistence_CoreLifecycle.lua")
local physActor = assert(registry:Create({
    actorId = "actor:dt_soak:dthoomans_1",
    identitySeed = "dthoom-soak-1",
}))
Service.Create({
    traderID = "trader:dt_soak:dthoom_1",
    actorID = physActor.actorId,
    provider = "DTHoomans",
    providerState = "materialized",
    abstractAccessEnabled = false,
})
assert(PNC.Persistence.CoreLifecycle.RetireActor({
    id = physActor.actorId,
    coreActorID = physActor.actorId,
}, "death", { retiredAt = worldHours }))
local availOK, availErr = Policy.IsAvailable(Service.GetRecord("trader:dt_soak:dthoom_1"))
T.falsy(availOK)
T.equal(availErr, "actor_retired")

T.finish("dt_actor_lifecycle_gc_scale_soak_smoke")
