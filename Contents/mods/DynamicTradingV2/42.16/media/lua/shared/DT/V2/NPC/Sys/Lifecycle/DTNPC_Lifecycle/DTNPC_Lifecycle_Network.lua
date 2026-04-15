-- ==============================================================================
-- DTNPC_Lifecycle_Network.lua
-- Network-facing lifecycle handlers for hit reports and client corpse policy.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

function DTNPCLifecycle.HandleReportWeaponHit(player, args)
    if not player or not args or not args.uuid then
        return false
    end

    if args.attackerOnlineID ~= nil and player.getOnlineID and player:getOnlineID() ~= args.attackerOnlineID then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Rejected ReportWeaponHit with mismatched attacker online ID for uuid=" .. tostring(args.uuid)
        )
        return true
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

    local damage = tonumber(args.damage) or 0
    if damage <= 0 then
        return true
    end

    if (not zombie or zombie:isDead()) and npcData and DTNPCHealth and DTNPCHealth.ApplyDamageToDataOnly then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "ReportWeaponHit applying data-only damage for dead/unresolved body "
                .. tostring(npcData.name or args.uuid)
                .. " uuid=" .. tostring(args.uuid)
                .. " player=" .. tostring(player:getUsername())
                .. " damage=" .. tostring(damage)
                .. " weapon=" .. tostring(args.weaponFullType)
                .. " clientHealthAfterHit=" .. tostring(args.targetHealthAfterHit)
        )
        local _, killed = DTNPCHealth.ApplyDamageToDataOnly(npcData, damage, player, {
            source = "client_weapon_hit_report_dead_body",
            weaponFullType = args.weaponFullType,
        })
        if killed and npcData.incapState == "Active" then
            DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, player)
        end
        return true
    end

    if not zombie or zombie:isDead() or not npcData then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "ReportWeaponHit could not resolve live DT NPC for uuid=" .. tostring(args.uuid)
        )
        return true
    end

    local modData = zombie:getModData()
    if not modData or modData.IsDTNPC ~= true then
        return true
    end

    local currentBodyInstanceID = npcData.currentBodyInstanceID
    if npcData.incapState == "Active"
        and args.bodyInstanceID
        and currentBodyInstanceID
        and args.bodyInstanceID ~= currentBodyInstanceID then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "Ignored stale pre-incapacitation ReportWeaponHit for "
                .. tostring(npcData.name or args.uuid)
                .. " uuid=" .. tostring(args.uuid)
                .. " reportedBodyInstanceID=" .. tostring(args.bodyInstanceID)
                .. " currentBodyInstanceID=" .. tostring(currentBodyInstanceID)
        )
        return true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
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
    return true
end

function DTNPCLifecycle.HandleClientRemovalCorpse(args, zombie, npcData)
    if not args then
        return false
    end

    local reason = args.removalReason or args.status
    local name = args.name or (npcData and npcData.name) or "Unknown"
    local preserveCorpse = reason == "Dead" and args.preserveCorpse == true
    local zombieX = zombie and math.floor(zombie:getX()) or nil
    local zombieY = zombie and math.floor(zombie:getY()) or nil
    local zombieZ = zombie and math.floor(zombie:getZ()) or nil

    local zombieIsDead = zombie and zombie.isDead and zombie:isDead() == true
    if zombie and preserveCorpse and not zombieIsDead then
        local createdCorpse = args.manualCorpseCreated == true
            or DTNPCLifecycle.CreateCorpseFromZombie(zombie, npcData, "client_preserved_dead", name) == true
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Remove",
            "Removed live local body for dead NPC after "
                .. (createdCorpse and "creating/receiving corpse: " or "corpse creation failed: ")
                .. name
        )
    elseif zombie and not preserveCorpse then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed zombie from local world: " .. name)
    elseif zombie and preserveCorpse then
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Preserved dead NPC body in local world: " .. name)
    end

    if args.cleanupCorpse == true or (reason == "Incapacitated" and args.cleanupCorpse == nil) then
        local corpseX = args.corpseX or (npcData and npcData.lastX) or zombieX
        local corpseY = args.corpseY or (npcData and npcData.lastY) or zombieY
        local corpseZ = args.corpseZ or (npcData and npcData.lastZ) or zombieZ or 0
        if corpseX and corpseY then
            local cleanupReason = reason == "Incapacitated" and "client_death_to_incapacitated" or "client_stale_body_cleanup"
            DTNPCLifecycle.CleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, cleanupReason)
            DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, cleanupReason .. "_delayed")
        end
    end

    return true
end
