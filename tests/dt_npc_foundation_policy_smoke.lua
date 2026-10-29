local T = require "tests/support/test"

local encoded = {}
package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] = function()
    return {
        encodeItem = function(item, quantity)
            return { fullType = item.fullType, quantity = quantity }
        end,
    }
end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {},
    TraderStock = {},
    TraderSupport = {},
}
DTCommon.TraderSupport.Bounded = function(value, maximum)
    value = tostring(value or "")
    return #value > maximum and string.sub(value, 1, maximum) or value
end
DTCommon.TraderStock.EncodeItem = function(fullType, quantity)
    return { fullType = fullType, quantity = quantity }
end

PsychopatzCore = {
    Actors = {
        Get = function(actorID)
            if actorID ~= "npc:p7:merchant" then return nil end
            return {
                actorId = actorID,
                social = {
                    relationships = {
                        ["player:user:alice"] = {
                            approval = 100, respect = 100,
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

MarketSense = {
    GetPriceDetails = function() return { price = 451 } end,
    GetPriceDetailsForInstance = function() return { price = 451 } end,
}
InventoryItemFactory = {
    CreateItem = function(fullType) return { fullType = fullType } end,
}

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local Stock = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")

local record = {
    b = 500,
    v = 1,
    ca = Policy.New({
        actorID = "npc:p7:merchant",
        relationshipPricing = true,
        restockIntervalHours = 24,
        restockItems = {
            { fullType = "Base.Bandage", quantity = 3 },
        },
    }),
}
local player = {
    getUsername = function() return "alice" end,
}
local context = Policy.PriceContext(record, player)
T.truthy(math.abs(context.relationshipModifier - 0.25) < 0.000001,
    "relationship price modifier is capped")
local buy = Stock.Quote("Base.Bandage", DTCommon.OP_BUY, nil, context)
local sell = Stock.Quote("Base.Bandage", DTCommon.OP_SELL, nil, context)
T.equal(buy.unitPrice, 338, "friendly relationship lowers buy price")
T.equal(sell.unitPrice, 281, "friendly relationship raises sell price")

local available = Policy.IsAvailable(record)
T.truthy(available, "available Core merchant policy")
local unavailable = Policy.SetAvailable(record, false, "journey")
T.equal(unavailable.available, false, "merchant availability state")
local availableAgain = Policy.SetAvailable(record, true)
T.truthy(availableAgain.available, "merchant availability restored")

local stock = { records = {} }
function stock:add(item)
    self.records[#self.records + 1] = item
    return true
end
local restocked, restockReason = Policy.Restock(record, stock, {
    authority = "server",
    atSettlement = true,
    settlementID = "community_p7",
    earned = true,
    now = 24,
})
T.truthy(restocked, restockReason)
T.equal(restocked.added, 3, "earned restock adds policy stock")
T.equal(#stock.records, 1, "restock uses DT stock only")
T.equal(record.ca.restock.nextAt, 48, "restock cooldown persists")
local notDue, notDueReason = Policy.Restock(record, stock, {
    authority = "server", atSettlement = true,
    settlementID = "community_p7", earned = true, now = 30,
})
T.equal(notDue, nil, "restock cooldown enforced")
T.equal(notDueReason, "restock_not_due", "restock cooldown reason")

local visit, visitReason = Policy.MarkVisit(record, {
    authority = "server", atSettlement = true, now = 48,
    settlementID = "community_p7",
    visitID = "journey:p7:arrival",
})
T.truthy(visit, visitReason)
T.equal(visit.visitCount, 1, "settlement visit recorded")
local duplicate, duplicateReason = Policy.MarkVisit(record, {
    authority = "server", atSettlement = true, now = 48,
    settlementID = "community_p7",
    visitID = "journey:p7:arrival",
})
T.equal(duplicate, nil, "arrival visit applied once")
T.equal(duplicateReason, "duplicate_visit", "arrival visit dedupe reason")

T.finish("dt_npc_foundation_policy_smoke")
