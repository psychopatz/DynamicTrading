-- ==============================================================================
-- DTNPC_ManagerTick_ShellCleanup.lua
-- Helpers for identifying and cleaning orphaned abstract soul shells.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}

local tickInternal = DTNPCManager.TickInternal

function tickInternal.IsZombieNakedShell(zombie)
    if not zombie or zombie:isDead() then
        return false, false
    end

    local modData = zombie:getModData()
    local hasDTMarkers = modData and (
        modData.IsDTNPC == true
        or modData.DTNPC_UUID ~= nil
        or modData.DTNPC_Data ~= nil
        or modData.DTNPCBrain ~= nil
        or modData.DTNPCPresenceRevision ~= nil
    ) or false
    local hasDTVariable = zombie.getVariableBoolean and zombie:getVariableBoolean("DTNPC") == true or false
    local useless = zombie.isUseless and zombie:isUseless() == true or false
    local hasSignature = hasDTMarkers or hasDTVariable or useless

    local wornItems = zombie.getWornItems and zombie:getWornItems() or nil
    local itemVisuals = zombie.getItemVisuals and zombie:getItemVisuals() or nil
    local wornCount = wornItems and wornItems.size and wornItems:size() or 0
    local visualCount = itemVisuals and itemVisuals.size and itemVisuals:size() or 0

    if wornCount > 0 or visualCount > 0 then
        return false, false
    end

    return true, hasSignature
end

function tickInternal.FindNearbyAbstractSoulForZombie(zombie, players, rosterSouls, requireShellSignature)
    if not zombie or not rosterSouls or not players or #players == 0 then
        return nil, nil
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local maxSoulDist = requireShellSignature and 3.5 or 1.25

    for uuid, soul in pairs(rosterSouls) do
        if soul and DTNPCManager.IsPhysicalWorldStatus and not DTNPCManager.IsPhysicalWorldStatus(soul.status, soul) then
            if requireShellSignature or tostring(soul.status or "") == "Away" then
                local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                local sz = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

                if sx and sy and math.abs(zz - sz) <= 1 then
                    local dx = zx - sx
                    local dy = zy - sy
                    local soulDist = math.sqrt(dx * dx + dy * dy)
                    if soulDist <= maxSoulDist then
                        for _, player in ipairs(players) do
                            if math.abs(player:getZ() - sz) <= 1 then
                                local pdx = player:getX() - sx
                                local pdy = player:getY() - sy
                                local playerDist = math.sqrt(pdx * pdx + pdy * pdy)
                                if playerDist <= 80 then
                                    return uuid, soul
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nil, nil
end

function tickInternal.CleanupNearbyAbstractSoulShells(zombieList, players)
    if not zombieList or not players or #players == 0 or not DTNPCManager.IsPhysicalWorldStatus then
        return
    end

    local rosterData = ModData and ModData.get and ModData.get("DynamicTrading_Roster") or nil
    local rosterSouls = rosterData and rosterData.Souls or nil
    if not rosterSouls then
        return
    end

    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        local isNakedShell, hasShellSignature = tickInternal.IsZombieNakedShell(zombie)
        if isNakedShell then
            local uuid, soul = tickInternal.FindNearbyAbstractSoulForZombie(zombie, players, rosterSouls, hasShellSignature)
            if uuid and soul then
                tickInternal.RemoveStaleWorldBody(
                    uuid,
                    zombie,
                    soul,
                    hasShellSignature and "abstract-shell-cleanup" or "abstract-naked-zombie-cleanup"
                )
            end
        end
    end
end
