local PriceConfig = DynamicTrading.PriceConfig

function PriceConfig.CreateEmptyData()
    return {
        version = PriceConfig.VERSION,
        updatedAt = 0,
        defaults = {},
        tagMultipliers = {},
        itemOverrides = {}
    }
end

function PriceConfig.EnsureSchema(data)
    if type(data) ~= "table" then
        return PriceConfig.CreateEmptyData()
    end

    if type(data.defaults) ~= "table" then
        data.defaults = {}
    end
    if type(data.tagMultipliers) ~= "table" then
        data.tagMultipliers = {}
    end
    if type(data.itemOverrides) ~= "table" then
        data.itemOverrides = {}
    end

    data.version = tonumber(data.version) or PriceConfig.VERSION
    data.updatedAt = tonumber(data.updatedAt) or 0

    return data
end

function PriceConfig.IsSinglePlayerSession()
    return not isClient() and not isServer()
end

function PriceConfig.HasAdminAccess(player)
    local accessLevel

    if not player or not player.getAccessLevel then
        return false
    end

    accessLevel = player:getAccessLevel()
    return accessLevel and string.lower(tostring(accessLevel)) == "admin"
end

function PriceConfig.CanEdit(player)
    if PriceConfig.IsSinglePlayerSession() then
        return isDebugEnabled()
    end

    return PriceConfig.HasAdminAccess(player)
end

function PriceConfig.CanEditLocalPlayer()
    local player = getPlayer and getPlayer() or nil

    if not player and getSpecificPlayer then
        player = getSpecificPlayer(0)
    end

    return PriceConfig.CanEdit(player)
end
