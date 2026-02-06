DynamicTradingInfoUI_Settings = {}

function DynamicTradingInfoUI_Settings.getGroups()
    local groups = {}
    
    -- 1. PRICING & ECONOMY
    local economy = {
        name = "PRICING & RETURNS",
        items = {}
    }
    
    local buyMult = SandboxVars.DynamicTrading.PriceBuyMult or 1.0
    local sellMult = SandboxVars.DynamicTrading.PriceSellMult or 0.5
    local buyDesc = buyMult > 1.5 and "Exorbitant" or (buyMult > 1.1 and "Pricey" or (buyMult < 0.9 and "Affordable" or "Standard"))
    table.insert(economy.items, { key = "PriceBuyMult", label = "Buy Pricing", desc = buyDesc, val = buyMult .. "x" })
    
    local sellDesc = sellMult < 0.3 and "Poor" or (sellMult > 0.7 and "Lucrative" or "Standard")
    table.insert(economy.items, { key = "PriceSellMult", label = "Sell Returns", desc = sellDesc, val = (sellMult * 100) .. "%" })
    
    local stockMult = SandboxVars.DynamicTrading.StockMult or 1.0
    local stockDesc = stockMult < 0.6 and "Scarcity" or (stockMult > 1.5 and "Abundant" or "Standard")
    table.insert(economy.items, { key = "StockMult", label = "Stock Levels", desc = stockDesc, val = stockMult .. "x" })

    table.insert(groups, economy)

    -- 2. TRADER STATUS
    local traders = {
        name = "TRADER CONFIG",
        items = {}
    }
    
    local restock = SandboxVars.DynamicTrading.RestockInterval or 1
    local restockDesc = restock == 1 and "Daily" or (restock >= 7 and "Weekly" or "Every " .. restock .. " days")
    table.insert(traders.items, { key = "RestockInterval", label = "Restock Frequency", desc = restockDesc, val = restock .. " Days" })
    
    local budgetMax = SandboxVars.DynamicTrading.TraderBudgetMax or 500
    local budgetMin = SandboxVars.DynamicTrading.TraderBudgetMin or 100
    local wealthDesc = budgetMax < 1000 and "Poor" or (budgetMax > 5000 and "Wealthy" or "Middle-Class")
    table.insert(traders.items, { key = "TraderBudget", label = "Trader Liquidity", desc = wealthDesc, val = "$" .. budgetMin .. "-$" .. budgetMax })

    local traderMin = SandboxVars.DynamicTrading.DailyTraderMin or 2
    local traderMax = SandboxVars.DynamicTrading.DailyTraderMax or 8
    local densityDesc = traderMax > 15 and "High Density" or (traderMax < 5 and "Isolated" or "Standard")
    table.insert(traders.items, { key = "DailyTraders", label = "Signal Density", desc = densityDesc, val = traderMin .. "-" .. traderMax .. " Found/Day" })

    table.insert(groups, traders)

    -- 3. MARKET BEHAVIOR
    local behavior = {
        name = "MARKET DYNAMICS",
        items = {}
    }
    
    local eventFreq = SandboxVars.DynamicTrading.EventFrequency or 3
    local volDesc = eventFreq <= 1 and "Chaotic" or (eventFreq >= 10 and "Stable" or "Dynamic")
    table.insert(behavior.items, { key = "EventFrequency", label = "Volatility", desc = volDesc, val = "Check every " .. eventFreq .. " days" })
    
    local defChance = SandboxVars.DynamicTrading.SellDeflationChance or 5
    local satDesc = defChance <= 3 and "Sensitive" or (defChance >= 15 and "Robust" or "Standard")
    table.insert(behavior.items, { key = "SellDeflationChance", label = "Price Stability", desc = satDesc, val = "1 in " .. defChance .. " chance" })

    local redChance = SandboxVars.DynamicTrading.SellPriceReductionChance or 20
    local redDesc = redChance > 40 and "Aggressive" or (redChance < 10 and "Lenient" or "Standard")
    table.insert(behavior.items, { key = "SellPriceReductionChance", label = "Personal Market", desc = redDesc, val = redChance .. "%" })

    local decay = SandboxVars.DynamicTrading.InflationDecay or 0.01
    local decayDesc = decay > 0.05 and "Rapid" or (decay < 0.005 and "Stagnant" or "Iterative")
    table.insert(behavior.items, { key = "InflationDecay", label = "Economy Recovery", desc = decayDesc, val = (decay * 100) .. "% Daily" })

    table.insert(groups, behavior)

    -- 4. RADIO & DISCOVERY
    local radio = {
        name = "RADIO & SIGNAL",
        items = {}
    }
    
    local scanBase = SandboxVars.DynamicTrading.ScanBaseChance or 30
    table.insert(radio.items, { key = "ScanBaseChance", label = "Base Discovery", desc = scanBase .. "% Base", val = scanBase .. "%" })
    
    local walkieDrop = SandboxVars.DynamicTrading.WalkieDropChance or 20.0
    table.insert(radio.items, { key = "WalkieDropChance", label = "Drop Rate", desc = walkieDrop .. "% on Zeds", val = walkieDrop .. "%" })

    table.insert(groups, radio)

    -- 5. WALLET SYSTEM
    local wallet = {
        name = "CURRENCY & LOOT",
        items = {}
    }
    
    local walletMin = SandboxVars.DynamicTrading.WalletMinCash or 1
    local walletMax = SandboxVars.DynamicTrading.WalletMaxCash or 100
    local emptyChance = SandboxVars.DynamicTrading.WalletEmptyChance or 35
    table.insert(wallet.items, { key = "WalletCash", label = "Wallet Loot", desc = "$" .. walletMin .. "-$" .. walletMax .. " range", val = "$" .. walletMin .. "-$" .. walletMax })
    table.insert(wallet.items, { key = "WalletEmptyChance", label = "Empty Wallets", desc = emptyChance .. "% of find", val = emptyChance .. "%" })

    table.insert(groups, wallet)

    return groups
end

function DynamicTradingInfoUI_Settings.getDetail(key)
    local details = {
        PriceBuyMult = "Determines how expensive items are when buying from traders. Higher values make the game more difficult by requiring more cash.",
        PriceSellMult = "Percentage of an item's value you receive when selling. Lower values make scavenging for profit much harder.",
        StockMult = "Controls how many items traders have in stock. Lower values lead to scarcity and may require visiting multiple traders.",
        RestockInterval = "How many days must pass before a trader refreshes their inventory and resets their personal item deflation.",
        TraderBudget = "The range of cash a trader starts with. If a trader runs out of money, they cannot buy more items from you.",
        EventFrequency = "How often the world economy faces 'Flash Events' like riots, weather disasters, or military lockdowns.",
        SellDeflationChance = "The chance that selling an item will cause its global market value to drop for the day.",
        SellPriceReductionChance = "The percentage chance that selling an item to a trader will cause THAT specific trader to offer less for subsequent copies of that item.",
        InflationDecay = "How quickly the global market recovers from price inflation or deflation each day. Higher means faster recovery.",
        ScanBaseChance = "The base success rate when searching for radio signals to discover new traders.",
        DailyTraders = "The daily range of how many unique traders move through the region. Higher values mean more opportunities to find signals.",
        WalletCash = "The minimum and maximum amount of cash that can be found in world-looted wallets.",
        WalkieDropChance = "The probability of finding a functional walkie-talkie on a neutralized zombie.",
        WalletMaxCash = "The maximum amount of cash that can be found in a world-looted wallet.",
        WalletEmptyChance = "The percentage of looted wallets that contain no cash at all."
    }
    return details[key] or "No additional information available."
end
