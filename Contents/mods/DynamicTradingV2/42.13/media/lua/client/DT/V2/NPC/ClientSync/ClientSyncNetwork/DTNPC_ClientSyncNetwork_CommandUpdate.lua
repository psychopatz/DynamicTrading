-- ==============================================================================
-- Position update handlers for client-side network sync modules.
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

if Network.Modules.CommandUpdate then
    return
end

Network.Modules.CommandUpdate = true

function Handlers.HandleUpdatePosition(args)
    if not args or not args.uuid then
        return
    end

    local uuid = args.uuid
    local cached = DTNPCClient.NPCCache[uuid]
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)

    Helpers.RecordInterpolation(uuid, args.x, args.y, args.z)

    if cached and cached.npcData then
        cached.npcData.lastX = math.floor(args.x)
        cached.npcData.lastY = math.floor(args.y)
        cached.npcData.lastZ = math.floor(args.z)

        if args.health then
            cached.npcData.health = args.health
        end
        if args.state then
            cached.npcData.state = args.state
        end
        if args.status then
            cached.npcData.status = args.status
        end
        if bodyInstanceID then
            DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = uuid
            cached.npcData.currentBodyInstanceID = bodyInstanceID
        end

        local zombie = Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
        if zombie then
            local zombieData = DTNPC.GetData(zombie)
            if zombieData then
                if args.state then
                    zombieData.state = args.state
                end
                if args.health then
                    zombieData.health = args.health
                end
                if args.status then
                    zombieData.status = args.status
                end
            end

            if not DTNPCClient.LocalControlled[uuid] then
                DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
            end
        end

        if args.state then
            cached.lastReportedState = cached.lastReportedState or {}
            cached.lastReportedState.state = args.state
        end
    end

    Helpers.TrackNPCSystems(nil, cached and cached.npcData or nil, uuid, bodyInstanceID)

    if args.health and DTNPCClient.MarkNPCCombatForHealthBars then
        DTNPCClient.MarkNPCCombatForHealthBars(uuid, nil, cached and cached.npcData or nil, bodyInstanceID)
    end
end
