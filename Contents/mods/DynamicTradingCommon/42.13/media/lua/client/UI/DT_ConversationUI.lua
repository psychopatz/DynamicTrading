-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI FRAMEWORK
-- =============================================================================
-- A generic, reusable dialogue window.
-- Features:
-- 1. Persistent Chat History (Dynamic Width, Min-Width, Smart Alignment)
-- 2. Scrollable Option List (Classic Design)
-- 3. Trader Object Integration
-- 4. Message Queue, Audio & Animations
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils" 
require "Utils/DT_CoreUtils"

DT_ConversationUI = DT_ConversationUI or ISCollapsableWindow:derive("DT_ConversationUI")
DT_ConversationUI.instance = nil

-- =============================================================================
-- CONFIGURATION
-- =============================================================================
DT_ConversationUI.TEXT_DELAY = 30 
DT_ConversationUI.MIN_BUBBLE_WIDTH = 100 -- Minimum pixel width for chat bubbles

-- =============================================================================
-- 1. INITIALIZATION & LAYOUT
-- =============================================================================
function DT_ConversationUI:initialise()
    ISCollapsableWindow.initialise(self)
    
    self:setResizable(false)
    
    self.history = {}        
    self.target = nil        
    self.isRadio = true      
    self.msgQueue = {}       
    self.typingTick = 0      
    self.interactionObj = nil
end

function DT_ConversationUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- DIMENSIONS
    local th = self:titleBarHeight()
    local leftColW = 200     
    local pad = 10
    
    local rightX = leftColW + (pad * 2)
    local rightW = self.width - rightX - pad
    
    -- MANUAL CLOSE BUTTON
    self.closeButton = ISButton:new(self.width - 18, 2, 13, 13, "X", self, self.close)
    self.closeButton:initialise()
    self.closeButton.borderColor = {r=0, g=0, b=0, a=0}
    self.closeButton.backgroundColor = {r=0, g=0, b=0, a=0}
    self.closeButton.textColor =  {r=1, g=1, b=1, a=1}
    self:addChild(self.closeButton)

    -- 1. LEFT SIDE: IDENTITY
    self.imageY = th + pad
    self.imageSize = leftColW
    
    self.lblName = ISLabel:new(leftColW / 2 + pad, self.imageY + self.imageSize + 10, 25, "Unknown", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblDesc = ISLabel:new(leftColW / 2 + pad, self.lblName:getY() + 25, 18, "Survivor", 1.0, 1.0, 0.8, 1, UIFont.Small, true)
    self.lblDesc.center = true
    self:addChild(self.lblDesc)

    -- Refined Faction Layout
    local factionY = self.lblDesc:getY() + 35 -- Added padding
    self.lblFactionTitle = ISLabel:new(leftColW / 2 + pad, factionY, 18, "FACTION", 0.7, 0.7, 0.8, 1, UIFont.Small, true)
    self.lblFactionTitle.center = true
    self.lblFactionTitle:setVisible(false)
    self:addChild(self.lblFactionTitle)

    self.lblFactionName = ISLabel:new(leftColW / 2 + pad, factionY + 15, 18, "Independent", 1, 1, 1, 1, UIFont.Small, true)
    self.lblFactionName.center = true
    self.lblFactionName:setVisible(false)
    self:addChild(self.lblFactionName)

    self.lblReputation = ISLabel:new(leftColW / 2 + pad, self.lblFactionName:getY() + 20, 18, "Reputation: 0 (Neutral)", 1, 1, 1, 1, UIFont.Small, true)
    self.lblReputation.center = true
    self.lblReputation:setVisible(false)
    self:addChild(self.lblReputation)

    -- CALCULATE HEIGHTS
    local optionHeight = 180 
    local chatH = self.height - th - pad - optionHeight - 15 
    local optionY = th + pad + chatH + 10

    -- 2. OPTION LIST (Bottom - Drawn First)
    self.optionList = ISScrollingListBox:new(rightX, optionY, rightW, optionHeight)
    self.optionList:initialise()
    self.optionList.font = UIFont.NewSmall
    self.optionList.itemheight = 30 
    self.optionList.drawBorder = false 
    self.optionList.backgroundColor = {r=0, g=0, b=0, a=0} 
    self.optionList.doDrawItem = self.drawOptionItem
    self.optionList.onMouseDown = self.onOptionListMouseDown
    self:addChild(self.optionList)

    -- 3. CHAT HISTORY (Top - Drawn Second)
    self.chatList = ISScrollingListBox:new(rightX, th + pad, rightW, chatH)
    self.chatList:initialise()
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 20
    self.chatList.drawBorder = true
    self.chatList.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.chatList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9} 
    self.chatList.doDrawItem = self.drawLogItem 
    self:addChild(self.chatList)
