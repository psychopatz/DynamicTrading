-- ==============================================================================
-- DTNPC_ProtectShared_Loadout.lua
-- Shared loadout condition helpers for DTNPC protect modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getScriptItem = Internal.getScriptItem

local function getConditionMax(fullType)
    local scriptItem = getScriptItem(fullType)
    if scriptItem and scriptItem.getConditionMax then
        local maxCondition = tonumber(scriptItem:getConditionMax()) or 0
        if maxCondition > 0 then
            return math.floor(maxCondition)
        end
    end
    return nil
end

local function createConditionProbeItem(fullType)
    if not fullType or fullType == "" then
        return nil
    end

    if instanceItem then
        return instanceItem(fullType)
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        return InventoryItemFactory.CreateItem(fullType)
    end

    return nil
end

local function normalizeWeaponCondition(loadout, weaponKey, conditionKey, trackCondition)
    local weapon = loadout[weaponKey]
    if not weapon or weapon == "" then
        loadout[conditionKey] = nil
        return
    end

    if not trackCondition then
        loadout[conditionKey] = nil
        return
    end

    local maxCondition = getConditionMax(weapon)
    if not maxCondition then
        loadout[conditionKey] = nil
        return
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition == nil then
        currentCondition = maxCondition
    end

    currentCondition = math.max(0, math.min(maxCondition, math.floor(currentCondition)))
    loadout[conditionKey] = currentCondition
end

Internal.getConditionMax = getConditionMax
Internal.createConditionProbeItem = createConditionProbeItem
Internal.normalizeWeaponCondition = normalizeWeaponCondition
