local PriceConfig = DynamicTrading.PriceConfig
local Internal = DT_PriceConfigInternal

function PriceConfig.GetData()
    local data = ModData.get(PriceConfig.MOD_DATA_KEY)

    if type(data) ~= "table" then
        return PriceConfig.CreateEmptyData()
    end

    return PriceConfig.EnsureSchema(data)
end

function PriceConfig.BuildSyncPayload(data)
    local source = PriceConfig.EnsureSchema(data or PriceConfig.GetData())

    return {
        version = source.version,
        updatedAt = source.updatedAt,
        defaults = Internal.CloneMap(source.defaults),
        tagMultipliers = Internal.CloneMap(source.tagMultipliers),
        itemOverrides = Internal.CloneMap(source.itemOverrides)
    }
end

function PriceConfig.Touch(data)
    local target = PriceConfig.EnsureSchema(data or PriceConfig.GetData())

    target.version = PriceConfig.VERSION
    if getGameTime and getGameTime() then
        target.updatedAt = math.floor(getGameTime():getWorldAgeHours() or 0)
    else
        target.updatedAt = target.updatedAt or 0
    end

    return target
end

function PriceConfig.SeedDefaults(data)
    local changed = false
    local target = PriceConfig.EnsureSchema(data or PriceConfig.GetData())

    for itemKey, itemData in pairs((DynamicTrading.Config and DynamicTrading.Config.MasterList) or {}) do
        if target.defaults[itemKey] == nil then
            target.defaults[itemKey] = Internal.RoundPrice(itemData.basePrice) or 0
            changed = true
        end
    end

    return changed
end

function PriceConfig.Init()
    local data
    local changed = false

    if isClient() and not isServer() then
        if ModData.request then
            ModData.request(PriceConfig.MOD_DATA_KEY)
        end
        return
    end

    data = ModData.get(PriceConfig.MOD_DATA_KEY)
    if type(data) ~= "table" then
        data = PriceConfig.CreateEmptyData()
        ModData.add(PriceConfig.MOD_DATA_KEY, data)
        changed = true
    end

    data = PriceConfig.EnsureSchema(data)
    if PriceConfig.SeedDefaults(data) then
        changed = true
    end

    if changed then
        PriceConfig.Touch(data)
        ModData.transmit(PriceConfig.MOD_DATA_KEY)
    end
end

function PriceConfig.HandleSyncPayload(payload)
    local copy

    if type(payload) ~= "table" then
        return
    end

    copy = PriceConfig.BuildSyncPayload(payload)
    ModData.add(PriceConfig.MOD_DATA_KEY, copy)
    Internal.TriggerPriceConfigUpdated()
end

function PriceConfig.RequestSync()
    if ModData.request then
        ModData.request(PriceConfig.MOD_DATA_KEY)
    end

    if isClient() and not isServer() then
        local player = getPlayer and getPlayer() or nil

        if player then
            sendClientCommand(player, "DynamicTrading", "RequestPriceConfig", {})
        end
    end
end
