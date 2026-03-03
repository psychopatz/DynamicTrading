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
    -- 0. SIGNAL EXPIRATION CHECK
    if trader and trader.returnTime then
        local gt = GameTime:getInstance()
        if trader.returnTime <= gt:getWorldAgeHours() then
            return false
        end
    end

    if not obj then return true end -- If no object, assume it's a permanent UI (like debug) or not distance-bound
    
    player = player or getSpecificPlayer(0)
    if not player then return false end

    -- 1. NPC CHARACTER
    if instanceof(obj, "IsoGameCharacter") then
        if obj:isDead() then return false end
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

print("[DynamicTrading] Core utility functions registered.")
