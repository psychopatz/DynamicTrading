-- DynamicTrading provider adapter for Core SurvivorWorld debug presence.
-- Core owns the debug authorization/session ledger; DTHoomans delegates the
-- physical trader transition to its existing transactional runtime.

if not PsychopatzCore
    or not PsychopatzCore.RuntimeRole
    or not PsychopatzCore.RuntimeRole.AllowsServerCode()
then
    return
end

local Presence = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldPresence"
local Runtime = DTHoomans and DTHoomans.ProviderRuntime

local function traderForActor(actorID)
    if not DTCommon or not DTCommon.TraderService
        or type(DTCommon.TraderService.ForEach) ~= "function"
    then
        return nil
    end
    local found
    DTCommon.TraderService.ForEach(function(traderID, record)
        if found or type(record) ~= "table" then return end
        local ca = record.ca
        if ca and tostring(ca.actorID or "") == tostring(actorID or "") then
            found = tostring(traderID)
        end
    end)
    return found
end

local function canForceLive(actor)
    return traderForActor(actor and (actor.actorId or actor.actorID)) ~= nil
end

local function forceLive(actor, _, spec)
    if not Runtime or type(Runtime.MaterializeTrader) ~= "function" then
        return nil, "dthoomans_runtime_unavailable"
    end
    local traderID = traderForActor(actor and (actor.actorId or actor.actorID))
    if not traderID then return nil, "dthoomans_trader_not_found" end
    local committed, result = Runtime.MaterializeTrader(traderID, {
        now = spec.now,
        reason = spec.reason or "core_debug_force_live",
    })
    if not committed then return nil, result end
    return {
        actor = committed,
        traderID = traderID,
        body = result and result.body or nil,
        bodyID = result and result.bodyID or nil,
    }
end

local function release(actor, _, spec)
    if not Runtime or type(Runtime.DematerializeTrader) ~= "function" then
        return nil, "dthoomans_runtime_unavailable"
    end
    local traderID = traderForActor(actor and (actor.actorId or actor.actorID))
    if not traderID then return nil, "dthoomans_trader_not_found" end
    local committed, result = Runtime.DematerializeTrader(traderID, {
        now = spec.now,
        reason = spec.reason or "core_debug_force_abstract",
    })
    if not committed then return nil, result end
    return {
        actor = committed,
        traderID = traderID,
        body = result and result.body or nil,
        bodyID = result and result.bodyID or nil,
    }
end

Presence.RegisterProvider("DTHoomans", {
    priority = 200,
    canForceLive = canForceLive,
    forceLive = forceLive,
    release = release,
})

return true
