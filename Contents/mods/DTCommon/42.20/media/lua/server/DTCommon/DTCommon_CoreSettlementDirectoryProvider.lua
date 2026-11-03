-- Read-only settlement geography adapter backed by the canonical Core
-- SurvivorWorld. DTCommon owns market/economy state, never settlement identity.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then
    return
end

DTCommon = DTCommon or {}
DTCommon.CoreSettlementDirectoryProvider =
    DTCommon.CoreSettlementDirectoryProvider or {}

local Provider = DTCommon.CoreSettlementDirectoryProvider
local Directory = DTCommon.SettlementDirectory
    or require "DTCommon/DTCommon_SettlementDirectory"
local SurvivorWorld = require
    "PsychopatzCore/SurvivorWorld/PsychopatzSurvivorWorld"

local function descriptor(community)
    if type(community) ~= "table" then return nil end
    local id = tostring(
        community.id or community.communityID or ""
    )
    local home = community.home
    if id == "" or type(home) ~= "table"
        or tonumber(home.x) == nil
        or tonumber(home.y) == nil
    then
        return nil
    end
    return {
        settlementID = id,
        name = tostring(community.name or id),
        position = {
            x = tonumber(home.x),
            y = tonumber(home.y),
            z = tonumber(home.z) or 0,
        },
        provider = "PsychopatzCore",
        profileID = tostring(
            community.profile or "survivor_world"
        ),
        enabled = community.status == nil
            or community.status == "active",
    }
end

function Provider.Registry()
    return SurvivorWorld.GetRuntimeRegistry()
end

function Provider.Get(settlementID)
    local registry = Provider.Registry()
    if not registry then return nil end
    return descriptor(
        registry:GetCommunity(tostring(settlementID or ""))
    )
end

function Provider.List()
    local output = {}
    local registry = Provider.Registry()
    if not registry then return output end
    for _, community in ipairs(
        registry:ListCommunities() or {}
    ) do
        local item = descriptor(community)
        if item and item.enabled ~= false then
            output[#output + 1] = item
        end
    end
    table.sort(output, function(left, right)
        return left.settlementID < right.settlementID
    end)
    return output
end

Directory.RegisterProvider("PsychopatzCore", Provider)

return Provider
