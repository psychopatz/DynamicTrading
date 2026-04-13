-- ==============================================================================
-- DTNPC_ServerCore_Control.lua
-- Stable UUID-based helpers for NPC state and order updates.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

local function normalizeController(controller)
    if controller and controller.getUsername then
        return controller:getUsername(), controller.getOnlineID and controller:getOnlineID() or nil
    end

    if type(controller) == "table" then
        local username = controller.username or controller.master or controller.ownerUsername or controller.leaderUsername
        local onlineID = controller.onlineID or controller.masterID
        if username and tostring(username) ~= "" then
            return tostring(username), tonumber(onlineID)
        end
    end

    return nil, nil
end

local OFFSCREEN_FOLLOW_MIN_RADIUS = 26
local OFFSCREEN_FOLLOW_MAX_RADIUS = 40

local function roundNumber(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function normalizeUUID(uuid)
    local text = uuid and tostring(uuid) or ""
    return text ~= "" and text or nil
end

local function atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end

    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    end

    return 0
end

local function isSpawnableSquare(square)
    return square
        and square:isFree(false)
        and not square:isSolid()
        and not square:isSolidTrans()
end

local function findNearbySpawnSquare(cell, x, y, z, searchRadius)
    if not cell then
        return nil
    end

    local baseX = roundNumber(x)
    local baseY = roundNumber(y)
    local baseZ = roundNumber(z)
    local radiusLimit = math.max(0, math.floor(tonumber(searchRadius) or 0))

    for radius = 0, radiusLimit do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if radius == 0 or math.abs(dx) == radius or math.abs(dy) == radius then
                    local square = cell:getGridSquare(baseX + dx, baseY + dy, baseZ)
                    if isSpawnableSquare(square) then
                        return square
                    end
                end
            end
        end
    end

    return nil
end

local function buildArrivalAngles(playerX, playerY, npcData)
    local home = npcData and npcData.homeCoords or nil
    local baseAngle = nil
    if home and home.x ~= nil and home.y ~= nil then
        local dx = tonumber(home.x) - tonumber(playerX)
        local dy = tonumber(home.y) - tonumber(playerY)
        if math.abs(dx or 0) > 0.01 or math.abs(dy or 0) > 0.01 then
            baseAngle = atan2(dy or 0, dx or 0)
        end
    end

    if not baseAngle then
        baseAngle = ZombRandFloat(0, math.pi * 2)
    end

    return {
        baseAngle,
        baseAngle + 0.35,
        baseAngle - 0.35,
        baseAngle + 0.7,
        baseAngle - 0.7,
        baseAngle + 1.05,
        baseAngle - 1.05,
        baseAngle + math.pi,
    }
end

local function findOffscreenArrivalSquare(controller, npcData)
    if not controller then
        return nil
    end

    local cell = getCell()
    if not cell then
        return nil
    end

    local playerX = controller:getX()
    local playerY = controller:getY()
    local playerZ = controller:getZ()
    local angles = buildArrivalAngles(playerX, playerY, npcData)

    for radius = OFFSCREEN_FOLLOW_MAX_RADIUS, OFFSCREEN_FOLLOW_MIN_RADIUS, -4 do
        for _, angle in ipairs(angles) do
            local targetX = playerX + math.cos(angle) * radius
            local targetY = playerY + math.sin(angle) * radius
            local square = findNearbySpawnSquare(cell, targetX, targetY, playerZ, 4)
            if square then
                return square
            end
        end
    end

    for _ = 1, 24 do
        local angle = ZombRandFloat(0, math.pi * 2)
        local radius = OFFSCREEN_FOLLOW_MIN_RADIUS + ZombRand(OFFSCREEN_FOLLOW_MAX_RADIUS - OFFSCREEN_FOLLOW_MIN_RADIUS + 1)
        local square = findNearbySpawnSquare(
            cell,
            playerX + math.cos(angle) * radius,
            playerY + math.sin(angle) * radius,
            playerZ,
            5
        )
        if square then
            return square
        end
    end

    return findNearbySpawnSquare(cell, playerX + 1, playerY + 1, playerZ, 6)
end

local function findNearbyArrivalSquare(controller, minRadius, maxRadius)
    if not controller then
        return nil
    end

    local cell = getCell()
    if not cell then
        return nil
    end

    local playerX = controller:getX()
    local playerY = controller:getY()
    local playerZ = controller:getZ()
    local safeMin = math.max(0, math.floor(tonumber(minRadius) or 2))
    local safeMax = math.max(safeMin, math.floor(tonumber(maxRadius) or math.max(3, safeMin)))

    for radius = safeMin, safeMax do
        for _ = 1, 20 do
            local angle = ZombRandFloat(0, math.pi * 2)
            local square = findNearbySpawnSquare(
                cell,
                playerX + math.cos(angle) * radius,
                playerY + math.sin(angle) * radius,
                playerZ,
                2
            )
            if square then
                return square
            end
        end
    end

    return findNearbySpawnSquare(cell, playerX + 1, playerY + 1, playerZ, 4)
end

local function copyLoadout(loadout)
    if DTNPCProtect and DTNPCProtect.CopyLoadout then
        return DTNPCProtect.CopyLoadout(loadout)
    end

    loadout = type(loadout) == "table" and loadout or {}
    return {
        rangedWeapon = loadout.rangedWeapon or nil,
        rangedAmmoType = loadout.rangedAmmoType or nil,
        ammoCount = math.max(0, tonumber(loadout.ammoCount) or 0),
        meleeWeapon = loadout.meleeWeapon or nil,
        bag = loadout.bag or nil,
        rangedCondition = loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or nil,
        meleeCondition = loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or nil,
    }
end

local function loadoutEquals(left, right)
    left = copyLoadout(left)
    right = copyLoadout(right)

    return left.rangedWeapon == right.rangedWeapon
        and left.rangedAmmoType == right.rangedAmmoType
        and left.ammoCount == right.ammoCount
        and left.meleeWeapon == right.meleeWeapon
        and left.bag == right.bag
        and left.rangedCondition == right.rangedCondition
        and left.meleeCondition == right.meleeCondition
end

local function removeLiveNPCToStatus(uuid, zombie, npcData, status, returnTime, returnStatus)
    if not uuid or not npcData then
        return false
    end

    npcData.status = status or npcData.status
    npcData.returnTime = returnTime
    npcData.returnStatus = returnStatus
    npcData.state = "Idle"
    npcData.master = nil
    npcData.masterID = nil
    npcData.combatOrder = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = nil
    npcData.travelTarget = nil

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end

    if DTNPCManager and DTNPCManager.RemoveData then
        DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
    end

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    return true
end

function DTNPCServerCore.GetNPCDataByUUID(uuid)
    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID then
        return nil, nil
    end

    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(normalizedUUID) or nil
    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[normalizedUUID] or nil

    if not npcData and zombie and DTNPC and DTNPC.GetData then
        npcData = DTNPC.GetData(zombie)
    end
    if not npcData and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        npcData = DynamicTrading_Roster.GetSoul(normalizedUUID)
    end

    if npcData and DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    return zombie, npcData
end

function DTNPCServerCore.SpawnOffscreenCompanionByUUID(uuid, controller)
    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID or not controller or not DTNPCServerCore.RespawnNPC then
        return false, nil, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if zombie and npcData then
        return true, zombie, npcData
    end

    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "SpawnOffscreenCompanionByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil, nil
    end

    local arrivalSquare = findOffscreenArrivalSquare(controller, npcData)
    if not arrivalSquare then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unable to find offscreen arrival square for companion: " .. normalizedUUID)
        return false, nil, npcData
    end

    npcData.lastX = arrivalSquare:getX()
    npcData.lastY = arrivalSquare:getY()
    npcData.lastZ = arrivalSquare:getZ()
    npcData.status = "Working"
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.travelTarget = nil
    npcData.requestedReturnStatus = nil

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(normalizedUUID, npcData)
    end

    local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, normalizedUUID)
    if not spawnedZombie then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Failed to respawn offscreen companion: " .. normalizedUUID)
        return false, nil, spawnedData or npcData
    end

    return true, spawnedZombie, spawnedData or npcData
