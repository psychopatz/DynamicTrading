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

local nameReply = askName.response()
T.contains(nameReply, "Elena Parker", "asking name discloses canonical name")
T.equal(spec.context.npcName, "Elena Parker", "context npcName updates after disclosure")
T.equal(spec.context.factionName, nil, "asking name does not prematurely leak faction")

-- Repeat-ask escalation on already-known name
local repeat1 = askName.response()
local repeat2 = askName.response()
local repeat3 = askName.response()
T.contains(repeat1, "already told you", "1st repeat reminds player")
T.contains(repeat2, "already asked", "2nd repeat is pointed")
T.contains(repeat3, "Stop asking", "3rd repeat is annoyed")

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

print("dt_trader_identity_knowledge_clothing_smoke: PASS")
