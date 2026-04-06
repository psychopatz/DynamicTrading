-- ==============================================================================
-- DTNPC_ServerCore_Commands.lua
-- Client command handler for all NPC network operations.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- CLIENT COMMAND HANDLER
-- ==============================================================================

local function countTable(t)
    local count = 0
    for _ in pairs(t or {}) do count = count + 1 end
    return count
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function getPlayerHeldDebugWeapon(player)
    if not player then
        return nil
    end

    local primary = player:getPrimaryHandItem()
    if primary and primary.IsWeapon and primary:IsWeapon() then
        return primary
    end

    local secondary = player:getSecondaryHandItem()
    if secondary and secondary.IsWeapon and secondary:IsWeapon() then
        return secondary
    end

    local function looksLikeWeapon(item)
        if not item then
            return false
        end

        local fullType = item.getFullType and item:getFullType() or item.getType and item:getType() or ""
        local lowered = lower(fullType)
        return lowered:find("bat", 1, true) ~= nil
            or lowered:find("axe", 1, true) ~= nil
            or lowered:find("knife", 1, true) ~= nil
            or lowered:find("crowbar", 1, true) ~= nil
            or lowered:find("hammer", 1, true) ~= nil
            or lowered:find("pistol", 1, true) ~= nil
            or lowered:find("revolver", 1, true) ~= nil
            or lowered:find("shotgun", 1, true) ~= nil
            or lowered:find("rifle", 1, true) ~= nil
            or lowered:find("carbine", 1, true) ~= nil
    end

    if looksLikeWeapon(primary) then
        return primary
    end
    if looksLikeWeapon(secondary) then
        return secondary
    end

    return nil
end

local function getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end
    if manager and manager.getItem then
        return manager:getItem(fullType)
    end

    return nil
end

local function isDebugRangedWeapon(item, scriptItem)
    if not item then
        return false
    end

    if scriptItem then
        if scriptItem.isRanged and scriptItem:isRanged() then
            return true
        end
        if scriptItem.isAimedFirearm and scriptItem:isAimedFirearm() then
            return true
        end
        if scriptItem.getAmmoType and scriptItem:getAmmoType() and scriptItem:getAmmoType() ~= "" then
            return true
        end
    end

    local fullType = item.getFullType and item:getFullType() or item.getType and item:getType() or ""
    local lowered = lower(fullType)
    return lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("carbine", 1, true) ~= nil
        or lowered:find("smg", 1, true) ~= nil
        or lowered:find("gun", 1, true) ~= nil
end

local function deriveDebugAmmoCount(item, scriptItem)
    local count = 0
    if item and item.getCurrentAmmoCount then
        count = math.max(count, tonumber(item:getCurrentAmmoCount()) or 0)
    end

    local clipSize = nil
    if item and item.getMaxAmmo then
        clipSize = tonumber(item:getMaxAmmo())
    end
    if (not clipSize or clipSize <= 0) and scriptItem and scriptItem.getClipSize then
        clipSize = tonumber(scriptItem:getClipSize())
    end
    clipSize = math.max(1, math.floor(clipSize or 0))

    if count <= 0 then
        count = clipSize * 3
    end

    return math.max(0, math.floor(count))
end

local function removeHeldItemFromPlayer(player, item)
    if not player or not item then
        return false
    end

    if player:getPrimaryHandItem() == item then
        player:setPrimaryHandItem(nil)
    end
    if player:getSecondaryHandItem() == item then
        player:setSecondaryHandItem(nil)
    end

    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.RemoveItem then
        DynamicTrading.ServerHelpers.RemoveItem(item)
        return true
    end

    local container = item:getContainer()
    if container then
        container:DoRemoveItem(item)
        if sendRemoveItemFromContainer then
            sendRemoveItemFromContainer(container, item)
        end
        return true
    end

    return false
end

local function copyLoadoutForDebug(loadout)
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

