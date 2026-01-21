-- =============================================================================
-- DYNAMIC TRADING: DATA WIPE CLIENT (REMOTE CONTROL)
-- =============================================================================
-- Adds the UI button to trigger the server-side wipe.
-- Handles the network feedback loop.
-- =============================================================================

local function RequestServerWipe(playerObj)
    if not playerObj then return end
    
    -- Send signal to Server (See: DT_DataWipe_Server.lua)
    -- In Singleplayer, this sends to the internal server logic.
    sendClientCommand(playerObj, "DynamicTrading", "WipeSystem", {})
    
    playerObj:Say("Requesting System Wipe...")
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
                "Dynamic Trading data has been wiped from the server.\n\nIt is HIGHLY RECOMMENDED to restart the server/session now to clear memory cache.", 
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

    -- Check for Admin/Debug privileges if you want to hide the button entirely from normal users
    -- For now, we leave it visible but the Server script will block execution if unauthorized.
    if not isDebugEnabled() and playerObj:getAccessLevel() == "None" then
        -- Optional: return here to hide the menu for normal players
    end

    -- 1. Main Option
    local debugOption = context:addOption("[DEBUG] DT Data Management", nil, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(debugOption, subMenu)

    -- 2. Wipe Option
    local wipeOption = subMenu:addOption("WIPE ALL SERVER DATA (Hazardous)", playerObj, RequestServerWipe)
    
    -- 3. Tooltip
    local toolTip = ISWorldObjectContextMenu.addToolTip()
    toolTip:setName("SERVER COMMAND")
    toolTip.description = "Sends a command to the Server/Host to delete all persistent Dynamic Trading data.\n\n- Requires Admin Access\n- Irreversible\n- Requires Server Restart"
    wipeOption.toolTip = toolTip
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)