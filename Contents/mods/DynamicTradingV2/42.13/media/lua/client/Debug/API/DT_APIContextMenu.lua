-- ==============================================================================
-- DT_APIContextMenu.lua
-- Standalone Context Menu for Engine API Tools.
-- Build 42 Compatible.
-- ==============================================================================

if not isDebugEnabled() then return end

require "Debug/API/DT_APIBrowser"

DT_APIMenu = DT_APIMenu or {}

function DT_APIMenu.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    -- print("DT_APIMenu.OnFillWorldObjectContextMenu called")
    -- Add a standalone option to the bottom of the context menu
    context:addOption("[DEBUG] Engine API Browser", nil, DT_APIBrowser.OnOpenWindow)
end

Events.OnFillWorldObjectContextMenu.Add(DT_APIMenu.OnFillWorldObjectContextMenu)
