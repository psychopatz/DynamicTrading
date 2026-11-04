local T = require "tests/support/test"
T.addPackagePaths()

local categories = {}
local blocks = {}
local eligibility = {}
local choiceProviders = {}

PNC = {
    API = {
        Conversations = {
            GetCategory = function(id)
                return categories[id]
            end,
            RegisterCategory = function(id, definition)
                if categories[id] then return false, "duplicate" end
                categories[id] = definition
                categories[id].id = id
                return true, definition
            end,
            GetBlock = function(id)
                return blocks[id]
            end,
            RegisterBlock = function(id, definition)
                if blocks[id] then return false, "duplicate" end
                blocks[id] = definition
                blocks[id].id = id
                return true, definition
            end,
        },
    },
    Conversation = {
        Registry = {
            categoryEligibilityProviders = eligibility,
            RegisterCategoryEligibilityProvider =
                function(id, provider)
                    if eligibility[id] then return false end
                    eligibility[id] = provider
                    return true
                end,
        },
    },
    Semantics = {
        DialogueChoiceRegistry = {
            GetProvider = function(id)
                return choiceProviders[id]
            end,
            RegisterProvider = function(provider)
                choiceProviders[provider.id] = provider
                return true, "registered"
            end,
        },
    },
}

local records = {
    ["trader:abstract"] = {
        ca = {
            actorID = "actor:abstract",
            provider = "DTAbstract",
            providerState = "abstract",
        },
    },
    ["trader:physical"] = {
        ca = {
            actorID = "actor:physical",
            provider = "DTHoomans",
            providerState = "materialized",
        },
        p = "actor:physical",
        l = "actor:physical",
        m = { "guard:one" },
    },
}

DTCommon = {
    TraderService = {
        ForEach = function(callback)
            for id, record in pairs(records) do
                callback(id, record)
            end
        end,
    },
}

local Integration = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_HoomansConversation.lua"
)

local registered, reason = Integration.Register()
T.truthy(registered, reason)
T.equal(
    Integration.TRADE_CATEGORY_ID,
    "projecthoomans:trade",
    "stable Hoomans trade category"
)
T.truthy(categories["projecthoomans:trade"],
    "shared trade category registered")
T.equal(
    categories["projecthoomans:trade"].ownerModID,
    "DTCommon",
    "generic trade category is provider-agnostic"
)
T.truthy(blocks["dtcommon:trade_basic"],
    "shared trade block registered")
T.equal(
    blocks["dtcommon:trade_basic"].category,
    "projecthoomans:trade",
    "shared trade block targets Hoomans trade category"
)
T.truthy(eligibility["dtcommon:trader_role"],
    "shared trade eligibility provider registered")
T.truthy(choiceProviders["dynamictrading.trader"],
    "shared semantic trade choice provider registered")

T.truthy(
    Integration.IsTraderActor("actor:abstract"),
    "abstract Core trader actor recognized"
)
T.truthy(
    Integration.IsTraderActor("actor:physical"),
    "physical Hoomans trader actor recognized"
)
T.falsy(
    Integration.IsTraderActor("guard:one"),
    "guard is not promoted to trader"
)

local provider = choiceProviders["dynamictrading.trader"]
local abstractChoices = provider.collect({
    npcID = "actor:abstract",
    actorConversationContext = {
        actorID = "actor:abstract",
        roles = { trader = true },
    },
})
T.equal(#abstractChoices, 1,
    "abstract trader receives same semantic Trade choice")
T.equal(
    abstractChoices[1].frame.extensions.categoryID,
    "projecthoomans:trade",
    "abstract choice routes through Hoomans category"
)

local physicalChoices = provider.collect({
    npcID = "actor:physical",
    actorConversationContext = {
        actorID = "actor:physical",
        roles = {},
    },
})
T.equal(#physicalChoices, 1,
    "physical trader receives same semantic Trade choice")

local nonTraderChoices = provider.collect({
    npcID = "guard:one",
    actorConversationContext = {
        actorID = "guard:one",
        roles = {},
    },
})
T.equal(#nonTraderChoices, 0,
    "non-trader does not receive Trade choice")

local allowedAbstract, abstractReason =
    eligibility["dtcommon:trader_role"].evaluate(
        { id = "projecthoomans:trade" },
        {
            npcID = "actor:abstract",
            actorConversationContext = {
                actorID = "actor:abstract",
                roles = { trader = true },
            },
        }
    )
T.truthy(allowedAbstract, abstractReason)

local deniedGuard, guardReason =
    eligibility["dtcommon:trader_role"].evaluate(
        { id = "projecthoomans:trade" },
        {
            npcID = "guard:one",
            actorConversationContext = {
                actorID = "guard:one",
                roles = {},
            },
        }
    )
T.falsy(deniedGuard,
    "guard must not pass generic trader eligibility")
T.equal(
    guardReason,
    "dynamictrading_trade_requires_trader",
    "shared trader eligibility reason"
)

local categoryCount = 0
for _ in pairs(categories) do categoryCount = categoryCount + 1 end
local blockCount = 0
for _ in pairs(blocks) do blockCount = blockCount + 1 end
registered, reason = Integration.Register()
T.truthy(registered, reason)
local categoryCountAfter = 0
for _ in pairs(categories) do
    categoryCountAfter = categoryCountAfter + 1
end
local blockCountAfter = 0
for _ in pairs(blocks) do
    blockCountAfter = blockCountAfter + 1
end
T.equal(categoryCountAfter, categoryCount,
    "shared registration is category-idempotent")
T.equal(blockCountAfter, blockCount,
    "shared registration is block-idempotent")

T.finish("dt_hoomans_conversation_parity_smoke")
