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
    -- [ANTICIPATION] Thoughts before opening a single wallet (20 lines)
    Anticipation = { 
        "Sorry, pal, you don't need this anymore...", 
        "Let's see who you were...", 
        "Feels heavy, that's a good sign...", 
        "Nice leather. Hope it's full.", 
        "Please be cash, not just receipts...",
        "Forgive me...",
        "Just need a little help here...",
        "Let's see what you're hiding.",
        "Don't let me down.",
        "Rent's due in hell, I guess.",
        "Checking the folds...",
        "Zipper is stuck... come on.",
        "Who were you? A banker? A mechanic?",
        "Blood on the corner... grim.",
        "This one feels thick.",
        "Just one lucky break, please.",
        "I promise to spend it well.",
        "Maybe enough for some gas?",
        "Velcro wallet? Probably empty.",
        "Let's check the secret compartment."
    },
    
    -- [BULK START] Thoughts before sorting a pile (20 lines)
    BulkStart = { 
        "Grim work, sorting through these.", 
        "Let's see what the dead left behind.", 
        "Okay, let's see if anyone was carrying cash.", 
        "Sorting time. Hope it's worth the guilt.",
        "Someone had to empty these eventually.",
        "Let's count the inheritance.",
        "A whole life in a pocket... let's look.",
        "Okay, systemizing the loot.",
        "Let's get this over with.",
        "Pockets to pile. Let's go.",
        "Starting the audit.",
        "Does anyone even use cash anymore? I do.",
        "Lined up and ready to check.",
        "Checking the harvest.",
        "Let's see who was prepared.",
        "This is going to take a minute.",
        "Systematic approach. Open, check, drop.",
        "Hope at least one of these is a winner.",
        "Sorting the dead's pockets. My life now.",
        "Let's see the total haul."
    },
    
    -- [BULK LOOP] Short thoughts while processing (20 lines)
    BulkLoop = { 
        "Next...", 
        "Another ID...", 
        "Toss the plastic.", 
        "Moving on...", 
        "Just personal stuff...", 
        "Checking...",
        "Emptying...",
        "Sorting...",
        "Aside.",
        "Flip it.",
        "And another.",
        "Check the coin pouch.",
        "Nothing interesting.",
        "Standard issue.",
        "Keep going.",
        "On to the next.",
        "Done with that one.",
        "Another leather one.",
        "Rummaging...",
        "Searching..."
    },

    -- [EMPTY] Finding nothing or useless items (20 lines)
    Empty = { 
        "Just a picture of their kids... damn.", 
        "Video rental card. Useless now.", 
        "Maxed out credit cards.", 
        "Grocery receipt from July.", 
        "Just a driver's license from Muldraugh.", 
        "Nothing but dust and lint.",
        "Totally cleaned out.",
        "Just a library card.",
        "Business cards... 'Insurance Agent'.",
        "A folded gum wrapper. Great.",
        "Bone dry.",
        "Just an appointment card for the dentist.",
        "A shopping list: Milk, Eggs, Bread.",
        "Unpaid parking ticket. Lucky you.",
        "Just a gym membership card.",
        "Condom in the wrapper. Optimist.",
        "Social Security card. Identity theft is over.",
        "Just a frequent diner punch card.",
        "Checkbook. Can't cash these anymore.",
        "Absolutely nothing. Why carry it?"
    },

    -- [LOW] Finding small change (20 lines)
    Low = { 
        "Couple of singles.", 
        "Just loose change.", 
        "Barely enough for a coffee.", 
        "Lint and a quarter.",
        "He kept the big bills elsewhere.",
        "Pocket change.",
        "Better than nothing, I suppose.",
        "Couple of ones crumpled up.",
        "Just a fiver.",
        "Gas money, maybe.",
        "Thin pickings.",
        "Enough for a gumball.",
        "Just some pennies and a dime.",
        "Was this guy broke too?",
        "A wrinkled dollar bill.",
        "Spare change.",
        "Not exactly a fortune.",
        "Guess he spent it all.",
        "Just a few coins rattling around.",
        "Minimum wage wallet."
    },

    -- [MEDIUM] Finding a decent amount (20 lines)
    Medium = { 
        "Okay, twenties. Not bad.", 
        "This helps.", 
        "Solid stash.",
        "Kept a little emergency fund.",
        "That's a week's worth of groceries.",
        "Nice and crisp.",
        "Respectable amount.",
        "Someone just got paid.",
        "Adding to the pile.",
        "Fair enough.",
        "Good find.",
        "This will buy some rounds.",
        "A decent handful of cash.",
        "Okay, we're getting somewhere.",
        "Not rich, but not poor.",
        "Useful paper.",
        "I'll take it.",
        "Lunch money secured.",
        "Someone was responsible.",
        "A few decent bills tucked away."
    },

    -- [HIGH] Finding a lot / Jackpot (20 lines)
    High = { 
        "Holy... was this guy a banker?", 
        "Stashed away for a rainy day!", 
        "Thick wad of hundreds!", 
        "Jackpot. Sorry pal, I need this more.", 
        "This guy was loaded!", 
        "Look at that stack...",
        "Retirement fund secured.",
        "Must have been heading to the casino.",
        "Unbelievable find.",
        "We are eating good tonight.",
        "Saving up for something big, huh?",
        "Motherlode!",
        "Did he just rob a bank?",
        "That is a LOT of cash.",
        "My hands are shaking... look at this.",
        "Who carries this much cash?!",
        "Top tier loot right here.",
        "Winner winner.",
        "I could buy a car with this... if they ran.",
        "This is what I'm talking about!"
    }
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
    if self.item and inv:contains(self.item) then return true end

    -- 2. Fallback ID check
    if self.itemID then
        local foundItem = inv:getItemById(self.itemID)
        if foundItem then
            self.item = foundItem 
            return true
        end
    end

    -- 3. Container check (rare case)
    if self.item and self.item:getContainer() then return true end

    return false
