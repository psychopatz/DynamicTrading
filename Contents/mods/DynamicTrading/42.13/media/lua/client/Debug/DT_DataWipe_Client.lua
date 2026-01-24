-- =============================================================================
-- DYNAMIC TRADING: DATA WIPE CLIENT (REMOTE CONTROL)
-- =============================================================================
-- Adds the UI button to trigger the server-side wipe.
-- Handles the network feedback loop.
-- =============================================================================

local function RequestServerWipe(playerObj, target)
    if not playerObj then return end
    
    local targetLabel = target or "ALL DATA"
    local warningText = "ARE YOU SURE YOU WANT TO WIPE " .. targetLabel .. "?\n\nThis action is PERMANENT and cannot be undone.\nA server restart is highly recommended afterwards."
    
    local function doWipe(this, button)
        if button.internal == "YES" then
            sendClientCommand(playerObj, "DynamicTrading", "WipeSystem", { target = target })
            playerObj:Say("Requesting System Wipe (" .. targetLabel .. ")...")
        end
    end

    local modal = ISModalDialog:new(0, 0, 350, 150, warningText, true, nil, doWipe, nil)
    modal:initialise()
    modal:addToUIManager()
end

-- =============================================================================
-- SERVER RESPONSE HANDLER
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "WipeResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        if args.success then
            -- Success Feedback
            player:playSound("AdminAction") -- Or any audible feedback
            player:Say("WIPE SUCCESS: " .. (args.count or 0) .. " files deleted.")
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "SERVER DATA WIPED", true, HaloTextHelper.getColorGreen())
            end
            
            -- Warning about reload
            local modal = ISModalDialog:new(0, 0, 350, 150, 
                args.msg .. "\n\nIt is HIGHLY RECOMMENDED to restart the server/session now to clear memory cache.", 
                true, nil, nil, nil)
            modal:initialise()
            modal:addToUIManager()
            
        else
            -- Failure/Security Feedback
            player:playSound("AccessDenied")
            player:Say("WIPE FAILED: " .. (args.msg or "Unknown Error"))
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "ACCESS DENIED", true, HaloTextHelper.getColorRed())
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- CONTEXT MENU INTEGRATION
-- =============================================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end

    -- Check for Admin/Debug privileges
    if not isDebugEnabled() and playerObj:getAccessLevel() == "None" then
        return
    end

    -- 1. Main Option
    local debugOption = context:addOption("[DEBUG] DT Data Management", nil, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(debugOption, subMenu)

    -- 2. Wipe Options
    -- A. Wipe ALL
    local wipeAll = subMenu:addOption("WIPE ALL DATA (HAZARDOUS)", playerObj, RequestServerWipe, "ALL")
    local toolTipAll = ISWorldObjectContextMenu.addToolTip()
    toolTipAll:setName("DANGER: WIPE ALL")
    toolTipAll.description = "Deletes ALL Dynamic Trading Data.\n- Stocks\n- Factions\n- Roster\n- Engine Data\n\nREQUIRES SERVER RESTART."
    wipeAll.toolTip = toolTipAll

    -- B. Wipe STOCKS
    local wipeStocks = subMenu:addOption("Wipe Stocks Only", playerObj, RequestServerWipe, "STOCKS")
    local toolTipStocks = ISWorldObjectContextMenu.addToolTip()
    toolTipStocks:setName("Wipe Stocks")
    toolTipStocks.description = "Reset valid storage, market values, and stock data."
    wipeStocks.toolTip = toolTipStocks

    -- C. Wipe FACTIONS
    local wipeFactions = subMenu:addOption("Wipe Factions Only", playerObj, RequestServerWipe, "FACTIONS")
    local toolTipFactions = ISWorldObjectContextMenu.addToolTip()
    toolTipFactions:setName("Wipe Factions")
    toolTipFactions.description = "Reset faction standings, generated factions, and alliances."
    wipeFactions.toolTip = toolTipFactions

    -- D. Wipe ROSTER
    local wipeRoster = subMenu:addOption("Wipe NPC Roster Only", playerObj, RequestServerWipe, "ROSTER")
    local toolTipRoster = ISWorldObjectContextMenu.addToolTip()
    toolTipRoster:setName("Wipe NPC Roster")
    toolTipRoster.description = "Delete all stored NPC data (Soul & Puppet data)."
    wipeRoster.toolTip = toolTipRoster

    -- E. Wipe ENGINE (Legacy)
    local wipeEngine = subMenu:addOption("Wipe Engine Data (Legacy)", playerObj, RequestServerWipe, "ENGINE")
    local toolTipEngine = ISWorldObjectContextMenu.addToolTip()
    toolTipEngine:setName("Wipe Engine Data")
    toolTipEngine.description = "Delete legacy engine data (DynamicTrading_Engine_v1.2)."
    wipeEngine.toolTip = toolTipEngine
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)