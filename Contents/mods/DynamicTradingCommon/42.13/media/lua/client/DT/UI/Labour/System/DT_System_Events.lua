local System = DT_System
local Internal = System.Internal

local function onServerCommand(module, command, args)
    if module ~= Internal.GetCommandModule() then
        return
    end

    if command ~= "SyncRecruitAttemptResult" then
        return
    end

    args = args or {}
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    if sourceNPCID then
        System.recruitResultCache[sourceNPCID] = args
    end

    local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
    if not ui then
        return
    end

    local currentSourceNPCID = System.GetConversationSourceNPCID(ui)
    if sourceNPCID and currentSourceNPCID and sourceNPCID ~= tostring(currentSourceNPCID) then
        return
    end

    if args.message and args.message ~= "" then
        ui:speak(args.message)
    end
    if args.success then
        System.OpenWindow()
    end
    ui:updateOptions(ui.baseOptions or {})
end

if not System.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    System.EventsAdded = true
end