end

function DTNPCServerCore.StartPatchUpByUUID(uuid)
    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not zombie or not npcData or not DTNPCHealth or not DTNPCHealth.ForceEnterSelfBandage then
        return false, npcData
    end

    if DTNPCHealth.HasUsableBandageSupply and not DTNPCHealth.HasUsableBandageSupply(npcData) then
        if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
            DTNPCProtect.PushCompanionNotice(zombie, npcData, "I don't have any bandages or rags packed.", "warning")
        end
        return false, npcData
    end

    local entered = DTNPCHealth.ForceEnterSelfBandage(zombie, npcData, npcData.state or "Idle")
    if not entered and DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "I can't patch up right now.", "warning")
    end
    return entered == true, npcData
end

function DTNPCServerCore.SpawnNearbyCompanionByUUID(uuid, controller, minRadius, maxRadius)
    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID or not controller or not DTNPCServerCore.RespawnNPC then
        return false, nil, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if zombie and npcData then
        return true, zombie, npcData
    end

    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "SpawnNearbyCompanionByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil, nil
    end

    local arrivalSquare = findNearbyArrivalSquare(controller, minRadius, maxRadius)
    if not arrivalSquare then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unable to find nearby arrival square for companion: " .. normalizedUUID)
        return false, nil, npcData
    end

    npcData.lastX = arrivalSquare:getX()
    npcData.lastY = arrivalSquare:getY()
    npcData.lastZ = arrivalSquare:getZ()
    npcData.status = "Working"
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.travelTarget = nil
    npcData.requestedReturnStatus = nil

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(normalizedUUID, npcData)
    end

    local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, normalizedUUID)
    if not spawnedZombie then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Failed to respawn nearby companion: " .. normalizedUUID)
        return false, nil, spawnedData or npcData
    end

    return true, spawnedZombie, spawnedData or npcData
