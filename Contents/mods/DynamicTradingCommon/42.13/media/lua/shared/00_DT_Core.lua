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
DynamicTrading.Config.NPCMovement = DynamicTrading.Config.NPCMovement or {
    walkSpeed = 0.06,
    runSpeed = 0.09
}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {
    Registry = {},
    Order = {}
}

-- CORE MODULES
require "DT/Common/DT_Logger"
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

function DynamicTrading.GetNPCWalkSpeed()
    local movement = DynamicTrading.Config and DynamicTrading.Config.NPCMovement
    return (movement and movement.walkSpeed) or 0.06
end

function DynamicTrading.GetNPCRunSpeed()
    local movement = DynamicTrading.Config and DynamicTrading.Config.NPCMovement
    return (movement and movement.runSpeed) or 0.09
end

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
        DynamicTrading.Log("DTCommons", "Init", "Item", "Registered Item: " .. tostring(uniqueID))
    end
end

function DynamicTrading.RegisterManual(id, data)
    if not id or type(data) ~= "table" then
        return
    end

    local chapters = {}
    for _, chapter in ipairs(type(data.chapters) == "table" and data.chapters or {}) do
        table.insert(chapters, {
            id = chapter.id,
            title = chapter.title,
            description = chapter.description,
        })
    end

    local pages = {}
    for _, page in ipairs(type(data.pages) == "table" and data.pages or {}) do
        local blocks = {}
        for _, block in ipairs(type(page.blocks) == "table" and page.blocks or {}) do
            table.insert(blocks, block)
        end

        table.insert(pages, {
            id = page.id,
            chapterId = page.chapterId or page.chapter_id,
            title = page.title,
            keywords = type(page.keywords) == "table" and page.keywords or {},
            blocks = blocks,
        })
    end

    local manual = {
        id = tostring(id),
        title = tostring(data.title or id),
        description = tostring(data.description or ""),
        icon = data.icon,
        startPageId = data.startPageId or data.start_page_id,
        chapters = chapters,
        pages = pages,
        source = data.source,
    }

    DynamicTrading.Manuals.Registry[id] = manual

    local alreadyTracked = false
    for _, existingId in ipairs(DynamicTrading.Manuals.Order) do
        if existingId == id then
            alreadyTracked = true
            break
        end
    end

    if not alreadyTracked then
        table.insert(DynamicTrading.Manuals.Order, id)
    end
end

function DynamicTrading.GetMasterListCount()
    local count = 0
    if DynamicTrading.Config and DynamicTrading.Config.MasterList then
        for _ in pairs(DynamicTrading.Config.MasterList) do count = count + 1 end
    end
    return count
end

DynamicTrading.Log("DTCommons", "Init", "Core", "Core initialized. Items Registered so far: " .. DynamicTrading.GetMasterListCount())
