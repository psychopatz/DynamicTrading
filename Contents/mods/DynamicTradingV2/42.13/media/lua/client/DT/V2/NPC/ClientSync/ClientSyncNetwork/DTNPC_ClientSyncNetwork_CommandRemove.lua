-- ==============================================================================
-- Removal handlers for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Helpers = Network.Helpers or {}
local Handlers = Network.Handlers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Helpers
Network.Handlers = Handlers

if Network.Modules.CommandRemove then
    return
end

Network.Modules.CommandRemove = true

function Handlers.HandleRemoveNPC(args)
    if not args or not args.uuid then
        return
    end

    local uuid = args.uuid
    local name = args.name or "Unknown"
    local outfitID = args.outfitID
    local cachedEntry = DTNPCClient.NPCCache[uuid]
    local factionID = cachedEntry and cachedEntry.npcData and cachedEntry.npcData.factionID or nil

    if name == "Unknown" and DTNPCClient.NPCCache[uuid] then
        name = DTNPCClient.NPCCache[uuid].npcData.name or "Unknown"
    end

    DynamicTrading.Log("DTV2", "NPC", "Remove", "Received RemoveNPC for: " .. name .. " (" .. uuid .. ")")

    DTNPC_ClientInterpolation.ClearNPC(uuid)

    local zombie = Helpers.FindZombieByIdentifiers(uuid, outfitID)

    if DT_Reputation then
        local reason = args.removalReason
        if reason == "Incapacitated" then
            DT_Reputation.ApplyIncapPenalty(uuid, factionID)
        elseif reason == "Dead" then
            if factionID and factionID ~= "Independent" then
                DT_Reputation.TryApplyKillPenalty(
                    uuid,
                    factionID,
                    zombie,
                    args.killerUsername,
                    args.killerOnlineID
                )
            end
        end
    end

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed zombie from local world: " .. name)
    end

    DTNPCClient.RemoveFromCache(uuid, outfitID)

    if DT_V2_RadarManager then
        if DT_V2_RadarManager.ClientRoster and DT_V2_RadarManager.ClientRoster.Souls then
            DT_V2_RadarManager.ClientRoster.Souls[uuid] = nil
        end
        DT_V2_RadarManager.FoundTraders[uuid] = nil
    end

    if DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Traders then
        DynamicTrading_Client.Cache.Traders[uuid] = nil
    end

    if DT_V2_RadarWindow and DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance.refresh then
        DT_V2_RadarWindow.instance:refresh()
    end
end
