-- ==============================================================================
-- Bootstrap and dependency guards for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Modules = ClientSync.Modules or {}
ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network

Network.Modules = Network.Modules or {}
Network.Helpers = Network.Helpers or {}
Network.Handlers = Network.Handlers or {}

if Network.Modules.Bootstrap then
    return
end

Network.Modules.Bootstrap = true
ClientSync.Modules.Network = true

require "DT/Common/Reputation/DT_Reputation"

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading client interpolation module...")

require "DT/V2/NPC/ClientSync/DTNPC_ClientSync_Interpolation"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_ClientInterpolation loaded: " .. tostring(DTNPC_ClientInterpolation ~= nil))

if not DTNPC_ClientInterpolation then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_ClientInterpolation is nil, creating fallback")
    DTNPC_ClientInterpolation = {
        LastPositions = {},
        UpdateTimes = {},
        RecordUpdate = function(uuid, x, y, z, updateFreq) end,
        GetInterpolatedPosition = function(uuid, zombie)
            if zombie then
                return zombie:getX(), zombie:getY(), zombie:getZ()
            end
            return 0, 0, 0
        end,
        ClearNPC = function(uuid) end,
        ClearAll = function() end,
        GetTrackedCount = function() return 0 end,
        DebugPrint = function() end
    }
end

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")
