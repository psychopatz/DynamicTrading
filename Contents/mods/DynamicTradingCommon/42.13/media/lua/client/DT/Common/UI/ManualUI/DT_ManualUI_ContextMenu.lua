require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

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

local function addManualEntries(context)
    local registry = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}
    local ordered = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Order or {}

    for _, manualId in ipairs(ordered) do
        local manual = registry[manualId]
        if manual then
            context:addOption("Manual: " .. tostring(manual.title or manual.id), nil, function()
                DynamicTrading.Manuals.Open({ manualId = manual.id })
            end)
        end
    end
end

function DT_ManualContextMenu.populate(context)
    context:addOption("Dynamic Trading Help", nil, function()
        DynamicTrading.Manuals.Open({ library = true })
    end)

    local saved = DT_ManualUI_Utils.getSavedLocation()
    if saved and saved.manualId then
        context:addOption("Resume Dynamic Trading Manual", nil, function()
            DynamicTrading.Manuals.Open(saved)
        end)
    end

    local registry = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}
    if hasAnyManuals(registry) then
        addManualEntries(context)
    end
end

function DT_ManualContextMenu.addRootMenu(context)
    local registry = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}
    if not hasAnyManuals(registry) then
        return
    end

    DT_ManualContextMenu.populate(context)
end

function DT_ManualContextMenu.onFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test and ISWorldObjectContextMenu and ISWorldObjectContextMenu.Test then
        return true
    end

    local playerObj = getSpecificPlayer(playerNum)
    if not playerObj then
        return
    end

    DT_ManualContextMenu.addRootMenu(context)
end

function DT_ManualContextMenu.onFillInventoryObjectContextMenu(playerNum, context, items)
    local playerObj = getSpecificPlayer(playerNum)
    if not playerObj then
        return
    end

    DT_ManualContextMenu.addRootMenu(context)
end

if not DT_ManualContextMenu._registered then
    Events.OnFillWorldObjectContextMenu.Add(DT_ManualContextMenu.onFillWorldObjectContextMenu)
    Events.OnFillInventoryObjectContextMenu.Add(DT_ManualContextMenu.onFillInventoryObjectContextMenu)
    DT_ManualContextMenu._registered = true
end
