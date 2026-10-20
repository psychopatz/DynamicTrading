local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

PsychopatzCore = {}
local Semantics = require "PsychopatzCore/Semantics/PsychopatzSemantic"
local Knowledge = require "PsychopatzCore/Actors/PsychopatzActorKnowledge"

Semantics.Registry.Reset()
Semantics.Registry.RegisterPattern({
    id = "dt.talk.hello",
    match = { { kind = "literal", value = "hello" } },
    emit = { intent = "GREETING", speechAct = "GREETING", subject = "SOCIAL" },
})

local actor = {
    actorId = "npc:trader:portable",
    identity = { displayName = "Mara" },
    persona = { selectionSetVersion = 2 },
    social = { personality = { warmth = 0.7 }, relationships = {} },
    knowledge = Knowledge.NewState({
        byPlayer = {
            ["user:alice"] = { facts = {} },
            ["user:bob"] = { facts = {} },
        },
    }),
}
local record = {
    s = "READY",
    a = 1,
    ca = { actorID = actor.actorId, providerRevision = 4 },
}
local playerA = {
    getUsername = function() return "alice" end,
}
local playerB = {
    getUsername = function() return "bob" end,
}

DTCommon = {
    STATUS_READY = "READY",
    Storage = { IsAuthority = function() return true end },
    T = function(_, fallback) return fallback end,
    CoreActorPolicy = {
        ResolveActor = function(value)
            return value == record and actor or nil, "actor_not_found"
        end,
    },
    TraderService = {
        GetRecord = function(id)
            return id == "trader:portable" and record or nil
        end,
        ValidateTalkAccess = function(_, id, mode)
            if id ~= "trader:portable" then return false, "trader_not_found" end
            if mode ~= "radio" then return false, "wrong_mode" end
            return true
        end,
    },
}

local Talk = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TalkService.lua")
local first, firstReason = Talk.Open(playerA, "trader:portable", "radio")
T.truthy(first, firstReason)
T.equal(first.actorID, actor.actorId, "Talk binds the Core actor")
T.equal(first.traderID, "trader:portable", "Talk retains DT trader ID")
T.equal(first.providerRevision, 4, "Talk carries provider revision")

local second, secondReason = Talk.Open(playerB, "trader:portable", "radio")
T.truthy(second, secondReason)
T.equal(first.sessionID == second.sessionID, false,
    "player sessions remain isolated")

local turn, turnReason = Talk.Submit(
    playerA, "trader:portable", first.sessionID, "hello", {
        mode = "radio",
        requestID = "turn-1",
        language = "EN",
    }
)
T.truthy(turn, turnReason)
T.equal(turn.actorID, actor.actorId, "turn uses the same actor")
T.equal(turn.result.rawText, "hello", "turn preserves the utterance")
T.truthy(turn.result.responses[1].text,
    "Talk returns a bounded visible response")

local duplicate, duplicateReason = Talk.Submit(
    playerA, "trader:portable", first.sessionID, "hello", {
        mode = "radio",
        requestID = "turn-1",
    }
)
T.truthy(duplicate, duplicateReason)
T.equal(duplicate.state.turnCount, turn.state.turnCount,
    "duplicate Talk request does not advance state")

local stale, staleReason = Talk.Submit(
    playerB, "trader:portable", first.sessionID, "hello", {
        mode = "radio",
        requestID = "other-player",
    }
)
T.equal(stale, nil, "another player cannot use the session")
T.equal(staleReason, "talk_session_invalid", "session ownership is enforced")

local closed, closeReason = Talk.Close(
    playerA, "trader:portable", first.sessionID, "radio")
T.truthy(closed, closeReason)
T.equal(Talk.Count(), 1, "closing one player leaves the other session")

T.finish("dt_talk_service_smoke")
