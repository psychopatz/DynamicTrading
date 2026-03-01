-- =============================================================================
-- DYNAMIC TRADING: DATA WIPE HANDLER (SERVER)
-- =============================================================================
-- Handles the secure deletion of global ModData.
-- This script runs on the Server (MP) or the Host (SP).
-- =============================================================================

if isClient() and not isServer() then return end -- Safety check: Only return on remote MP Client

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

        local target = args.target or "ALL"
        print("[DynamicTrading] Server: Received Data Wipe Request (" .. target .. ") from " .. player:getUsername())
        
        -- 2. DETERMINE TARGET KEYS
        local keysToWipe = {}
        
        if target == "ALL" then
            keysToWipe = ServerWipe.TargetKeys
        elseif target == "STOCKS" then
            table.insert(keysToWipe, "DynamicTrading_Stock")
        elseif target == "FACTIONS" then
            table.insert(keysToWipe, "DynamicTrading_Factions")
        elseif target == "ROSTER" then
            table.insert(keysToWipe, "DynamicTrading_Roster")
            table.insert(keysToWipe, "DTNPC_GlobalList")
        elseif target == "ENGINE" then
            table.insert(keysToWipe, "DynamicTrading_Engine_v1.1")
        end

        if #keysToWipe == 0 then
             sendServerCommand(player, "DynamicTrading", "WipeResult", { 
                success = false, 
                msg = "No valid wipe target specified."
            })
            return
        end

        -- 3. WIPE DATA
        local count = 0
        
        -- Special Handling: fragmented Souls
        local rosterTarget = false
        for _, k in ipairs(keysToWipe) do if k == "DynamicTrading_Roster" then rosterTarget = true break end end
        
        if rosterTarget then
            local roster = ModData.get("DynamicTrading_Roster")
            if roster and roster.Souls then
                for uuid, _ in pairs(roster.Souls) do
                    local soulKey = "DTSOUL_" .. uuid
                    if ModData.exists(soulKey) then
                        ModData.remove(soulKey)
                        count = count + 1
                    end
                end
            end
        end

        for _, key in ipairs(keysToWipe) do
            if ModData.exists(key) then
                ModData.remove(key)
                print("[DynamicTrading] Server: Deleted Global ModData -> " .. key)
                count = count + 1
            end
        end

        -- 4. BROADCAST RESULT
        -- We send a command back to the client so they get visual feedback
        sendServerCommand(player, "DynamicTrading", "WipeResult", { 
            success = true, 
            count = count,
            msg = "Server Data (" .. target .. ") Wiped. Reboot Recommended."
        })
        
        -- Broadcast to all admins that a wipe occurred
        sendServerCommand("DynamicTrading", "AdminAlert", { text = player:getUsername() .. " wiped Dynamic Trading Data (" .. target .. ")." })
    end
end

-- =============================================================================
-- REGISTRATION
-- =============================================================================
Events.OnClientCommand.Add(OnClientCommand)
print("[DynamicTrading] Server Wipe Module Loaded.")