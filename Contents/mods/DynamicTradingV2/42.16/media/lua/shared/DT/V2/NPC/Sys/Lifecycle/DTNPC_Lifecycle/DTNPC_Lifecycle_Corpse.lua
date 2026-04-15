-- ==============================================================================
-- DTNPC_Lifecycle_Corpse.lua
-- Corpse creation, preservation contexts, and stray body cleanup.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal
local pendingIncapacitationCorpseCleanups = {}

function DTNPCLifecycle.CleanupStrayIncapacitationCorpse(x, y, z, npcData, reason)
    local cell = getCell and getCell() or nil
    local square = cell and cell:getGridSquare(x, y, z or 0) or nil
    if not square then
        return false
    end

    local removed = 0
    local function purgeFromList(list)
        if not list then
            return
        end

        for i = list:size() - 1, 0, -1 do
            local obj = list:get(i)
            if obj and instanceof and instanceof(obj, "IsoDeadBody") then
                obj:removeFromWorld()
                obj:removeFromSquare()
                removed = removed + 1
            end
        end
    end

    if square.getStaticMovingObjects then
        purgeFromList(square:getStaticMovingObjects())
    end
    if removed <= 0 and square.getMovingObjects then
        purgeFromList(square:getMovingObjects())
    end

    if removed > 0 then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "Removed stray incapacitation corpse(s) for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " count=" .. tostring(removed)
                .. " reason=" .. tostring(reason or "incap_transition")
                .. " square=" .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z or 0)
        )
        return true
    end

    return false
end

local function runPendingIncapacitationCorpseCleanups()
    for i = #pendingIncapacitationCorpseCleanups, 1, -1 do
        local cleanup = pendingIncapacitationCorpseCleanups[i]
        cleanup.attempts = (cleanup.attempts or 0) + 1

        local removed = DTNPCLifecycle.CleanupStrayIncapacitationCorpse(
            cleanup.x,
            cleanup.y,
            cleanup.z,
            cleanup.npcData,
            cleanup.reason
        )

        if removed or cleanup.attempts >= (cleanup.maxAttempts or 8) then
            table.remove(pendingIncapacitationCorpseCleanups, i)
        end
    end

    if #pendingIncapacitationCorpseCleanups <= 0 and Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
    end
end

function DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(x, y, z, npcData, reason)
    if not x or not y then
        return
    end

    table.insert(pendingIncapacitationCorpseCleanups, {
        x = x,
        y = y,
        z = z or 0,
        npcData = npcData,
        reason = reason,
        attempts = 0,
        maxAttempts = 8,
    })

    if Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
        Events.OnTick.Add(runPendingIncapacitationCorpseCleanups)
    end
end

function DTNPCLifecycle.WithIncapacitationCorpseCleanupContext(removalContext, x, y, z)
    local context = internal.copyContext(removalContext)
    context.cleanupCorpse = true
    context.corpseX = x
    context.corpseY = y
    context.corpseZ = z or 0
    return context
end

function DTNPCLifecycle.WithPreservedCorpseContext(removalContext)
    local context = internal.copyContext(removalContext)
    context.preserveCorpse = true
    return context
end

function DTNPCLifecycle.WithStaleBodyCleanupContext(removalContext, x, y, z)
    local context = DTNPCLifecycle.WithIncapacitationCorpseCleanupContext(removalContext, x, y, z)
    context.staleBodyOnly = true
    return context
end

function DTNPCLifecycle.WithFinalKillContext(zombie, removalContext)
    local isCorpseReady = zombie and zombie.isDead and zombie:isDead() == true
    if isCorpseReady then
        return DTNPCLifecycle.WithPreservedCorpseContext(removalContext)
    end

    local context = internal.copyContext(removalContext)
    context.preserveCorpse = true
    context.forcedLiveBodyRemoval = true
    return context
end

function DTNPCLifecycle.CreateCorpseFromZombie(zombie, npcData, reason, name)
    if not zombie or not IsoDeadBody then
        return false, nil
    end

    local ok, body = pcall(IsoDeadBody.new, zombie, false, true)
    if not ok or not body then
        ok, body = pcall(IsoDeadBody.new, zombie, false)
    end
    if not ok or not body then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Failed to create manual corpse for "
                .. tostring(name or (npcData and (npcData.name or npcData.uuid)) or "Unknown")
                .. " reason=" .. tostring(reason or "final_kill")
                .. " error=" .. tostring(body)
        )
        return false, nil
    end

    local bodyModData = body.getModData and body:getModData() or nil
    if bodyModData and npcData then
        bodyModData.DTNPC_UUID = npcData.uuid
        bodyModData.DTNPC_Name = npcData.name
        bodyModData.DTNPC_FinalKillCorpse = true
    end

    if isServer and isServer() and body.transmitCompleteItemToClients then
        pcall(function()
            body:transmitCompleteItemToClients()
        end)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "Created manual corpse for "
            .. tostring(name or (npcData and (npcData.name or npcData.uuid)) or "Unknown")
            .. " reason=" .. tostring(reason or "final_kill")
    )
    return true, body
end
