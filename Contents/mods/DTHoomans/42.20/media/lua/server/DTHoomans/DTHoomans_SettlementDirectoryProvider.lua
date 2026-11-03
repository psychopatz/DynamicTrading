-- Optional Hoomans geography adapter for DTCommon.SettlementDirectory.
-- DTCommon stays PNC-agnostic; DTHoomans owns the integration.

DTHoomans = DTHoomans or {}
DTHoomans.SettlementDirectoryProvider =
    DTHoomans.SettlementDirectoryProvider or {}

local Provider = DTHoomans.SettlementDirectoryProvider

local function descriptor(community)
    if type(community) ~= "table" then return nil end
    local id = tostring(community.id or community.communityID or "")
    local home = community.home
        or (community.site and community.site.home) or nil
    if id == "" or type(home) ~= "table"
        or tonumber(home.x) == nil or tonumber(home.y) == nil
    then
        return nil
    end
    return {
        settlementID = id,
        name = tostring(community.name or community.displayName or id),
        position = {
            x = tonumber(home.x),
            y = tonumber(home.y),
            z = tonumber(home.z) or 0,
        },
        provider = "DTHoomans",
        profileID = "hoomans",
        regionID = community.regionID or community.regionId or community.region,
        enabled = community.status == nil or community.status == "active",
    }
end

function Provider.Get(settlementID)
    if not PNC or not PNC.Communities
        or type(PNC.Communities.Get) ~= "function"
    then
        return nil
    end
    local community = PNC.Communities.Get(tostring(settlementID or ""))
    return descriptor(community)
end

function Provider.List()
    local output = {}
    if not PNC or not PNC.Communities
        or type(PNC.Communities.List) ~= "function"
    then
        return output
    end
    for _, community in ipairs(PNC.Communities.List() or {}) do
        local item = descriptor(community)
        if item and item.enabled ~= false then output[#output + 1] = item end
    end
    table.sort(output, function(left, right)
        return left.settlementID < right.settlementID
    end)
    return output
end

if DTCommon and DTCommon.SettlementDirectory
    and type(DTCommon.SettlementDirectory.RegisterProvider) == "function"
then
    DTCommon.SettlementDirectory.RegisterProvider("DTHoomans", Provider)
end

return Provider
