require "Utils/DT_StringUtils"

-- =============================================================================
-- 1. CONNECTION & POWER VALIDATION
-- =============================================================================
function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    if not obj then return false end

    local data = nil
    if obj.getDeviceData then
        data = obj:getDeviceData()
    end
    
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

-- =============================================================================
-- 2. LOGGING & FEEDBACK (BUBBLE STYLE)
-- =============================================================================
--- Adds a message to the chat list.
function DynamicTradingUI:logLocal(text, isError, isPlayer)
    -- [ADJUSTED] Reduced padding from 25 to 13 to match scrollbar width exactly
    local padding = 13 
    local fullWidth = self.chatList:getWidth() - padding
    if fullWidth <= 50 then fullWidth = 200 end 
    
    local bubbleWidth = fullWidth * 0.85 
    local font = self.chatList.font
    local lines = DynamicTrading.Utils.WrapText(text, bubbleWidth, font)
    
    local lineHeight = self.chatList.itemheight or 18
    local totalHeight = #lines * lineHeight
    totalHeight = totalHeight + 4 
    if totalHeight < lineHeight then totalHeight = lineHeight end 

    local entry = { 
        text = text, 
        error = isError or false,
        isPlayer = isPlayer or false, 
        lines = lines,
        height = totalHeight
    }
    table.insert(self.localLogs, entry)

    self.chatList:clear()
    for _, log in ipairs(self.localLogs) do
        local addedItem = self.chatList:addItem(log.text, log)
        addedItem.height = log.height + 2 
    end
    self.chatList:ensureVisible(#self.chatList.items)
end

function DynamicTradingUI:drawLogItem(y, item, alt)
    local data = item.item 
    local height = data.height or self.itemheight
    local width = self:getWidth()
    local lineHeight = self.itemheight
    local tm = getTextManager()

    -- [ADJUSTED] Tighter padding to make bubbles stick to the scrollbar
    local padding = 13 

    -- ==========================================================
    -- BACKGROUND BUBBLE LOGIC
    -- ==========================================================
    local bubbleWidth = (width - padding) * 0.85
    
    if data.isPlayer then
        -- PLAYER: Right side
        -- xPos is calculated so the bubble ends exactly at (width - padding)
        local xPos = (width - padding) - bubbleWidth
        
        self:drawRect(xPos, y, bubbleWidth, height, 0.1, 0.2, 0.35, 0.7) 
        self:drawRectBorder(xPos, y, bubbleWidth, height, 0.2, 0.4, 0.6, 0.3)
        
    elseif data.error then
        -- ERROR: Left side
        self:drawRect(0, y, bubbleWidth, height, 0.3, 0.1, 0.1, 0.7)
        self:drawRectBorder(0, y, bubbleWidth, height, 0.5, 0.2, 0.2, 0.5)
        
    else
        -- TRADER / SYSTEM: Left side
        self:drawRect(0, y, bubbleWidth, height, 0.15, 0.15, 0.15, 0.7)
        self:drawRectBorder(0, y, bubbleWidth, height, 0.3, 0.3, 0.3, 0.3)
    end

    -- ==========================================================
    -- TEXT COLOR LOGIC
    -- ==========================================================
    local r, g, b = 0.9, 0.9, 0.9 
    
    if data.isPlayer then
        r, g, b = 0.6, 0.9, 1.0 
    elseif data.error then 
        r, g, b = 1.0, 0.5, 0.5 
    elseif string.find(data.text, "Purchased") then 
        r, g, b = 0.4, 1.0, 0.4 
    elseif string.find(data.text, "Sold") then 
        r, g, b = 0.4, 0.8, 1.0 
    end

    -- ==========================================================
    -- TEXT DRAWING LOGIC
    -- ==========================================================
    if data.lines and #data.lines > 0 then
        local currentY = y + 2 
        for _, lineStr in ipairs(data.lines) do
            local xPos = 5 
            
            if data.isPlayer then
                -- Right Align Logic:
                -- We align text relative to the right edge (width - padding)
                -- minus a small 5px margin for inside the bubble
                local textWid = tm:MeasureStringX(self.font, lineStr)
                xPos = (width - padding) - textWid - 5
            end
            
            self:drawText(lineStr, xPos, currentY, r, g, b, 1, self.font)
            currentY = currentY + lineHeight
        end
    else
        self:drawText(data.text, 5, y + 2, r, g, b, 1, self.font)
    end
    
    return y + height
end

-- =============================================================================
-- 3. TEXTURE & VISUAL ENGINE
-- =============================================================================
function DynamicTradingUI:getTraderTexture(trader)
    if not trader then return getTexture("Item_Radio") end
    local arch = trader.archetype or "General"
    local gender = trader.gender or "Male"
    local id = trader.portraitID or 1
    local specificPath = "media/ui/Portraits/" .. arch .. "/" .. gender .. "/" .. id .. ".png"
    local tex = getTexture(specificPath)
    if tex then return tex end
    local fallbackPath = "media/ui/Portraits/General/" .. gender .. "/" .. id .. ".png"
    tex = getTexture(fallbackPath)
    if tex then return tex end
    return getTexture("media/ui/Effects/crt.png")
end

function DynamicTradingUI:getBackgroundTexture()
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

function DynamicTradingUI:getOverlayTexture()
    return getTexture("media/ui/Effects/crt.png")
end

-- =============================================================================
-- 4. PLAYER DATA & ECONOMY HELPERS
-- =============================================================================
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
    if self.lblName then self.lblName:setName(trader.name or "Unknown") end
    if self.lblArchetype then
        local archName = "Survivor"
        if DynamicTrading.Archetypes and DynamicTrading.Archetypes[trader.archetype] then
            archName = DynamicTrading.Archetypes[trader.archetype].name
        end
        self.lblArchetype:setName(archName)
    end
    if self.lblTraderBudget then
        local budget = trader.budget or 0
        self.lblTraderBudget:setName("Trader Budget: $" .. budget)
        if budget < 50 then
            self.lblTraderBudget:setColor(1, 0.2, 0.2, 1)
        else
            self.lblTraderBudget:setColor(1, 0.8, 0.2, 1)
        end
    end
    if self.lblSignal then
        local gt = GameTime:getInstance()
        local text = "Signal: Permanent"
        local r, g, b = 0.5, 0.8, 1.0
        if trader.expirationTime then
            local diff = trader.expirationTime - gt:getWorldAgeHours()
            if diff <= 0 then text = "Signal: Disconnection Imminent!"; r, g, b = 1, 0, 0
            elseif diff < 1 then text = "Signal: Unstable Transmission"; r, g, b = 1, 0.4, 0
            elseif diff < 8 then text = string.format("Signal: Fading (%dh)", math.floor(diff)); r, g, b = 1, 0.8, 0.2
            else text = string.format("Signal: Stable (%dh)", math.floor(diff)); r, g, b = 0.2, 1, 0.2 end
        end
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end

-- =============================================================================
-- 5. UTILITIES (WRAPPERS)
-- =============================================================================
function DynamicTradingUI.TruncateString(text, font, maxWidth)
    return DynamicTrading.Utils.TruncateString(text, font, maxWidth)
end

function DynamicTradingUI:isItemLocked(itemID)
    if not itemID or itemID == -1 then return false end
    local player = getSpecificPlayer(0)
    local modData = player:getModData()
    if modData.DT_LockedItems and modData.DT_LockedItems[itemID] then
        return true
    end
    return false
end

-- =============================================================================
-- 6. ICON & TEXTURE ENGINE (V2 ROBUST)
-- =============================================================================
local function split(str, sep)
    local result = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, s)
    end
    return result
