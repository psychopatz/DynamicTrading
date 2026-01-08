-- =============================================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\client\UI\DynamicTradingUI_Layout.lua
-- =============================================================================

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local leftColW = 250
    local rightX = 270
    local rightW = self.width - rightX - 10
    local th = self:titleBarHeight()

    self.imageY = th + 10
    
    -- [CHANGE] Set Height to 250 to match Width (250). 
    -- This ensures a perfect square aspect ratio for 512x512 images.
    self.imageH = 250 

    -- Calculate Y positions relative to the image height
    local nameY = self.imageY + self.imageH + 10
    local archY = nameY + 25
    local sigY  = archY + 20
    local wallY = sigY + 30

    -- Labels
    self.lblName = ISLabel:new(leftColW / 2 + 10, nameY, 25, "Loading...", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblArchetype = ISLabel:new(leftColW / 2 + 10, archY, 20, "Survivor", 1.0, 0.8, 0.2, 1, UIFont.Small, true)
    self.lblArchetype.center = true
    self:addChild(self.lblArchetype)

    self.lblSignal = ISLabel:new(leftColW / 2 + 10, sigY, 16, "Signal: ...", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)

    self.lblInfo = ISLabel:new(leftColW / 2 + 10, wallY, 25, "Wallet: $0", 0.2, 1.0, 0.2, 1, UIFont.Medium, true)
    self.lblInfo.center = true
    self:addChild(self.lblInfo)

    -- Action button
    self.btnAction = ISButton:new(20, wallY + 35, leftColW - 20, 30, "BUY ITEM", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- Log list
    -- Calculate remaining height for the log list
    local logY = wallY + 75
    local logH = self.height - logY - 10

    self.chatList = ISScrollingListBox:new(10, logY, leftColW, logH)
    self.chatList:initialise()
    self.chatList:setAnchorBottom(true)
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 18
    self.chatList.drawBorder = true
    self.chatList.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.chatList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.8}
    self.chatList.doDrawItem = self.drawLogItem
    self:addChild(self.chatList)

    self:logLocal("Connection established.", false)

    -- Switch button
    self.btnSwitch = ISButton:new(rightX, th + 10, rightW, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self.btnSwitch:setAnchorRight(true)
    self:addChild(self.btnSwitch)

    -- Item listbox
    self.listbox = ISScrollingListBox:new(rightX, th + 45, rightW, self.height - (th + 55))
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingUI.drawItem

    -- Crash-safe prerender
    local oldPrerender = self.listbox.prerender
    self.listbox.prerender = function(box)
        if box.items == nil then box.items = {} end
        if type(box.selected) ~= "number" then box.selected = -1 end
        if box.selected ~= -1 and box.selected > #box.items then box.selected = -1 end
        if oldPrerender then oldPrerender(box) end
    end

    -- Category collapse + selection handling
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row == -1 then return end

        local item = target.items[row]
        if not item then return end

        if item.item.isCategory then
            local catName = item.item.categoryName
            local ui = DynamicTradingUI.instance
            if ui then
                ui.collapsed[catName] = not ui.collapsed[catName]
                ui:populateList()
            end
            return
        end

        target.selected = row
        local ui = DynamicTradingUI.instance
        if ui then
            ui.selectedKey = item.item.key
            ui.lastSelectedIndex = row
            ui.btnAction:setEnable(true)
            if ui.isBuying then
                ui.btnAction:setTitle("BUY ($" .. item.item.price .. ")")
            else
                ui.btnAction:setTitle("SELL ($" .. item.item.price .. ")")
            end
        end
    end

    self:addChild(self.listbox)
end

function DynamicTradingUI:render()
    ISCollapsableWindow.render(self)

    if self.traderID then
        -- 1. Get the real trader object (contains gender, portraitID, etc)
        local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
        
        -- 2. Pass the FULL object to the helper
        local tex = self:getTraderTexture(trader)

        if tex then
            -- [CHANGE] Draw Border: 250 Width, 250 Height (Square)
            self:drawRectBorder(10, self.imageY, 250, 250, 1.0, 1.0, 1.0, 1.0)
            
            -- [CHANGE] Draw Texture: 248 Width, 248 Height (Square, with 1px padding inside border)
            self:drawTextureScaled(tex, 11, self.imageY + 1, 248, 248, 1.0, 1.0, 1.0, 1.0)
        end
    end
end