end

-- =============================================================================
-- 2. UPDATE LOOP
-- =============================================================================
function DT_ConversationUI:update()
    ISCollapsableWindow.update(self)

    -- IDLE/DISTANCE CHECK
    if not DynamicTrading.Utils.IsInteractionValid(self.interactionObj, nil, self.target) then
        self:close()
        return
    end
    
    self.typingTick = self.typingTick + 1

    -- QUEUE PROCESSING
    if #self.msgQueue > 0 then
        local msg = self.msgQueue[1]
        
        if msg.delay > 0 then
            msg.delay = msg.delay - 1
        else
            self:addMessage(msg.text, msg.author, msg.isPlayer)
            
            if msg.sound then
                getSoundManager():PlaySound(msg.sound, false, 0.1)
            end
            
            table.remove(self.msgQueue, 1)
        end
    end
end

-- =============================================================================
-- 3. VISUALS
-- =============================================================================

function DT_ConversationUI:resolvePortrait(trader)
    if not trader then return nil end
    if trader.texture then return trader.texture end
    
    local arch = trader.archetype or trader.role or "General"
    local gender = trader.gender or "Male"
    local seed = trader.portraitID or 1
    
    local mappedID = 1
    if DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetMappedID then
        mappedID = DynamicTrading.Portraits.GetMappedID(arch, gender, seed)
    end
    
    local pathFolder = DynamicTrading.Portraits.GetPathFolder(arch, gender)
    local tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    if tex then return tex end
    
    -- Final fallback
    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

function DT_ConversationUI:getBackgroundTexture()
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

function DT_ConversationUI:render()
    ISCollapsableWindow.render(self)
    
    local x = 10
    local y = self.imageY
    local w = self.imageSize
    local h = self.imageSize
    
    -- BACKGROUND
    local bgTex = self:getBackgroundTexture()
    if bgTex then
        self:drawTextureScaled(bgTex, x, y, w, h, 1.0, 1.0, 1.0, 1.0)
    else
        self:drawRect(x, y, w, h, 1, 0.1, 0.1, 0.1)
    end

    -- PORTRAIT
    if self.targetTexture then
        self:drawTextureScaled(self.targetTexture, x, y, w, h, 1, 1, 1, 1)
    end

    -- CRT
    if self.isRadio then
        local crtTex = getTexture("media/ui/Effects/crt.png")
        if crtTex then
            local alpha = 0.15 + ZombRandFloat(0.0, 0.05)
            if ZombRand(100) < 5 then alpha = alpha + ZombRandFloat(0.1, 0.25) end
            self:drawTextureScaled(crtTex, x, y, w, h, math.min(alpha, 0.9), 1, 1, 1)
        end
    end

    self:drawRectBorder(x, y, w, h, 1, 1.0, 1.0, 1.0)

    -- TYPING INDICATOR
    if #self.msgQueue > 0 then
        local nextMsg = self.msgQueue[1]
        if (not nextMsg.isPlayer) and (nextMsg.delay > 0) then
            local frame = math.floor(self.typingTick / 10) % 4
            local dots = ""
            if frame == 1 then dots = "."
            elseif frame == 2 then dots = ".."
            elseif frame == 3 then dots = "..."
            end
            
            local bubbleX = self.chatList:getX() + 5
            local bubbleY = self.chatList:getY() + self.chatList:getHeight() - 25
            local bubbleW = 40
            local bubbleH = 20
            
            self:drawRect(bubbleX, bubbleY, bubbleW, bubbleH, 0.9, 0.2, 0.2, 0.2)
            self:drawRectBorder(bubbleX, bubbleY, bubbleW, bubbleH, 0.5, 0.5, 0.5, 0.5)
            self:drawText(dots, bubbleX + 12, bubbleY + 2, 0.8, 0.8, 0.8, 1, self.chatList.font)
        end
    end
end

-- =============================================================================
-- 4. LOGIC & DATA
-- =============================================================================

function DT_ConversationUI:queueMessage(text, author, isPlayer, delay, sound)
    table.insert(self.msgQueue, {
        text = text,
        author = author,
        isPlayer = isPlayer,
        delay = delay or 0,
        sound = sound
    })
end

function DT_ConversationUI:speak(text)
    local author = self.target and self.target.name or "NPC"
    local soundName = "DT_RadioRandom"
    self:queueMessage(text, author, false, DT_ConversationUI.TEXT_DELAY, soundName)
end

