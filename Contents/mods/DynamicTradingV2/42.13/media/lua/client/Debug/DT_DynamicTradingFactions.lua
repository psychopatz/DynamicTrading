-- ==============================================================================
-- media/lua/client/Debug/DT_DynamicTradingFactions.lua
-- Debug Tool: Faction Management & Simulation Controls
-- Build 42 Compatible.
-- ==============================================================================

-- [[ OPTIMIZATION CHECK ]]
-- If we are not in Debug Mode AND not an Admin, stop reading this file immediately.
-- if not (isDebugEnabled() or (getSpecificPlayer(0) and getSpecificPlayer(0):getAccessLevel() ~= "None")) then return end

require "client/Debug/DT_FactionDebugWindow"

DT_DebugFactions = {}

-- ==========================================================
-- 1. UTILITY: SEND COMMAND TO SERVER
-- ==========================================================
local function SendDebugAction(action, args)
    local payload = args or {}
    payload.action = action
    -- We send this to the "DynamicTrading_V2" module defined in Network Server
    sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", payload)
end

-- ==========================================================
-- 2. ACTION: PRINT DETAILED DATA
-- ==========================================================
-- DEPRECATED: Replaced by DT_FactionDebugWindow

-- ==========================================================
-- 3. CONTEXT MENU BUILDER
-- ==========================================================
DT_DebugFactions.OnFillWorldObjectContextMenu = function(playerNum, context, worldobjects, test)
    local playerObj = getSpecificPlayer(playerNum)
    if not (isDebugEnabled() or playerObj:getAccessLevel() ~= "None") then return end

    local factionData = ModData.get("DynamicTrading_Factions") or {}

    -- Main Debug Entry
    local mainOption = context:addOption("[DEBUG] Dynamic Trading", worldobjects, nil)
    local mainSubMenu = context:getNew(context)
    context:addSubMenu(mainOption, mainSubMenu)

    -- --- SECTION: FACTION GENERATION ---
    local genOption = mainSubMenu:addOption("Factions", worldobjects, nil)
    local genMenu = mainSubMenu:getNew(mainSubMenu)
    mainSubMenu:addSubMenu(genOption, genMenu)

    genMenu:addOption("OPEN FACTION DEBUG WINDOW", worldobjects, function()
        DT_FactionDebugWindow.Open()
    end)

    genMenu:addOption("Create Random Faction", worldobjects, function()
        local testID = "Faction_" .. ZombRand(1000, 9999)
        SendDebugAction("createTestFaction", { targetID = testID })
    end)

    -- --- SECTION: SIMULATION ---
    local simOption = mainSubMenu:addOption("Simulation", worldobjects, nil)
    local simMenu = mainSubMenu:getNew(mainSubMenu)
    mainSubMenu:addSubMenu(simOption, simMenu)

    simMenu:addOption("Force Daily Sim", worldobjects, function()
        SendDebugAction("SimulateDay")
        if HaloTextHelper then
            HaloTextHelper.addText(playerObj, "Simulation Triggered")
        end
    end)

    simMenu:addOption("Wipe Faction ModData", worldobjects, function()
        SendDebugAction("WipeFactions")
    end)
end

Events.OnFillWorldObjectContextMenu.Add(DT_DebugFactions.OnFillWorldObjectContextMenu)

print("DT DEBUG: Debug Faction Menu (Build 42) Fixed and Loaded.")