end

local function persistNPCUpdate(uuid, zombie, npcData, shouldBroadcast)
    if not uuid or not npcData then
        return false
    end

    if DTNPCManager and DTNPCManager.Data then
        DTNPCManager.Data[tostring(uuid)] = npcData
    end

    if zombie and DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(zombie, npcData)
    end

    if zombie and DTNPCManager and DTNPCManager.Register then
        DTNPCManager.Register(zombie, npcData)
    end

    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(tostring(uuid), npcData)
    end

    if zombie and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        if shouldBroadcast ~= false and DTNPCServerCore.BroadcastPosition then
            DTNPCServerCore.BroadcastPosition(zombie, npcData)
        end
    end

    return true
end

function DTNPCServerCore.UpdateNPCByUUID(uuid, updates, shouldBroadcast)
    if not uuid or type(updates) ~= "table" then
        return false, nil
    end

    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPCByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil
    end

    local changed = false
    for key, value in pairs(updates) do
        if key ~= "broadcastPosition" then
            if key == "loadout" then
                local normalizedLoadout = copyLoadout(value)
                if not loadoutEquals(npcData.loadout, normalizedLoadout) then
                    npcData.loadout = normalizedLoadout
                    changed = true
                end
            elseif npcData[key] ~= value then
                npcData[key] = value
                changed = true
            end
        end
    end

    if not changed then
        return false, npcData
    end

    persistNPCUpdate(normalizedUUID, zombie, npcData, shouldBroadcast)
    return true, npcData
end

function DTNPCServerCore.IssueOrderByUUID(uuid, controller, args)
    if not uuid or type(args) ~= "table" then
        return false, nil
    end

    local normalizedUUID = normalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "IssueOrderByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil
    end

    local state = tostring(args.state or npcData.state or "Idle")
    local masterUsername, masterID = normalizeController(controller)
    local usesMaster = state == "Follow"
        or state == "Flee"
        or state == "Attack"
        or state == "AttackRange"
        or state == "ProtectRanged"
        or state == "ProtectMelee"
        or state == "ProtectAuto"
    local requestedReturnStatus = args.returnStatus

    if usesMaster and not zombie and controller and DTNPCServerCore.SpawnNearbyCompanionByUUID then
        local spawned, spawnedZombie, spawnedData = DTNPCServerCore.SpawnNearbyCompanionByUUID(
            normalizedUUID,
            controller,
            2,
            5
        )
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
        removeLiveNPCToStatus(normalizedUUID, zombie, npcData, "Away", returnTime, nextStatus)
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
    if args.combatOrder == "ProtectRanged" or args.combatOrder == "ProtectMelee" or args.combatOrder == "ProtectAuto" then
        combatOrder = args.combatOrder
    elseif state == "ProtectRanged" or state == "ProtectMelee" or state == "ProtectAuto" then
        combatOrder = state
    end
    if npcData.combatOrder ~= combatOrder then
        npcData.combatOrder = combatOrder
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

    persistNPCUpdate(normalizedUUID, zombie, npcData, true)
    return true, npcData
end
