if isClient() then return end

require "DynamicTrading_Manager"

local Commands = {}

function Commands.GenerateTrader(player, args)
    print("[Server] DynamicTrading: Generating Trader for " .. player:getUsername())
    
    -- 1. Generate the data on the Server
    -- This function (in Manager) updates ModData and transmits it to all clients automatically
    local trader = DynamicTrading.Manager.GenerateRandomContact()
    
    if trader then
        -- 2. Send confirmation back ONLY to the player who scanned
        -- We send the trader's name so the client can display it
        sendServerCommand(player, "DynamicTrading", "ScanResult", { 
            success = true, 
            name = trader.name,
            archetype = trader.archetype
        })
    else
        sendServerCommand(player, "DynamicTrading", "ScanResult", { success = false })
    end
end

local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)