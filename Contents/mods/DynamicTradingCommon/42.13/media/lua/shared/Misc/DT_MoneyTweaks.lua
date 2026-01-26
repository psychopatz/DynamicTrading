-- [DYNAMIC TRADING] Money UI Tweaks
-- Handles Context Menu interactions for Currency and Weight adjustments.
-- Compatible with SP, MP Client, and MP Server.

-- =============================================================================
-- 1. COMMON LOGIC (Weight)
-- =============================================================================

local function SetMoneyWeight()
    -- We set the weight to 0.0 for both Money and Bundles.
    -- This needs to run on GameBoot so the definitions update before the player loads.
    local scriptMoney = ScriptManager.instance:getItem("Base.Money")
    if scriptMoney then 
        scriptMoney:setActualWeight(0.0) 
    end
    
    local scriptBundle = ScriptManager.instance:getItem("Base.MoneyBundle")
    if scriptBundle then 
        scriptBundle:setActualWeight(0.0) 
    end
    
    print("[DT-Money] Currency weight set to 0.0")
end

-- =============================================================================
-- 2. CLIENT / SP LOGIC (Context Menu)
-- =============================================================================

-- These functions are only needed where a user interface exists (Client & SP)

local function onCompressMoney(playerObj)
    local player = getSpecificPlayer(0)
    -- This works in MP (sends to server) and SP (sends to internal server)
    sendClientCommand(player, "DT_Money", "CompressMoney", {})
end

local function onUnbundleMoney(playerObj)
    local player = getSpecificPlayer(0)
    sendClientCommand(player, "DT_Money", "UncompressMoney", {})
end

local function OnFillInventoryObjectContextMenu(player, context, items)
    local playerObj = getSpecificPlayer(player)
    local inv = playerObj:getInventory()
    
    local moneySelected = false
    local bundleSelected = false
    
    -- 1. Identify what was clicked
    for i, v in ipairs(items) do
        local testItem = v
        if not instanceof(v, "InventoryItem") then
            -- Handle collapsed stacks (Table of items)
            if v.items and v.items[1] then
                testItem = v.items[1]
            end
        end
        
        if testItem then
            local type = testItem:getFullType()
            if type == "Base.Money" then
                moneySelected = true
            elseif type == "Base.MoneyBundle" then
                bundleSelected = true
            end
        end
    end

    -- 2. Compress Logic (Money -> Bundle)
    if moneySelected then
        -- We explicitly check the MAIN inventory. 
        -- Context menus can trigger inside bags, but our server command targets the main inv.
        local moneyList = inv:getItemsFromType("Base.Money")
        local count = moneyList and moneyList:size() or 0
        
        if count >= 100 then
            local bundlesPossible = math.floor(count / 100)
            local text = "Compress Money (Makes " .. bundlesPossible .. ")"
            local option = context:addOption(text, playerObj, onCompressMoney)
            
            local script = ScriptManager.instance:getItem("Base.MoneyBundle")
            if script and script:getIcon() then
                option.iconTexture = getTexture("Item_" .. script:getIcon())
            end
        end
    end

    -- 3. Uncompress Logic (Bundle -> Money)
    if bundleSelected then
        local bundleList = inv:getItemsFromType("Base.MoneyBundle")
        local count = bundleList and bundleList:size() or 0
        
        if count > 0 then
            local totalCash = count * 100
            local text = "Uncompress Bundles (Makes $" .. totalCash .. ")"
            local option = context:addOption(text, playerObj, onUnbundleMoney)
            
            local script = ScriptManager.instance:getItem("Base.Money")
            if script and script:getIcon() then
                option.iconTexture = getTexture("Item_" .. script:getIcon())
            end
        end
    end
end

-- =============================================================================
-- 3. REGISTRATION (Networking Logic)
-- =============================================================================

if isClient() then
    -- [MULTIPLAYER CLIENT]
    -- Needs UI Events AND Weight definitions
    Events.OnGameBoot.Add(SetMoneyWeight)
    Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)

elseif isServer() then
    -- [MULTIPLAYER SERVER]
    -- Needs Weight definitions so it doesn't calculate player weight incorrectly.
    -- Does NOT need UI events.
    Events.OnGameBoot.Add(SetMoneyWeight)

else
    -- [SINGLEPLAYER]
    -- Behaves like a Client with full authority.
    -- Needs UI Events AND Weight definitions.
    Events.OnGameBoot.Add(SetMoneyWeight)
    Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
end

print("[DynamicTrading] Money Tweaks Registered.")