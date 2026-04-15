DynamicTrading = DynamicTrading or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {}

local COLONY_MANUAL_ID = "dc_scavenging"
local COLONY_MANUAL_PAGE_ID = "scavenge_overview"

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("DynamicColonies") or false
end

local function openColonyManual()
    if not isDynamicColoniesActive() then
        return false
    end

    if not (DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Open) then
        return false
    end

    DynamicTrading.Manuals.Open({
        viewMode = "manuals",
        manualId = COLONY_MANUAL_ID,
        pageId = COLONY_MANUAL_PAGE_ID,
    })
    return true
end

local function patchColonyHelp()
    if not isDynamicColoniesActive() then
        return
    end

    if DC_ColonyHelpWindow and not DC_ColonyHelpWindow.__dtManualBridgePatched then
        local originalOpen = DC_ColonyHelpWindow.Open
        DC_ColonyHelpWindow.__dtManualBridgePatched = true
        DC_ColonyHelpWindow.__dtManualBridgeOriginalOpen = originalOpen

        function DC_ColonyHelpWindow.Open()
            if openColonyManual() then
                return nil
            end
            if originalOpen then
                return originalOpen()
            end
            return nil
        end
    end

    if DC_MainWindow and not DC_MainWindow.__dtManualBridgePatched then
        local originalHandler = DC_MainWindow.onOpenHelp
        DC_MainWindow.__dtManualBridgePatched = true

        function DC_MainWindow:onOpenHelp()
            if openColonyManual() then
                if self.updateStatus then
                    self:updateStatus("Opened scavenging manual.")
                end
                return
            end

            if originalHandler then
                return originalHandler(self)
            end
        end
    end
end

Events.OnGameStart.Add(patchColonyHelp)
Events.OnCreatePlayer.Add(function()
    patchColonyHelp()
end)
