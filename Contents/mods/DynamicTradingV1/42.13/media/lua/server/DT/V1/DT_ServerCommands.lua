-- =============================================================================
-- DYNAMIC TRADING V1: SERVER COMMAND HANDLER (FACTION PARITY)
-- =============================================================================
-- Compatible with Singleplayer, MP Hosted, and MP Dedicated.
-- Radio-specific commands: Scanning, RequestTrader, BurnMoney, UnpackContainer.
-- Trade transactions are delegated to the shared TradeHandlers in Common.
-- =============================================================================

require "DT/V1/Manager"
require "DT/Common/Config"
require "DT/Common/ServerHelpers/ServerHelpers"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"

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
        
        -- Targeted Sync: Transmit individual soul brains for active radio traders
        -- This ensures clients get visuals and full identity for found traders
        if data.RadioTraders then
            for uuid, _ in pairs(data.RadioTraders) do
                local soulKey = "DTSOUL_" .. uuid
                if ModData.exists(soulKey) then
                    ModData.transmit(soulKey)
                end
            end
        end
    end
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

    -- 1. Cooldown Check
    local canScan, timeRem = DynamicTrading.CooldownManager.CanScan(player)
    if not canScan then
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    -- 2. Get Undiscovered Traders (Existing ones in "Trading" state)
    local undiscovered = DynamicTrading.Manager.GetUndiscoveredTraders(player)
    local hasUndiscovered = (#undiscovered > 0)

    -- [NEW] If no undiscovered traders exist, scan always fails (no generation allowed)
    if not hasUndiscovered then
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    -- 3. Apply Cooldown
    DynamicTrading.CooldownManager.SetScanTimestamp(player)

    -- 4. Calculate Chances
    local radioTier = args.radioTier or 0.5
    local baseChance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanBaseChance) or 30
    local skillBonus = args.skillBonus or 1.0
    
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        eventMult = DynamicTrading.Events.GetSystemModifier("scanChance")
    end

    -- [REFACTORED] Difficulty Scaling (Based on Capacity)
    local capacity = args.capacity or 1
    local foundSignals = args.foundSignals or 0
    
    -- BLOCK: Capacity Check
    if foundSignals >= capacity then
        DynamicTrading.Log("DTV1", "Radio", "Scan", "FAILED: Radio Capacity Full (" .. foundSignals .. "/" .. capacity .. ")")
        SendResponse(player, "ScanResult", { status = "CAPACITY_FULL", targetUser = targetUser, currentCount = foundSignals, capacity = capacity })
        return
    end

    local progressRatio = foundSignals / capacity
    
    -- Penalty increases as you approach capacity
    -- At 0% full, penalty is 1.0. At 99% full, penalty is ~5.0.
    local penaltyFactor = 1.0 + (progressRatio * 4.0)
    
    local finalChance = (baseChance * radioTier * skillBonus * eventMult) / penaltyFactor
    
    -- Ensure chance is at least 1% if any undiscovered exist
    if finalChance < 1 then finalChance = 1 end
    
    -- [DEBUG PRINTS]
    DynamicTrading.Log("DTV1", "Radio", "Scan", "Scanning for undiscovered traders...")
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Base Chance: " .. baseChance)
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Radio Tier: " .. radioTier)
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Skill Bonus: " .. skillBonus)
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Radio Capacity: " .. foundSignals .. "/" .. capacity .. " (Ratio: " .. string.format("%.2f", progressRatio) .. ")")
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Penalty Factor: " .. string.format("%.2f", penaltyFactor))
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Final Calculated Chance: " .. string.format("%.2f", finalChance) .. "%")
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Undiscovered Traders Pool: " .. #undiscovered)
    
    local roll = ZombRand(100) + 1
    DynamicTrading.Log("DTV1", "Radio", "Scan", "  - Roll: " .. roll)

    -- 5. Roll Dice
    local isSuccess = roll <= finalChance
    
    if isSuccess then
        -- 6. Discover EXISTING trader
        local trader = undiscovered[ZombRand(#undiscovered) + 1]
        
        if trader then
            DynamicTrading.Log("DTV1", "Radio", "Scan", "  - SUCCESS! Found: " .. trader.name .. " (" .. trader.archetype .. ")")
            
            SendResponse(player, "ScanResult", { 
                status = "SUCCESS", 
                id = trader.id, -- [NEW] Send ID so client can discover locally
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser,
                wasNew = false -- Scanning never generates new now
            })
        else
            SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        end
    else
        DynamicTrading.Log("DTV1", "Radio", "Scan", "  - FAILED: Roll > Final Chance")
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
    end
end


-- =============================================================================
-- 3. EVENT LISTENER (MULTIPLAYER BRIDGE)
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and command == "TradeTransaction" then
        if DynamicTrading and DynamicTrading.NetworkServer and DynamicTrading.NetworkServer.HandlesSharedCommands then
            return
        end
    end
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
            if radioData.returnTime and currentHours > radioData.returnTime then
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

DynamicTrading.Log("DTV1", "Init", "System", "V1 Server Commands (Faction Parity) Loaded.")
