-- ==============================================================================
-- DT_PlayerModDataDebugMenu.lua
-- Context menu entry for browsing local player ModData
-- ==============================================================================

require "DT/Common/UI/Debug/DT_PlayerModDataDebugWindow"

local function canUseDebugMenu(playerObj)
    if not playerObj then
        return false
    end

    if isDebugEnabled() then
        return true
    end

    if not playerObj.getAccessLevel then
        return false
    end

    return tostring(playerObj:getAccessLevel() or "None") ~= "None"
end

local function onFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    local playerObj = getSpecificPlayer(playerNum)
    if not canUseDebugMenu(playerObj) then
        return
    end

    local mainOption = context:addOption("[Debug] Dynamic Trading", worldobjects, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(mainOption, subMenu)

    subMenu:addOption("Player ModData Browser", worldobjects, function()
        DT_PlayerModDataDebugWindow.Open()
    end)
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
