local Internal = DT_PricingOptionsTabInternal
local CreateInternal = DT_PricingOptionsCreateInternal

function CreateInternal.BuildEventHandlers(state)
    state.onConfigUpdated = function()
        Internal.refreshAll(state)
    end

    state.onActionResult = function(args)
        local message = args and args.message or "Pricing action completed."
        local warnings = args and args.warnings or nil

        if warnings and #warnings > 0 then
            message = message .. " (" .. tostring(#warnings) .. " warnings)"
        end
        Internal.setStatus(state, message, not (args and args.success))
        CreateInternal.RefreshPresetSelector(state)
        Internal.refreshAll(state)
    end
end

function CreateInternal.InstallPanelPrerender(owner, state)
    local panel = state.panel
    local previousPrerender = panel.prerender

    state.previousPanelPrerender = previousPrerender
    panel.prerender = function(self)
        local liveW
        local liveH

        if previousPrerender then
            previousPrerender(self)
        else
            ISPanel.prerender(self)
        end

        liveW = self.getWidth and self:getWidth() or self.width or 0
        liveH = self.getHeight and self:getHeight() or self.height or 0
        if liveW ~= state.lastPanelW or liveH ~= state.lastPanelH then
            state.lastPanelW = liveW
            state.lastPanelH = liveH
            DT_PricingOptionsTab.OnResize(owner)
        end
    end
end

function DT_PricingOptionsTab.Create(owner, panel)
    local state
    local defaultPresetName

    state = CreateInternal.NewState(owner, panel)
    CreateInternal.BuildWidgets(state)
    CreateInternal.BuildEventHandlers(state)

    Events.OnDynamicTradingPriceConfigUpdated.Add(state.onConfigUpdated)
    Events.OnDynamicTradingPriceConfigActionResult.Add(state.onActionResult)

    CreateInternal.InstallPanelPrerender(owner, state)

    owner.pricingState = state
    defaultPresetName = DT_ConfigManager and DT_ConfigManager.getLastPricePresetName and DT_ConfigManager.getLastPricePresetName() or "default"
    CreateInternal.RefreshPresetSelector(state, defaultPresetName)
    DT_PricingOptionsTab.OnResize(owner)
    DynamicTrading.PriceConfig.RequestSync()
    Internal.refreshAll(state)
end
