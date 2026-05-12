local Internal = DT_PricingOptionsTabInternal

function DT_PricingOptionsTab.Refresh(owner)
    local state = owner and owner.pricingState or nil

    if not state then
        return
    end
    Internal.refreshAll(state)
end

function DT_PricingOptionsTab.SaveLocalState(owner)
    local state = owner and owner.pricingState or nil

    if not state then
        return
    end

    Internal.persistTreeState(state)
    if DT_ConfigManager and DT_ConfigManager.setLastPricePresetName and state.presetEntry then
        DT_ConfigManager.setLastPricePresetName(state.presetEntry:getText())
    end
end

function DT_PricingOptionsTab.Destroy(owner)
    local state = owner and owner.pricingState or nil

    if not state then
        return
    end

    DT_PricingOptionsTab.SaveLocalState(owner)

    if state.onConfigUpdated then
        Events.OnDynamicTradingPriceConfigUpdated.Remove(state.onConfigUpdated)
    end
    if state.onActionResult then
        Events.OnDynamicTradingPriceConfigActionResult.Remove(state.onActionResult)
    end
    if state.panel then
        state.panel.prerender = state.previousPanelPrerender
    end

    owner.pricingState = nil
end
