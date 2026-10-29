local T = require "tests/support/test"

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end

local markets = {
    farm = {
        revision = 4,
        categories = { Food = { supply = 0.85, demand = 0.25 } },
    },
    military = {
        revision = 8,
        categories = { Food = { supply = 0.35, demand = 0.75 } },
    },
}
local catalogCalls = 0

local function copyMarket(value)
    local categories = {}
    for key, category in pairs(value.categories or {}) do
        categories[key] = {
            supply = category.supply,
            demand = category.demand,
        }
    end
    return { revision = value.revision, categories = categories }
end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    MarketSchema = { MAX_MODIFIERS = 16, MAX_CATEGORIES = 32 },
    SettlementMarket = {
        Get = function(settlementID)
            return markets[settlementID] and copyMarket(markets[settlementID])
                or nil, "market_not_found"
        end,
    },
    MarketCatalog = {
        Get = function(fullType)
            catalogCalls = catalogCalls + 1
            return fullType == "Base.CannedBeans"
                and { fullType = fullType, category = "Food" } or nil
        end,
    },
    TraderSupport = {},
}

MarketSense = {
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}

PsychopatzCore = {
    Actors = {
        Get = function()
            return {
                social = {
                    relationships = {
                        ["player:user:alice"] = {
                            approval = 100,
                            respect = 100,
                            familiarity = 100,
                        },
                    },
                },
            }
        end,
        Social = {
            Get = function(state, target)
                return state.relationships[target]
            end,
        },
    },
}

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local Pricing = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
local Stock = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")

local player = { getUsername = function() return "alice" end }
local record = {
    ca = Policy.New({
        actorID = "npc:merchant",
        lastSettlementID = "farm",
        relationshipPricing = true,
    }),
}

local intrinsic = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY)
T.equal(intrinsic.unitPrice, 100,
    "without settlement context quote stays intrinsic")
T.equal(intrinsic.commercialMargin, 1,
    "buy quote exposes the existing commercial margin")

local farmContext = Pricing.BuildContext(record, nil)
local farmBuy = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    farmContext)
local farmSell = Stock.Quote("Base.CannedBeans", DTCommon.OP_SELL, nil,
    farmContext)
T.equal(farmBuy.unitPrice, 85, "farm surplus lowers buy quote")
T.equal(farmSell.unitPrice, 43, "farm surplus lowers sell quote")
T.equal(farmBuy.marketRevision, 4, "buy quote carries market revision")
T.equal(farmBuy.explanation.marketCategory, "Food",
    "quote explanation carries MarketSense category")
T.truthy(math.abs(farmBuy.explanation.marketModifier + 0.15) < 0.000001,
    "surplus pressure maps to the bounded negative modifier")
T.equal(farmBuy.explanation.commercialBase, 100,
    "buy explanation preserves intrinsic commercial base")
T.equal(farmSell.explanation.commercialBase, 50,
    "sell explanation preserves the half-price commercial base")
T.equal(farmSell.explanation.unitPrice, farmSell.unitPrice,
    "sell explanation matches server unit price")

record.ca.lastSettlementID = "military"
local militaryContext = Pricing.BuildContext(record, nil)
local militaryBuy = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    militaryContext)
local militarySell = Stock.Quote("Base.CannedBeans", DTCommon.OP_SELL, nil,
    militaryContext)
T.equal(militaryBuy.unitPrice, 110, "military shortage raises buy quote")
T.equal(militarySell.unitPrice, 55, "military shortage raises sell quote")
T.truthy(militaryBuy.unitPrice > farmBuy.unitPrice,
    "opposite settlement pressure produces different buy quotes")
T.truthy(militarySell.unitPrice > farmSell.unitPrice,
    "opposite settlement pressure produces different sell quotes")
T.truthy(math.abs(militaryBuy.explanation.priceBeforeRounding - 110)
    < 0.000001, "explanation arithmetic is exact for shortage buy")

local relationship = Pricing.BuildContext(record, player)
local friendly = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    relationship)
T.equal(friendly.unitPrice, 83,
    "relationship bias composes with market pressure")
T.equal(friendly.explanation.relationshipFactor, 0.75,
    "relationship factor remains separately explained")

DTCommon.MarketEvents = {
    ResolveContext = function()
        return {
            revision = 7,
            modifiers = {
                {
                    marketTag = "Food",
                    demandDelta = 0.2,
                    priceMultiplier = 1.1,
                },
            },
        }
    end,
    GetRevision = function() return 7 end,
}
record.ca.lastSettlementID = "farm"
local eventContext = Pricing.BuildContext(record, nil)
local eventQuote = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    eventContext)
T.equal(eventQuote.eventRevision, 7,
    "active event context revision reaches the quote")
T.equal(eventQuote.unitPrice, 99,
    "typed event modifier reacts immediately without changing intrinsic value")
T.equal(eventQuote.intrinsicPrice, 100,
    "event does not replace MarketSense intrinsic valuation")
T.equal(eventQuote.explanation.eventCount, 1,
    "quote explanation identifies applied event modifiers")
T.truthy(Pricing.IsCurrent(eventContext), "current market and event context")

markets.farm.revision = 5
local current, currentReason = Pricing.IsCurrent(eventContext)
T.falsy(current, "market revision invalidates an old quote context")
T.equal(currentReason, "stale_market", "stale market reason is explicit")

DTCommon.MarketEvents = nil
markets.farm.categories.Food = { supply = 0.2, demand = 0.8 }
markets.farm.revision = 6
local reloadedContext = Pricing.BuildContext(record, nil)
local reloadedQuote = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    reloadedContext)
T.equal(reloadedQuote.unitPrice, 115,
    "a reloaded market context reacts immediately to shortage pressure")
T.truthy(Pricing.IsCurrent(reloadedContext),
    "newly reloaded market revision is current")

markets.farm.categories.Food = { supply = 0, demand = 1 }
markets.farm.revision = 7
local boundedContext = Pricing.BuildContext(record, nil)
local boundedQuote = Stock.Quote("Base.CannedBeans", DTCommon.OP_BUY, nil,
    boundedContext)
T.equal(boundedQuote.unitPrice, 125,
    "extreme pressure is clamped to the market modifier bound")
T.truthy(math.abs(boundedQuote.marketModifier - 0.25) < 0.000001,
    "market modifier never exceeds the positive bound")

T.equal(catalogCalls, 7,
    "item taxonomy lookup stays bounded and cached per quote context")
T.finish("dt_market_pricing")
