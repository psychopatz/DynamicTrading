-- ==============================================================================
-- media/lua/server/DynamicTrading_Network_Server.lua
-- Logic: Server-side handling of Client Requests (Networking V2)
-- Build 42 Compatible.
-- ==============================================================================

if isClient() then return end

local ServerNetwork = {}
local COMMAND_MODULE = "DynamicTrading_V2"

-- Ensure we have access to our systems
require "DynamicTrading_Factions"
require "DynamicTrading_Roster"
require "DynamicTrading_Stock"
require "DynamicTrading_Engine"
require "DynamicTrading_Archetypes"

-- =============================================================================
-- 1. COMMAND HANDLERS
-- =============================================================================
local Handlers = {}

-- [TRADER DATA REQUEST]
Handlers.RequestTrader = function(player, args)
    local traderID = args.traderID
    local traderData = DynamicTrading_Roster.GetTrader(traderID)
    if traderData then
        local response = {
            id = traderID,
            visuals = traderData.visuals,
            factionID = traderData.factionID,
            homeCoords = traderData.homeCoords,
            isSpawned = traderData.isPhysicallySpawned
        }
        sendServerCommand(player, COMMAND_MODULE, "SyncTrader", response)
    end
end

-- [STOCK DATA REQUEST]
Handlers.RequestStock = function(player, args)
    local traderID = args.traderID
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if stockData then
        sendServerCommand(player, COMMAND_MODULE, "SyncStock", { 
            id = traderID, 
            items = stockData.items, 
            restock = stockData.restock 
        })
    end
end

-- [DEBUG & ADMIN COMMANDS]
Handlers.DebugCommand = function(player, args)
    -- Security Check: Only allow if Debug is on OR player is an Admin
    if not (isAdmin() or isDebugEnabled()) then 
        print("DT SECURITY: Unauthorized DebugCommand attempt by " .. player:getUsername())
        return 
    end
    
    local action = args.action
    print("DT DEBUG: Server received action [" .. tostring(action) .. "] from " .. player:getUsername())

    if action == "SimulateDay" then
        -- Force the daily update for all factions
        DynamicTrading_Factions.UpdateDaily()
        -- Also force the engine simulation
        DynamicTrading_Engine.RunDailySimulation()
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Simulation Triggered" })

    elseif action == "createTestFaction" then
        local targetID = args.targetID or ("Faction_" .. ZombRand(1000))
        -- This calls our new logic that includes the LocationManager!
        DynamicTrading_Factions.CreateFaction(targetID, {
            memberCount = ZombRand(5, 15),
            stockpile = { food = 200, ammo = 100 }
        })
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Created" })

    elseif action == "WipeFactions" then
        -- Clear the ModData table completely
        local key = "DynamicTrading_Factions"
        -- We must overwrite the actual table content in the ModData system
        local data = ModData.get(key)
        if data then
            -- Clear existing keys
            for k in pairs(data) do data[k] = nil end
        else
            ModData.add(key, {})
        end
        
        -- Re-initialize to restore the "Independent" nomadic faction and Town factions
        DynamicTrading_Factions.Init()
        ModData.transmit(key)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="All Factions Wiped & Repopulated" })

    elseif action == "ForceRestock" then
        -- Reset restock timers for a specific trader
        local traderID = args.targetID
        local stock = DynamicTrading_Stock.GetStock(traderID)
        if stock then
            stock.restock.nextRestockTime = 0
            ModData.transmit("DynamicTrading_Stock")
            sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Restock Forced" })
        end
    elseif action == "ModifySoul" then
        local factionID = args.factionID
        local amount = args.amount
        if amount > 0 then
            for i=1, amount do
                local archetypes = {}
                for aid, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, aid) end
                local randomArch = archetypes[ZombRand(#archetypes) + 1]
                DynamicTrading_Roster.AddSoul(factionID, randomArch)
                
                local f = DynamicTrading_Factions.GetFaction(factionID)
                if f then f.memberCount = f.memberCount + 1 end
            end
        else
            DynamicTrading_Roster.RemoveSoul(factionID, math.abs(amount))
            local f = DynamicTrading_Factions.GetFaction(factionID)
            if f then f.memberCount = math.max(0, f.memberCount + amount) end
        end
        ModData.transmit("DynamicTrading_Factions")
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Roster Modified" })

    elseif action == "ModifyStockpile" then
        local factionID = args.factionID
        local res = args.resource
        local amt = args.amount
        DynamicTrading_Factions.ModifyStockpile(factionID, res, amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stockpile Modified" })

    elseif action == "ModifyWealth" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyWealth(factionID, amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Wealth Modified" })

    elseif action == "ModifyReputation" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyReputation(factionID, player:getUsername(), amt)
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Reputation Modified" })

    elseif action == "ForceSpawn" then
        local town = args.town or "Rosewood"
        local factionID = town .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
        DynamicTrading_Factions.CreateFaction(factionID, {
            town = town,
            memberCount = 10
        })
        sendServerCommand(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Spawned" })
    end
end

-- =============================================================================
-- 2. MAIN EVENT LISTENER
-- =============================================================================
-- This function listens for the 'sendClientCommand' from the UI
local function OnClientCommand(module, command, player, args)
    if module == COMMAND_MODULE and Handlers[command] then
        Handlers[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

print("DynamicTrading: Server Network Layer (Factions Update) Initialized.")