function DT_ConversationUI:addMessage(text, author, isPlayer)
    if not text then return end
    
    -- 1. Determine Max Width (Leave 15% space for contrast)
    local maxBubbleW = (self.chatList:getWidth() - 25) * 0.85
    
    -- 2. Wrap Text based on max width
    local lines = DynamicTrading.Utils.WrapText(text, maxBubbleW, self.chatList.font)
    
    -- 3. Measure Actual Width (Dynamic Sizing)
    local tm = getTextManager()
    local actualMaxWidth = 0
    for _, line in ipairs(lines) do
        local w = tm:MeasureStringX(self.chatList.font, line)
        if w > actualMaxWidth then actualMaxWidth = w end
    end
    
    -- 4. Apply Minimum Width (Prevents "Ugly" narrow bubbles)
    -- Default 100px or configured value
    local minW = DT_ConversationUI.MIN_BUBBLE_WIDTH or 100
    if actualMaxWidth < minW then actualMaxWidth = minW end

    local lineHeight = 18 
    local totalHeight = (#lines * lineHeight) + 10 
    if totalHeight < 30 then totalHeight = 30 end

    local entry = {
        text = text,
        lines = lines,
        author = author,
        isPlayer = isPlayer,
        height = totalHeight,
        trueWidth = actualMaxWidth
    }
    
    local item = self.chatList:addItem(author, entry)
    item.height = totalHeight + 4 
    self.chatList:ensureVisible(#self.chatList.items)
end

-- =============================================================================
-- 5. OPTION LIST LOGIC (Classic Buttons)
-- =============================================================================

function DT_ConversationUI:updateOptions(options)
    self.optionList:clear()
    if not options or #options == 0 then return end
    
    local btnWidth = self.optionList:getWidth() - 25 

    for i, opt in ipairs(options) do
        local lines = DynamicTrading.Utils.WrapText(opt.text, btnWidth, self.optionList.font)
        local lineHeight = 20
        local totalHeight = (#lines * lineHeight) + 16 
        if totalHeight < 35 then totalHeight = 35 end

        local item = self.optionList:addItem(opt.text, opt)
        item.lines = lines
        item.height = totalHeight + 5 
    end
end

function DT_ConversationUI:drawOptionItem(y, item, alt)
    local data = item.item 
    local width = self:getWidth() - 15 
    local height = item.height - 5     
    
    local ui = DT_ConversationUI.instance
    local isLocked = (ui and #ui.msgQueue > 0)
    local isMouseOver = self.mouseoverselected == item.index and not isLocked

    -- COLORS (Classic "Trading UI" Style)
    -- Solid Dark Grey
    local r, g, b, a = 0.2, 0.2, 0.2, 1.0 
    local br, bg, bb, ba = 0.5, 0.5, 0.5, 1.0
    local tr, tg, tb, ta = 0.9, 0.9, 0.9, 1.0

    if isLocked then
        r, g, b, a = 0.15, 0.15, 0.15, 1.0
        br, bg, bb = 0.3, 0.3, 0.3
        tr, tg, tb = 0.5, 0.5, 0.5
    elseif isMouseOver then
        r, g, b, a = 0.3, 0.3, 0.3, 1.0 
        br, bg, bb = 0.8, 0.8, 0.8
        tr, tg, tb = 1.0, 1.0, 1.0
    end

    self:drawRect(0, y, width, height, a, r, g, b)
    self:drawRectBorder(0, y, width, height, ba, br, bg, bb)

    local lineH = 20
    local textBlockH = #item.lines * lineH
    local startY = y + (height - textBlockH) / 2

    for i, line in ipairs(item.lines) do
        self:drawTextCentre(line, width / 2, startY + ((i-1)*lineH), tr, tg, tb, ta, self.font)
    end

    return y + item.height
end

function DT_ConversationUI:onOptionListMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then return end
    
    local ui = DT_ConversationUI.instance
    if ui and #ui.msgQueue > 0 then return end 

    local item = self.items[row]
    local data = item.item

    local chatText = data.text 
    if data.message ~= nil then chatText = data.message end

    if chatText and chatText ~= "" then
        ui:queueMessage(chatText, "Me", true, 0, "DT_RadioRandom")
    end

    if data.onSelect then
        data.onSelect(ui, data.data)
    end
end

-- =============================================================================
-- 6. RENDER HELPERS (CHAT BUBBLES)
-- =============================================================================
function DT_ConversationUI:drawLogItem(y, item, alt)
    local data = item.item
    local width = self:getWidth() 
    
    -- Bubble Width: Measured text + 20px padding
    local bubbleW = data.trueWidth + 20 
    local bubbleH = data.height
    local x = 0
    local r, g, b = 0.2, 0.2, 0.2 
    
    if data.isPlayer then
        -- ALIGN RIGHT (Fixed)
        -- Check if scrollbar is VISIBLE. If yes, reserve 13px gap. If no, tight spacing (2px).
        local scrollGap = (self.vscroll and self.vscroll:isVisible()) and 13 or 0
        local rightPadding = 2 -- Small gap from edge
        
        x = width - bubbleW - scrollGap - rightPadding
        
        -- Player Color
        r, g, b = 0.1, 0.2, 0.35
    else
        -- ALIGN LEFT
        x = 5
        r, g, b = 0.15, 0.15, 0.15
    end

    -- Draw Bubble
    self:drawRect(x, y, bubbleW, bubbleH, 0.8, r, g, b)
    self:drawRectBorder(x, y, bubbleW, bubbleH, 0.5, 0.6, 0.6, 0.6)

    -- Draw Text
    local ly = y + 5
    local font = self.font
    local textR, textG, textB = 0.9, 0.9, 0.9
    
    for _, line in ipairs(data.lines) do
        self:drawText(line, x + 10, ly, textR, textG, textB, 1, font)
        ly = ly + 18
    end
    return y + item.height
end

-- =============================================================================
-- 7. PUBLIC API
-- =============================================================================

function DT_ConversationUI.Open(traderObj, initialText, initialOptions, isRadio, interactionObj)
    if DT_ConversationUI.instance then
        DT_ConversationUI.instance:close()
    end

    local x, y = 150, 150
    local w, h = 600, 600
    
    -- Load Persistence
    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("ConversationUI")
        if state then
            x = state.x
            y = state.y
            -- We typically respect X/Y for this window but stick to default size if it's fixed
            -- However, if we ever make it resizable, we can use state.w/h
        end
    end
    
    -- Bounds Check
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    if x > screenW - 50 then x = screenW - 600 end
    if y > screenH - 50 then y = screenH - 600 end

    local ui = DT_ConversationUI:new(x, y, w, h) 
    ui:initialise()
    ui:addToUIManager()
    
    if isRadio == false then ui.isRadio = false else ui.isRadio = true end
    
    ui.target = traderObj
    local name = traderObj.name or "Unknown"
    ui.lblName:setName(name)
    
    local role = "Survivor"
    if traderObj.archetype then role = traderObj.archetype
    elseif traderObj.role then role = traderObj.role end
    ui.lblDesc:setName(role)
    
    -- FACTION & REPUTATION (Optional)
    if traderObj.factionID then
        local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions) or ModData.get("DynamicTrading_Factions") or {}
        local f = factionData[traderObj.factionID]
        if f then
            ui.lblFactionTitle:setVisible(true)
            ui.lblFactionName:setName(f.name or traderObj.factionID)
            ui.lblFactionName:setVisible(true)
            
            local player = getPlayer()
            local username = player:getUsername()
            local rep = (f.reputation and f.reputation[username]) or 0
            
            -- REPUTATION STAGES & COLORS
            local stage = "Neutral"
            local r, g, b = 0.8, 0.8, 0.8 -- Silver (Neutral)
            
            if rep >= 81 then
                stage = "Exalted"
                r, g, b = 1.0, 0.8, 0.0 -- Gold
            elseif rep >= 41 then
                stage = "Honored"
                r, g, b = 0.2, 1.0, 0.2 -- Green
            elseif rep >= 11 then
                stage = "Friendly"
                r, g, b = 0.5, 1.0, 0.5 -- Light Green
            elseif rep >= -10 then
                stage = "Neutral"
                r, g, b = 0.8, 0.8, 0.8
            elseif rep >= -39 then
                stage = "Unfriendly"
                r, g, b = 1.0, 0.5, 0.2 -- Orange
            elseif rep >= -79 then
                stage = "Hostile"
                r, g, b = 1.0, 0.2, 0.2 -- Red
            else
                stage = "Nemesis"
                r, g, b = 0.8, 0.0, 0.0 -- Dark Red
            end
            
            ui.lblReputation:setName(string.format("Reputation: %d (%s)", rep, stage))
            ui.lblReputation:setColor(r, g, b)
            ui.lblReputation:setVisible(true)
        end
    end
    
    ui.targetTexture = ui:resolvePortrait(traderObj)
    
    if initialText then
        ui:speak(initialText)
    end
    
    if initialOptions then
        ui:updateOptions(initialOptions)
    end

    ui.interactionObj = interactionObj

    DT_ConversationUI.instance = ui
    return ui
end

function DT_ConversationUI:close()
    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("ConversationUI", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DT_ConversationUI.instance = nil
end