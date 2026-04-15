-- =============================================================================
-- 1. ITEM REGISTRY
-- =============================================================================
DynamicTrading.Config.MasterList = DynamicTrading.Config.MasterList or {}

-- Single Item Adder
function DynamicTrading.AddItem(id, data)
    if not id or not data then 
        DynamicTrading.Log("DTCommons", "Core", "Error", "Invalid item data passed to AddItem")
        return 
    end
    DynamicTrading.Config.MasterList[id] = data
end

-- Batch Item Loader 
function DynamicTrading.RegisterBatch(list)
    if not list then return end
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
    -- Reduced spam: only print batch totals
    DynamicTrading.Log("DTCommons", "Core", "Info", "Item Batch Loaded: " .. #list .. " entries.")
end
