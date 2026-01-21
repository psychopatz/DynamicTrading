-- =============================================================================
-- DYNAMIC TRADING: DATA WIPE HANDLER (SERVER)
-- =============================================================================
-- Handles the secure deletion of global ModData.
-- This script runs on the Server (MP) or the Host (SP).
-- =============================================================================

if isClient() then return end -- Safety check: Only load on Server

local ServerWipe = {}
ServerWipe.TargetKeys = {
    "DTNPC_GlobalList",
    "DynamicTrading_Engine_v1.1",
    "DynamicTrading_Stock",
    "DynamicTrading_Roster",
    "DynamicTrading_Factions"
}

-- =============================================================================
-- COMMAND HANDLER
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module ~= "DynamicTrading" then return end

    if command == "WipeSystem" then
        -- 1. SECURITY CHECK
        -- Ensure only Admins or specific access levels can wipe data.
        -- In Singleplayer, getAccessLevel() might return "None", so we skip check if not MP.
        if isServer() and getServerOptions():getBoolean("PublicServer") then
            local access = player:getAccessLevel()
            if access ~= "Admin" and access ~= "Observer" and access ~= "GM" and access ~= "Overseer" then
                print("[DynamicTrading] Security Warning: Unauthorized Wipe attempt by " .. player:getUsername())
                sendServerCommand(player, "DynamicTrading", "WipeResult", { success = false, msg = "Unauthorized: Admin access required." })
                return
            end
        end

        print("[DynamicTrading] Server: Received Data Wipe Request from " .. player:getUsername())
        
        -- 2. WIPE DATA
        local count = 0
        for _, key in ipairs(ServerWipe.TargetKeys) do
            if ModData.exists(key) then
                ModData.remove(key)
                print("[DynamicTrading] Server: Deleted Global ModData -> " .. key)
                count = count + 1
            end
        end

        -- 3. BROADCAST RESULT
        -- We send a command back to the client so they get visual feedback
        sendServerCommand(player, "DynamicTrading", "WipeResult", { 
            success = true, 
            count = count,
            msg = "Server Data Wiped. Reboot Recommended."
        })
        
        -- Broadcast to all admins that a wipe occurred
        sendServerCommand("DynamicTrading", "AdminAlert", { text = player:getUsername() .. " wiped Dynamic Trading Data." })
    end
end

-- =============================================================================
-- REGISTRATION
-- =============================================================================
Events.OnClientCommand.Add(OnClientCommand)
print("[DynamicTrading] Server Wipe Module Loaded.")