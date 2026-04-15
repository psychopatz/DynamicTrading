-- =============================================================================
-- TEXTURE & VISUAL ENGINE
-- =============================================================================

function DT_TradingWindow:getTraderTexture(trader)
    return DT_NPCPortraitRenderers.GetLegacyTexture(trader, self.dataProvider)
end

function DT_TradingWindow:getBackgroundTexture()
    return DT_NPCPortraitRenderers.GetBackgroundTexture()
end

function DT_TradingWindow:getOverlayTexture()
    return DT_NPCPortraitRenderers.GetOverlayTexture()
end