local function buildDebugWeaponLoadout(npcData, item)
    local loadout = copyLoadoutForDebug(npcData and npcData.loadout or nil)
    local fullType = item and item.getFullType and item:getFullType() or nil
    local scriptItem = getScriptItem(fullType)
    local condition = item and item.getCondition and tonumber(item:getCondition()) or nil
    local isRanged = isDebugRangedWeapon(item, scriptItem)

    if isRanged then
        loadout.rangedWeapon = fullType
        loadout.rangedAmmoType = scriptItem and scriptItem.getAmmoType and scriptItem:getAmmoType() or nil
        loadout.ammoCount = deriveDebugAmmoCount(item, scriptItem)
        loadout.rangedCondition = condition
    else
        loadout.meleeWeapon = fullType
        loadout.meleeCondition = condition
    end

    return loadout, isRanged and "ranged" or "melee"
end

local function resolveFactionName(factionID)
    if not factionID then return "Independent" end
    local factions = ModData.get("DynamicTrading_Factions")
    if factions and factions.Factions and factions.Factions[factionID] then
        local f = factions.Factions[factionID]
        return f.name or f.displayName or factionID
    end
    return factionID
end

local function buildMetadataEntry(uuid, soul)
    return {
        uuid = uuid,
        name = soul.name,
        archetypeID = soul.archetypeID or "General",
        factionID = soul.factionID or "Independent",
        factionName = resolveFactionName(soul.factionID),
        isFemale = soul.isFemale,
        identitySeed = soul.identitySeed or 1,
        status = soul.status or "Unknown",
        state = soul.state,
        returnTime = soul.returnTime,
        lastX = soul.lastX or (soul.homeCoords and soul.homeCoords.x),
        lastY = soul.lastY or (soul.homeCoords and soul.homeCoords.y),
        lastZ = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0,
    }
end

local function getSoulCoords(soul)
    if not soul then return nil, nil, nil end
    return soul.lastX or (soul.homeCoords and soul.homeCoords.x),
        soul.lastY or (soul.homeCoords and soul.homeCoords.y),
        soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
end

local function isZombieNearSoul(zombie, soul)
    if not zombie or not soul then
        return false
    end

    local sx, sy, sz = getSoulCoords(soul)
    if not sx or not sy then
        return false
    end

    local dx = zombie:getX() - sx
    local dy = zombie:getY() - sy
    local dz = zombie:getZ() - sz
    return math.abs(dz) <= 1 and math.sqrt(dx * dx + dy * dy) <= 3
end

local function tryReclaimZombieFromStartupHint(uuid, npcData, soul)
    if not uuid or not npcData or not DTNPCServerCore or not DTNPCManager then
        return nil
    end

    local hintBodyInstanceID = npcData.startupBodyInstanceHint
    if not hintBodyInstanceID or not DTNPCServerCore.FindZombieByBodyInstanceID then
        return nil
    end

    local zombie = DTNPCServerCore.FindZombieByBodyInstanceID(hintBodyInstanceID)
    if not zombie or zombie:isDead() or not isZombieNearSoul(zombie, soul or npcData) then
        return nil
    end

    local existingUUID = DTNPCManager.GetUUIDFromZombie and DTNPCManager.GetUUIDFromZombie(zombie) or nil
    if existingUUID and existingUUID ~= uuid then
        return nil
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Adopt",
        "Reattached nearby startup body for " .. tostring(npcData.name or uuid) ..
            " using BodyInstanceID hint " .. tostring(hintBodyInstanceID)
    )

    if DTNPCManager.ReclaimZombie then
        return DTNPCManager.ReclaimZombie(zombie, npcData, "startup-hint")
    end

    DTNPCManager.Register(zombie, npcData)
    return zombie
