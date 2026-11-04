-- Registers Hoomans-specific physical trader capabilities behind DTCommon's
-- adopter-agnostic integration seam.

DTHoomans = DTHoomans or {}

local Integrations = DTCommon and DTCommon.Integrations
    or require "DTCommon/DTCommon_IntegrationRegistry"

local function matches(record)
    if type(record) ~= "table" then return false end
    local ca = record.ca or {}
    if tostring(ca.provider or "") == "DTHoomans" then
        return true
    end
    return record.g ~= nil
        and tostring(record.g) ~= ""
        and (record.p ~= nil or record.l ~= nil)
end

local function resolveBody(record)
    local npcID = record and (record.p or record.l) or nil
    local registry = PNC and PNC.Registry or nil
    if not npcID or not registry then return nil end
    if type(registry.GetLiveZombie) == "function" then
        local ok, body = pcall(registry.GetLiveZombie, npcID)
        if ok and body then return body end
    end
    if type(registry.Get) == "function" then
        local ok, value = pcall(registry.Get, npcID)
        if ok then return value end
    end
    return nil
end

Integrations.RegisterTraderAdapter("DTHoomans", {
    priority = 200,
    matches = matches,
    getCapacity = function(record)
        local caravan = DTHoomans.Caravan
        if not caravan or type(caravan.GetCapacity) ~= "function" then
            return nil
        end
        return caravan.GetCapacity(record)
    end,
    displayName = function(record)
        local caravan = DTHoomans.Caravan
        if not caravan
            or type(caravan.ResolveTraderDisplayName) ~= "function"
        then
            return nil
        end
        return caravan.ResolveTraderDisplayName(record)
    end,
    resolveBody = resolveBody,
    validateAccess = function(player, record, mode)
        if type(DTHoomans.ValidateTraderAccess) ~= "function" then
            return false, "physical_access_unavailable"
        end
        return DTHoomans.ValidateTraderAccess(player, record, mode)
    end,
})

return DTHoomans
