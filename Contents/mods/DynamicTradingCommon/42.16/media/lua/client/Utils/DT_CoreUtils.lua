-- =============================================================================
-- DYNAMIC TRADING: CORE UTILITIES
-- =============================================================================
require "Utils/DT_StringUtils"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Utils = DynamicTrading.Utils or {}

--- Checks whether a mod is active.
--- @param modID string
--- @return boolean
function DynamicTrading.Utils.IsModActive(modID)
    if not modID then return false end

    DynamicTrading.Utils._ActiveModCache = DynamicTrading.Utils._ActiveModCache or {}
    local cache = DynamicTrading.Utils._ActiveModCache
    if cache[modID] ~= nil then
        return cache[modID]
    end

    local activated = getActivatedMods and getActivatedMods() or nil
    local isActive = activated and activated.contains and activated:contains(modID) or false
    cache[modID] = isActive
    return isActive
end

--- Returns true when a square can currently supply mains power.
--- Mirrors the indoor hydro fallback used by radio plug-in mods.
--- @param square any
--- @return boolean
function DynamicTrading.Utils.IsWorldSquarePowered(square)
    if not square then return false end
    if square.haveElectricity and square:haveElectricity() then return true end

    local world = getWorld and getWorld() or nil
    if world and world.isHydroPowerOn and world:isHydroPowerOn() then
        if square.isOutside and not square:isOutside() then
            return true
        end
    end

    return false
end

--- Detects support for portable world radios drawing from the grid.
--- Supports Nep Radio Plugs directly and compatible variants that keep the same runtime hook.
--- @return boolean
function DynamicTrading.Utils.SupportsPlugPoweredPortableRadios()
    if DynamicTrading.Utils._PortableGridRadioCompat == true then
        return true
    end

    local supported = DynamicTrading.Utils.IsModActive("NepRadioPlugs")
        or NepRadioPlugs ~= nil
        or (ISRadioWindow and ISRadioWindow.NepPlugItIn ~= nil)

    if supported then
        DynamicTrading.Utils._PortableGridRadioCompat = true
    end

    return supported
end

--- Returns true when a world radio can draw power from the electrical grid.
--- Stationary radios always qualify; portable placed radios require a compatibility mod.
--- @param obj any
--- @param deviceData any
--- @return boolean
function DynamicTrading.Utils.CanWorldRadioUseGridPower(obj, deviceData)
    if not obj or not instanceof(obj, "IsoWaveSignal") then return false end

    local sq = obj:getSquare()
    if not DynamicTrading.Utils.IsWorldSquarePowered(sq) then return false end

    local data = deviceData
    if not data and obj.getDeviceData then
        data = obj:getDeviceData()
    end
    if not data then return false end

    local isPortable = data.getIsPortable and data:getIsPortable() or false
    if not isPortable then
        return true
    end

    return DynamicTrading.Utils.SupportsPlugPoweredPortableRadios()
end

--- Unified radio power resolver for inventory and world radios.
--- World radios are considered operational if they have charge or a valid grid source.
--- @param obj any
--- @param deviceData any
--- @return boolean
function DynamicTrading.Utils.HasOperationalRadioPower(obj, deviceData)
    if not obj then return false end

    local data = deviceData
    if not data and obj.getDeviceData then
        data = obj:getDeviceData()
    end
    if not data or not data:getIsTurnedOn() then return false end

    if instanceof(obj, "IsoWaveSignal") and DynamicTrading.Utils.CanWorldRadioUseGridPower(obj, data) then
        return true
    end

    return data:getPower() > 0.001
end

--- Checks if an interaction with an object (NPC or Radio) is still valid.
--- @param obj any: The object to check (IsoGameCharacter, IsoWaveSignal, or InventoryItem).
--- @param player any: Optional. The player character. Defaults to player 0.
--- @param trader any: Optional. The trader data object.
--- @return boolean: True if valid, false otherwise.
--- @return string|nil: Invalid reason when false.
function DynamicTrading.Utils.CheckInteractionValid(obj, player, trader)
    local liveNpcData = nil
    if obj and instanceof(obj, "IsoGameCharacter") and DTNPC and DTNPC.GetData then
        liveNpcData = DTNPC.GetData(obj)
    end

    -- 0. SIGNAL EXPIRATION CHECK
    local traderForTimer = trader
    if liveNpcData then
        if liveNpcData.status == "Trading" then
            traderForTimer = liveNpcData
        else
            traderForTimer = nil
        end
    end

    if traderForTimer and traderForTimer.returnTime then
        local gt = GameTime:getInstance()
        if traderForTimer.returnTime <= gt:getWorldAgeHours() then
            return false, "trader_return_time_expired"
        end
    end

    if not obj then return true, nil end -- If no object, assume it's a permanent UI (like debug) or not distance-bound
    
    player = player or getSpecificPlayer(0)
    if not player then return false, "missing_player" end

    -- 1. NPC CHARACTER
    if instanceof(obj, "IsoGameCharacter") then
        if obj:isDead() then return false, "npc_dead" end
        if liveNpcData and liveNpcData.state == "Departure" then return false, "npc_departure" end
        -- Distance check for NPCs (4 tiles)
        local dist = IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY())
        if dist > 4.0 then return false, "npc_out_of_range" end
        return true, nil
    end

    -- 2. RADIO DEVICE (In-World or Inventory)
    local deviceData = nil
    if obj.getDeviceData then
        deviceData = obj:getDeviceData()
    end
    
    if not deviceData then return false, "radio_missing_device_data" end
    if not deviceData:getIsTurnedOn() then return false, "radio_powered_off" end

    -- A. In-World Radio
    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false, "world_radio_missing_square" end

        -- Distance check for World Radios (5 tiles)
        local dist = IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY())
        if dist > 5.0 then return false, "world_radio_out_of_range" end

        if not DynamicTrading.Utils.HasOperationalRadioPower(obj, deviceData) then return false, "world_radio_no_power" end

        return true, nil
    end

    -- B. Handheld Radio (Inventory Item)
    -- Check if it's still in player's inventory
    if obj:getContainer() ~= player:getInventory() then return false, "handheld_not_in_inventory" end
    if not DynamicTrading.Utils.HasOperationalRadioPower(obj, deviceData) then return false, "handheld_no_power" end

    return true, nil
end

function DynamicTrading.Utils.IsInteractionValid(obj, player, trader)
    local valid = DynamicTrading.Utils.CheckInteractionValid(obj, player, trader)
    return valid == true
end

--- Resolves a MasterList key from an item's fullType.
--- Caches lookups for speed; safe to use across V1/V2 data providers.
--- @param fullType string
--- @return string|nil
function DynamicTrading.Utils.GetMasterKey(fullType)
    if not fullType then return nil end
    local masterList = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList
    if not masterList then return nil end

    DynamicTrading.Utils._MasterKeyByItem = DynamicTrading.Utils._MasterKeyByItem or {}
    local cache = DynamicTrading.Utils._MasterKeyByItem
    local cached = cache[fullType]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end

    if masterList[fullType] then
        cache[fullType] = fullType
        return fullType
    end

    for k, v in pairs(masterList) do
        if v and v.item == fullType then
            cache[fullType] = k
            return k
        end
    end

    cache[fullType] = false
    return nil
end

DynamicTrading.Log("DTCommons", "Init", "Utils", "Core utility functions registered")
