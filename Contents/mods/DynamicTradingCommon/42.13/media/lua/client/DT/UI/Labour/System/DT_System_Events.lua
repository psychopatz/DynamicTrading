local System = DT_System
local Internal = System.Internal

local function onServerCommand(module, command, args)
    if module ~= Internal.GetCommandModule() then
        return
    end

    if command ~= "SyncRecruitAttemptResult" then
        if command == "SyncOwnedFactionStatus" then
            System.ownedFactionStatusCache = args and args.status or nil

            local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
            if ui then
                ui:updateOptions(ui.baseOptions or {})
            end
            return
        end

        if command == "OwnedFactionActionResult" then
            if args and args.success and args.discoverTrader and args.traderID
                and DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.DiscoverTrader then
                local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
                if player then
                    DynamicTrading.Manager.DiscoverTrader(args.traderID, player)
                end
            end

            local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
            if ui and args and args.message and args.message ~= "" then
                ui:speak(args.message)
                ui:updateOptions(ui.baseOptions or {})
            end
            return
        end

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
