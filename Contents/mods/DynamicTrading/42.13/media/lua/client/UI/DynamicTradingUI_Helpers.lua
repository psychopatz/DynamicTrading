-- =============================================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\client\UI\DynamicTradingUI_Helpers.lua
-- =============================================================================

function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    if not obj then return false end

    local data = obj:getDeviceData()
    if not data or not data:getIsTurnedOn() then return false end

    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 5.0 then return false end
        if data:getIsBatteryPowered() and data:getPower() <= 0 then return false end
        if not data:getIsBatteryPowered() and not sq:haveElectricity() then return false end
    else
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
end

function DynamicTradingUI:logLocal(text, isError)
    local entry = { text = text, error = isError or false }
    table.insert(self.localLogs, entry)

    self.chatList:clear()
    for _, log in ipairs(self.localLogs) do
        self.chatList:addItem(log.text, log)
    end
    self.chatList:ensureVisible(#self.chatList.items)
end

function DynamicTradingUI:drawLogItem(y, item, alt)
    local height = self.itemheight
    local width = self:getWidth()

    if alt then
        self:drawRect(0, y, width, height, 0.1, 0.1, 0.1, 0.5)
    end

    local r, g, b = 0.8, 0.8, 0.8
    if item.item.error then r, g, b = 1.0, 0.4, 0.4 end
    if string.find(item.item.text, "Purchased") then r, g, b = 0.4, 1.0, 0.4 end
    if string.find(item.item.text, "Sold") then r, g, b = 0.4, 0.8, 1.0 end

    self:drawText(item.text, 5, y + 2, r, g, b, 1, self.font)
    return y + height
end

-- =============================================================================
-- TRADER TEXTURES (LAYER 2: PORTRAIT)
-- =============================================================================
function DynamicTradingUI:getTraderTexture(trader)
    if not trader then return getTexture("Item_Radio") end

    local arch = trader.archetype or "General"
    local gender = trader.gender or "Male"
    local id = trader.portraitID or 1

    -- 1. Try Specific Path
    local specificPath = "media/ui/Portraits/" .. arch .. "/" .. gender .. "/" .. id .. ".png"
    local tex = getTexture(specificPath)
    if tex then return tex end

    -- 2. Try Fallback Path
    local fallbackPath = "media/ui/Portraits/General/" .. gender .. "/" .. id .. ".png"
    tex = getTexture(fallbackPath)
    if tex then return tex end

    -- 3. Ultimate Fallback
    return getTexture("Item_Radio")
end

-- =============================================================================
-- BACKGROUND TEXTURES (LAYER 1: DYNAMIC TIME)
-- =============================================================================
function DynamicTradingUI:getBackgroundTexture()
    local hour = GameTime:getInstance():getHour()
    local filename = "twilight" -- Default / Night

    -- Time Mapping Logic
    if hour >= 4 and hour < 6 then
        filename = "dawn"
    elseif hour >= 6 and hour < 9 then
        filename = "sunrise"
    elseif hour >= 9 and hour < 17 then
        -- Day Phase: Tries 'day.png', falls back to 'sunrise.png' if missing
        local dayTex = getTexture("media/ui/Backgrounds/day.png")
        if dayTex then return dayTex else filename = "sunrise" end
    elseif hour >= 17 and hour < 19 then
        filename = "sunset"
    elseif hour >= 19 and hour < 21 then
        filename = "dusk"
    elseif hour >= 21 or hour < 4 then
        filename = "twilight"
    end

    local path = "media/ui/Backgrounds/" .. filename .. ".png"
    local tex = getTexture(path)
    
    -- Fallback if specific phase missing
    if not tex then return getTexture("media/ui/Backgrounds/twilight.png") end
    
    return tex
end

-- =============================================================================
-- OVERLAY TEXTURES (LAYER 3: CRT EFFECT)
-- =============================================================================
function DynamicTradingUI:getOverlayTexture()
    return getTexture("media/ui/Effects/crt.png")
end

-- =============================================================================
-- UTILITIES
-- =============================================================================
function DynamicTradingUI.TruncateString(text, font, maxWidth)
    local tm = TextManager.instance
    if tm:MeasureStringX(font, text) <= maxWidth then return text end

    local len = #text
    while len > 0 do
        local truncated = string.sub(text, 1, len - 1) .. "..."
        if tm:MeasureStringX(font, truncated) <= maxWidth then
            return truncated
        end
        len = len - 1
    end
    return "..."
end

function DynamicTradingUI:getPlayerWealth(player)
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = loose and loose:size() or 0
    local bundleCount = bundles and bundles:size() or 0
    return looseCount + (bundleCount * 100)
end

function DynamicTradingUI:updateWallet()
    local player = getSpecificPlayer(0)
    local wealth = self:getPlayerWealth(player)
    if self.lblInfo then
        self.lblInfo:setName("Wallet: $" .. wealth)
    end
end

function DynamicTradingUI:updateIdentityDisplay(trader)
    if self.lblName then
        self.lblName:setName(trader.name or "Unknown")
    end

    if self.lblArchetype then
        local archName = "Survivor"
        if DynamicTrading.Archetypes and DynamicTrading.Archetypes[trader.archetype] then
            archName = DynamicTrading.Archetypes[trader.archetype].name
        end
        self.lblArchetype:setName(archName)
    end

    if self.lblSignal then
        local gt = GameTime:getInstance()
        local text = "Signal: Permanent"
        local r, g, b = 0.5, 0.8, 1.0

        if trader.expirationTime then
            local diff = trader.expirationTime - gt:getWorldAgeHours()
            
            if diff <= 0 then
                text = "Signal: Imminent Loss"
                r, g, b = 1.0, 0.0, 0.0
            elseif diff > 8 then
                text = string.format("Signal: Stable (%dh)", math.floor(diff))
                r, g, b = 0.2, 1.0, 0.2
            elseif diff < 1 then
                -- [NEW] Special handling for <1h remaining
                text = "Signal: Heavy Interference"
                r, g, b = 1.0, 0.4, 0.0 -- Bright Orange-Red alert color
            else
                text = string.format("Signal: Fading (%dh)", math.floor(diff))
                r, g, b = 1.0, 0.8, 0.2
            end
        end

        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end