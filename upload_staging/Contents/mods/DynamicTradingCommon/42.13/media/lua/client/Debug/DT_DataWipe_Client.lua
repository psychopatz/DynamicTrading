-- =============================================================================
-- DYNAMIC TRADING COMMON: DATA WIPE CLIENT (REMOTE CONTROL)
-- =============================================================================
-- Labeled [Admin] for clarity.
-- restricted to Admins with precise categorization and tooltips.
-- =============================================================================

if not isDebugEnabled() and (not getPlayer() or getPlayer():getAccessLevel() == "None") then return end

local function RequestServerWipe(playerObj, target, label)
    if not playerObj then return end
    
    local targetLabel = label or target or "ALL DATA"
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
            player:playSound("AdminAction")
            player:Say("WIPE SUCCESS: " .. (args.count or 0) .. " entries cleared.")
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "SERVER DATA WIPED", true, HaloTextHelper.getColorGreen())
            end
            
            local modal = ISModalDialog:new(0, 0, 350, 150, 
                (args.msg or "Wipe Complete") .. "\n\nIt is HIGHLY RECOMMENDED to restart the server/session now to clear memory cache.", 
                true, nil, nil, nil)
            modal:initialise()
            modal:addToUIManager()
        else
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
    local debugOption = context:addOption("[Admin] DynamicTrading Mod Data Management", nil, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(debugOption, subMenu)

    -- Option: REFRESH ALL
    local optRefresh = subMenu:addOption("[REFRESH ALL DATA]", playerObj, RequestServerWipe, "REFRESH", "TOTAL REFRESH")
    local ttRefresh = ISWorldObjectContextMenu.addToolTip()
    ttRefresh:setName("DANGER: TOTAL REFRESH")
    ttRefresh.description = "Nuclear Option: Deletes EVERY DT key found (Current + Legacy + Souls + Logs).\n\nBest for fully resetting the mod state in an existing save."
    optRefresh.toolTip = ttRefresh

    subMenu:addOption("_", nil, nil) -- Divider-ish

    -- Option: Wipe Current
    local optCurrent = subMenu:addOption("Wipe Current Mods", playerObj, RequestServerWipe, "CURRENT", "ACTIVE DATA")
    local ttCurrent = ISWorldObjectContextMenu.addToolTip()
    ttCurrent:setName("Wipe Current Mods")
    ttCurrent.description = "Deletes active Engine v2, Stocks, Factions, Roster, and Souls.\n\nLegacy keys (v1.1, v1.3) are preserved."
    optCurrent.toolTip = ttCurrent

    -- Option: Wipe Legacy
    local optLegacy = subMenu:addOption("Wipe Legacy Data", playerObj, RequestServerWipe, "LEGACY", "OLD VERSIONS")
    local ttLegacy = ISWorldObjectContextMenu.addToolTip()
    ttLegacy:setName("Wipe Legacy Data")
    ttLegacy.description = "Cleans up old DTNPC_GlobalList and V1 Engine keys (v1.1, v1.3).\n\nSafe for active games to clean up junk."
    optLegacy.toolTip = ttLegacy

    subMenu:addOption("_", nil, nil) -- Divider-ish

    -- Categorized Precise Controls
    -- Engine
    local optEngine = subMenu:addOption("Wipe: Engine Only", playerObj, RequestServerWipe, "ENGINE", "ECONOMY ENGINE")
    local ttEngine = ISWorldObjectContextMenu.addToolTip()
    ttEngine:setName("Wipe Engine")
    ttEngine.description = "Resets the simulation clock, daily recruit data, and global heat/inflation."
    optEngine.toolTip = ttEngine

    -- Stocks
    local optStocks = subMenu:addOption("Wipe: Stocks Only", playerObj, RequestServerWipe, "STOCKS", "MERCHANT STOCKS")
    local ttStocks = ISWorldObjectContextMenu.addToolTip()
    ttStocks:setName("Wipe Stocks")
    ttStocks.description = "Reset all merchant inventories, shop balances, and local price multipliers."
    optStocks.toolTip = ttStocks

    -- Factions
    local optFactions = subMenu:addOption("Wipe: Factions Only", playerObj, RequestServerWipe, "FACTIONS", "FACTIONS/ALLIANCES")
    local ttFactions = ISWorldObjectContextMenu.addToolTip()
    ttFactions:setName("Wipe Factions")
    ttFactions.description = "Resets faction reputations, stockpiles, wealth, and territory data."
    optFactions.toolTip = ttFactions

    -- Roster/Souls
    local optRoster = subMenu:addOption("Wipe: Roster/Souls", playerObj, RequestServerWipe, "ROSTER", "NPC IDENTITIES")
    local ttRoster = ISWorldObjectContextMenu.addToolTip()
    ttRoster:setName("Wipe Roster")
    ttRoster.description = "Deletes all NPC identities (Souls) and the central roster registry.\n\nRequires server restart to prevent ghost NPCs."
    optRoster.toolTip = ttRoster

    -- Buildings/Logs
    local optLogs = subMenu:addOption("Wipe: Buildings & Logs", playerObj, RequestServerWipe, "BUILDINGS", "SYSTEM LOGS")
    local ttLogs = ISWorldObjectContextMenu.addToolTip()
    ttLogs:setName("Wipe Logs")
    ttLogs.description = "Clears scanned building data and debug logs from ModData."
    optLogs.toolTip = ttLogs
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
