-- ==============================================================================
-- DT_FactionDebugMenu.lua
-- Debug Tool: Faction Management Context Menu
-- Build 42 Compatible - Version Agnostic
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugWindow"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_ColonyArchiveDebugWindow"
require "DT/Common/UI/Debug/DT_PlayerModDataDebugWindow"
-- Merchant window will be loaded when available

DT_FactionDebugMenu = DT_FactionDebugMenu or {}

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    if activated and activated.contains and activated:contains("DynamicColonies") then
        return true
    end
    return rawget(_G, "DC_Colony") ~= nil
end

local function hasAdminAccess(playerObj)
    if not playerObj or not playerObj.getAccessLevel then
        return false
    end

    local accessLevel = playerObj:getAccessLevel()
    return accessLevel and string.lower(tostring(accessLevel)) == "admin"
end

local function isSinglePlayerSession()
    return not isClient() and not isServer()
end

local function canOpenDynamicTradingDebugMenu(playerObj)
    if isSinglePlayerSession() then
        return isDebugEnabled()
    end

    return hasAdminAccess(playerObj)
end

-- ==========================================================
-- CONTEXT MENU BUILDER
-- ==========================================================
DT_FactionDebugMenu.OnFillWorldObjectContextMenu = function(playerNum, context, worldobjects, test)
    local playerObj = getSpecificPlayer(playerNum)
    if not canOpenDynamicTradingDebugMenu(playerObj) then return end

    local menuLabel = isSinglePlayerSession() and "[Debug] Dynamic Trading" or "[Admin] Dynamic Trading"

    -- Main Debug Entry
    local mainOption = context:addOption(menuLabel, worldobjects, nil)
    local debugMenu = context:getNew(context)
    context:addSubMenu(mainOption, debugMenu)

    -- Faction Debug Tools
    debugMenu:addOption("Faction Manager", worldobjects, function()
        DT_FactionDebugWindow.Open()
    end)

    if isDynamicColoniesActive() then
        debugMenu:addOption("Colony Archive Manager", worldobjects, function()
            DT_ColonyArchiveDebugWindow.Open()
        end)
    end

    debugMenu:addOption("Merchant Stock Manager", worldobjects, function()
        if DT_MerchantDebugWindow and DT_MerchantDebugWindow.Open then
            DT_MerchantDebugWindow.Open()
        else
            DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Window not loaded!")
        end
    end)

    debugMenu:addOption("Player ModData Browser", worldobjects, function()
        DT_PlayerModDataDebugWindow.Open()
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
