-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Events.lua
-- Network result handling for revive interactions.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Events then
    return
end

modules.Events = true

local function playReviveSuccessSound(npc)
    local soundName = tostring(DTNPCHealth and DTNPCHealth.REVIVE_SUCCESS_SOUND or "DT_Healed")
    if soundName == "" then
        return false
    end

    local emitter = npc and npc.getEmitter and npc:getEmitter() or nil
    if emitter and emitter.playSound then
        emitter:playSound(soundName)
        return true
    end

    if npc and npc.playSound then
        npc:playSound(soundName)
        return true
    end

    local square = npc and npc.getSquare and npc:getSquare() or nil
    local soundManager = getSoundManager and getSoundManager() or nil
    if square and soundManager and soundManager.PlayWorldSound then
        soundManager:PlayWorldSound(soundName, square, 0, 8, 1.0, false)
        return true
    end

    return false
end

local function sayReviveResult(npc, npcData, playerObj, args)
    if args and args.success == true then
        playReviveSuccessSound(npc)
        local thankYouLine = ReviveUI.T("DTNPC_Dialogue_ReviveThankYou", nil, "Thank you. I can make it home from here.")
        if DTNPC_WaveHiInteraction and DTNPC_WaveHiInteraction.BuildPlanForEmote then
            local plan = DTNPC_WaveHiInteraction.BuildPlanForEmote("thankyou", playerObj, npc, npcData)
            thankYouLine = plan and plan.introGreeting and plan.introGreeting.text
                or plan and plan.npcLine
                or thankYouLine
        end

        if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
            DTNPCProtect.PushCompanionNotice(npc, npcData or {}, thankYouLine, "friendly", "Chat")
        end

        if DTNPCHostility and DTNPCHostility.Say then
            DTNPCHostility.Say(npc, npcData or {}, thankYouLine, "Chat", "friendly")
        elseif npc and npc.setHaloNote then
            npc:setHaloNote(thankYouLine, 130, 255, 160, 300)
        end
        return
    end

    if playerObj and playerObj.setHaloNote then
        playerObj:setHaloNote(tostring(args and args.message or ReviveUI.T("DTNPC_Dialogue_ReviveCouldNotHelp", nil, "You couldn't help them right now.")), 255, 190, 120, 220)
    elseif playerObj and playerObj.Say then
        playerObj:Say(tostring(args and args.message or ReviveUI.T("DTNPC_Dialogue_ReviveCouldNotHelp", nil, "You couldn't help them right now.")))
    end
end

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" or command ~= "ReviveResult" or type(args) ~= "table" then
        return
    end

    local pending = ReviveUI.pendingRequest
    ReviveUI.pendingRequest = nil

    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("npc-revive-result")
    end

    if not pending or (pending.uuid and args.uuid and tostring(pending.uuid) ~= tostring(args.uuid)) then
        return
    end

    local npcData = ReviveUI.GetNPCData(pending.npc)
    sayReviveResult(pending.npc, npcData, pending.player, args)

    if not pending.ui then
        return
    end

    if args.success == true then
        ReviveUI.ShowReviveResultConversation(pending.ui, pending.npc, pending.player, npcData or {}, args)
        return
    end

    pending.ui:speak(args.message or ReviveUI.T("DTNPC_Dialogue_ReviveCouldNotHelp", nil, "You couldn't help them right now."))
    ReviveUI.ShowReviveConversation(pending.ui, pending.npc, pending.player, npcData or {})
end

Events.OnServerCommand.Add(onServerCommand)
