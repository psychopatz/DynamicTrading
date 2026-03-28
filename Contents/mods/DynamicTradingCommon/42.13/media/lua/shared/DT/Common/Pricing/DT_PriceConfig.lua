-- =============================================================================
-- DYNAMIC TRADING: SHARED PRICE CONFIG
-- =============================================================================
-- Server-authoritative pricing overrides with client sync helpers.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.PriceConfig = DynamicTrading.PriceConfig or {}

local PriceConfig = DynamicTrading.PriceConfig

PriceConfig.MOD_DATA_KEY = "DynamicTrading_PriceConfig"
PriceConfig.VERSION = 1

local function trim(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function roundPrice(value)
    local number = tonumber(value)
    if not number then
        return nil
    end

    if number < 0 then
        number = 0
    end

    return math.floor(number + 0.5)
end

local function normalizeMultiplier(value)
    local number = tonumber(value)
    if not number then
        return nil
    end

    if number < 0 then
        number = 0
    elseif number > 100 then
        number = 100
    end

    return math.floor((number * 1000) + 0.5) / 1000
end

local function cloneMap(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function triggerPriceConfigUpdated()
    if LuaEventManager and LuaEventManager.OnDynamicTradingPriceConfigUpdated then
        triggerEvent("OnDynamicTradingPriceConfigUpdated")
    end
end

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
    if not player or not player.getAccessLevel then
        return false
    end

    local accessLevel = player:getAccessLevel()
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
        defaults = cloneMap(source.defaults),
        tagMultipliers = cloneMap(source.tagMultipliers),
        itemOverrides = cloneMap(source.itemOverrides)
    }
end

function PriceConfig.NormalizeTag(tag)
    local normalized = trim(tag)
    if normalized == "" then
        return nil
    end
    return normalized
end

function PriceConfig.HasKnownItem(itemKey)
    return itemKey and DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList
        and DynamicTrading.Config.MasterList[itemKey] ~= nil
end

function PriceConfig.GetKnownTags()
    local tags = {}

    for tag in pairs((DynamicTrading.Config and DynamicTrading.Config.Tags) or {}) do
        tags[tag] = true
    end

    for _, itemData in pairs((DynamicTrading.Config and DynamicTrading.Config.MasterList) or {}) do
        for _, tag in ipairs(itemData.tags or {}) do
            local probe = tag
            while probe do
                tags[probe] = true
                probe = string.match(probe, "^(.*)%.")
            end
        end
    end

    return tags
end

function PriceConfig.HasKnownTag(tag)
    local normalized = PriceConfig.NormalizeTag(tag)
    if not normalized then
        return false
    end

    return PriceConfig.GetKnownTags()[normalized] == true
end

function PriceConfig.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then
        return false
    end

    return itemTag == queryTag or string.sub(itemTag, 1, #queryTag + 1) == (queryTag .. ".")
end

function PriceConfig.ItemMatchesTag(itemData, queryTag)
    for _, itemTag in ipairs(itemData and itemData.tags or {}) do
        if PriceConfig.TagMatches(itemTag, queryTag) then
            return true
        end
    end
    return false
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
            target.defaults[itemKey] = roundPrice(itemData.basePrice) or 0
            changed = true
        end
    end

    return changed
end

function PriceConfig.Init()
    if isClient() and not isServer() then
        if ModData.request then
            ModData.request(PriceConfig.MOD_DATA_KEY)
        end
        return
    end

    local data = ModData.get(PriceConfig.MOD_DATA_KEY)
    local changed = false

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
    if type(payload) ~= "table" then
        return
    end

    local copy = PriceConfig.BuildSyncPayload(payload)
    ModData.add(PriceConfig.MOD_DATA_KEY, copy)
    triggerPriceConfigUpdated()
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

function PriceConfig.GetDefaultBasePrice(itemKey, itemData)
    local data = PriceConfig.GetData()
    if itemKey and data.defaults[itemKey] ~= nil then
        return roundPrice(data.defaults[itemKey]) or 0
    end
    return roundPrice(itemData and itemData.basePrice) or 0
end

function PriceConfig.GetBranchMultiplierForTag(tag, data)
    local normalized = PriceConfig.NormalizeTag(tag)
    local source = PriceConfig.EnsureSchema(data or PriceConfig.GetData())
    local multiplier = 1.0
    local probe = normalized
    local found = false

    while probe do
        local override = source.tagMultipliers[probe]
        if override ~= nil then
            local normalizedValue = normalizeMultiplier(override)
            if normalizedValue then
                multiplier = multiplier * normalizedValue
                found = true
            end
        end
        probe = string.match(probe, "^(.*)%.")
    end

    if not found then
        return 1.0, false
    end

    return multiplier, true
end

function PriceConfig.GetBestBranchMultiplier(itemTags, data)
    local best = 1.0
    local foundAny = false

    for _, tag in ipairs(itemTags or {}) do
        local branch, found = PriceConfig.GetBranchMultiplierForTag(tag, data)
        if found and (not foundAny or branch > best) then
            best = branch
            foundAny = true
        end
    end

    if not foundAny then
        return 1.0
    end

    return best
end

function PriceConfig.GetEffectiveBasePrice(itemKey, itemData, data)
    local source = PriceConfig.EnsureSchema(data or PriceConfig.GetData())
    local defaultBase = PriceConfig.GetDefaultBasePrice(itemKey, itemData)

    if itemKey and source.itemOverrides[itemKey] ~= nil then
        return roundPrice(source.itemOverrides[itemKey]) or defaultBase
    end

    local branchMultiplier = PriceConfig.GetBestBranchMultiplier(itemData and itemData.tags or nil, source)
    return math.max(0, math.floor((defaultBase * branchMultiplier) + 0.5))
end

function PriceConfig.SanitizePresetPayload(payload)
    local sanitized = {
        tagMultipliers = {},
        itemOverrides = {}
    }
    local warnings = {}

    for tag, value in pairs(payload and payload.tagMultipliers or {}) do
        local normalizedTag = PriceConfig.NormalizeTag(tag)
        local normalizedValue = normalizeMultiplier(value)

        if normalizedTag and normalizedValue ~= nil and PriceConfig.HasKnownTag(normalizedTag) then
            if math.abs(normalizedValue - 1.0) > 0.0001 then
                sanitized.tagMultipliers[normalizedTag] = normalizedValue
            end
        else
            warnings[#warnings + 1] = "Skipped tag override: " .. tostring(tag)
        end
    end

    for itemKey, value in pairs(payload and payload.itemOverrides or {}) do
        local normalizedKey = trim(itemKey)
        local normalizedValue = roundPrice(value)

        if normalizedKey ~= "" and normalizedValue ~= nil and PriceConfig.HasKnownItem(normalizedKey) then
            sanitized.itemOverrides[normalizedKey] = normalizedValue
        else
            warnings[#warnings + 1] = "Skipped item override: " .. tostring(itemKey)
        end
    end

    return sanitized, warnings
end

function PriceConfig.SetTagMultiplier(tag, value)
    local normalizedTag = PriceConfig.NormalizeTag(tag)
    local normalizedValue = normalizeMultiplier(value)
    if not normalizedTag or normalizedValue == nil then
        return false, "Invalid tag multiplier."
    end
    if not PriceConfig.HasKnownTag(normalizedTag) then
        return false, "Unknown tag."
    end

    local data = PriceConfig.GetData()
    if math.abs(normalizedValue - 1.0) <= 0.0001 then
        data.tagMultipliers[normalizedTag] = nil
    else
        data.tagMultipliers[normalizedTag] = normalizedValue
    end

    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetTagMultiplier(tag)
    local normalizedTag = PriceConfig.NormalizeTag(tag)
    if not normalizedTag then
        return false, "Invalid tag."
    end

    local data = PriceConfig.GetData()
    data.tagMultipliers[normalizedTag] = nil
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.SetItemOverride(itemKey, value)
    local normalizedKey = trim(itemKey)
    local normalizedValue = roundPrice(value)
    if normalizedKey == "" or normalizedValue == nil then
        return false, "Invalid item override."
    end
    if not PriceConfig.HasKnownItem(normalizedKey) then
        return false, "Unknown item."
    end

    local data = PriceConfig.GetData()
    data.itemOverrides[normalizedKey] = normalizedValue
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetItemOverride(itemKey)
    local normalizedKey = trim(itemKey)
    if normalizedKey == "" then
        return false, "Invalid item."
    end

    local data = PriceConfig.GetData()
    data.itemOverrides[normalizedKey] = nil
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ResetAllOverrides()
    local data = PriceConfig.GetData()
    data.tagMultipliers = {}
    data.itemOverrides = {}
    if PriceConfig.SeedDefaults(data) then
        -- Keep defaults current when resetting after content updates.
    end
    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true
end

function PriceConfig.ReplaceFromPreset(payload)
    local sanitized, warnings = PriceConfig.SanitizePresetPayload(payload)
    local data = PriceConfig.GetData()

    data.tagMultipliers = sanitized.tagMultipliers
    data.itemOverrides = sanitized.itemOverrides
    if PriceConfig.SeedDefaults(data) then
        -- Defaults are always server-owned.
    end

    PriceConfig.Touch(data)
    ModData.transmit(PriceConfig.MOD_DATA_KEY)
    return true, warnings
end

local function onReceiveGlobalModData(key, data)
    if key ~= PriceConfig.MOD_DATA_KEY or type(data) ~= "table" then
        return
    end

    PriceConfig.HandleSyncPayload(data)
end

local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading" then
        return
    end

    if command == "SyncPriceConfig" and type(args) == "table" then
        PriceConfig.HandleSyncPayload(args)
    elseif command == "PriceConfigActionResult" then
        if LuaEventManager and LuaEventManager.OnDynamicTradingPriceConfigActionResult then
            triggerEvent("OnDynamicTradingPriceConfigActionResult", args or {})
        end
    end
end

Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
Events.OnServerCommand.Add(onServerCommand)
Events.OnInitGlobalModData.Add(PriceConfig.Init)

return PriceConfig