end

function ISWalletAction:update()
    -- Reset hand models to ensure animation looks right
    self.character:setMetabolicTarget(Metabolics.LightWork)

    if not self.soundStarted then
        self.soundStarted = true
        
        if DT_AudioManager then
            DT_AudioManager.PlaySound("DT_CasinoRandom", false, 1.0)
        else
            getSoundManager():PlaySound("DT_CasinoRandom", false, 1.0)
        end
        
        -- DYNAMIC FLAVOR TEXT LOGIC
        if self.isBulk then
            -- In bulk mode: Lower chance (25%) and use "Loop" text (shorter lines)
            -- This prevents spamming "Come on..." 20 times.
            if ZombRand(100) < 45 then
                self.character:Say(GetRandomLine(WalletTalk.BulkLoop))
            end
        else
            -- In single mode: High chance (60%) and use "Anticipation" text
            -- Makes single interactions feel livelier.
            if ZombRand(100) < 70 then
                self.character:Say(GetRandomLine(WalletTalk.Anticipation))
            end
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

function ISWalletAction:new(character, item, isBulk)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item
    o.isBulk = isBulk or false -- Store the bulk flag
    
    -- Store ID for robust lookup in SP
    if item then
        o.itemID = item:getID()
    end
    
    -- Reduced time slightly for mass opening QoL (was 120)
    o.maxTime = 90 
    o.soundStarted = false 
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
            
            -- Reduced chat spam for mass opening
            if ZombRand(100) < 30 then 
                ForceSay(player, GetRandomLine(WalletTalk.Empty))
            end
            
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
                if ZombRand(100) < 50 then ForceSay(player, GetRandomLine(WalletTalk.Medium)) end
            else
                r, g, b = 150, 200, 150 
                if ZombRand(100) < 30 then ForceSay(player, GetRandomLine(WalletTalk.Low)) end
            end
            
            local messageText = "+ $" .. tostring(total)
            ShowFloatingText(player, messageText, r, g, b)
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- 5. CONTEXT MENU & BULK ACTION LOGIC
-- =============================================================================

