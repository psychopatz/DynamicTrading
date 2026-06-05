-- ==============================================================================
-- DTNPC_ServerCoreCommands_Orders.lua
-- Order command handlers for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreCommands.Internal
local Handlers = DTNPCServerCoreCommands.Handlers

local function normalizeFollowSpacingMode(mode)
    local text = string.lower(tostring(mode or ""))
    if text == "far" then
        return "far"
    end
    if text == "near" then
        return "near"
    end
    return nil
end

local function applyFallbackOrder(player, obj, npcData, args, escortLocked)
    npcData.state = args.state
    npcData.tasks = {}

    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil

    npcData.requestedReturnStatus = args.returnStatus
    npcData.combatTargetID = nil

    if escortLocked then
        npcData.requestedReturnStatus = nil
        args.combatOrder = nil
        args.guardCombatOrder = nil
        args.guardAttackMode = nil
    end

    if args.state == "Follow" or args.state == "Flee"
        or args.state == "ProtectRanged" or args.state == "ProtectMelee" or args.state == "ProtectAuto" then
        npcData.master = player:getUsername()
        npcData.masterID = isClient() and player:getOnlineID() or 0
        npcData.combatOrder = (args.state == "ProtectRanged" or args.state == "ProtectMelee" or args.state == "ProtectAuto") and args.state or nil
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
        local followSpacingMode = normalizeFollowSpacingMode(args.followSpacingMode)
        if args.state == "Follow" and followSpacingMode then
            npcData.followSpacingMode = followSpacingMode
        end
        DynamicTrading.Log("DTV2", "NPC", "Order", "Master assigned for " .. args.state .. " order: " .. npcData.master)
    elseif args.state == "Guard" then
        npcData.combatOrder = nil
        npcData.guardCombatOrder = (args.guardCombatOrder == "GuardRanged" or args.guardCombatOrder == "GuardMelee" or args.guardCombatOrder == "GuardAuto")
            and args.guardCombatOrder
            or ((args.guardAttackMode == "GuardRanged" or args.guardAttackMode == "GuardMelee" or args.guardAttackMode == "GuardAuto") and args.guardAttackMode or npcData.guardCombatOrder or "GuardAuto")
        npcData.guardAttackMode = npcData.guardCombatOrder
        npcData.master = nil
        npcData.masterID = nil
        npcData.stationaryPostX = args.x or obj:getX()
        npcData.stationaryPostY = args.y or obj:getY()
        npcData.stationaryPostZ = args.z or obj:getZ()
        npcData.stationaryPostState = "Guard"
        npcData.anchorX = npcData.stationaryPostX
        npcData.anchorY = npcData.stationaryPostY
        npcData.anchorZ = npcData.stationaryPostZ
        npcData.guardReturningToPost = nil
    elseif args.state == "LootNearby" then
        npcData.combatOrder = (args.combatOrder == "ProtectRanged" or args.combatOrder == "ProtectMelee" or args.combatOrder == "ProtectAuto")
            and args.combatOrder
            or npcData.combatOrder
            or "ProtectAuto"
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
        npcData.master = nil
        npcData.masterID = nil
        npcData.anchorX = args.x or obj:getX()
        npcData.anchorY = args.y or obj:getY()
        npcData.anchorZ = args.z or obj:getZ()
        npcData.dcLootAnchorX = npcData.anchorX
        npcData.dcLootAnchorY = npcData.anchorY
        npcData.dcLootAnchorZ = npcData.anchorZ
        npcData.dcLootRadius = math.max(2, math.min(25, math.floor(tonumber(args.lootRadius or args.radius) or tonumber(npcData.dcLootRadius) or 10)))
        npcData.dcLootTarget = nil
        npcData.dcLootVisited = nil
        npcData.dcLootTargetKey = nil
        npcData.dcLootStatus = "searching"
        npcData.guardReturningToPost = nil
    elseif args.state == "GoTo" then
        table.insert(npcData.tasks, { x = args.targetX, y = args.targetY, z = args.targetZ or 0 })
        npcData.combatOrder = nil
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
        DynamicTrading.Log("DTV2", "NPC", "Order", "GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
    elseif args.state == "Trading" then
        npcData.master = nil
        npcData.masterID = nil
        npcData.tasks = {}
        npcData.combatOrder = nil
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
        npcData.stationaryPostX = nil
        npcData.stationaryPostY = nil
        npcData.stationaryPostZ = nil
        npcData.stationaryPostState = nil
        npcData.guardReturningToPost = nil
    else
        npcData.combatOrder = nil
        if args.state == "Stay" then
            npcData.guardCombatOrder = nil
            npcData.guardAttackMode = nil
        end
    end

    DTNPC.AttachData(obj, npcData)
    if DTNPCManager then
        DTNPCManager.Register(obj, npcData)
    end

    DTNPCServerCore.SyncToAllClients(obj, npcData)
    DTNPCServerCore.BroadcastPosition(obj, npcData)
end

Handlers.Order = function(player, args)
    DynamicTrading.Log("DTV2", "NPC", "Command", "Received Order command from: " .. player:getUsername() .. " | State: " .. (args.state or "Unknown"))

    if args.uuid and DTNPCServerCore and DTNPCServerCore.IssueOrderByUUID then
        local npcData = nil
        if DTNPCServerCore.GetNPCDataByUUID then
            local zombie = nil
            zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(args.uuid)
        end

        local canCommand, reason = Internal.CanPlayerCommandCompanion(player, npcData, args.systemCompanionOrder)
        if not canCommand then
            Internal.SendCompanionNotice(player, reason)
            return
        end

        if args.state == "PatchUp" and DTNPCServerCore.StartPatchUpByUUID then
            local changed, updatedNPC = DTNPCServerCore.StartPatchUpByUUID(args.uuid)
            if changed and updatedNPC then
                DynamicTrading.Log("DTV2", "NPC", "Order", "Issued PatchUp order for " .. tostring(updatedNPC.name or args.uuid))
            end
            return
        end

        local changed, updatedNPC = DTNPCServerCore.IssueOrderByUUID(args.uuid, player, args)
        if changed and updatedNPC then
            DynamicTrading.Log("DTV2", "NPC", "Order", "Issued UUID order for " .. tostring(updatedNPC.name or args.uuid) .. ": " .. tostring(args.state))
        end
        return
    end

    local square = getCell():getGridSquare(args.x, args.y, args.z)
    if not square then
        return
    end

    local movingObjects = square:getMovingObjects()
    for i = 0, movingObjects:size() - 1 do
        local obj = movingObjects:get(i)
        if instanceof(obj, "IsoZombie") then
            local npcData = DTNPC.GetBrain(obj)
            if npcData then
                local escortLocked = tostring(npcData.doObjectiveHookId or "") == "TraderNeeds.HelpEscort"
                    and npcData.doObjectiveEscortActive == true
                if escortLocked and args.state ~= "Follow" and args.state ~= "Stay" then
                    DynamicTrading.Log(
                        "DTV2",
                        "NPC",
                        "Escort",
                        "Rejected escort-locked fallback order for "
                            .. tostring(npcData.name or npcData.uuid or "unknown")
                            .. " state=" .. tostring(args.state)
                    )
                    return
                end

                local canCommand, reason = Internal.CanPlayerCommandCompanion(player, npcData, false)
                if not canCommand then
                    Internal.SendCompanionNotice(player, reason)
                    return
                end

                applyFallbackOrder(player, obj, npcData, args, escortLocked)
                break
            end
        end
    end
end
