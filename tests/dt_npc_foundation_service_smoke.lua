local T = require "tests/support/test"

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] =
    function() return {} end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] =
    function() return {} end

local stock = { records = {} }
function stock:add(item)
    self.records[#self.records + 1] = item
    return true
end

local record = {
    s = "AWAY",
    v = 1,
    b = 500,
    ca = {
        actorID = "npc:p7:service",
        restockItems = {
            { fullType = "Base.Bandage", quantity = 2 },
        },
    },
}
local touched = 0
DTCommon = {
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
    Storage = {
        IsAuthority = function() return true end,
        LoadInventory = function() return stock end,
        SaveInventory = function() return true end,
        Touch = function() touched = touched + 1 end,
        Transmit = function() end,
    },
    TraderStock = {
        EncodeItem = function(fullType, quantity)
            return { fullType = fullType, quantity = quantity }
        end,
        SaveAndTransmit = function() end,
    },
    TraderSupport = {},
    TraderService = {},
    DEFAULT_STOCK = {},
}
DTCommon.TraderSupport.Bounded = function(value, maximum)
    value = tostring(value or "")
    return #value > maximum and string.sub(value, 1, maximum) or value
end

PsychopatzCore = {}
T.load("DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
local Service = DTCommon.TraderService
Service.GetRecord = function() return record end
PsychopatzCore.Actors = {
    Get = function(actorID)
        return { actorId = actorID, identity = {}, appearance = {}, world = {} }
    end,
}

local bound, bindReason = Service.BindCoreActor("trader:p7", "npc:p7:service", {
    restockItems = { { fullType = "Base.Bandage", quantity = 2 } },
})
T.truthy(bound, bindReason)
T.equal(record.ca.provider, "DTAbstract", "default abstract provider")
local leaseBound, leaseReason = Service.SetCoreProviderLease("trader:p7", {
    provider = "DTHoomans",
    state = "abstract",
    leaseID = "lease:npc:p7:service",
    revision = 4,
})
T.truthy(leaseBound, leaseReason)
T.equal(record.ca.provider, "DTHoomans", "provider lease provider")
T.equal(record.ca.providerLeaseID, "lease:npc:p7:service",
    "provider lease id")
local visit, visitReason = Service.MarkSettlementVisit("trader:p7", {
    authority = "server",
    atSettlement = true,
    earned = true,
    restock = true,
    now = 24,
    visitID = "journey:p7:service",
})
T.truthy(visit, visitReason)
T.equal(record.s, "READY", "settlement visit makes merchant available")
T.equal(#stock.records, 1, "service restock adds DT stock")
T.equal(record.v, 2, "restock advances stock version")
T.equal(visit.visitCount, 1, "service records one settlement visit")
T.truthy(touched > 0, "service persists policy visit")

local mapRegistry = {
    ProjectActor = function(self, actor, spec)
        return { actorID = actor.actorId, provider = spec.provider,
            capabilities = spec.capabilities }
    end,
}
local mapEntry, mapReason = Service.ProjectCoreMapEntry("trader:p7",
    PsychopatzCore, mapRegistry)
T.truthy(mapEntry, mapReason)
T.equal(mapEntry.provider, "DynamicTrading", "DT map provider projection")
T.equal(mapEntry.capabilities.trade, true, "DT trade capability projection")

local duplicate, duplicateReason = Service.MarkSettlementVisit("trader:p7", {
    authority = "server", atSettlement = true, earned = true,
    visitID = "journey:p7:service", now = 24,
})
T.equal(duplicate, nil, "service rejects duplicate arrival")
T.equal(duplicateReason, "duplicate_visit", "service arrival dedupe reason")

local available, availabilityReason = Service.SetCoreActorAvailability(
    "trader:p7", false, "journey")
T.truthy(available, availabilityReason)
local unavailable, unavailableReason = Service.Snapshot("trader:p7", {
    getUsername = function() return "alice" end,
})
T.equal(unavailable, nil, "unavailable Core merchant snapshot rejected")
T.equal(unavailableReason, "journey", "availability reason preserved")

T.finish("dt_npc_foundation_service_smoke")
