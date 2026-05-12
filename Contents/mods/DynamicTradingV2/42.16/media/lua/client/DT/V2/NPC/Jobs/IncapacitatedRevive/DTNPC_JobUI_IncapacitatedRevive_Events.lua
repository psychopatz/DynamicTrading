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

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" or command ~= "ReviveResult" or type(args) ~= "table" then
        return
    end

    local pending = ReviveUI.pendingRequest
    ReviveUI.pendingRequest = nil

    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("npc-revive-result")
    end

    if not pending or not pending.ui or (pending.uuid and args.uuid and tostring(pending.uuid) ~= tostring(args.uuid)) then
        return
    end

    local npcData = ReviveUI.GetNPCData(pending.npc)
    if args.success == true then
        ReviveUI.ShowReviveResultConversation(pending.ui, pending.npc, pending.player, npcData or {}, args)
        return
    end

    pending.ui:speak(args.message or "You couldn't help them right now.")
    ReviveUI.ShowReviveConversation(pending.ui, pending.npc, pending.player, npcData or {})
end

Events.OnServerCommand.Add(onServerCommand)
