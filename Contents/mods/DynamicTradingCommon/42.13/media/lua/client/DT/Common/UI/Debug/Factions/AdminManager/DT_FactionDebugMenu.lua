-- ==============================================================================
-- DT_FactionDebugMenu.lua
-- Debug Tool: Faction Management Context Menu
-- Build 42 Compatible - Version Agnostic
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugWindow"
-- Merchant window will be loaded when available

DT_FactionDebugMenu = DT_FactionDebugMenu or {}

-- ==========================================================
-- CONTEXT MENU BUILDER
-- ==========================================================
DT_FactionDebugMenu.OnFillWorldObjectContextMenu = function(playerNum, context, worldobjects, test)
    local playerObj = getSpecificPlayer(playerNum)
    -- Only allow Admin access
    if playerObj:getAccessLevel() == "None" then return end

    -- Main Debug Entry
    local mainOption = context:addOption("[Admin] Dynamic Trading", worldobjects, nil)
    local debugMenu = context:getNew(context)
    context:addSubMenu(mainOption, debugMenu)

    -- Faction Debug Tools
    debugMenu:addOption("Faction Manager", worldobjects, function()
        DT_FactionDebugWindow.Open()
    end)

    debugMenu:addOption("Merchant Stock Manager", worldobjects, function()
        if DT_MerchantDebugWindow and DT_MerchantDebugWindow.Open then
            DT_MerchantDebugWindow.Open()
        else
            DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Window not loaded!")
        end
    end)

    -- Separator
    debugMenu:addOption("---", worldobjects, nil)

    -- Quick Actions
    debugMenu:addOption("Create Random Faction", worldobjects, function()
        local testID = "Faction_" .. ZombRand(1000, 9999)
        DT_DebugNetworkAdapter.sendDebugAction("createTestFaction", { targetID = testID })
    end)

    debugMenu:addOption("Force Daily Simulation", worldobjects, function()
        DT_DebugNetworkAdapter.sendDebugAction("SimulateDay")
        if HaloTextHelper then
            HaloTextHelper.addText(playerObj, "Simulation Triggered")
        end
    end)

    debugMenu:addOption("Wipe Faction ModData", worldobjects, function()
        DT_DebugNetworkAdapter.sendDebugAction("WipeFactions")
    end)
end

Events.OnFillWorldObjectContextMenu.Add(DT_FactionDebugMenu.OnFillWorldObjectContextMenu)

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Menu Loaded (Version: " .. DT_DebugNetworkAdapter.getVersion() .. ")")
