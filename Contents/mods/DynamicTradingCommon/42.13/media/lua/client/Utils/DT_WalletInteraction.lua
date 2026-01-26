-- =============================================================================
-- DYNAMIC TRADING: WALLET INTERACTION
-- =============================================================================

require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISInventoryTransferAction"
require "Utils/DT_AudioManager"

-- =============================================================================
-- 1. FLAVOR TEXT & CONFIG
-- =============================================================================
local WalletTalk = {
    Anticipation = { "Come on...", "Daddy needs a new pair of shoes...", "Please don't be empty...", "Big money...", "Fingers crossed..." },
    Empty = { "Ugh. Nothing.", "Totally broke.", "Just dust.", "Moths." },
    Low = { "Pocket change.", "Better than nothing.", "Cheapskate." },
    Medium = { "Not bad.", "Lunch money secured.", "Solid find." },
    High = { "Jackpot!!", "We're rich!", "Dinner is on me!" }
}

local function GetRandomLine(category)
    if not category or #category == 0 then return "..." end
    return category[ZombRand(#category) + 1]
end

local function ForceSay(player, text)
    if not player or not text then return end
    if player.setSpeakTime then player:setSpeakTime(0) end
    player:Say(text)
end

local function ShowFloatingText(player, text, r, g, b)
    if not player then return end
    player:setHaloNote(text, r, g, b, 300)
end

-- =============================================================================
-- 2. LOCAL SP LOGIC
-- =============================================================================
local function ProcessWalletSP(player, item)
    if not item then return end
    local inv = player:getInventory()
    
    local minCash = SandboxVars.DynamicTrading.WalletMinCash or 1
    local maxCash = SandboxVars.DynamicTrading.WalletMaxCash or 300
    local emptyChance = SandboxVars.DynamicTrading.WalletEmptyChance or 20
    local jackpotChance = SandboxVars.DynamicTrading.WalletJackpotChance or 5.0

    if item:getContainer() then
        item:getContainer():DoRemoveItem(item)
    end

    local amount = 0
    local resultType = "NORMAL"

    if ZombRand(100) < emptyChance then
        resultType = "EMPTY"
    else
        if ZombRandFloat(0.0, 100.0) <= jackpotChance then
            local bonus = ZombRandFloat(0.8, 1.5)
            amount = math.floor(maxCash * bonus)
            resultType = "JACKPOT"
        else
            local roll = ZombRand(100)
            if roll < 60 then
                amount = ZombRand(minCash, math.floor(maxCash * 0.3))
            elseif roll < 90 then
                amount = ZombRand(math.floor(maxCash * 0.3), math.floor(maxCash * 0.7))
            else
                amount = ZombRand(math.floor(maxCash * 0.7), maxCash)
            end
            resultType = "MONEY"
        end
        if amount < 1 then amount = 1 end
    end

    if amount > 0 then
        local bundles = math.floor(amount / 100)
        local looseCash = amount % 100
        if bundles > 0 then inv:AddItems("Base.MoneyBundle", bundles) end
        if looseCash > 0 then inv:AddItems("Base.Money", looseCash) end
    end

    local args = { total = amount, type = resultType }
    triggerEvent("OnServerCommand", "DynamicTrading", "WalletResult", args)
end

-- =============================================================================
-- 3. TIMED ACTION
-- =============================================================================
ISWalletAction = ISBaseTimedAction:derive("ISWalletAction")

function ISWalletAction:isValid()
    if not self.character then return false end


    local inv = self.character:getInventory()
    
    -- 1. Check if the current object reference is still valid and in inventory
    if self.item and inv:contains(self.item) then
        return true
    end


    if self.itemID then
        local foundItem = inv:getItemById(self.itemID)
        if foundItem then
            self.item = foundItem 
            return true
        end
    end

    if self.item and self.item:getContainer() then
         return true
    end

    return false
end

function ISWalletAction:update()
    -- Reset hand models
    self.character:setMetabolicTarget(Metabolics.LightWork)

    if not self.soundStarted then
        self.soundStarted = true
        
        if DT_AudioManager then
            DT_AudioManager.PlaySound("DT_CasinoRandom", false, 1.0)
        else
            getSoundManager():PlaySound("DT_CasinoRandom", false, 1.0)
        end
        
        if ZombRand(100) < 50 then
            self.character:Say(GetRandomLine(WalletTalk.Anticipation))
        end
    end
end

function ISWalletAction:start()
    self:setActionAnim("Loot")
    self:setOverrideHandModels(nil, nil)
    self.character:playSound("ClothesRustle")
end

function ISWalletAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISWalletAction:perform()
    
    -- Ensure item is valid before processing
    if self.item then
        if isClient() then
            local args = { item = self.item }
            sendClientCommand(self.character, "DynamicTrading", "OpenWallet", args)
        else
            ProcessWalletSP(self.character, self.item)
        end
    end
    
    ISBaseTimedAction.perform(self)
end

function ISWalletAction:new(character, item)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item
    
    -- Store ID for robust lookup in SP
    if item then
        o.itemID = item:getID()
    end
    
    o.maxTime = 120
    o.soundStarted = false -- Init flag
    return o
end

-- =============================================================================
-- 4. VISUALS HANDLER (Client Side)
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end
    
    if command == "WalletResult" then
        local player = getPlayer() 
        if not player then return end

        local total = args.total
        local type = args.type
        local r, g, b = 170, 170, 170 

        if type == "EMPTY" then
            if DT_AudioManager then DT_AudioManager.PlaySound("DT_CasinoLose", false, 1.0) else getSoundManager():PlaySound("DT_CasinoLose", false, 1.0) end
            ForceSay(player, GetRandomLine(WalletTalk.Empty))
            ShowFloatingText(player, "Empty", 150, 150, 150)
        else
            if DT_AudioManager then DT_AudioManager.PlaySound("DT_Cashier", false, 1.0) else getSoundManager():PlaySound("DT_Cashier", false, 1.0) end
            
            local maxPossible = SandboxVars.DynamicTrading.WalletMaxCash or 300
            local ratio = total / maxPossible

            if type == "JACKPOT" or ratio >= 0.7 then
                r, g, b = 50, 255, 50 
                ForceSay(player, GetRandomLine(WalletTalk.High))
            elseif ratio >= 0.3 then
                r, g, b = 100, 255, 100 
                ForceSay(player, GetRandomLine(WalletTalk.Medium))
            else
                r, g, b = 150, 200, 150 
                ForceSay(player, GetRandomLine(WalletTalk.Low))
            end
            
            local messageText = "+ $" .. tostring(total)
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
                        if item:getContainer() ~= playerObj:getInventory() then
                            ISTimedActionQueue.add(ISInventoryTransferAction:new(
                                playerObj, item, item:getContainer(), playerObj:getInventory()
                            ))
                        end
                        
                        ISTimedActionQueue.add(ISWalletAction:new(playerObj, item))
                    end
                end
            )
            
            -- [NEW] Add dice icon to signify lottery/RNG aspect
            local diceIcon = getTexture("Item_Dice")
            if diceIcon and option then
                option.iconTexture = diceIcon
            end
            
            break 
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(WalletContextMenu)