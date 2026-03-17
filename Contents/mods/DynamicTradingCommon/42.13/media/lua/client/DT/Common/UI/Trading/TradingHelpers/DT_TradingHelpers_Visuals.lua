-- =============================================================================
-- TEXTURE & VISUAL ENGINE
-- =============================================================================

function DT_TradingWindow:getTraderTexture(trader)
    if not trader then return getTexture("Item_Radio") end
    local arch = trader.archetype or "General"
    local gender = trader.gender or "Male"
    local seed = trader.identitySeed or 1

    -- CRITICAL FIX: The identitySeed is a persistent seed (1-1000).
    -- It MUST be mapped to the actual file count using GetMappedID.
    local mappedID = 1
    if self.dataProvider and self.dataProvider.getPortraitID then
        mappedID = self.dataProvider:getPortraitID(arch, gender, seed)
    elseif DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetMappedID then
        mappedID = DynamicTrading.Portraits.GetMappedID(arch, gender, seed)
    else
        -- Fallback if no mapper exists (shouldn't happen in finalized build)
        mappedID = 1
    end

    local pathFolder = "media/ui/Portraits/" .. arch .. "/" .. gender .. "/"
    if self.dataProvider and self.dataProvider.getPortraitPath then
        pathFolder = self.dataProvider:getPortraitPath(arch, gender)
    elseif DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetPathFolder then
        pathFolder = DynamicTrading.Portraits.GetPathFolder(arch, gender)
    end

    local specificPath = pathFolder .. tostring(mappedID) .. ".png"
    local tex = getTexture(specificPath)
    if tex then return tex end

    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

function DT_TradingWindow:getBackgroundTexture()
    local hour = GameTime:getInstance():getHour()
    local filename = "twilight"
    if hour >= 4 and hour < 6 then filename = "dawn"
    elseif hour >= 6 and hour < 9 then filename = "sunrise"
    elseif hour >= 9 and hour < 17 then
        local dayTex = getTexture("media/ui/Backgrounds/day.png")
        if dayTex then return dayTex else filename = "sunrise" end
    elseif hour >= 17 and hour < 19 then filename = "sunset"
    elseif hour >= 19 and hour < 21 then filename = "dusk"
    elseif hour >= 21 or hour < 4 then filename = "twilight"
    end
    local path = "media/ui/Backgrounds/" .. filename .. ".png"
    local tex = getTexture(path)
    return tex or getTexture("media/ui/Backgrounds/twilight.png")
end

function DT_TradingWindow:getOverlayTexture()
    return getTexture("media/ui/Effects/crt.png")
end
