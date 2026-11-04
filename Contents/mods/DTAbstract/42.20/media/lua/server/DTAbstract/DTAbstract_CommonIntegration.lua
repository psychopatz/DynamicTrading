-- Registers DTAbstract's provider-neutral physical contact authorization.
-- DTCommon owns the access gate; this adapter supplies only the canonical
-- Core position proof for a nearby bodyless trader.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

DTAbstract = DTAbstract or {}

local Integrations = DTCommon and DTCommon.Integrations
    or require "DTCommon/DTCommon_IntegrationRegistry"
local Provider = DTAbstract.TraderWorldProvider
    or require "DTAbstract/DTAbstract_TraderWorldProvider"

local function matches(record)
    local ca = record and record.ca or nil
    return tostring(ca and ca.provider or "") == "DTAbstract"
end

local function coordinate(value, method)
    if value and type(value[method]) == "function" then
        local ok, result = pcall(value[method], value)
        if ok and tonumber(result) ~= nil then
            return tonumber(result)
        end
    end
    local field = method == "getX" and "x" or "y"
    if type(value) == "table" and tonumber(value[field]) ~= nil then
        return tonumber(value[field])
    end
    return nil
end

local function validateAccess(player, record, mode)
    if tostring(mode or "") ~= "nearby" then
        return false, "merchant_not_present"
    end
    if not player or type(Provider.getPosition) ~= "function" then
        return false, "merchant_position_unavailable"
    end

    local position, positionReason = Provider.getPosition(
        nil,
        record
    )
    if not position then
        return false, positionReason or "merchant_position_unavailable"
    end

    local px = coordinate(player, "getX")
    local py = coordinate(player, "getY")
    local nx = tonumber(position.x)
    local ny = tonumber(position.y)
    if not px or not py or not nx or not ny then
        return false, "merchant_position_unavailable"
    end

    local dx = px - nx
    local dy = py - ny
    local radius = tonumber(Provider.NEARBY_TALK_RADIUS) or 60
    if dx * dx + dy * dy <= radius * radius then
        return true
    end
    return false, "access_denied"
end

Integrations.RegisterTraderAdapter("DTAbstract", {
    priority = 100,
    matches = matches,
    validateAccess = validateAccess,
})

return DTAbstract
