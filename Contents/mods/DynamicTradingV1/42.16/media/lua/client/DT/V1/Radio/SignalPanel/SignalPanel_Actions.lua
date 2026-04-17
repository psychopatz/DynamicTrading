-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - ACTIONS
-- =============================================================================

V1_SignalPanel_Actions_logic = {}

function DT_SignalPanel:onScanClick()
    local player = getSpecificPlayer(0)
    if self.parent and self.parent.CheckConnectionValidity and not self.parent:CheckConnectionValidity() then
        self.parent:close()
        return
    end

    self.signalFoundPersist = false
    self.clickAnimTimer = 300
    sendClientCommand(player, "DynamicTrading", "RequestFullState", {})

    if DT_RadioInteraction and DT_RadioInteraction.PerformScan then
        DT_RadioInteraction.PerformScan(player, self.parent.radioObj, self.parent.isHam)
    end
end

function DT_SignalPanel.OnServerCommand(module, command, args)
    if module == "DynamicTrading" and command == "ScanResult" and args.status == "CAPACITY_FULL" then
        local player = getSpecificPlayer(0)
        if player then
            player:Say("This radio's memory is full. (" .. args.currentCount .. "/" .. args.capacity .. ")")
            if DT_AudioManager then
                DT_AudioManager.PlaySound("DT_RadioRandom", false, 0.1)
            end
        end
    end
end

Events.OnServerCommand.Remove(DT_SignalPanel.OnServerCommand)
Events.OnServerCommand.Add(DT_SignalPanel.OnServerCommand)

function DT_SignalPanel:onInfoClick()
    if DT_FactionInfoWindow then
        DT_FactionInfoWindow.ToggleWindow()
    end
end

function DT_SignalPanel:onContactsClick()
    DT_ContactsWindow.Open()
end

function DT_SignalPanel:onOptionsClick()
    if DT_OptionsManager then
        DT_OptionsManager.ToggleWindow()
    else
        DynamicTrading.Log("DTV1", "Radio", "Error", "DT_OptionsManager failed to load.")
    end
end
