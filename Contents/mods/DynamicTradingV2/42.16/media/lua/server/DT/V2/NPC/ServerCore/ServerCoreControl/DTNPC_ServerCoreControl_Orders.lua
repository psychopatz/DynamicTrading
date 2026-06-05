-- ==============================================================================
-- DTNPC_ServerCoreControl_Orders.lua
-- Order issuance helpers for DTNPC server control.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreControl.Internal

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

function DTNPCServerCore.IssueOrderByUUID(uuid, controller, args)
    if not uuid or type(args) ~= "table" then
        return false, nil
    end

    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "IssueOrderByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil
    end

    local state = tostring(args.state or npcData.state or "Idle")
    local requestedFollowSpacingMode = normalizeFollowSpacingMode(args.followSpacingMode)
    local masterUsername, masterID = Internal.NormalizeController(controller)
    local usesMaster = state == "Follow"
        or state == "Flee"
        or state == "Attack"
        or state == "AttackRange"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
    local requestedReturnStatus = args.returnStatus
    local escortLocked = tostring(npcData.doObjectiveHookId or "") == "TraderNeeds.HelpEscort"
        and npcData.doObjectiveEscortActive == true

    if escortLocked then
        if state ~= "Follow" and state ~= "Stay" then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Escort",
                "Rejected escort-locked order for " .. tostring(npcData.name or normalizedUUID)
                    .. " state=" .. tostring(state)
                    .. " controller=" .. tostring(masterUsername or "system")
            )
            return false, npcData
        end

        args.combatOrder = nil
        args.guardCombatOrder = nil
        args.guardAttackMode = nil
        requestedReturnStatus = nil
    end

    if usesMaster and not zombie and controller and DTNPCServerCore.SpawnNearbyCompanionByUUID then
        local arrivalMode = "bandit_hostile"
        if npcData.contactVisitActive == true then
            arrivalMode = "contact_follow"
        elseif tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            or tostring(npcData.linkedWorkerID or "") ~= "" then
            arrivalMode = "companion_follow"
        end

        local spawned, spawnedZombie, spawnedData = false, nil, npcData
        local arrivalStatus = arrivalMode == "contact_follow" and "Trading" or "Working"
        if DTNPCServerCore.ActivateArrivalByUUID then
            spawned, spawnedZombie, spawnedData = DTNPCServerCore.ActivateArrivalByUUID(normalizedUUID, {
                controller = controller,
                targetPlayer = controller,
                spawnPolicy = "nearby_follow",
                activationMode = arrivalMode,
                state = state,
                status = arrivalStatus,
                returnTime = 0,
                returnStatus = nil,
                requestedReturnStatus = requestedReturnStatus,
                combatOrder = args.combatOrder,
                guardCombatOrder = args.guardCombatOrder,
                guardAttackMode = args.guardAttackMode,
                minRadius = 2,
                maxRadius = 5,
            })
        else
            spawned, spawnedZombie, spawnedData = DTNPCServerCore.SpawnNearbyCompanionByUUID(
                normalizedUUID,
                controller,
                2,
                5
            )
        end
        if spawned then
            zombie = spawnedZombie or zombie
            npcData = spawnedData or npcData
        end
    end

    if args.startDeparture and not usesMaster then
        local nextStatus = requestedReturnStatus or "Resting"
        local home = npcData.homeCoords
        local walkHours = SandboxVars
            and SandboxVars.DynamicTrading
            and SandboxVars.DynamicTrading.NPCTradingWalkHours
            or 1.0

        if home and DTNPCManager and DTNPCManager.TryStartLiveDeparture
            and DTNPCManager.TryStartLiveDeparture(normalizedUUID, nextStatus, walkHours, home.x, home.y, home.z or 0) then
            return true, (DTNPCManager.Data and DTNPCManager.Data[normalizedUUID]) or npcData
        end

        local currentHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
        local returnTime = currentHours + walkHours
        Internal.RemoveLiveNPCToStatus(normalizedUUID, zombie, npcData, "Away", returnTime, nextStatus)
        return true, npcData
    end

    local changed = false
    if state ~= "PatchUp"
        and DTNPCHealth
        and DTNPCHealth.CancelPendingSelfBandage
        and DTNPCHealth.CancelPendingSelfBandage(zombie, npcData, state, {
            manualInterrupt = true,
            retryDelayMs = DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS,
            sync = false,
        }) then
        changed = true
    end

    if npcData.state ~= state then
        npcData.state = state
        changed = true
    end

    if npcData.tasks == nil or #npcData.tasks > 0 then
        npcData.tasks = {}
        changed = true
    end

    if npcData.combatTargetID ~= nil then
        npcData.combatTargetID = nil
        changed = true
    end
    if npcData.anchorX ~= nil then
        npcData.anchorX = nil
        changed = true
    end
    if npcData.anchorY ~= nil then
        npcData.anchorY = nil
        changed = true
    end
    if npcData.anchorZ ~= nil then
        npcData.anchorZ = nil
        changed = true
    end

    if npcData.requestedReturnStatus ~= requestedReturnStatus then
        npcData.requestedReturnStatus = requestedReturnStatus
        changed = true
    end

    if state == "Follow" and requestedFollowSpacingMode and npcData.followSpacingMode ~= requestedFollowSpacingMode then
        npcData.followSpacingMode = requestedFollowSpacingMode
        changed = true
    end

    if usesMaster then
        if npcData.status ~= "Working" then
            npcData.status = "Working"
            changed = true
        end
        if npcData.returnTime ~= 0 then
            npcData.returnTime = 0
            changed = true
        end
        if npcData.returnStatus ~= nil then
            npcData.returnStatus = nil
            changed = true
        end
        if npcData.master ~= masterUsername then
            npcData.master = masterUsername
            changed = true
        end
        if npcData.masterID ~= masterID then
            npcData.masterID = masterID
            changed = true
        end
    else
        if npcData.master ~= nil then
            npcData.master = nil
            changed = true
        end
        if npcData.masterID ~= nil then
            npcData.masterID = nil
            changed = true
        end
    end

    local combatOrder = nil
    local guardCombatOrder = nil
    if args.combatOrder == "ProtectRanged" or args.combatOrder == "ProtectMelee" or args.combatOrder == "ProtectAuto" then
        combatOrder = args.combatOrder
    elseif state == "ProtectRanged" or state == "ProtectMelee" or state == "ProtectAuto" then
        combatOrder = state
    end
    if args.guardCombatOrder == "GuardRanged" or args.guardCombatOrder == "GuardMelee" or args.guardCombatOrder == "GuardAuto" then
        guardCombatOrder = args.guardCombatOrder
    elseif args.guardAttackMode == "GuardRanged" or args.guardAttackMode == "GuardMelee" or args.guardAttackMode == "GuardAuto" then
        guardCombatOrder = args.guardAttackMode
    elseif state == "Guard" then
        guardCombatOrder = npcData.guardCombatOrder or npcData.guardAttackMode or "GuardAuto"
    end
    if npcData.combatOrder ~= combatOrder then
        npcData.combatOrder = combatOrder
        changed = true
    end
    if npcData.guardCombatOrder ~= guardCombatOrder then
        npcData.guardCombatOrder = guardCombatOrder
        changed = true
    end
    if npcData.guardAttackMode ~= guardCombatOrder then
        npcData.guardAttackMode = guardCombatOrder
        changed = true
    end
    if state == "Guard" then
        local guardX = tonumber(args.x) or zombie:getX()
        local guardY = tonumber(args.y) or zombie:getY()
        local guardZ = tonumber(args.z) or zombie:getZ()

        if npcData.stationaryPostX ~= guardX then
            npcData.stationaryPostX = guardX
            changed = true
        end
        if npcData.stationaryPostY ~= guardY then
            npcData.stationaryPostY = guardY
            changed = true
        end
        if npcData.stationaryPostZ ~= guardZ then
            npcData.stationaryPostZ = guardZ
            changed = true
        end
        if npcData.stationaryPostState ~= "Guard" then
            npcData.stationaryPostState = "Guard"
            changed = true
        end
        if npcData.anchorX ~= guardX then
            npcData.anchorX = guardX
            changed = true
        end
        if npcData.anchorY ~= guardY then
            npcData.anchorY = guardY
            changed = true
        end
        if npcData.anchorZ ~= guardZ then
            npcData.anchorZ = guardZ
            changed = true
        end
        if npcData.guardReturningToPost ~= nil then
            npcData.guardReturningToPost = nil
            changed = true
        end
    elseif state == "LootNearby" then
        local lootX = tonumber(args.x) or zombie:getX()
        local lootY = tonumber(args.y) or zombie:getY()
        local lootZ = tonumber(args.z) or zombie:getZ()
        local lootConfig = type(npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
        local requestedRadius = tonumber(args.lootRadius or args.radius or lootConfig.radius) or 10
        local normalizedRadius = math.max(2, math.min(25, math.floor(requestedRadius)))

        if npcData.anchorX ~= lootX then
            npcData.anchorX = lootX
            changed = true
        end
        if npcData.anchorY ~= lootY then
            npcData.anchorY = lootY
            changed = true
        end
        if npcData.anchorZ ~= lootZ then
            npcData.anchorZ = lootZ
            changed = true
        end
        if npcData.dcLootAnchorX ~= lootX then
            npcData.dcLootAnchorX = lootX
            changed = true
        end
        if npcData.dcLootAnchorY ~= lootY then
            npcData.dcLootAnchorY = lootY
            changed = true
        end
        if npcData.dcLootAnchorZ ~= lootZ then
            npcData.dcLootAnchorZ = lootZ
            changed = true
        end
        if npcData.dcLootRadius ~= normalizedRadius then
            npcData.dcLootRadius = normalizedRadius
            changed = true
        end
        if npcData.dcLootTarget ~= nil then
            npcData.dcLootTarget = nil
            changed = true
        end
        if npcData.dcLootVisited ~= nil then
            npcData.dcLootVisited = nil
            changed = true
        end
        if npcData.dcLootTargetKey ~= nil then
            npcData.dcLootTargetKey = nil
            changed = true
        end
        if npcData.dcLootStatus ~= "searching" then
            npcData.dcLootStatus = "searching"
            changed = true
        end
        if npcData.guardReturningToPost ~= nil then
            npcData.guardReturningToPost = nil
            changed = true
        end
    elseif state == "Stay" and npcData.guardReturningToPost ~= nil then
        npcData.guardReturningToPost = nil
        changed = true
    end
    if combatOrder == nil and npcData.combatFallbackAnnouncedAt ~= nil then
        npcData.combatFallbackAnnouncedAt = nil
        changed = true
    end

    if state == "GoTo" then
        local targetTask = {
            x = tonumber(args.targetX) or 0,
            y = tonumber(args.targetY) or 0,
            z = tonumber(args.targetZ) or 0,
        }
        local existingTask = npcData.tasks[1]
        if not existingTask
            or existingTask.x ~= targetTask.x
            or existingTask.y ~= targetTask.y
            or existingTask.z ~= targetTask.z then
            npcData.tasks = { targetTask }
            changed = true
        end
    end

    if not changed then
        return false, npcData
    end

    Internal.PersistNPCUpdate(normalizedUUID, zombie, npcData, true)
    return true, npcData
end
