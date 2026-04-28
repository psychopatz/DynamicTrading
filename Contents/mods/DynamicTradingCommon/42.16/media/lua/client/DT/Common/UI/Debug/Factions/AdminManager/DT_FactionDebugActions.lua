-- ==============================================================================
-- DT_FactionDebugActions.lua
-- Faction Debug Tool: Action Handlers
-- Button click handlers and user interactions
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
require "DT/Common/UI/Debug/Shared/DT_NPCLocator"
require "DT/Common/Reputation/DT_Reputation"
require "DT/Common/Contacts/DT_TraderContacts"

DT_FactionDebugActions = DT_FactionDebugActions or {}

-- ==========================================================
-- FACTION MODIFICATION ACTIONS
-- ==========================================================
function DT_FactionDebugActions.modifyWealth(factionID, amount)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("ModifyColonyWealth", { 
        factionID = factionID, 
        amount = amount 
    })
end

function DT_FactionDebugActions.modifyFactionBias(factionID, amount)
    if not factionID then return end

    if DT_Reputation and DT_Reputation.ModifyFactionBias then
        DT_Reputation.ModifyFactionBias(factionID, amount, "admin_debug")
    end

    DT_DebugNetworkAdapter.sendDebugAction("ModifyFactionBias", {
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

function DT_FactionDebugActions.grantContactTestAccess(traderUUID, soul, factionID)
    if not traderUUID or type(soul) ~= "table" then
        return false
    end

    local targetFactionID = factionID or soul.factionID
    local currentRep = DT_Reputation and DT_Reputation.GetEffectiveRep and DT_Reputation.GetEffectiveRep(traderUUID, targetFactionID) or 0
    local delta = 100 - tonumber(currentRep or 0)
    if DT_Reputation and DT_Reputation.ModifyPersonalRep and delta ~= 0 then
        DT_Reputation.ModifyPersonalRep(traderUUID, targetFactionID, delta, "admin_debug_contact_test")
    end

    local contactTrader = {}
    for key, value in pairs(soul) do
        contactTrader[key] = value
    end
    contactTrader.id = tostring(traderUUID)
    contactTrader.uuid = tostring(traderUUID)
    contactTrader.traderID = tostring(traderUUID)
    contactTrader.factionID = targetFactionID

    local ok, saved, reason = false, nil, "unavailable"
    if DT_TraderContacts and DT_TraderContacts.UnlockContact then
        ok, saved, reason = DT_TraderContacts.UnlockContact(contactTrader, {
            ignoreReputation = true,
            debugGranted = true,
        })
    end

    local player = getPlayer and getPlayer() or nil
    if player then
        if ok then
            local name = tostring((saved and saved.name) or soul.name or traderUUID)
            player:Say("Contact unlocked for testing: " .. name .. " (Rep 100)")
        else
            player:Say("Failed to unlock debug contact: " .. tostring(reason or traderUUID))
        end
    end

    return ok, saved, reason
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

function DT_FactionDebugActions.adminReviewPlayerFaction(factionID)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("AdminReviewPlayerFaction", {
        factionID = factionID
    })
end

function DT_FactionDebugActions.restorePlayerFactionLeader(factionID, username)
    if not factionID or not username or tostring(username) == "" then return end
    DT_DebugNetworkAdapter.sendDebugAction("RestorePlayerFactionLeader", {
        factionID = factionID,
        username = username
    })
end

function DT_FactionDebugActions.archivePlayerFaction(factionID)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("ArchivePlayerFaction", {
        factionID = factionID
    })
end

function DT_FactionDebugActions.deletePlayerFactionArchive(factionID)
    if not factionID then return end
    DT_DebugNetworkAdapter.sendDebugAction("DeletePlayerFactionArchive", {
        factionID = factionID
    })
end

function DT_FactionDebugActions.forceTraderByArchetype(archetypeID)
    if type(archetypeID) ~= "string" or archetypeID == "" then
        return false
    end

    DT_DebugNetworkAdapter.sendDebugAction("ForceTraderByArchetype", {
        archetypeID = archetypeID,
        factionID = "Independent"
    })

    if getPlayer() then
        getPlayer():Say("Requested trader spawn: " .. archetypeID)
    end
    return true
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
