-- =============================================================================
-- DYNAMIC TRADING: CORE INITIALIZATION
-- =============================================================================
-- This file ensures the global DynamicTrading table and its core registration
-- functions are defined BEFORE any subdirectory scripts auto-load alphabetically.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = DynamicTrading.Config or {}
DynamicTrading.Config.MasterList = DynamicTrading.Config.MasterList or {} 
DynamicTrading.Config.Tags = DynamicTrading.Config.Tags or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

-- CORE MODULES
require "DT/Common/Quests/DT_QuestManager"
require "DT/Common/Items/DT_QuestItems"


-- 0. CUSTOM SIGNALS
-- Definitions for custom events to handle engine simulation phases.
-- Added to LuaEventManager so other modules can hook via Events.OnDynamicTrading...
if LuaEventManager then
    if not LuaEventManager.OnDynamicTradingDailySimulation then
        LuaEventManager.AddEvent("OnDynamicTradingDailySimulation")
    end
    if not LuaEventManager.OnDynamicTradingHourlyTick then
        LuaEventManager.AddEvent("OnDynamicTradingHourlyTick")
    end
    -- UI & Network Sync Events
    if not LuaEventManager.OnDynamicTradingTraderUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingTraderUpdated")
    end
    if not LuaEventManager.OnDynamicTradingFactionUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingFactionUpdated")
    end
    if not LuaEventManager.OnDynamicTradingStockUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingStockUpdated")
    end
    if not LuaEventManager.OnDynamicTradingTradeCompleted then
        LuaEventManager.AddEvent("OnDynamicTradingTradeCompleted")
    end
end

-- 1. STATIC CONFIGURATION (Commonly referenced)

DynamicTrading.Config.RadioTiers = {
    ["Base.WalkieTalkie1"]          = { power = 0.5, capacity = 1, desc = "Weak Signal (Toy)" },
    ["Base.WalkieTalkieMakeShift"]  = { power = 0.6, capacity = 1, desc = "Weak Signal (Makeshift)" },
    ["Base.WalkieTalkie2"]          = { power = 0.8, capacity = 2, desc = "Average Signal" },
    ["Base.WalkieTalkie3"]          = { power = 1.0, capacity = 3, desc = "Good Signal" },
    ["Base.WalkieTalkie4"]          = { power = 1.2, capacity = 4, desc = "Strong Signal" },
    ["Base.WalkieTalkie5"]          = { power = 1.5, capacity = 5, desc = "Military Grade" },
    ["Base.HamRadioMakeShift"]      = { power = 1.2, capacity = 8, desc = "Stationary (Makeshift)" },
    ["Base.HamRadio1"]              = { power = 1.5, capacity = 12, desc = "Stationary (Premium)" },
    ["Base.HamRadio2"]              = { power = 2.0, capacity = 20, desc = "Stationary (Military)" },
    ["Base.ManPackRadio"]           = { power = 1.5, capacity = 10, desc = "Military Manpack" }
}

-- 2. REGISTRATION API

function DynamicTrading.RegisterTag(tag, data)
    if not tag or not data then return end
    if not data.priceMult then data.priceMult = 1.0 end
    if not data.weight then data.weight = 50 end
    DynamicTrading.Config.Tags[tag] = data
end

function DynamicTrading.RegisterArchetype(id, data)
    if not id or not data then return end
    data.name = data.name or id
    data.allocations = data.allocations or {} 
    data.wants = data.wants or {} 
    data.forbid = data.forbid or {} 
    DynamicTrading.Archetypes[id] = data
end

function DynamicTrading.AddItem(uniqueID, data)
    if not uniqueID or not data then return end
    if not data.basePrice then data.basePrice = 10 end
    if not data.tags then data.tags = { "Misc" } end
    local hasValid = false
    for _, t in ipairs(data.tags) do if t then hasValid = true break end end
    if not hasValid then table.insert(data.tags, "Misc") end
    if not data.stockRange then data.stockRange = {min=1, max=5} end
    DynamicTrading.Config.MasterList[uniqueID] = data
    if isDebugEnabled() then
        print("[DynamicTrading] Registered Item: " .. tostring(uniqueID))
    end
end

function DynamicTrading.GetMasterListCount()
    local count = 0
    if DynamicTrading.Config and DynamicTrading.Config.MasterList then
        for _ in pairs(DynamicTrading.Config.MasterList) do count = count + 1 end
    end
    return count
end

print("[DynamicTrading] Core initialized. Items Registered so far: " .. DynamicTrading.GetMasterListCount())
