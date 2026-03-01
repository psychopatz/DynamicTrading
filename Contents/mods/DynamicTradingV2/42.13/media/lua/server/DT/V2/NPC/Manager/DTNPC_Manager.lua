-- ==============================================================================
-- DTNPC_Manager.lua (Core Bootstrap)
-- Declares the global DTNPCManager table, sub-tables, require, helpers, and
-- the SP/MP client guard. All other Manager sub-modules attach to this table.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {}
DTNPCManager.PendingRegistrations = {}
DTNPCManager.OutfitIDToUUID = {} -- Maps current outfit IDs to persistent UUIDs

require "DT/Common/Faction/TradingSys/DynamicTrading_Roster" -- V2 Roster Bridge

-- Helper for SP/MP Compatibility
function DTNPCManager.GetActivePlayers()
    local players = {}
    if not isServer() and not isClient() then
         -- Single Player
         local p = getSpecificPlayer(0)
         if p then table.insert(players, p) end
    else
         -- Dedicated Server / Host
         local online = getOnlinePlayers()
         if online then
             for i=0, online:size()-1 do
                 local p = online:get(i)
                 if p then table.insert(players, p) end
             end
         end
    end
    return players
end

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- UTILITIES
-- ==============================================================================

function DTNPCManager.GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end
