require "Utils/DT_StringUtils" -- This is common utils

-- =============================================================================
-- 1. CONNECTION & POWER VALIDATION
-- =============================================================================
function DT_TradingWindow:isConnectionValid()
    return self.dataProvider:isConnectionValid(self.radioObj)
end

-- =============================================================================
-- 2. LOGGING & FEEDBACK (BUBBLE STYLE)
-- =============================================================================
--- Adds a message to the chat list.
function DT_TradingWindow:logLocal(text, isError, isPlayer)
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

function DT_TradingWindow:drawLogItem(y, item, alt)
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

-- =============================================================================
-- 4. PLAYER DATA & ECONOMY HELPERS
-- =============================================================================
function DT_TradingWindow:getPlayerWealth(player)
    return self.dataProvider:getPlayerWealth(player)
end

function DT_TradingWindow:updateWallet()
    local player = getSpecificPlayer(0)
    -- [CRASH FIX] Check for valid player
    if not player or player:isDead() then 
        if self.lblInfo then self.lblInfo:setName("Wallet: ---") end
        return 
    end

    local wealth = self:getPlayerWealth(player)
    if self.lblInfo then
        self.lblInfo:setName("Wallet: $" .. wealth)
    end
end

function DT_TradingWindow:updateIdentityDisplay(trader)
    if self.lblName then self.lblName:setName(trader.name or "Unknown") end
    if self.lblArchetype then
        local archName = "Survivor"
        if self.dataProvider and self.dataProvider.getArchetypeName then
            archName = self.dataProvider:getArchetypeName(trader.archetype)
        elseif DynamicTrading.Archetypes and DynamicTrading.Archetypes[trader.archetype] then
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
        local text = "Status: Permanent"
        local r, g, b = 0.5, 0.8, 1.0
        local expireTime = trader.returnTime
        if expireTime then
            local diff = expireTime - gt:getWorldAgeHours()
            if diff <= 0.5 then 
                text = "Status: Departing Now..."
                r, g, b = 1, 0, 0
            elseif diff < 1 then 
                text = string.format("Status: Leaving in (%dm)", math.floor(diff * 60))
                r, g, b = 1, 0.4, 0
            elseif diff < 8 then 
                text = string.format("Status: Leaving in (%dh)", math.ceil(diff))
                r, g, b = 1, 0.8, 0.2
            else 
                text = string.format("Status: Leaving in (%dh)", math.ceil(diff))
                r, g, b = 0.2, 1, 0.2 
            end
        end
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end

-- =============================================================================
-- 5. UTILITIES (WRAPPERS)
-- =============================================================================
function DT_TradingWindow.TruncateString(text, font, maxWidth)
    return DynamicTrading.Utils.TruncateString(text, font, maxWidth)
end

function DT_TradingWindow:isItemLocked(itemID)
    if not itemID or itemID == -1 then return false end
    local player = getSpecificPlayer(0)
    if not player then return false end -- Safety check
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

local function isValidItemTexture(tex)
    return tex and tex.getName and tex:getName() ~= "Question_Highlight"
end

local function safeCall(target, methodName, ...)
    if not target or not target[methodName] then return nil end
    local ok, result = pcall(target[methodName], target, ...)
    if ok then
        return result
    end
    return nil
end

local function tryTexture(textureName)
    if not textureName or textureName == "" then return nil end
    local tex = getTexture(textureName)
    if isValidItemTexture(tex) then
        return tex
    end
    return nil
end

local function normalizeIconVariants(rawVariants)
    if not rawVariants then
        return nil
    end

    if type(rawVariants) == "string" then
        local variants = {}
        for entry in string.gmatch(rawVariants, "([^;]+)") do
            entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
            if entry ~= "" then
                table.insert(variants, entry)
            end
        end
        return #variants > 0 and variants or nil
    end

    if type(rawVariants) == "table" then
        return #rawVariants > 0 and rawVariants or nil
    end

    if rawVariants.size and rawVariants.get then
        local variants = {}
        for i = 0, rawVariants:size() - 1 do
            local entry = rawVariants:get(i)
            if entry and tostring(entry) ~= "" then
                table.insert(variants, tostring(entry))
            end
        end
        return #variants > 0 and variants or nil
    end

    return nil
end

local function getScriptIconVariants(script)
    if not script then
        return nil
    end

    local candidates = {
        safeCall(script, "getIconsForTexture"),
        safeCall(script, "getIconsForTextures"),
        safeCall(script, "getIconsForTextureString"),
        safeCall(script, "getIconsForTextureChoices"),
    }

    for _, candidate in ipairs(candidates) do
        local variants = normalizeIconVariants(candidate)
        if variants then
            return variants
        end
    end

    return nil
end

local function resolveScriptVariantTexture(script)
    local variants = getScriptIconVariants(script)
    if not variants then
        return nil
    end

    for _, variant in ipairs(variants) do
        local tex = tryTexture("Item_" .. variant) or tryTexture(variant) or tryTexture("media/textures/Item_" .. variant .. ".png")
        if tex then
            return tex
        end
    end

    return nil
end

