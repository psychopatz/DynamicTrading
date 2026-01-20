-- Debug Menu for Dynamic Trading V2
-- Place in media/lua/client/Debug/DT_DebugMenu.lua

DT_DebugMenu = {}

local function OnDebugCommand(action, args)
    local payload = args or {}
    payload.action = action
    sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", payload)
end

local function Debug_PrintEngineData(worldobjects, player)
    -- This relies on the client having the moddata synced, which happens automatically basically
    local data = ModData.get("DynamicTrading_Engine_v1.1")
    if data then
        print("DT DEBUG: Engine Data")
        print("  Day: " .. tostring(data.SimState.lastSimulationDay))
        print("  Recruits: " .. tostring(data.Demographics.availableRecruits))
    else
        print("DT DEBUG: No Engine Data Synced")
    end
end

local function Debug_ShowFactions(worldobjects, player)
    -- Request update just in case
    DynamicTrading_Client.RequestFactionData("All") -- Server needs to support "All" or we iterate knowns
    -- check local cache
    local cache = DynamicTrading_Client.Cache.Factions
    for id, f in pairs(cache) do
        print("DT DEBUG: Faction " .. id .. " | State: " .. tostring(f.state) .. " | Food: " .. tostring(f.stockpile.food))
    end
    HaloTextHelper.addText(player, "Check Console for Factions", HaloTextHelper.getColorWhite())
end

DT_DebugMenu.OnFillWorldObjectContextMenu = function(player, context, worldobjects, test)
    if not isDebugEnabled() then return end

    local dtOption = context:addOption("Dynamic Trading Debug", worldobjects, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(dtOption, subMenu)

    -- Engine Submenu
    local engineOption = subMenu:addOption("Engine", worldobjects, nil)
    local engineMenu = subMenu:getNew(subMenu)
    subMenu:addSubMenu(engineOption, engineMenu)
    
    engineMenu:addOption("Print Engine Data", worldobjects, Debug_PrintEngineData, getSpecificPlayer(player))
    engineMenu:addOption("Force Daily Sim", worldobjects, function() OnDebugCommand("SimulateDay") end)

    -- Factions Submenu
    local factionOption = subMenu:addOption("Factions", worldobjects, nil)
    local factionMenu = subMenu:getNew(subMenu)
    subMenu:addSubMenu(factionOption, factionMenu)

    factionMenu:addOption("Create Test Faction", worldobjects, function() OnDebugCommand("createTestFaction") end)
    factionMenu:addOption("Print Local Cache", worldobjects, Debug_ShowFactions, getSpecificPlayer(player))

    -- Roster/Stock Submenu
    local rosterOption = subMenu:addOption("Traders", worldobjects, nil)
    local rosterMenu = subMenu:getNew(subMenu)
    subMenu:addSubMenu(rosterOption, rosterMenu)

    rosterMenu:addOption("Force Restock (Target ID needed in code)", worldobjects, function() 
        -- Hardcoded ID for quick testing, ideally a popup
        OnDebugCommand("ForceRestock", {targetID="Trader1"}) 
    end)
end

Events.OnFillWorldObjectContextMenu.Add(DT_DebugMenu.OnFillWorldObjectContextMenu)