end

function DynamicTradingUI.GetItemTexture(fullType, itemObj)
    -- 1. ELEGANT Build 42 APPROACH (Item Instance)
    if itemObj then
        -- Build 42: Clothing instances often need a specific texture lookup
        if instanceof(itemObj, "Clothing") then
            -- getTex() returns the actual resolved texture (including variations/coloring)
            if itemObj.getTex then
                local tex = itemObj:getTex()
                if tex and tex:getName() ~= "Question_Highlight" then
                    return tex
                end
            end
        end

        -- Standard Build 42 icon lookup for any InventoryItem
        if itemObj.getIcon then
            local icon = itemObj:getIcon()
            -- If it returns a texture object directly
            if icon and type(icon) ~= "string" then
                if icon:getName() ~= "Question_Highlight" then
                    return icon
                end
            end
        end
        
        -- Fallback: standard getTexture() (usually defined in Java/C++ layers)
        local tex = itemObj:getTexture()
        if tex and tex:getName() ~= "Question_Highlight" then
            return tex
        end
    end
    
    -- 2. DYNAMIC LOOKUP (Script/Trader Items where itemObj is nil)
    if fullType then
        local script = getScriptManager():getItem(fullType)
        if script then
            local iconStr = script:getIcon()
            
            -- If the script has a specific icon string defined
            if iconStr and iconStr ~= "" then
                -- Try standard "Item_" prefix first
                local tex = getTexture("Item_" .. iconStr) or getTexture(iconStr)
                if tex and tex:getName() ~= "Question_Highlight" then return tex end
                
                -- B42 Apparel Path Fallback (common for newer items)
                tex = getTexture("media/textures/Item_" .. iconStr .. ".png")
                if tex and tex:getName() ~= "Question_Highlight" then return tex end
            end
            
            -- guess: ClothingItem name lookup
            -- Many B42 clothes use their 'ClothingItem' name as the icon key
            if script:getClothingItem() then
                local ciName = script:getClothingItem()
                local tex = getTexture("Item_" .. ciName) or getTexture(ciName)
                if tex and tex:getName() ~= "Question_Highlight" then return tex end
            end

            -- Guess based on fullType (last resort)
            local parts = split(fullType, "%.")
            local shortName = parts[#parts]
            if shortName then
                local guesses = { shortName, "Bag_" .. shortName, "Item_" .. shortName, "Clothing_" .. shortName }
                for _, g in ipairs(guesses) do
                    local tex = getTexture("Item_" .. g) or getTexture(g)
                    if tex and tex:getName() ~= "Question_Highlight" then return tex end
                end
            end
        end
    end
    
    -- Final fallback to a generic icon if everything else fails
    return getTexture("media/ui/Effects/crt.png")
end
