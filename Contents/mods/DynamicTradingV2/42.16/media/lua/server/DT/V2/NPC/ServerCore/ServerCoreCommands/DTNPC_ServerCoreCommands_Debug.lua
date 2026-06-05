-- ==============================================================================
-- DTNPC_ServerCoreCommands_Debug.lua
-- Debug helpers and command handlers for DTNPC server commands.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreCommands.Internal
local Handlers = DTNPCServerCoreCommands.Handlers

function Internal.GetPlayerHeldDebugWeapon(player)
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
        local lowered = Internal.Lower(fullType)
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

function Internal.GetScriptItem(fullType)
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

function Internal.IsDebugRangedWeapon(item, scriptItem)
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
    local lowered = Internal.Lower(fullType)
    return lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("carbine", 1, true) ~= nil
        or lowered:find("smg", 1, true) ~= nil
        or lowered:find("gun", 1, true) ~= nil
end

function Internal.DeriveDebugAmmoCount(item, scriptItem)
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

function Internal.RemoveHeldItemFromPlayer(player, item)
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

function Internal.CopyLoadoutForDebug(loadout)
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

function Internal.BuildDebugWeaponLoadout(npcData, item)
    local loadout = Internal.CopyLoadoutForDebug(npcData and npcData.loadout or nil)
    local fullType = item and item.getFullType and item:getFullType() or nil
    local scriptItem = Internal.GetScriptItem(fullType)
    local condition = item and item.getCondition and tonumber(item:getCondition()) or nil
    local isRanged = Internal.IsDebugRangedWeapon(item, scriptItem)

    if isRanged then
        loadout.rangedWeapon = fullType
        loadout.rangedAmmoType = scriptItem and scriptItem.getAmmoType and scriptItem:getAmmoType() or nil
        loadout.ammoCount = Internal.DeriveDebugAmmoCount(item, scriptItem)
        loadout.rangedCondition = condition
    else
        loadout.meleeWeapon = fullType
        loadout.meleeCondition = condition
    end

    return loadout, isRanged and "ranged" or "melee"
end

Handlers.DebugGiveHeldWeapon = function(player, args)
    if not player or not args or not args.uuid then
        return
    end

    local heldItem = Internal.GetPlayerHeldDebugWeapon(player)
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

    local loadout, slotKind = Internal.BuildDebugWeaponLoadout(npcData, heldItem)
    local removed = Internal.RemoveHeldItemFromPlayer(player, heldItem)

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
end

Handlers.DebugForceBandage = function(player, args)
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
end

Handlers.DebugForceCorpseCleanup = function(player, args)
    if not player or not args or not args.uuid then
        return
    end

    local zombie, npcData = nil, nil
    if DTNPCServerCore and DTNPCServerCore.GetNPCDataByUUID then
        zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(args.uuid)
    end
    if not zombie or not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "DebugForceCorpseCleanup for unknown UUID: " .. tostring(args.uuid))
        return
    end

    local targetState = "CorpseCleanup"
    local policyMode = "ai"
    local currentState = tostring(npcData.state or "Idle")
    local hasHome = type(npcData.homeCoords) == "table"
        and tonumber(npcData.homeCoords.x) ~= nil
        and tonumber(npcData.homeCoords.y) ~= nil

    if npcData.linkedWorkerID ~= nil and tostring(npcData.ownerUsername or "") ~= "" then
        targetState = "ColonyCorpseRemoval"
        policyMode = "colony"
    elseif hasHome ~= true then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Debug",
            "DebugForceCorpseCleanup refused: no home anchor for " .. tostring(npcData.name or args.uuid)
        )
        return
    end

    npcData.dcCorpseCleanupTask = nil
    npcData.dcCorpsePickupStartMs = nil
    npcData.dcCorpseWorkAnimActive = nil
    npcData.dcCorpseBlockedTicks = 0

    local now = getTimeInMillis and tonumber(getTimeInMillis()) or 0
    now = math.floor(now or 0)
    if targetState == "CorpseCleanup" then
        npcData.debugForceCorpseCleanupUntil = now + 20000
        npcData.debugForceCorpseCleanupMode = policyMode
        if currentState ~= "CorpseCleanup" and currentState ~= "ColonyCorpseRemoval" then
            npcData.dcCorpseCleanupResumeState = currentState
        end
    else
        npcData.debugForceCorpseCleanupUntil = nil
        npcData.debugForceCorpseCleanupMode = nil
        npcData.dcCorpseCleanupResumeState = nil
    end

    local available = DTNPCCorpseCleanup
        and DTNPCCorpseCleanup.HasAvailableTask
        and DTNPCCorpseCleanup.HasAvailableTask(npcData, {
            mode = policyMode,
            allowDebugForce = targetState == "CorpseCleanup",
        })
        or false

    if DTNPCServerCore and DTNPCServerCore.UpdateNPCByUUID then
        DTNPCServerCore.UpdateNPCByUUID(args.uuid, {
            state = targetState,
            debugForceCorpseCleanupUntil = npcData.debugForceCorpseCleanupUntil,
            debugForceCorpseCleanupMode = npcData.debugForceCorpseCleanupMode,
            dcCorpseCleanupResumeState = npcData.dcCorpseCleanupResumeState,
        }, true)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Debug",
        "DebugForceCorpseCleanup: " .. tostring(player:getUsername())
            .. " -> " .. tostring(npcData.name or args.uuid)
            .. " | state=" .. tostring(targetState)
            .. " | mode=" .. tostring(policyMode)
            .. " | available=" .. tostring(available == true)
    )
end