-- Helper to check if an item is a wallet
local function isWalletItem(item)
    if not item then return false end
    local fullType = item:getFullType()
    return fullType == "Base.Wallet" or fullType == "Base.Wallet_Female" or fullType == "Base.Wallet_Male"
end

-- Helper to actually perform the queue logic
local function OnOpenWallet(items, playerObj, openAll)
    local playerInv = playerObj:getInventory()
    local walletsToOpen = {}

    -- 1. Gather all valid wallets from the selection
    local actualItems = ISInventoryPane.getActualItems(items)
    
    if openAll then
        -- If Open All, we ignore the specific selection and look at the container of the first item selected
        local firstItem = actualItems[1]
        if firstItem and firstItem:getContainer() then
            local containerItems = firstItem:getContainer():getItems()
            for i=0, containerItems:size()-1 do
                local it = containerItems:get(i)
                if isWalletItem(it) then
                    table.insert(walletsToOpen, it)
                end
            end
        end
    else
        -- Just open the specifically selected items
        for _, item in ipairs(actualItems) do
            if isWalletItem(item) then
                table.insert(walletsToOpen, item)
            end
        end
    end
    
    -- 2. Trigger Bulk Start Dialogue (Immediate)
    local count = #walletsToOpen
    local isBulkOperation = (count > 1)
    
    if isBulkOperation then
        ForceSay(playerObj, GetRandomLine(WalletTalk.BulkStart))
    end

    -- 3. Iterate and Queue Actions
    for _, wallet in ipairs(walletsToOpen) do
        if ISWalletAction then
            if wallet:getContainer() ~= playerInv then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(
                    playerObj, wallet, wallet:getContainer(), playerInv
                ))
            end
            
            -- Pass the 'isBulkOperation' flag to the action
            ISTimedActionQueue.add(ISWalletAction:new(playerObj, wallet, isBulkOperation))
        end
    end
end

local function WalletContextMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    if not items then return end
    
    local actualItems = ISInventoryPane.getActualItems(items)
    local walletCount = 0
    local testItem = nil

    -- Count how many wallets are in the selection to determine menu options
    for _, item in ipairs(actualItems) do
        if isWalletItem(item) then
            walletCount = walletCount + 1
            testItem = item
        end
    end

    -- If we found at least one wallet
    if walletCount > 0 and testItem then
        local diceIcon = getTexture("Item_Dice")
        
        -- Option 1: Open Selected
        local text = "Rummage through Wallet"
        if walletCount > 1 then
            text = "Rummage through Selected Wallets (" .. walletCount .. ")"
        end
        
        local option = context:addOption(text, items, OnOpenWallet, playerObj, false)
        if diceIcon then option.iconTexture = diceIcon end

        -- Option 2: Open All in Container (Detect if more exist in the container)
        local container = testItem:getContainer()
        if container then
            local totalWalletsInContainer = 0
            local cItems = container:getItems()
            for i=0, cItems:size()-1 do
                if isWalletItem(cItems:get(i)) then
                    totalWalletsInContainer = totalWalletsInContainer + 1
                end
            end

            -- Only show "Open All" if there are more in the container than currently selected
            if totalWalletsInContainer > 1 and totalWalletsInContainer > walletCount then
                local allText = "Rummage through ALL Wallets (" .. totalWalletsInContainer .. ")"
                local allOption = context:addOption(allText, items, OnOpenWallet, playerObj, true)
                if diceIcon then allOption.iconTexture = diceIcon end
            end
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(WalletContextMenu)
print("[DynamicTrading] Registered wallet interaction with Smart Flavor Text.")