-- =============================================================================
-- DYNAMIC TRADING V1: SERVER COMMAND HANDLER (FACTION PARITY)
-- =============================================================================
-- Compatible with Singleplayer, MP Hosted, and MP Dedicated.
-- Radio-specific commands: Scanning, RequestTrader, BurnMoney, UnpackContainer.
-- Trade transactions are delegated to the shared TradeHandlers in Common.
-- =============================================================================

require "DT/V1/Manager"
require "DT/Common/Config"
require "DT/Common/ServerHelpers"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"

local TradeHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers"
local DataHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers"

-- 1. GLOBAL TABLE REGISTRATION
DynamicTrading = DynamicTrading or {}
DynamicTrading.ServerCommands = {}

local Commands = DynamicTrading.ServerCommands
local lastProcessedDay = -1

-- =============================================================================
-- 0. ALIASES TO SHARED HELPERS
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers
local ServerRemoveItem = Helpers.RemoveItem
local ServerAddItem = Helpers.AddItem
local GetServerWealth = Helpers.GetWealth
local ServerRemoveMoney = Helpers.RemoveMoney

local function SendResponse(player, command, args)
    Helpers.SendResponse(player, "DynamicTrading", command, args)
end

-- =============================================================================
-- 2. COMMAND HANDLERS
-- =============================================================================

-- COMMAND: RequestFullState
-- Description: Client asking for the latest state (Engine + Roster + V1 Radio)
function Commands.RequestFullState(player, args)
    -- Sync Engine v2 data
    if ModData.exists("DynamicTrading_Engine_v2") then
        ModData.transmit("DynamicTrading_Engine_v2")
    end
    -- Sync Roster
    if ModData.exists("DynamicTrading_Roster") then
        ModData.transmit("DynamicTrading_Roster")
    end
    -- Sync Factions
    if ModData.exists("DynamicTrading_Factions") then
        ModData.transmit("DynamicTrading_Factions")
    end
    -- Sync Stock
    if ModData.exists("DynamicTrading_Stock") then
        ModData.transmit("DynamicTrading_Stock")
    end
    -- Sync V1 Radio state (scanning limits, discovery data)
    local data = DynamicTrading.Manager.GetData()
    if data then
        ModData.transmit("DynamicTrading_V1_Radio")
    end
end

-- COMMAND: TradeTransaction
-- Description: Delegates to the shared TradeHandlers (same logic as V2)
function Commands.TradeTransaction(player, args)
    TradeHandlers.Handlers.TradeTransaction(player, args)
end

-- COMMAND: RequestTrader
-- Description: Buying a specific contact lead (Favor)
function Commands.RequestTrader(player, args)
    local archetype = args.archetype
    local price = args.price or 0
    local targetUser = player:getUsername()

    -- 1. Validate Money
    if GetServerWealth(player) < price then
        SendResponse(player, "RequestResult", { success=false, msg="Insufficient Funds" })
        return
    end

    -- 2. Validate Cap (Double Check Server Side)
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        SendResponse(player, "RequestResult", { success=false, msg="Network Busy (Cap Reached)" })
        return
    end

    -- 3. Deduct Money
    if not ServerRemoveMoney(player, price) then
        SendResponse(player, "RequestResult", { success=false, msg="Transaction Error" })
        return
    end

    -- 4. Generate Trader (creates Soul in Roster + Stock)
    local trader = DynamicTrading.Manager.GenerateRandomContact(player, archetype)
    
    if trader then
        -- Auto-discover for requesting player
        DynamicTrading.Manager.DiscoverTrader(trader.id, player)
        
        DynamicTrading.NetworkLogs.AddLog("Favor: " .. targetUser .. " requested a " .. archetype, "info")
        SendResponse(player, "RequestResult", { success=true, name=trader.name })
    else
        ServerAddItem(player:getInventory(), "Base.Money", price) -- Refund
        SendResponse(player, "RequestResult", { success=false, msg="Contact unavailable" })
    end
end

-- COMMAND: BurnMoney
-- Description: Removes money without reward (Scam/Theft mechanics)
function Commands.BurnMoney(player, args)
    local amount = args.amount
    if amount and amount > 0 then
        ServerRemoveMoney(player, amount)
        DynamicTrading.NetworkLogs.AddLog("Scam: " .. player:getUsername() .. " lost $" .. amount, "bad")
    end
end

-- COMMAND: UnpackContainer
-- Description: Drops everything inside a bag to the player's feet
function Commands.UnpackContainer(player, args)
    if not player or not args.itemID then return end
    
    local inv = player:getInventory()
    local bag = inv:getItemById(args.itemID)
    
    if not bag or not instanceof(bag, "InventoryContainer") then return end
    
    -- Use shared helper for the actual drop logic
    Helpers.DropContainerToGround(player, bag)
    
    -- Notify Client to refresh UI
    SendResponse(player, "UnpackResult", { success = true })
end

