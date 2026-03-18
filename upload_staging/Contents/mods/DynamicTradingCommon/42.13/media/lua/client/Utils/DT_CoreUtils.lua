-- =============================================================================
-- DYNAMIC TRADING: CORE UTILITIES
-- =============================================================================
require "Utils/DT_StringUtils"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Utils = DynamicTrading.Utils or {}

--- Checks if an interaction with an object (NPC or Radio) is still valid.
--- @param obj any: The object to check (IsoGameCharacter, IsoWaveSignal, or InventoryItem).
--- @param player any: Optional. The player character. Defaults to player 0.
--- @param trader any: Optional. The trader data object.
--- @return boolean: True if valid, false otherwise.
function DynamicTrading.Utils.IsInteractionValid(obj, player, trader)
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
            return false
        end
    end

    if not obj then return true end -- If no object, assume it's a permanent UI (like debug) or not distance-bound
    
    player = player or getSpecificPlayer(0)
    if not player then return false end

    -- 1. NPC CHARACTER
    if instanceof(obj, "IsoGameCharacter") then
        if obj:isDead() then return false end
        if liveNpcData and liveNpcData.state == "Departure" then return false end
        -- Distance check for NPCs (4 tiles)
        local dist = IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY())
        if dist > 4.0 then return false end
        return true
    end

    -- 2. RADIO DEVICE (In-World or Inventory)
    local deviceData = nil
    if obj.getDeviceData then
        deviceData = obj:getDeviceData()
    end
    
    if not deviceData or not deviceData:getIsTurnedOn() then return false end

    -- A. In-World Radio
    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        
        -- Distance check for World Radios (5 tiles)
        local dist = IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY())
        if dist > 5.0 then return false end
        
        -- Power check
        if deviceData:getIsBatteryPowered() and deviceData:getPower() <= 0 then return false end
        if not deviceData:getIsBatteryPowered() and not sq:haveElectricity() then return false end
        
        return true
    end

    -- B. Handheld Radio (Inventory Item)
    -- Check if it's still in player's inventory
    if obj:getContainer() ~= player:getInventory() then return false end
    -- Power check
    if deviceData:getPower() <= 0.001 then return false end

    return true
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
