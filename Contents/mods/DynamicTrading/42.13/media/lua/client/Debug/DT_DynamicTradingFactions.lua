-- ==============================================================================
-- media/lua/client/Debug/DT_DynamicTradingFactions.lua
-- Debug Tool: Faction Management & Simulation Controls
-- Build 42 Compatible.
-- ==============================================================================

-- [[ OPTIMIZATION CHECK ]]
-- If we are not in Debug Mode, stop reading this file immediately.
if not isDebugEnabled() then return end

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
local function Debug_PrintFactionInfo(factionID)
    local allFactions = ModData.get("DynamicTrading_Factions")
    local f = allFactions and allFactions[factionID]
    
    if not f then 
        print("DT DEBUG: Faction " .. tostring(factionID) .. " not found in ModData.")
        return 
    end

    print("-----------------------------------------")
    print("DT FACTION REPORT: " .. tostring(factionID))
    print("  Name: " .. tostring(f.name))
    print("  State: " .. tostring(f.state))
    print("  Members: " .. tostring(f.memberCount))
    
    if f.homeCoords then
        print("  Base: " .. tostring(f.homeCoords.name))
        print("  Town: " .. tostring(f.homeCoords.town))
        print("  Coords: " .. f.homeCoords.x .. ", " .. f.homeCoords.y .. ", " .. f.homeCoords.z)
    else
        print("  Base: NOMADIC (No Physical Home)")
    end

    print("  STOCKPILE:")
    if f.stockpile then
        for resource, amount in pairs(f.stockpile) do
            print("    - " .. resource .. ": " .. amount)
        end
    end
    print("-----------------------------------------")
    
    -- B42 FIXED SYNTAX: Simple text helper
    local player = getPlayer()
    if HaloTextHelper then
        -- In B42, addText(player, text) is the safest baseline.
        -- If you want color/arrows, use addTextWithArrow(player, text, bSuccess, color)
        HaloTextHelper.addText(player, "Data Printed to Console (F11)")
    end
end

-- ==========================================================
-- 3. CONTEXT MENU BUILDER
-- ==========================================================
DT_DebugFactions.OnFillWorldObjectContextMenu = function(playerNum, context, worldobjects, test)
    if not isDebugEnabled() then return end

    local playerObj = getSpecificPlayer(playerNum)
    local factionData = ModData.get("DynamicTrading_Factions") or {}

    -- Main Debug Entry
    local mainOption = context:addOption("[DEBUG] Dynamic Trading", worldobjects, nil)
    local mainSubMenu = context:getNew(context)
    context:addSubMenu(mainOption, mainSubMenu)

    -- --- SECTION: FACTION GENERATION ---
    local genOption = mainSubMenu:addOption("Factions", worldobjects, nil)
    local genMenu = mainSubMenu:getNew(mainSubMenu)
    mainSubMenu:addSubMenu(genOption, genMenu)

    genMenu:addOption("Create Random Faction", worldobjects, function()
        local testID = "Faction_" .. ZombRand(1000, 9999)
        SendDebugAction("createTestFaction", { targetID = testID })
    end)

    -- --- SECTION: LIST & INSPECT ---
    local listOption = genMenu:addOption("Inspect Existing...", worldobjects, nil)
    local listMenu = genMenu:getNew(genMenu)
    genMenu:addSubMenu(listOption, listMenu)

    local count = 0
    -- Sort keys for a cleaner menu
    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys)

    for _, id in ipairs(keys) do
        count = count + 1
        listMenu:addOption("Info: " .. id, id, Debug_PrintFactionInfo)
    end

    if count == 0 then
        local opt = listMenu:addOption("No Factions Found")
        opt.notAvailable = true
    end

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