require "DT/Common/Config"
require "DT/Common/Tags"
require "DT/V1/Events"
require "DT/Common/Trading/DT_Economy_Common"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.V1 = {}

-- Shortcut to Common Logic
local Common = DynamicTrading.Economy.Common

-- =============================================================================
-- 1. STOCK GENERATOR (Wrapper)
-- =============================================================================
function DynamicTrading.Economy.V1.GenerateStock(archetypeKey)
    local masterList = DynamicTrading.Config.MasterList
    
    local masterCount = 0
    for _ in pairs(masterList) do masterCount = masterCount + 1 end
    print("[DynamicTrading] Economy.GenerateStock: Archetype=" .. tostring(archetypeKey) .. " | MasterList Size=" .. masterCount)

    if masterCount == 0 then 
        print("[DynamicTrading] Error: MasterList is empty. Stock generation aborted.")
        return {} 
    end

    -- A. Load Context
    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetype = DynamicTrading.Archetypes[archetypeKey] or DynamicTrading.Archetypes["General"]
    
    -- B. Prepare Modifiers
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        globalStockMult = 1.0,
        eventInjections = {},
        getVolumeModifier = nil
    }

    if DynamicTrading.Events then
        if DynamicTrading.Events.GetSystemModifier then
            modifiers.globalStockMult = DynamicTrading.Events.GetSystemModifier("globalStock")
        end
        if DynamicTrading.Events.GetInjections then
            modifiers.eventInjections = DynamicTrading.Events.GetInjections()
        end
        if DynamicTrading.Events.GetVolumeModifier then
            modifiers.getVolumeModifier = DynamicTrading.Events.GetVolumeModifier
        end
    end

    -- C. Delegate to Common
    local resultStock = Common.GenerateStock(archetype, masterList, diff, modifiers)

    local finalCount = 0
    for _ in pairs(resultStock) do finalCount = finalCount + 1 end
    print("[DynamicTrading] Economy.GenerateStock: FINISHED. Unique Items Picked: " .. finalCount)

    return resultStock
end

-- =============================================================================
-- 2. BUY PRICE CALCULATOR (Wrapper)
-- =============================================================================
function DynamicTrading.Economy.V1.GetBuyPrice(itemKey, globalHeat)
    local itemData = DynamicTrading.Config.MasterList[itemKey]
    if not itemData then return 1 end
    
    local diff = DynamicTrading.Config.GetDifficultyData()
    
    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        globalHeat = globalHeat,
        getPriceModifier = nil
    }

    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        modifiers.getPriceModifier = DynamicTrading.Events.GetPriceModifier
    end

    return Common.GetBuyPrice(itemKey, itemData, diff, modifiers)
end

-- =============================================================================
-- 3. SELL PRICE CALCULATOR (Wrapper)
-- =============================================================================
function DynamicTrading.Economy.V1.GetSellPrice(itemObj, itemKey, archetypeKey, globalHeat, localDeflationCount)
    local itemData = DynamicTrading.Config.MasterList[itemKey]
    if not itemData then return 0 end

    local diff = DynamicTrading.Config.GetDifficultyData()
    local archetype = DynamicTrading.Archetypes[archetypeKey]

    local modifiers = {
        tagsConfig = DynamicTrading.Config.Tags,
        globalHeat = globalHeat,
        localDeflationCount = localDeflationCount,
        getPriceModifier = nil
    }

    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        modifiers.getPriceModifier = DynamicTrading.Events.GetPriceModifier
    end

    return Common.GetSellPrice(itemKey, itemData, itemObj, diff, archetype, modifiers)
end