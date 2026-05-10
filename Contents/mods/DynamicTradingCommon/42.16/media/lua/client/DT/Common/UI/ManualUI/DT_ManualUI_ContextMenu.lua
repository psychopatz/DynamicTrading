DynamicTrading = DynamicTrading or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {}

DT_ManualContextMenu = DT_ManualContextMenu or {}

local function hasAnyManuals(registry)
    if not registry then
        return false
    end

    for _ in pairs(registry) do
        return true
    end

    return false
end

-- function DT_ManualContextMenu.populate(context)
--     context:addOption("Dynamic Trading Help", nil, function()
--         DynamicTrading.Manuals.Open({ library = true })
--     end)
-- end

-- [...]

-- if not DT_ManualContextMenu._registered then
--     Events.OnFillWorldObjectContextMenu.Add(DT_ManualContextMenu.onFillWorldObjectContextMenu)
--     Events.OnFillInventoryObjectContextMenu.Add(DT_ManualContextMenu.onFillInventoryObjectContextMenu)
--     DT_ManualContextMenu._registered = true
-- end
