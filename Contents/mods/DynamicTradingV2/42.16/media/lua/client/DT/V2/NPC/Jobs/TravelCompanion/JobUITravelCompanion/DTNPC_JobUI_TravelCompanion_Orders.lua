-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Orders.lua
-- Companion command dispatch and live state patching.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Orders then
    return
end

modules.Orders = true

function CompanionUI.SendCompanionOrder(player, npc, args)
    local npcData = CompanionUI.GetNPCData(npc)
    if not player or not npcData or not npcData.uuid then
        return false, npcData
    end

    args = type(args) == "table" and args or {}
    args.uuid = npcData.uuid
    sendClientCommand(player, "DTNPC", "Order", args)
    return true, npcData
end

function CompanionUI.UpdateCompanionState(player, npc, state, extraArgs)
    local sent, npcData = CompanionUI.SendCompanionOrder(player, npc, extraArgs and extraArgs or { state = state })
    if not sent or not npcData then
        return false
    end

    if state ~= "PatchUp" then
        if DTNPCHealth and DTNPCHealth.CancelPendingSelfBandage then
            DTNPCHealth.CancelPendingSelfBandage(npc, npcData, state, {
                manualInterrupt = true,
                retryDelayMs = DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS,
                sync = false,
            })
        end
        npcData.state = state or npcData.state
    end

    if extraArgs and extraArgs.combatOrder then
        npcData.combatOrder = extraArgs.combatOrder
    elseif state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.combatOrder = state
    elseif state ~= "PatchUp" then
        npcData.combatOrder = nil
    end

    if extraArgs and extraArgs.guardCombatOrder then
        npcData.guardCombatOrder = extraArgs.guardCombatOrder
        npcData.guardAttackMode = extraArgs.guardCombatOrder
    elseif extraArgs and extraArgs.guardAttackMode then
        npcData.guardAttackMode = extraArgs.guardAttackMode
        npcData.guardCombatOrder = extraArgs.guardAttackMode
    elseif state == "Stay" and extraArgs and extraArgs.clearGuardMode == true then
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
    elseif state == "PatchUp" then
        -- Preserve guard settings through temporary self-care orders.
    elseif state ~= "Guard" then
        npcData.guardCombatOrder = npcData.guardCombatOrder
        npcData.guardAttackMode = npcData.guardAttackMode
    end

    local followSpacingMode = CompanionUI.NormalizeFollowSpacingMode and CompanionUI.NormalizeFollowSpacingMode(extraArgs and extraArgs.followSpacingMode or nil) or nil
    if followSpacingMode then
        npcData.followSpacingMode = followSpacingMode
    end

    if state == "Follow" or state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.master = player and player.getUsername and player:getUsername() or npcData.master
        npcData.masterID = player and player.getOnlineID and player:getOnlineID() or npcData.masterID
    end

    if state == "Guard" and npc then
        npcData.stationaryPostX = npc:getX()
        npcData.stationaryPostY = npc:getY()
        npcData.stationaryPostZ = npc:getZ()
        npcData.stationaryPostState = "Guard"
        npcData.anchorX = npc:getX()
        npcData.anchorY = npc:getY()
        npcData.anchorZ = npc:getZ()
        npcData.guardReturningToPost = nil
    end

    if state == "Stay" then
        npcData.guardReturningToPost = nil
    end

    npcData.tasks = {}
    CompanionUI.AttachNPCData(npc, npcData)
    return true
end

function CompanionUI.BuildFollowOrderArgs(npcData, extraArgs)
    local args = type(extraArgs) == "table" and extraArgs or {}
    local followSpacingMode = CompanionUI.NormalizeFollowSpacingMode
        and CompanionUI.NormalizeFollowSpacingMode(args.followSpacingMode or (npcData and npcData.followSpacingMode) or nil)
        or nil

    args.state = "Follow"
    args.returnStatus = args.returnStatus or "Resting"
    if followSpacingMode then
        args.followSpacingMode = followSpacingMode
    end

    return args
end

function CompanionUI.PlayCompanionCommandCue(player, cueKey)
    if DTNPC_CommandEmotes and DTNPC_CommandEmotes.Play then
        DTNPC_CommandEmotes.Play(player, cueKey)
    end
end

function CompanionUI.ResolveCompanionCommandCue(state, extraArgs)
    local explicitCue = CompanionUI.NormalizeText(extraArgs and extraArgs.commandCue or nil)
    if explicitCue then
        return explicitCue
    end

    local combatOrder = CompanionUI.NormalizeText(extraArgs and extraArgs.combatOrder or nil)
    if combatOrder then
        return combatOrder
    end

    local guardOrder = CompanionUI.NormalizeText(extraArgs and (extraArgs.guardCombatOrder or extraArgs.guardAttackMode) or nil)
    if guardOrder then
        return guardOrder
    end

    return CompanionUI.NormalizeText(state)
end

function CompanionUI.IssueCompanionStateOrder(player, npc, state, extraArgs)
    local sent = CompanionUI.UpdateCompanionState(player, npc, state, extraArgs)
    if sent then
        CompanionUI.PlayCompanionCommandCue(player, CompanionUI.ResolveCompanionCommandCue(state, extraArgs))
    end
    return sent
end

function CompanionUI.SendPatchUpOrder(player, npc)
    return CompanionUI.UpdateCompanionState(player, npc, "PatchUp", {
        state = "PatchUp",
    })
end

function CompanionUI.SendCompanionHome(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    return DC_System.SendCommand("SetWorkerJobEnabled", {
        workerID = worker.workerID,
        enabled = false,
    }) == true
end

function CompanionUI.OrderCompanionReturnHome(player, npc)
    local sent, npcData = CompanionUI.SendCompanionOrder(player, npc, {
        state = "Idle",
        returnStatus = "Resting",
        startDeparture = true,
    })
    if not sent or not npcData then
        return false
    end

    npcData.state = "Departure"
    npcData.status = "Away"
    npcData.returnStatus = "Resting"
    npcData.requestedReturnStatus = "Resting"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatOrder = nil
    CompanionUI.AttachNPCData(npc, npcData)
    return true
end
