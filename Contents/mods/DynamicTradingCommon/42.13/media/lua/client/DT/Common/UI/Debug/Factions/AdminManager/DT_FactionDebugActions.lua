-- ==============================================================================
-- DT_FactionDebugActions.lua
-- Faction Debug Tool: Action Handlers
-- Button click handlers and user interactions
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
require "DT/Common/UI/Debug/Shared/DT_NPCLocator"
require "DT/Common/Reputation/DT_Reputation"

DT_FactionDebugActions = DT_FactionDebugActions or {}

-- ==========================================================
-- FACTION MODIFICATION ACTIONS
-- ==========================================================
function DT_FactionDebugActions.modifyWealth(factionID, amount)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("ModifyWealth", { 
        factionID = factionID, 
        amount = amount 
    })
end

function DT_FactionDebugActions.modifyReputation(factionID, amount)
    if not factionID then return end
    
    -- [NEW LOGIC] Use the current reputation system for local player testing
    if DT_Reputation and DT_Reputation.ModifyFactionBias then
        DT_Reputation.ModifyFactionBias(factionID, amount, "admin_debug")
    end

    -- [OLD LOGIC] Keep for backend faction state continuity
    DT_DebugNetworkAdapter.sendDebugAction("ModifyReputation", { 
        factionID = factionID, 
        amount = amount 
    })
end

function DT_FactionDebugActions.modifyPersonalReputation(traderUUID, factionID, amount)
    if not traderUUID then return end
    
    -- [NEW LOGIC] Direct modification of personal relationship
    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(traderUUID, factionID, amount, "admin_debug")
    end
end

-- ==========================================================
-- SIMULATION ACTIONS
-- ==========================================================
function DT_FactionDebugActions.simulateDay()
    DT_DebugNetworkAdapter.sendDebugAction("SimulateDay")
    if HaloTextHelper then
        HaloTextHelper.addText(getPlayer(), "Global Simulation Triggered")
    end
end

function DT_FactionDebugActions.wipeFactions()
    DT_DebugNetworkAdapter.sendDebugAction("WipeFactions")
end

function DT_FactionDebugActions.createRandomFaction()
    local testID = "Faction_" .. ZombRand(1000, 9999)
    DT_DebugNetworkAdapter.sendDebugAction("createTestFaction", { targetID = testID })
end

-- ==========================================================
-- NPC ROSTER ACTIONS
-- ==========================================================
function DT_FactionDebugActions.locateNPC(uuid, soul)
    if not uuid or not soul then 
        DynamicTrading.Log("DTCommons", "Debug", "UI", "Cannot locate NPC: missing data")
        return false
    end
    
    return DT_NPCLocator.locateNPC(uuid, soul)
end

function DT_FactionDebugActions.forceTradeMission(uuid, soul)
    if not uuid or not soul then return false end
    
    if soul.status ~= "Resting" then
        if getPlayer() then 
            getPlayer():Say("Only 'Resting' NPCs can be forced to trade.") 
        end
        return false
    end
    
    DT_DebugNetworkAdapter.forceTradeMission(uuid)
    if getPlayer() then 
        getPlayer():Say("Forced trade mission for: " .. (soul.name or "Unknown")) 
    end
    return true
end

-- ==========================================================
-- EVENT INJECTION
-- ==========================================================
function DT_FactionDebugActions.injectEvent(factionID, eventID)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("InjectEvent", { 
        factionID = factionID, 
        eventID = eventID 
    })
end

function DT_FactionDebugActions.clearEvents(factionID)
    DT_FactionDebugActions.injectEvent(factionID, nil)
end

function DT_FactionDebugActions.showEventSelection(factionID, mouseX, mouseY)
    if not factionID then 
        if HaloTextHelper then 
            HaloTextHelper.addText(getPlayer(), "Select a faction first!") 
        end
        return 
    end
    
    local context = ISContextMenu.get(0, mouseX, mouseY)
    
    -- CLEAR OPTION
    context:addOption("--- CLEAR CURRENT EVENT ---", nil, function()
        DT_FactionDebugActions.clearEvents(factionID)
    end)

    -- Get available events from Registry
    if DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.Registry then
        local events = {}
        for id, def in pairs(DynamicTrading.Events.Registry) do
            if def.type == "flash" or def.type == "meta" then
                table.insert(events, { id = id, name = def.name or id })
            end
        end
        table.sort(events, function(a,b) return a.name < b.name end)
        
        for _, e in ipairs(events) do
            context:addOption("Force: " .. e.name, nil, function()
                DT_FactionDebugActions.injectEvent(factionID, e.id)
            end)
        end
    end
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Actions Loaded")