-- COMMAND: AttemptScan
-- Description: The RNG roll for finding new traders via radio
function Commands.AttemptScan(player, args)
    if not player then return end
    local targetUser = player:getUsername()
    local isPublicNetwork = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork)

    -- 1. Cooldown Check
    local canScan, timeRem = DynamicTrading.CooldownManager.CanScan(player)
    if not canScan then
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    -- 2. Daily Limit Check (Global)
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    local canGenerateNew = (found < limit)
    
    -- 3. Get Undiscovered Traders (for Private Network mode)
    local undiscovered = DynamicTrading.Manager.GetUndiscoveredTraders(player)
    local hasUndiscovered = (#undiscovered > 0)

    -- [PUBLIC NETWORK MODE] Block if limit reached (old behavior)
    if isPublicNetwork and not canGenerateNew then
        SendResponse(player, "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end
    
    -- [PRIVATE NETWORK MODE] Block if limit reached AND no undiscovered traders left
    if not isPublicNetwork and not canGenerateNew and not hasUndiscovered then
        SendResponse(player, "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end

    -- 4. Apply Cooldown
    DynamicTrading.CooldownManager.SetScanTimestamp(player)

    -- 5. Calculate Chances
    local penaltyPerTrader = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanPenaltyPerTrader) or 0.2
    local penaltyFactor = 1.0 + (found * penaltyPerTrader) 
    
    local radioTier = args.radioTier or 0.5
    local baseChance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanBaseChance) or 30
    local skillBonus = args.skillBonus or 1.0
    
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        eventMult = DynamicTrading.Events.GetSystemModifier("scanChance")
    end

    local finalChance = (baseChance * radioTier * skillBonus * eventMult) / penaltyFactor
    
    -- [DEBUG PRINTS]
    print("[DynamicTrading] Scanning for traders...")
    print("  - Public Network Mode: " .. tostring(isPublicNetwork))
    print("  - Base Chance: " .. baseChance)
    print("  - Radio Tier: " .. radioTier)
    print("  - Skill Bonus: " .. skillBonus)
    print("  - Event Mult: " .. eventMult)
    print("  - Penalty Factor: " .. penaltyFactor .. " (Found: " .. found .. ")")
    print("  - Final Calculated Chance: " .. string.format("%.2f", finalChance) .. "%")
    print("  - Undiscovered Traders Available: " .. #undiscovered)
    
    local roll = ZombRand(100) + 1
    print("  - Roll: " .. roll)

    -- 6. Roll Dice
    if roll <= finalChance then
        local trader = nil
        local wasNewGeneration = false
        
        -- ==========================================================
        -- PUBLIC NETWORK MODE (Old Behavior: Everyone shares)
        -- ==========================================================
        if isPublicNetwork then
            trader = DynamicTrading.Manager.GenerateRandomContact(player)
            wasNewGeneration = true
            
        -- ==========================================================
        -- PRIVATE NETWORK MODE (Per-player discovery)
        -- ==========================================================
        else
            if canGenerateNew then
                -- 70% Generate New / 30% Discover Existing (if any)
                local generateChance = hasUndiscovered and 70 or 100
                if ZombRand(100) < generateChance then
                    -- Generate NEW trader (creates Soul in Roster)
                    trader = DynamicTrading.Manager.GenerateRandomContact(player)
                    wasNewGeneration = true
                    
                    if trader then
                        -- Auto-discover for creating player
                        DynamicTrading.Manager.DiscoverTrader(trader.id, player)
                        print("  - Generated NEW trader, auto-discovered for " .. targetUser)
                    end
                else
                    -- Discover EXISTING trader
                    trader = undiscovered[ZombRand(#undiscovered) + 1]
                    DynamicTrading.Manager.DiscoverTrader(trader.id, player)
                    print("  - Discovered EXISTING trader: " .. trader.name)
                end
            else
                -- Cap reached: Can ONLY discover existing
                trader = undiscovered[ZombRand(#undiscovered) + 1]
                DynamicTrading.Manager.DiscoverTrader(trader.id, player)
                print("  - Cap reached, discovered EXISTING trader: " .. trader.name)
            end
        end
        
        if trader then
            print("  - SUCCESS! Found: " .. trader.name .. " (" .. trader.archetype .. ")")
            SendResponse(player, "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser,
                wasNew = wasNewGeneration
            })
        else
            print("  - FAILED: Generated trader was nil (Archetypes empty?)")
            local count = 0
            if DynamicTrading.Archetypes then
                for _ in pairs(DynamicTrading.Archetypes) do count = count + 1 end
            end
            print("  - Registered Archetypes Count: " .. count)
            SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        end
    else
        print("  - FAILED: Roll > Final Chance")
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
    end
end


-- =============================================================================
-- 3. EVENT LISTENER (MULTIPLAYER BRIDGE)
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

-- =============================================================================
-- 4. SERVER MAINTENANCE LOOP
-- =============================================================================
-- Runs every hour to check for V1 Radio Trader expirations and daily resets.
-- Economy ticks (heat, events, faction sim) are handled by Engine v2.
local function Server_OnHourlyTick()
    -- Initialize Persistence on first run if needed
    if DynamicTrading.CooldownManager and DynamicTrading.CooldownManager.Init then
         DynamicTrading.CooldownManager.Init() 
    end

    if not DynamicTrading or not DynamicTrading.Manager then return end

    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()

    -- 1. V1 Radio Daily Reset (scanning limits only — economy is in Engine v2)
    DynamicTrading.Manager.CheckDailyReset()

    -- 2. Radio Trader Expiration Check
    local data = DynamicTrading.Manager.GetData()
    local changesMade = false
    
    if data.RadioTraders then
        for id, radioData in pairs(data.RadioTraders) do
            if radioData.expirationTime and currentHours > radioData.expirationTime then
                DynamicTrading.Manager.ExpireRadioTrader(id)
                changesMade = true
            end
        end
    end
    
    -- Sync if traders removed
    if changesMade then 
        DynamicTrading.Manager.BumpTradersVersion()
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)

print("[DynamicTrading] V1 Server Commands (Faction Parity) Loaded.")