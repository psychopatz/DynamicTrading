-- =============================================================================
-- DYNAMIC TRADING: TRADER DIALOGUE REQUEST LOGIC
-- =============================================================================
require "UI/DT_ConversationUI"
require "02_DynamicTrading_Manager"

DT_TraderDialogue_Request = {}

function DT_TraderDialogue_Request.Start(ui, trader)
    if not ui or not trader then return end
    
    -- 1. Speak Intro
    local intro = DynamicTrading.DialogueManager.GetDialogue(trader, "Request", "Start") 
    ui:speak(intro or "I know some people. Who are you looking for?")
    
    -- 2. Generate Options
    DT_TraderDialogue_Request.GenerateArchetypeOptions(ui, trader)
end

function DT_TraderDialogue_Request.GenerateArchetypeOptions(ui, trader)
    local options = {}
    
    -- 1. Dynamic Pricing
    local current, max = DynamicTrading.Manager.GetDailyStatus()
    local saturation = current / max
    local basePrice = 500
    local finalPrice = math.floor(basePrice * (1 + (saturation * 2))) 
    
    -- 2. Build List
    for id, _ in pairs(DynamicTrading.Archetypes) do
        table.insert(options, {
            text = "Find a " .. id .. " ($" .. finalPrice .. ")",
            message = "I'm looking for a " .. id .. ". Can you hook me up?",
            data = { archetype = id, price = finalPrice, traderID = trader.id },
            onSelect = function(ui, data) 
                DT_TraderDialogue_Request.OnSelectArchetype(ui, data)
            end
        })
    end
    
    -- 3. Cancel
    table.insert(options, {
        text = "Nevermind",
        message = "Actually, nevermind.",
        onSelect = function(ui) 
            -- Return to Hub
            require "UI/DT_TraderDialogue_Hub"
            DT_TraderDialogue_Hub.Init(ui, trader)
        end
    })
    
    ui:updateOptions(options)
end

function DT_TraderDialogue_Request.OnSelectArchetype(ui, data)
    local player = getSpecificPlayer(0)
    local price = data.price
    local archetype = data.archetype
    
    -- 1. Check Wealth
    local function getPlayerWealth(player)
         local inv = player:getInventory()
         local loose = inv:getItemsFromType("Base.Money", true)
         local bundle = inv:getItemsFromType("Base.MoneyBundle", true)
         local val = (loose and loose:size() or 0) + ((bundle and bundle:size() or 0) * 100)
         return val
    end

    if getPlayerWealth(player) < price then
        local noCash = DynamicTrading.DialogueManager.GetDialogue(ui.target, "Request", "NoFunds")
        ui:speak(noCash or "You don't have enough credits.")
        return
    end

    -- 2. Lock
    local trader = DynamicTrading.Manager.GetTrader(data.traderID)
    if trader then 
        trader.hasRequestedFavor = true 
        -- [CHANGED] Do not disable the main Talk button. 
        -- The Hub will handle disabling the 'Request' option internally.
        if DynamicTradingUI.instance and DynamicTradingUI.instance.btnAsk then
            DynamicTradingUI.instance.btnAsk.tooltip = "Favor requested."
        end
    end

    -- 3. Execute
    local roll = ZombRand(100)
    local scamChance = 20 
    
    if roll < scamChance then
        -- FAIL
        local scamMsg = DynamicTrading.DialogueManager.GetDialogue(trader, "Request", "Scammed")
        ui:speak(scamMsg or "Sent the funds... but they ghosted us.")
        
        local args = { amount = price }
        sendClientCommand(player, "DynamicTrading", "BurnMoney", args)
    else
        -- SUCCESS
        local successMsg = DynamicTrading.DialogueManager.GetDialogue(trader, "Request", "Success")
        ui:speak(successMsg or "Done. Sending coordinates.")
        
        local args = { 
            archetype = archetype, 
            price = price, 
            traderID = data.traderID 
        }
        sendClientCommand(player, "DynamicTrading", "RequestTrader", args)
    end
    
    -- Clear Options and provide Leave/Back
    ui:updateOptions({
        { 
            text = "Back to Main", 
            message = "", 
            onSelect = function(ui) 
                require "UI/DT_TraderDialogue_Hub"
                DT_TraderDialogue_Hub.Init(ui, trader)
            end 
        },
        { 
            text = "Leave", 
            message = "", 
            onSelect = function(ui) ui:close() end 
        }
    })
end
