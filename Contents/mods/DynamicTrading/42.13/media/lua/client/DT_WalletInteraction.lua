-- =============================================================================
-- DYNAMIC TRADING: WALLET INTERACTION
-- =============================================================================

require "TimedActions/ISBaseTimedAction"

-- =============================================================================
-- 1. FLAVOR TEXT CONFIGURATION
-- =============================================================================
local WalletTalk = {
    Anticipation = {
        "Come on, be loaded...",
        "Daddy needs a new pair of shoes...",
        "Let's see what you've got...",
        "Please don't be empty...",
        "Big money, big money...",
        "Who acts like this in an apocalypse?",
        "Fingers crossed...",
    },
    Empty = { 
        "Ugh. Nothing.", 
        "Totally broke.", 
        "Waste of time.", 
        "Just dust.", 
        "Moths. Just moths." 
    },
    Low = { 
        "Pocket change.", 
        "Better than nothing.", 
        "Barely enough for a soda.", 
        "Cheapskate." 
    },
    Medium = { 
        "Not bad.", 
        "This will help.", 
        "Lunch money secured.", 
        "Solid find." 
    },
    High = { 
        "Jackpot!!", 
        "Tonight we feast!", 
        "We're rich!", 
        "Now that's what I'm talking about!" 
    }
}

local function GetRandomLine(category)
    if not category or #category == 0 then return "..." end
    return category[ZombRand(#category) + 1]
end

-- =============================================================================
-- 2. VISUAL HELPERS
-- =============================================================================

-- HELPER: Force the character to speak, overriding any previous text immediately.
-- This prevents the "Anticipation" text from hiding the "Result" text in Singleplayer.
local function ForceSay(player, text)
    if not player or not text then return end
    
    -- Reset the speech timer to 0 so the previous bubble vanishes instantly
    if player.setSpeakTime then
        player:setSpeakTime(0)
    end
    
    player:Say(text)
end

-- HELPER: Display the floating "+ $100" text using the native engine function
local function ShowFloatingText(player, text, r, g, b)
    if not player then return end
    -- Native function: Safe, robust, prevents crashes
    -- Arguments: Text, R, G, B, Duration (frames?)
    player:setHaloNote(text, r, g, b, 300)
end

-- =============================================================================
-- 3. TIMED ACTION
-- =============================================================================
ISWalletAction = ISBaseTimedAction:derive("ISWalletAction")

function ISWalletAction:isValid()
    return self.character:getInventory():contains(self.item)
end

function ISWalletAction:update()
end

function ISWalletAction:start()
    self:setActionAnim("Loot")
    self:setOverrideHandModels(nil, nil)
    self.character:playSound("ClothesRustle")
    
    -- Anticipation Text (50% chance)
    if ZombRand(100) < 50 then
        self.character:Say(GetRandomLine(WalletTalk.Anticipation))
    end
end

function ISWalletAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISWalletAction:perform()
    local args = { item = self.item }
    
    -- Trigger Server Logic
    sendClientCommand(self.character, "DynamicTrading", "OpenWallet", args)
    
    ISBaseTimedAction.perform(self)
end

function ISWalletAction:new(character, item)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item
    o.maxTime = 120 -- 2.5 seconds
    return o
end

-- =============================================================================
-- 4. SERVER RESPONSE HANDLER
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end
    
    if command == "WalletResult" then
        local player = getPlayer() 
        if not player then return end

        local total = args.total
        local type = args.type
        
        -- Variables for color calculation
        local r, g, b = 170, 170, 170 -- Default Grey
        local messageText = ""

        if type == "EMPTY" then
            player:playSound("PZ_PaperCrumple")
            
            -- Speech
            ForceSay(player, GetRandomLine(WalletTalk.Empty))
            
            -- Floating Text (Grey for Empty)
            ShowFloatingText(player, "Empty", 150, 150, 150)
            
        else
            getSoundManager():PlaySound("DT_Cashier", false, 1.0)
            
            local maxPossible = SandboxVars.DynamicTrading.WalletMaxCash or 300
            local ratio = total / maxPossible

            -- ==========================================================
            -- COLOR CODING LOGIC
            -- ==========================================================
            if type == "JACKPOT" or ratio >= 0.7 then
                -- HIGH: Bright Neon Green
                r, g, b = 50, 255, 50 
                ForceSay(player, GetRandomLine(WalletTalk.High))
                
            elseif ratio >= 0.3 then
                -- MEDIUM: Normal Green
                r, g, b = 100, 255, 100 
                ForceSay(player, GetRandomLine(WalletTalk.Medium))
                
            else
                -- LOW: Pale/Dull Green
                r, g, b = 150, 200, 150 
                ForceSay(player, GetRandomLine(WalletTalk.Low))
            end
            
            -- Display the Cash Amount floating up
            messageText = "+ $" .. tostring(total)
            ShowFloatingText(player, messageText, r, g, b)
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- 5. CONTEXT MENU
-- =============================================================================
local function WalletContextMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    if not items then return end
    
    local selectedItems = ISInventoryPane.getActualItems(items) 
    
    for _, item in ipairs(selectedItems) do
        local fullType = item:getFullType()
        if fullType == "Base.Wallet" or fullType == "Base.Wallet_Female" or fullType == "Base.Wallet_Male" then
            local option = context:addOption("Rummage through Wallet", playerObj, 
                function()
                    if ISWalletAction then
                        ISTimedActionQueue.add(ISWalletAction:new(playerObj, item))
                    end
                end
            )
            break 
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(WalletContextMenu)