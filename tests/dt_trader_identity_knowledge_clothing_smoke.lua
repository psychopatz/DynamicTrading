local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. coreRepository
    .. "/Contents/mods/PsychopatzCore/42.20/media/lua/client/?.lua;"
    .. coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/client/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local Presets = require "DTCommon/DTCommon_TraderPresets"

-- 1. Preset clothing slots use real PZ Build 42 body locations (no fake slots).
local INVALID_SLOTS = { Torso_Upper = true, Legs = true }
for _, presetID in ipairs({
    "dt.trader.caravan",
    "dt.guard.shotgun",
    "dt.guard.sidearm",
}) do
    local def = Presets.Get(presetID)
    T.truthy(def, "preset exists: " .. presetID)
    T.truthy(#(def.clothing or {}) >= 4, "preset has clothing: " .. presetID)
    for _, c in ipairs(def.clothing) do
        T.falsy(INVALID_SLOTS[c.wornSlot],
            presetID .. " must not use fake slot " .. tostring(c.wornSlot))
    end
    for _, it in ipairs(def.items) do
        if it.wornSlot then
            T.falsy(INVALID_SLOTS[it.wornSlot],
                presetID .. " item must not use fake slot " .. tostring(it.wornSlot))
        end
    end
end

-- 2. Procedural seed-based identities: different seeds produce distinct names
--    (never repeating "Nina Cole" / "Mara Voss" / "Dane Holt" across saves).
local traderNames = {}
local guardNames = {}
for i = 1, 12 do
    local built, reason = Presets.BuildMembers({
        seed = "save_seed_" .. tostring(i * 7919),
        actorPrefix = "caravan_" .. tostring(i),
        memberCount = 3,
        providerID = "DTAbstract",
    })
    T.truthy(built, reason)
    T.equal(#built.memberSpecs, 3, "3 caravan members built")
    local tName = built.memberSpecs[1].identity.displayName
    local gName = built.memberSpecs[3].identity.displayName
    T.truthy(tName and tName ~= "", "trader has displayName")
    T.truthy(gName and gName ~= "", "sidearm guard has displayName")
    traderNames[tName] = true
    guardNames[gName] = true
end

local uniqueTraders, uniqueGuards = 0, 0
for _ in pairs(traderNames) do uniqueTraders = uniqueTraders + 1 end
for _ in pairs(guardNames) do uniqueGuards = uniqueGuards + 1 end
T.truthy(uniqueTraders >= 8,
    "expected diverse trader names across 12 saves, got " .. tostring(uniqueTraders))
T.truthy(uniqueGuards >= 8,
    "expected diverse sidearm guard names across 12 saves, got " .. tostring(uniqueGuards))

-- 3. DTCommon_TraderConversation knowledge gating & disclosure:
--    Unknown trader shows "Stranger", nil factionName, exposes ask-name &
--    ask-faction near the top, and discloses both when asked.
local mockKnowledge = {
    state = "unknown",
    nameKnown = false,
    knownName = nil,
    nicknameKnown = false,
    knownNickname = nil,
    surnameKnown = false,
    knownSurname = nil,
    factionKnown = false,
    factionID = nil,
    factionName = nil,
    revision = 1,
}

local projection = {
    actorID = "npc_dt_test_1",
    displayName = "Elena Parker",
    provider = "DTHoomans",
    providerState = "materialized",
    factionID = "faction_maple",
    factionName = "Maple Enclave",
    factionArchetypeID = "DT.trader",
    capabilities = { ["DT.trade"] = true },
    identity = {
        displayName = "Elena Parker",
        survivor = { forename = "Elena", surname = "Parker", gender = "female" },
    },
    portrait = {
        face = { gender = "female" },
        equipment = { worn = { Shirt = "Base.Shirt_FormalWhite" } },
    },
}

package.preload["PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"] = function()
    return {
        GetActor = function() return projection end,
        ResolveActorReference = function(id)
            return projection, { canonicalActorID = projection.actorID, requestedID = id }
        end,
        GetPortraitSpec = function() return projection.portrait end,
        GetActorKnowledge = function() return mockKnowledge end,
        RequestActorKnowledge = function() return true end,
    }
end

DTCommon = DTCommon or {}
DTCommon.TraderService = {
    GetRecord = function()
        return {
            n = "Caravan Trader",
            ca = {
                actorID = projection.actorID,
                provider = "DTHoomans",
                providerState = "materialized",
                factionID = "faction_maple",
                factionName = "Maple Enclave",
            },
            m = { projection.actorID },
        }
    end,
}

package.loaded["DTCommon/DTCommon_TraderConversation"] = nil
local Conversation = T.load("DTCommon", "client", "DTCommon/DTCommon_TraderConversation.lua")

local spec, err = Conversation.BuildSpec("trader:test:1", projection.actorID, { mode = "face" })
T.truthy(spec, err)
T.equal(spec.context.npcName, "Stranger", "unknown trader name is Stranger")
T.equal(spec.context.factionName, nil, "unknown trader does not leak factionName")
T.equal(spec.context.factionID, nil, "unknown trader does not leak factionID")

local function findChoice(list, id)
    for _, c in ipairs(list or {}) do
        if c.id == id then return c end
    end
    return nil
end

local askName = findChoice(spec.nodes.landing.choices, "core.question.identity")
T.truthy(askName, "ask-name choice is present on landing for unknown trader")
T.falsy(findChoice(spec.nodes.landing.choices, "about_you"),
    "about_you hub is hidden until name is known")
T.truthy((askName.order or 99) <= 20, "ask-name choice is ordered near top")
T.equal(askName.next, "identity_exchange",
    "asking name enters mutual identity_exchange node instead of instant reveal")

local exchangeNode = spec.nodes.identity_exchange
T.truthy(exchangeNode and type(exchangeNode.npc) == "string",
    "identity_exchange node prompts player for their name first")
local realChoice = findChoice(exchangeNode.choices, "identity.choice.real_name")
local lieChoice = findChoice(exchangeNode.choices, "identity.choice.lie_name")
local refuseChoice = findChoice(exchangeNode.choices, "identity.choice.refuse_name")
T.truthy(realChoice, "identity_exchange offers real_name option")
T.falsy(lieChoice, "identity_exchange omits lie_name button (typed false names act as lie guard)")
T.truthy(refuseChoice, "identity_exchange offers refuse_name option")
T.equal(exchangeNode.choices[#exchangeNode.choices].id, "identity_exchange_back",
    "backout choice sits below the beat suggestions")
T.equal(exchangeNode.choices[#exchangeNode.choices].text, "Let's talk about something else.",
    "backout choice uses standard backout wording")

-- Optional hideBackout flag suppresses the backout button for mandatory branches
local lockedSpec = assert(Conversation.BuildSpec(
    "trader:test:1", projection.actorID, { mode = "face", hideBackout = true }))
T.falsy(findChoice(lockedSpec.nodes.identity_exchange.choices, "identity_exchange_back"),
    "hideBackout=true suppresses identity_exchange backout button")
T.falsy(findChoice(lockedSpec.nodes.about_you.choices, "about_you_back"),
    "hideBackout=true suppresses about_you backout button")

-- Refusing in standalone mode must NOT expose trader name
local refuseReply = refuseChoice.response()
T.truthy(type(refuseReply) == "string" and refuseReply ~= "", "refusing returns guarded reply")
T.equal(spec.context.npcName, "Stranger", "refusing does not reveal trader name")

-- Truthful self-introduction in standalone mode reveals first name only (respecting surname gate)
local nameReply = realChoice.response()
T.contains(nameReply, "Elena", "truthful exchange discloses first name")
T.falsy(string.find(nameReply, "Parker", 1, true), "initial exchange does not leak surname")
T.equal(spec.context.npcName, "Elena", "context npcName updates to first name after exchange")
T.equal(spec.context.factionName, nil, "asking name does not prematurely leak faction")

-- Rebuild after name is known: root now shows about_you subcategory instead of ask-name
local spec2, err2 = Conversation.BuildSpec("trader:test:1", projection.actorID, { mode = "face" })
T.truthy(spec2, err2)
T.falsy(findChoice(spec2.nodes.landing.choices, "core.question.identity"),
    "ask-name disappears from landing once name is known")
T.truthy(findChoice(spec2.nodes.landing.choices, "about_you"),
    "about_you subcategory appears on landing once name is known")
T.truthy(spec2.nodes.about_you and type(spec2.nodes.about_you.npc) == "string",
    "about_you node has NPC prompt")

local askFaction = findChoice(spec2.nodes.about_you.choices, "core.question.identity_faction")
T.truthy(askFaction, "ask-faction is inside about_you submenu")
-- Low familiarity (0) triggers relationship gate refusal
local gatedReply = askFaction.response()
T.contains(gatedReply, "known each other", "low familiarity gates faction disclosure")
T.equal(spec2.context.factionName, nil, "gated faction stays nil")

-- Once familiarity >= 10, faction discloses cleanly
spec2.context.relationship = { familiarity = 25 }
local factionReply = askFaction.response()
T.contains(factionReply, "Maple Enclave", "asking faction discloses canonical faction at fam>=10")
T.equal(spec2.context.factionName, "Maple Enclave", "context factionName updates after disclosure")

-- Authoritative provider bridge: when CoreClient exposes SubmitActorIdentityClaim
-- and RequestActorKnowledgeTopic, both identity claims and facet disclosures delegate
-- to the server-authoritative provider instead of mutating local client state.
local submittedClaims, requestedTopics = {}, {}
local CoreClient = package.loaded["PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"]
CoreClient.SubmitActorIdentityClaim = function(aID, opts)
    submittedClaims[#submittedClaims + 1] = { actorID = aID, opts = opts }
    return true, "dispatched"
end
CoreClient.RequestActorKnowledgeTopic = function(aID, topicID, opts)
    requestedTopics[#requestedTopics + 1] = { actorID = aID, topicID = topicID, opts = opts }
    return true, "dispatched"
end
local bridgedRealReply = realChoice.response()
T.equal(bridgedRealReply, nil, "authoritative identity claim awaits server response")
T.equal(#submittedClaims, 1, "identity claim routed to CoreClient.SubmitActorIdentityClaim")
T.equal(submittedClaims[1].opts.claimMode, "canonical", "real_name sends canonical claimMode")

local bridgedRefuseReply = refuseChoice.response()
T.equal(bridgedRefuseReply, nil, "authoritative evasion awaits server response")
T.equal(#submittedClaims, 2, "evasion routed to CoreClient.SubmitActorIdentityClaim")
T.equal(submittedClaims[2].opts.kind, "identity_evasion", "refuse_name sends identity_evasion")

local bridgedFactionReply = askFaction.response()
T.equal(bridgedFactionReply, nil, "authoritative faction request awaits server response")
T.equal(#requestedTopics, 1, "faction request routed to CoreClient.RequestActorKnowledgeTopic")
T.equal(requestedTopics[1].topicID, "faction", "faction facet maps to 'faction' topicID")

print("dt_trader_identity_knowledge_clothing_smoke: PASS")
