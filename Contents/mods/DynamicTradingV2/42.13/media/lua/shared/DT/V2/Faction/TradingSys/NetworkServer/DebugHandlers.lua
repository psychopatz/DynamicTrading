-- ==============================================================================
-- NetworkServer/DebugHandlers.lua
-- Logic: Debug/Admin commands and Faction data requests
-- Build 42 Compatible.
-- ==============================================================================

local COMMAND_MODULE = "DynamicTrading_V2"

require "DT/V2/Faction/TradingSys/DynamicTrading_Factions"
require "DT/V2/Faction/TradingSys/DynamicTrading_Roster"
require "DT/V2/Faction/TradingSys/DynamicTrading_Stock"
require "DT/V2/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/ServerHelpers"

local DebugHandlers = {}
local Handlers = {}

-- =============================================================================
-- FACTION DATA REQUEST
-- =============================================================================
Handlers.RequestFactionData = function(player, args)
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local stockData = ModData.get("DynamicTrading_Stock") or {}
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncFactionDebugData", {
        factions = factionData,
        roster = rosterData,
        stock = stockData
    })
end

-- =============================================================================
-- DEBUG & ADMIN COMMANDS
-- =============================================================================
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
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Simulation Triggered" })

    elseif action == "createTestFaction" then
        local targetID = args.targetID or ("Faction_" .. ZombRand(1000))
        -- This calls our new logic that includes the LocationManager!
        DynamicTrading_Factions.CreateFaction(targetID, {
            memberCount = ZombRand(5, 15),
            stockpile = { food = 200, ammo = 100 }
        })
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Created" })

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
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="All Factions Wiped & Repopulated" })

    elseif action == "ForceRestock" then
        -- Reset restock timers for a specific trader
        local traderID = args.targetID
        local stock = DynamicTrading_Stock.GetStock(traderID)
        if stock then
            stock.restock.nextRestockTime = 0
            ModData.transmit("DynamicTrading_Stock")
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Restock Forced" })
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
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Roster Modified" })

    elseif action == "ModifyStockpile" then
        local factionID = args.factionID
        local res = args.resource
        local amt = args.amount
        DynamicTrading_Factions.ModifyStockpile(factionID, res, amt)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stockpile Modified" })

    elseif action == "ModifyWealth" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyWealth(factionID, amt)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Wealth Modified" })

    elseif action == "ModifyReputation" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyReputation(factionID, player:getUsername(), amt)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Reputation Modified" })

    elseif action == "ForceSpawn" then
        local town = args.town or "Rosewood"
        local factionID = town .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
        DynamicTrading_Factions.CreateFaction(factionID, {
            town = town,
            memberCount = 10
        })
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Spawned" })
    
    elseif action == "InjectEvent" then
        local factionID = args.factionID
        local eventID = args.eventID
        local hours = args.hours or 72 -- Default 3 days
        
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        
        if faction then
            local currentHour = math.floor(getGameTime():getWorldAgeHours())
            faction.ActiveFlashEvent = faction.ActiveFlashEvent or {}
            faction.ActiveFlashEvent.id = eventID
            faction.ActiveFlashEvent.expires = eventID and (currentHour + hours) or 0
            
            ModData.transmit("DynamicTrading_Factions")
            local msg = eventID and ("Event Injected: " .. eventID) or "Event Cleared"
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason=msg })
        end
    end
end

DebugHandlers.Handlers = Handlers
return DebugHandlers