end

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    if command == "Spawn" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Spawn command from: " .. player:getUsername())
        DTNPCServerCore.SpawnNPC(player, nil, args)
    end

    if command == "Summon" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Summon command from: " .. player:getUsername())
        DTNPCServerCore.SummonAll(player)
    end

    if command == "Order" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received Order command from: " .. player:getUsername() .. " | State: " .. (args.state or "Unknown"))

        if args.uuid and DTNPCServerCore and DTNPCServerCore.IssueOrderByUUID then
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
        if square then
            local movingObjects = square:getMovingObjects()
            for i=0, movingObjects:size()-1 do
                local obj = movingObjects:get(i)
                if instanceof(obj, "IsoZombie") then
                    local npcData = DTNPC.GetBrain(obj)
                    if npcData then
                        npcData.state = args.state
                        npcData.tasks = {} 
                        
                        npcData.anchorX = nil
                        npcData.anchorY = nil
                        npcData.anchorZ = nil
                        
                        npcData.requestedReturnStatus = args.returnStatus
                        npcData.combatTargetID = nil
                        
                        if args.state == "Follow" or args.state == "Flee"
                            or args.state == "ProtectRanged" or args.state == "ProtectMelee" or args.state == "ProtectAuto" then
                            npcData.master = player:getUsername()
                            npcData.masterID = isClient() and player:getOnlineID() or 0
                            npcData.combatOrder = (args.state == "ProtectRanged" or args.state == "ProtectMelee" or args.state == "ProtectAuto") and args.state or nil
                            DynamicTrading.Log("DTV2", "NPC", "Order", "Master assigned for " .. args.state .. " order: " .. npcData.master)
                        elseif args.state == "GoTo" then
                           table.insert(npcData.tasks, {x = args.targetX, y = args.targetY, z = args.targetZ or 0})
                           npcData.combatOrder = nil
                           DynamicTrading.Log("DTV2", "NPC", "Order", "GoTo task added: " .. args.targetX .. "," .. args.targetY .. "," .. (args.targetZ or 0))
                        else
                            npcData.combatOrder = nil
                        end

                        DTNPC.AttachData(obj, npcData)
                        if DTNPCManager then DTNPCManager.Register(obj, npcData) end
                        
                        DTNPCServerCore.SyncToAllClients(obj, npcData)
                        DTNPCServerCore.BroadcastPosition(obj, npcData)
                        break
                    end
                end
            end
        end
    end
    
    if command == "RequestSync" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestSync from: " .. player:getUsername())
        if not DTNPCManager then return end
        
        local cell = getCell()
        if not cell then return end
        
        local zombieList = cell:getZombieList()
        if not zombieList then return end
        
        local syncCount = 0
        for i = 0, zombieList:size() - 1 do
            local zombie = zombieList:get(i)
            if zombie then
                local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
                if uuid then
                    local npcData = DTNPCManager.Data[uuid]
                    if npcData then
                        DTNPCServerCore.SyncToPlayer(player, zombie, npcData)
                        syncCount = syncCount + 1
                    end
                end
            end
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent " .. syncCount .. " nearby NPCs to: " .. player:getUsername())
    end

    if command == "RequestFullSync" then
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received RequestFullSync from: " .. player:getUsername())
        if not DTNPCManager or not DTNPCManager.Data then return end
        
        sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent full database (" .. DTNPCManager.GetTableSize(DTNPCManager.Data) .. " NPCs) to: " .. player:getUsername())
    end

    if command == "RequestNearbySync" then
        if not player then return end

        local px = args and args.x or player:getX()
        local py = args and args.y or player:getY()
        local pz = args and args.z or player:getZ()
        local nearRadius = args and args.nearRadius or 200
        local metadataRadius = args and args.metadataRadius or 1000

        local nearby = {}
        local metadata = {}

        local roster = ModData.get("DynamicTrading_Roster")
        local souls = roster and roster.Souls or nil

        if souls then
            for uuid, soul in pairs(souls) do
                local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                local sz = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

                if sx and sy and math.abs((pz or 0) - sz) <= 1 then
                    local dx = px - sx
                    local dy = py - sy
                    local dist = math.sqrt(dx * dx + dy * dy)

                    if dist <= nearRadius then
                        local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
                        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
                        if not zombie and npcData then
                            zombie = tryReclaimZombieFromStartupHint(uuid, npcData, soul)
                        end
                        if npcData and zombie then
                            nearby[uuid] = {
                                uuid = uuid,
                                bodyInstanceID = zombie:getPersistentOutfitID(),
                                x = zombie:getX(),
                                y = zombie:getY(),
                                z = zombie:getZ(),
                                npcData = npcData,
                            }
                        else
                            metadata[uuid] = buildMetadataEntry(uuid, soul)
                        end
                    elseif dist <= metadataRadius then
                        metadata[uuid] = buildMetadataEntry(uuid, soul)
                    end
                end
            end
        end

        sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {
            nearby = nearby,
            metadata = metadata,
            nearRadius = nearRadius,
            metadataRadius = metadataRadius,
        })

        DynamicTrading.Log("DTV2", "NPC", "Sync", "Sent tiered sync to " .. player:getUsername() .. ": nearby=" .. countTable(nearby) .. ", metadata=" .. countTable(metadata))
    end

    if command == "ReportWeaponHit" then
        if not player or not args or not args.uuid then
            return
        end

        if args.attackerOnlineID ~= nil and player.getOnlineID and player:getOnlineID() ~= args.attackerOnlineID then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "Rejected ReportWeaponHit with mismatched attacker online ID for uuid=" .. tostring(args.uuid)
            )
            return
        end

        local zombie, npcData = nil, nil
        if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
            zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(args.uuid)
        end

        if (not zombie or zombie:isDead()) and args.bodyInstanceID and DTNPCServerCore and DTNPCServerCore.FindZombieByBodyInstanceID then
            zombie = DTNPCServerCore.FindZombieByBodyInstanceID(args.bodyInstanceID)
            if zombie and not npcData and DTNPC and DTNPC.GetData then
                npcData = DTNPC.GetData(zombie)
            end
        end

        if not zombie or zombie:isDead() or not npcData then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "ReportWeaponHit could not resolve live DT NPC for uuid=" .. tostring(args.uuid)
            )
            return
        end

        local modData = zombie:getModData()
        if not modData or modData.IsDTNPC ~= true then
            return
        end

        local damage = tonumber(args.damage) or 0
        if damage <= 0 then
            return
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Health",
            "ReportWeaponHit applying server-authoritative damage for "
                .. tostring(npcData.name or args.uuid)
                .. " uuid=" .. tostring(args.uuid)
                .. " player=" .. tostring(player:getUsername())
                .. " damage=" .. tostring(damage)
                .. " weapon=" .. tostring(args.weaponFullType)
                .. " clientHealthAfterHit=" .. tostring(args.targetHealthAfterHit)
        )

        if DTNPCHealth and DTNPCHealth.ApplyDamage then
            DTNPCHealth.ApplyDamage(zombie, npcData, damage, player, {
                source = "client_weapon_hit_report",
                weaponFullType = args.weaponFullType,
            })
        end
        return
    end

    if command == "UpdateNPC" then
        if not args.uuid or not args.updates then return end
        
        DynamicTrading.Log("DTV2", "NPC", "Command", "Received UpdateNPC for UUID: " .. args.uuid)

        if DTNPCServerCore and DTNPCServerCore.UpdateNPCByUUID then
            local changed, updatedNPC = DTNPCServerCore.UpdateNPCByUUID(
                args.uuid,
                args.updates,
                args.updates.broadcastPosition or false
            )
            if changed and updatedNPC then
                DynamicTrading.Log("DTV2", "NPC", "Update", "Updated and synced NPC via control module: " .. tostring(updatedNPC.name or args.uuid))
            elseif not updatedNPC then
                DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPC for unknown UUID: " .. args.uuid)
            end
            return
        end
        
        local uuid = args.uuid
        local serverBrain = DTNPCManager.Data[uuid]
        
        if serverBrain then
            local shouldBroadcast = args.updates.broadcastPosition or false
            
            for k, v in pairs(args.updates) do
                if k ~= "broadcastPosition" then
                    DynamicTrading.Log("DTV2", "NPC", "Update", "  Updating " .. k .. " to " .. tostring(v))
                    serverBrain[k] = v
                end
            end
            
            DTNPCManager.Save()
            
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            if zombie then
                DTNPC.AttachData(zombie, serverBrain)
                DTNPCServerCore.SyncToAllClients(zombie, serverBrain)
                
                if shouldBroadcast then
                    DynamicTrading.Log("DTV2", "NPC", "Update", "Broadcasting position due to state change")
                    DTNPCServerCore.BroadcastPosition(zombie, serverBrain)
                end
                
                DynamicTrading.Log("DTV2", "NPC", "Update", "Updated and synced NPC to all clients")
            end
        else
            DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPC for unknown UUID: " .. uuid)
        end
    end

    if command == "DebugGiveHeldWeapon" then
        if not player or not args or not args.uuid then
            return
        end

        local heldItem = getPlayerHeldDebugWeapon(player)
        if not heldItem then
            DynamicTrading.Log("DTV2", "NPC", "Debug", "DebugGiveHeldWeapon failed: player is not holding a valid weapon")
            return
        end

        local zombie, npcData = nil, nil
        if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
            zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(args.uuid)
        end
        if not npcData then
            DynamicTrading.Log("DTV2", "NPC", "Warn", "DebugGiveHeldWeapon for unknown UUID: " .. tostring(args.uuid))
            return
        end

        local loadout, slotKind = buildDebugWeaponLoadout(npcData, heldItem)
        local removed = removeHeldItemFromPlayer(player, heldItem)

        if DTNPCServerCore and DTNPCServerCore.UpdateNPCByUUID then
            DTNPCServerCore.UpdateNPCByUUID(args.uuid, {
                loadout = loadout,
                randomLoadoutType = (loadout.rangedWeapon and loadout.meleeWeapon) and "hybrid" or slotKind,
            }, true)
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Debug",
            "DebugGiveHeldWeapon: " .. tostring(player:getUsername())
                .. " -> " .. tostring(npcData.name or args.uuid)
                .. " | item=" .. tostring(heldItem:getFullType())
                .. " | slot=" .. tostring(slotKind)
                .. " | removed=" .. tostring(removed)
        )
        return
    end

    if command == "DebugForceBandage" then
        if not player or not args or not args.uuid then
            return
        end

        local zombie, npcData = nil, nil
        if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
            zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(args.uuid)
        end
        if not zombie or not npcData then
            DynamicTrading.Log("DTV2", "NPC", "Warn", "DebugForceBandage for unknown UUID: " .. tostring(args.uuid))
            return
        end

        local started = DTNPCHealth
            and DTNPCHealth.ForceEnterSelfBandage
            and DTNPCHealth.ForceEnterSelfBandage(zombie, npcData, npcData.state or "Idle")

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Debug",
            "DebugForceBandage: " .. tostring(player:getUsername())
                .. " -> " .. tostring(npcData.name or args.uuid)
                .. " | started=" .. tostring(started == true)
                .. " | state=" .. tostring(npcData.state)
        )
        return
    end

    if command == "RemoveNPC" then
        if not args.uuid then 
            DynamicTrading.Log("DTV2", "NPC", "Error", "RemoveNPC received with no UUID!")
            return 
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Received RemoveNPC request for UUID: " .. args.uuid .. " (Status: " .. (args.status or "nil") .. ")")
        
        if DTNPCManager then
            local name = "Unknown"
            if DTNPCManager.Data[args.uuid] then
                name = DTNPCManager.Data[args.uuid].name or "Unknown"
                DTNPCManager.RemoveData(args.uuid, args.status, args.returnTime, args.returnStatus)
                DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC data from database: " .. name .. " (" .. args.uuid .. ")")
            else
                DynamicTrading.Log("DTV2", "NPC", "Warn", "UUID " .. args.uuid .. " not found in database for removal.")
                -- Even if not in Manager, we might want to update Roster status if provided
                if DynamicTrading_Roster and args.status then
                    DynamicTrading_Roster.UpdateSoulStatus(args.uuid, args.status, args.returnTime, args.returnStatus)
                end
            end
            
            local zombie = DTNPCServerCore.FindZombieByUUID(args.uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed NPC from world: " .. args.uuid)
            else
                DynamicTrading.Log("DTV2", "NPC", "Remove", "INFO: NPC " .. args.uuid .. " not found in local world (may already be unloaded).")
            end
        else
            DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPCManager not available for removal!")
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
