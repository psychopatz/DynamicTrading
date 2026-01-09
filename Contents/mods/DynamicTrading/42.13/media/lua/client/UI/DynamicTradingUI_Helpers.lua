
-- =============================================================================
-- 1. CONNECTION & POWER VALIDATION
-- =============================================================================
function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    if not obj then return false end

    local data = nil
    -- Safe check to get device data from either an Item or a World Object
    if obj.getDeviceData then
        data = obj:getDeviceData()
    end
    
    if not data or not data:getIsTurnedOn() then return false end

    -- Check for World HAM Radios
    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        -- Distance check: Must be near the stationary radio
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 5.0 then return false end
        -- Power check: Battery or Grid
        if data:getIsBatteryPowered() and data:getPower() <= 0 then return false end
        if not data:getIsBatteryPowered() and not sq:haveElectricity() then return false end
    else
        -- Check for Handheld Walkies
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
end

-- =============================================================================
-- 2. TEXT WRAPPING UTILITY (NEW FIX)
-- =============================================================================
-- Helper function to split text into lines that fit the width.
-- Replaces the failed Java call with pure Lua logic using MeasureStringX.
function DynamicTradingUI.WrapText(text, maxWidth, font)
    local tm = getTextManager()
    local result = {}
    
    if not text then return {""} end
    text = tostring(text)

    -- Split explicit newlines (paragraphs) first
    local paragraphs = {}
    for s in string.gmatch(text, "[^\r\n]+") do
        table.insert(paragraphs, s)
    end
    if #paragraphs == 0 then table.insert(paragraphs, text) end

    -- Process each paragraph for wrapping
    for _, para in ipairs(paragraphs) do
        local currentLine = ""
        
        for word in string.gmatch(para, "%S+") do
            local testLine = (currentLine == "") and word or (currentLine .. " " .. word)
            
            if tm:MeasureStringX(font, testLine) <= maxWidth then
                currentLine = testLine
            else
                -- If line is full, push it and start new line with current word
                if currentLine ~= "" then table.insert(result, currentLine) end
                currentLine = word
            end
        end
        -- Push the remaining text
        if currentLine ~= "" then table.insert(result, currentLine) end
    end
    
    if #result == 0 then return {""} end
    return result
end

-- =============================================================================
-- 3. LOGGING & FEEDBACK (UPDATED)
-- =============================================================================
function DynamicTradingUI:logLocal(text, isError)
    -- Calculate text wrapping logic
    -- Subtract scrollbar width (~15px) + padding (~10px)
    local listWidth = self.chatList:getWidth() - 25 
    if listWidth <= 50 then listWidth = 200 end -- Safety fallback
    
    local font = self.chatList.font
    
    -- [FIX] Use Lua wrapper instead of Java splitIntoLines
    local lines = DynamicTradingUI.WrapText(text, listWidth, font)
    
    -- Calculate total height needed
    local lineHeight = self.chatList.itemheight or 18
    local totalHeight = #lines * lineHeight
    if totalHeight < lineHeight then totalHeight = lineHeight end 

    local entry = { 
        text = text, 
        error = isError or false,
        lines = lines,       -- Store the lua table of lines
        height = totalHeight -- Store the dynamic height
    }
    table.insert(self.localLogs, entry)

    self.chatList:clear()
    -- Rebuild the list from the logs table
    for _, log in ipairs(self.localLogs) do
        local addedItem = self.chatList:addItem(log.text, log)
        -- CRITICAL: Set the height of this specific row so the listbox scrolls correctly
        addedItem.height = log.height
    end
    -- Auto-scroll to the bottom so newest messages are visible
    self.chatList:ensureVisible(#self.chatList.items)
end

function DynamicTradingUI:drawLogItem(y, item, alt)
    local data = item.item -- This is the 'entry' table created in logLocal
    
    -- Use the calculated dynamic height, or fallback to default
    local height = data.height or self.itemheight
    local width = self:getWidth()
    local lineHeight = self.itemheight

    if alt then
        self:drawRect(0, y, width, height, 0.1, 0.1, 0.1, 0.5)
    end

    local r, g, b = 0.8, 0.8, 0.8
    if data.error then r, g, b = 1.0, 0.4, 0.4 end -- Failure/Error
    if string.find(data.text, "Purchased") then r, g, b = 0.4, 1.0, 0.4 end -- Finance Green
    if string.find(data.text, "Sold") then r, g, b = 0.4, 0.8, 1.0 end -- Finance Blue

    -- Draw the multi-line text (Iterating Lua Table)
    if data.lines and #data.lines > 0 then
        local currentY = y
        for _, lineStr in ipairs(data.lines) do
            self:drawText(lineStr, 5, currentY + 2, r, g, b, 1, self.font)
            currentY = currentY + lineHeight
        end
    else
        -- Fallback if lines weren't calculated
        self:drawText(data.text, 5, y + 2, r, g, b, 1, self.font)
    end
    
    -- Return the Y position where the NEXT item should start
    return y + height
end

-- =============================================================================
-- 4. TEXTURE & VISUAL ENGINE
-- =============================================================================
function DynamicTradingUI:getTraderTexture(trader)
    if not trader then return getTexture("Item_Radio") end

    local arch = trader.archetype or "General"
    local gender = trader.gender or "Male"
    local id = trader.portraitID or 1

    -- Attempt to find the specific portrait file
    local specificPath = "media/ui/Portraits/" .. arch .. "/" .. gender .. "/" .. id .. ".png"
    local tex = getTexture(specificPath)
    if tex then return tex end

    -- Fallback to General category if specific is missing
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
-- 5. PLAYER DATA & ECONOMY HELPERS
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
-- 6. UTILITIES (STRING & LOCKS)
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

-- [NEW] ITEM LOCK HELPER
-- Checks the player's private ModData to see if a specific item is protected.
function DynamicTradingUI:isItemLocked(itemID)
    if not itemID or itemID == -1 then return false end
    
    local player = getSpecificPlayer(0)
    local modData = player:getModData()
    
    -- Check if the Lock table exists and contains this ID
    if modData.DT_LockedItems and modData.DT_LockedItems[itemID] then
        return true
    end
    
    return false
end