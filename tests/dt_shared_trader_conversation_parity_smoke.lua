local T = require "tests/support/test"
T.addPackagePaths()

local opened
local projections = {
    ["actor:abstract:conversation"] = {
        actorID = "actor:abstract:conversation",
        displayName = "Abstract Ada",
        provider = "DTAbstract",
        providerState = "abstract",
        factionPresentation = { factionID = "faction:one", glyph = "A" },
        portrait = { actorID = "actor:abstract:conversation", face = {} },
    },
    ["actor:physical:conversation"] = {
        actorID = "actor:physical:conversation",
        displayName = "Physical Bea",
        provider = "DTHoomans",
        providerState = "materialized",
        factionPresentation = { factionID = "faction:two", glyph = "B" },
        portrait = { actorID = "actor:physical:conversation", face = {} },
    },
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        GetActor = function(id) return projections[id] end,
        GetPortraitSpec = function(entry) return entry.portrait end,
    }
end
PsychopatzCore = {
    Conversation = {
        Open = function(spec)
            opened = spec
            return spec
        end,
    },
}
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id == "trader:abstract:conversation" then
                return { n = "Abstract Ada", ca = {
                    actorID = "actor:abstract:conversation",
                    provider = "DTAbstract",
                    providerState = "abstract",
                } }
            end
            if id == "trader:physical:conversation" then
                return { n = "Physical Bea", ca = {
                    actorID = "actor:physical:conversation",
                    provider = "DTHoomans",
                    providerState = "materialized",
                } }
            end
        end,
    },
    Client = { OpenTrader = function() return true end },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)
T.truthy(Conversation, "shared trader conversation module is missing")

local abstract = assert(Conversation.BuildSpec(
    "trader:abstract:conversation", "actor:abstract:conversation", {}))
local physical = assert(Conversation.BuildSpec(
    "trader:physical:conversation", "actor:physical:conversation", {}))
T.equal(abstract.namespace, physical.namespace,
    "provider-specific trader conversation namespaces remain")
T.equal(abstract.nodes.root.choices[1].id, physical.nodes.root.choices[1].id,
    "providers do not share the same trader content definition")
T.falsy(abstract.context.abstractOnly,
    "shared trader content still carries abstract-only policy")
T.falsy(physical.context.abstractOnly,
    "physical trader content unexpectedly carries abstract-only policy")

assert(Conversation.Open(
    "trader:physical:conversation", "actor:physical:conversation", {}))
T.equal(opened.context.provider, "DTHoomans",
    "shared open path lost physical provider context")

print("dt_shared_trader_conversation_parity_smoke: PASS")
