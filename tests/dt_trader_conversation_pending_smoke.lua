local T = require "tests/support/test"
T.addPackagePaths()

local ready = false
local requestCount = 0
local tick
local openedSpec
local projection = {
    actorID = "actor:pending:conversation",
    displayName = "Pending Mara",
    provider = "DTAbstract",
    providerState = "abstract",
    portrait = { actorID = "actor:pending:conversation", face = {} },
}

Events = {
    OnTick = {
        Add = function(callback) tick = callback end,
    },
}

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        Resolve = function(id)
            if ready and id == projection.actorID then
                return projection, {
                    canonicalActorID = projection.actorID,
                }
            end
            return nil, "actor_projection_pending"
        end,
        GetPortraitSpec = function(entry)
            return entry == projection and projection.portrait or nil
        end,
        RequestActorsIfDue = function()
            requestCount = requestCount + 1
            return true
        end,
    }
end

PsychopatzCore = {
    Conversation = {
        Open = function(spec)
            openedSpec = spec
            return { spec = spec }
        end,
    },
}

DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:pending:conversation" then return nil end
            return {
                n = "Pending Caravan",
                ca = {
                    actorID = projection.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                },
            }
        end,
    },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)
local view, reason = Conversation.Open(
    "trader:pending:conversation",
    projection.actorID,
    { mode = "radio", provider = "DTAbstract", providerState = "abstract" }
)
T.falsy(view, "projection-pending open must not fabricate a conversation")
T.equal(reason, "core_actor_projection_pending",
    "projection-pending open returns an explicit resumable state")
T.equal(requestCount, 1,
    "projection-pending open requests a Core snapshot")
T.truthy(tick, "projection-pending open installs one retry hook")

ready = true
tick()
T.truthy(openedSpec,
    "pending conversation resumes when the Core projection becomes available")
T.equal(openedSpec.npcID, projection.actorID,
    "resumed conversation keeps the canonical actor identity")

print("dt_trader_conversation_pending_smoke: PASS")
