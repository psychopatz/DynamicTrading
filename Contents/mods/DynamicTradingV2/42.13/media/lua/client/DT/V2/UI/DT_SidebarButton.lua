require "ISUI/ISUIElement"
require "ISUI/ISButton"
require "DynamicTradingInfoUI"

DT_SidebarButton = ISUIElement:derive("DT_SidebarButton")
DT_SidebarButton.instance = nil

function DT_SidebarButton:initialise()
    ISUIElement.initialise(self)
end

function DT_SidebarButton:createChildren()
    -- 1. LOAD CUSTOM TEXTURE
    -- Place your PNG in: YourMod/media/ui/Icon_MarketInfo.png
    -- Then use: getTexture("media/ui/Icon_MarketInfo.png")
    local btnIcon = getTexture("media/ui/Icon_MarketInfo.png")
    
    -- Fallback for testing: uses vanilla hammer icon (very visible)
    if not btnIcon then
        btnIcon = getTexture("Item_Hammer")
        print("DT_SidebarButton: Custom icon failed to load, using fallback hammer")
    end
    
    -- 2. CREATE BUTTON (dynamic size to match container)
    self.btn = ISButton:new(0, 0, self.width, self.height, "", nil, DT_SidebarButton.onButtonClick)
    self.btn:initialise()
    self.btn:setImage(btnIcon)
    
    -- Visual Styling (Transparent background like vanilla buttons)
    self.btn:setDisplayBackground(false) 
    self.btn.borderColor = {r=0, g=0, b=0, a=0}
    
    -- Mouse Over Effect (Gray highlight like vanilla)
    self.btn.onMouseOver = function(btn)
        btn:setDisplayBackground(true)
        btn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0.5}
    end
    self.btn.onMouseOut = function(btn)
        btn:setDisplayBackground(false)
    end
    
    self.btn:setTooltip("Global Market Info")
    self:addChild(self.btn)
end

function DT_SidebarButton.onButtonClick()
    if DynamicTradingInfoUI then
        DynamicTradingInfoUI.ToggleWindow()
    end
end

-- =============================================================================
-- VISIBILITY SYNC
-- =============================================================================
function DT_SidebarButton:render()
    ISUIElement.render(self)
    
    -- Sync visibility with the vanilla sidebar (ISEquippedItem)
    if ISEquippedItem and ISEquippedItem.instance then
        local vanillaVisible = ISEquippedItem.instance:isVisible()
        
        if self:isVisible() ~= vanillaVisible then
            self:setVisible(vanillaVisible)
        end
    end
end

-- =============================================================================
-- SMART POSITIONING LOGIC
-- =============================================================================
local function FindBestYPosition()
    local yMax = 60 -- Slight offset from top if no buttons found
    
    if ISEquippedItem and ISEquippedItem.instance and ISEquippedItem.instance.children then
        -- Scan children of the sidebar to find the lowest button
        for _, child in pairs(ISEquippedItem.instance.children) do
            if child:isVisible() then
                local bottom = child:getY() + child:getHeight()
                if bottom > yMax then
                    yMax = bottom
                end
            end
        end
    end
    
    -- Place with small gap below the lowest found button
    return yMax + 15
end

local function CreateSidebarButton()
    if DT_SidebarButton.instance then 
        DT_SidebarButton.instance:removeFromUIManager()
        DT_SidebarButton.instance = nil
    end

    local y = FindBestYPosition()
    
    -- Create Container (x=16 to align with vanilla buttons, 50x50 size)
    local btn = DT_SidebarButton:new(16, y, 50, 50)
    btn:initialise()
    btn:createChildren()
    btn:setAlwaysOnTop(true)
    btn:addToUIManager()
    btn:setVisible(true)
    
    DT_SidebarButton.instance = btn
end

-- OnGameStart is reliable for HUD creation in build 42
Events.OnGameStart.Add(CreateSidebarButton)