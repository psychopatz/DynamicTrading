-- ==============================================================================
-- Behavior_Attack_Shared.lua
-- Shared constants and helper functions for hostile attack behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}
local Constants = BehaviorAttack.Constants or {}

BehaviorAttack.Modules = modules
BehaviorAttack.Constants = Constants

if modules.Shared then
    return
end

modules.Shared = true

Constants.MELEE_DEFAULT_REACH = 1.25
Constants.MELEE_DEFAULT_SPEED = 0.05
Constants.MELEE_APPROACH_STOP_BUFFER = 0.16

function BehaviorAttack.IsPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

function BehaviorAttack.GetTimeMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

function BehaviorAttack.IsHostileDebugEnabled()
    if DynamicTrading and DynamicTrading.Debug == true then
        return true
    end

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and (sandbox.NPCDebug == true or sandbox.NPCProtectDebug == true) then
        return true
    end

    return DTNPCProtect
        and DTNPCProtect.CONFIG
        and (DTNPCProtect.CONFIG.DebugLogging == true or DTNPCProtect.CONFIG.CombatIssueLogging == true)
end

function BehaviorAttack.HostileDebugLog(npcData, event, message)
    if not BehaviorAttack.IsHostileDebugEnabled() or not DynamicTrading or not DynamicTrading.Log then
        return
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "HostileDebug",
        tostring(event or "state")
            .. " npc=" .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
            .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
            .. " " .. tostring(message or "")
    )
end

function BehaviorAttack.GetDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

function BehaviorAttack.CreatePointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
        isDead = function() return false end,
    }
end

function BehaviorAttack.GetPlayerTargetKey(player)
    if not player then
        return nil
    end
    if player.getOnlineID then
        local onlineID = player:getOnlineID()
        if onlineID and onlineID ~= 0 then
            return "player:" .. tostring(onlineID)
        end
    end
    if player.getUsername then
        return "player:" .. tostring(player:getUsername())
    end
    return tostring(player)
end

function BehaviorAttack.SyncHostileState(zombie, npcData, forcePosition)
    if not zombie or not npcData or not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie == zombie then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        if DTNPCServerCore.BroadcastPosition then
            DTNPCServerCore.BroadcastPosition(zombie, npcData, forcePosition == true)
        end
    end
end

function BehaviorAttack.PushHostileNotice(zombie, npcData, text, sentiment)
    if not npcData or not text or text == "" then
        return false
    end
    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, text, sentiment or "warning")
    end

    npcData.protectNoticeSerial = (tonumber(npcData.protectNoticeSerial) or 0) + 1
    npcData.protectNoticeText = text
    npcData.protectNoticeSentiment = sentiment or "warning"
    npcData.protectNoticeDialogueStatus = nil
    npcData.protectNoticeDialogueState = nil
    BehaviorAttack.SyncHostileState(zombie, npcData, true)
    return true
end

function BehaviorAttack.IsTradingLike(npcData)
    if not npcData then
        return false
    end
    return tostring(npcData.status or "") == "Trading"
        or tostring(npcData.state or "") == "Trading"
        or tostring(npcData.combatResumeState or "") == "Trading"
        or tostring(npcData.hostileReturnState or "") == "Trading"
        or tostring(npcData.stationaryPostState or "") == "Trading"
end

function BehaviorAttack.IsBanditLike(npcData)
    return npcData
        and (npcData.isBandit == true
            or npcData.banditGroupID ~= nil
            or npcData.raidHostileFaction == true
            or tostring(npcData.factionID or "") == "Bandits"
            or tostring(npcData.archetypeID or "") == "Bandit")
end