local function resolveMoveableSpriteTexture(script, itemObj)
    local worldSprite = safeCall(itemObj, "getWorldSprite")
    if (not worldSprite or worldSprite == "") and script then
        worldSprite = safeCall(script, "getWorldObjectSprite")
    end
    if not worldSprite or worldSprite == "" then
        return nil
    end

    local tex = tryTexture(worldSprite)
    if tex then
        return tex
    end

    local sprite = nil
    if getSprite then
        local ok, result = pcall(getSprite, worldSprite)
        if ok then
            sprite = result
        end
    end

    if not sprite and IsoSpriteManager and IsoSpriteManager.instance and IsoSpriteManager.instance.getSprite then
        local ok, result = pcall(IsoSpriteManager.instance.getSprite, IsoSpriteManager.instance, worldSprite)
        if ok then
            sprite = result
        end
    end

    if not sprite then
        return nil
    end

    tex = safeCall(sprite, "getTextureForCurrentFrame", 0)
    if isValidItemTexture(tex) then
        return tex
    end

    tex = safeCall(sprite, "getTexture")
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

local function resolveInventoryItemTexture(itemObj)
    if not itemObj then
        return nil
    end

    if instanceof(itemObj, "Clothing") and itemObj.getTex then
        local tex = itemObj:getTex()
        if isValidItemTexture(tex) then
            return tex
        end
    end

    if itemObj.getIcon then
        local icon = itemObj:getIcon()
        if icon and type(icon) ~= "string" and isValidItemTexture(icon) then
            return icon
        end
    end

    local tex = safeCall(itemObj, "getTexture")
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

local function resolveGeneratedItemTexture(fullType)
    if not fullType or not InventoryItemFactory or not InventoryItemFactory.CreateItem then
        return nil
    end

    local ok, tempItem = pcall(InventoryItemFactory.CreateItem, fullType)
    if not ok or not tempItem then
        return nil
    end

    return resolveInventoryItemTexture(tempItem)
end

function DT_TradingWindow.GetItemTexture(fullType, itemObj)
    DT_TradingWindow.TextureCache = DT_TradingWindow.TextureCache or {}
    if not itemObj and fullType and DT_TradingWindow.TextureCache[fullType] then
        return DT_TradingWindow.TextureCache[fullType]
    end

    local script = fullType and getScriptManager():getItem(fullType) or nil
    local iconStr = script and safeCall(script, "getIcon") or nil
    local isDefaultMoveableIcon = iconStr and string.lower(iconStr) == "default"

    if isDefaultMoveableIcon then
        local moveableTex = resolveMoveableSpriteTexture(script, itemObj)
        if moveableTex then
            if not itemObj and fullType then
                DT_TradingWindow.TextureCache[fullType] = moveableTex
            end
            return moveableTex
        end
    end

    -- 1. ELEGANT Build 42 APPROACH (Item Instance)
    if itemObj then
        local tex = resolveInventoryItemTexture(itemObj)
        if isValidItemTexture(tex) then
            return tex
        end
    end

    if script then
        local variantTex = resolveScriptVariantTexture(script)
        if variantTex then
            if not itemObj and fullType then
                DT_TradingWindow.TextureCache[fullType] = variantTex
            end
            return variantTex
        end
    end
    
    -- 2. DYNAMIC LOOKUP (Script/Trader Items where itemObj is nil)
    if script then
        -- If the script has a specific icon string defined
        if iconStr and iconStr ~= "" and not isDefaultMoveableIcon then
            -- Try standard "Item_" prefix first
            local tex = getTexture("Item_" .. iconStr) or getTexture(iconStr)
            if isValidItemTexture(tex) then return tex end

            -- B42 Apparel Path Fallback (common for newer items)
            tex = getTexture("media/textures/Item_" .. iconStr .. ".png")
            if isValidItemTexture(tex) then return tex end
        end

        -- guess: ClothingItem name lookup
        -- Many B42 clothes use their 'ClothingItem' name as the icon key
        if script:getClothingItem() then
            local ciName = script:getClothingItem()
            local tex = getTexture("Item_" .. ciName) or getTexture(ciName)
            if isValidItemTexture(tex) then return tex end
        end

        -- Guess based on fullType (last resort)
        local parts = split(fullType, "%.")
        local shortName = parts[#parts]
        if shortName then
            local guesses = { shortName, "Bag_" .. shortName, "Item_" .. shortName, "Clothing_" .. shortName }
            for _, g in ipairs(guesses) do
                local tex = getTexture("Item_" .. g) or getTexture(g)
                if isValidItemTexture(tex) then
                    if not itemObj and fullType then
                        DT_TradingWindow.TextureCache[fullType] = tex
                    end
                    return tex
                end
            end
        end
    end

    local generatedTex = resolveGeneratedItemTexture(fullType)
    if isValidItemTexture(generatedTex) then
        if not itemObj and fullType then
            DT_TradingWindow.TextureCache[fullType] = generatedTex
        end
        return generatedTex
    end
    
    -- Final fallback to a generic icon if everything else fails
    return getTexture("media/ui/Effects/crt.png")
end
