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
-- 2. FLOATING TEXT HELPER (BUILD 42 ROBUST)
-- =============================================================================
local function ShowFloatingText(player, text, r, g, b)
    -- Wrap in pcall to prevent crashes from hiding the text completely
    local success = pcall(function()
        if HaloTextHelper then
            -- B42: r, g, b are usually 0-255 ints
            HaloTextHelper.addText(player, text, r, g, b)
        else
            -- Legacy / Fallback
            player:setHaloNote(text, r, g, b, 300)
        end
    end)

    -- If the fancy method failed, force the standard HaloNote
    if not success then
        player:setHaloNote(text, r, g, b, 300)
    end
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
    
    -- Anticipation Text (50% chance to speak while searching)
    if ZombRand(100) < 50 then
        self.character:Say(GetRandomLine(WalletTalk.Anticipation))
    end
end

function ISWalletAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISWalletAction:perform()
    local args = { item = self.item }
    -- Send command to server
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
-- 4. SERVER RESPONSE HANDLER (VISUALS)
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end
    
    if command == "WalletResult" then
        local player = getPlayer() 
        if not player then return end

        local total = args.total
        local type = args.type
        
        -- Default: Grey (170, 170, 170)
        local r, g, b = 170, 170, 170 
        local messageText = ""

        if type == "EMPTY" then
            player:playSound("PZ_PaperCrumple")
            
            -- 1. Reaction (Speech)
            player:Say(GetRandomLine(WalletTalk.Empty))
            
            -- 2. Floating Text (Halo)
            ShowFloatingText(player, "Empty", 150, 150, 150)
            
        else
            player:playSound("CashRegister")
            
            local maxPossible = SandboxVars.DynamicTrading.WalletMaxCash or 300
            local ratio = total / maxPossible

            if type == "JACKPOT" or ratio >= 0.7 then
                -- HIGH: Bright Green
                r, g, b = 50, 255, 50
                player:Say(GetRandomLine(WalletTalk.High))
                
            elseif ratio >= 0.3 then
                -- MEDIUM: Normal Green
                r, g, b = 100, 255, 100
                player:Say(GetRandomLine(WalletTalk.Medium))
                
            else
                -- LOW: Pale Green
                r, g, b = 150, 200, 150
                player:Say(GetRandomLine(WalletTalk.Low))
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