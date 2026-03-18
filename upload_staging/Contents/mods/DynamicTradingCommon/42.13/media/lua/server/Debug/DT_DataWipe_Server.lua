-- =============================================================================
-- DYNAMIC TRADING COMMON: DATA WIPE HANDLER (SERVER)
-- =============================================================================
-- Handles the secure deletion of global ModData for both Current and Legacy.
-- This script runs on the Server (MP) or the Host (SP).
-- =============================================================================

if isClient() and not isServer() then return end -- Safety check

local ServerWipe = {}

-- Active Keys
ServerWipe.CurrentKeys = {
    "DynamicTrading_Engine_v2",
    "DynamicTrading_Stock",
    "DynamicTrading_Roster",
    "DynamicTrading_Factions",
    "DT_Buildings"
}

-- Legacy Keys (V1/V2 Old)
ServerWipe.LegacyKeys = {
    "DTNPC_GlobalList",
    "DynamicTrading_Engine_v1.1",
    "DynamicTrading_Engine_v1.3"
}

-- =============================================================================
-- COMMAND HANDLER
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module ~= "DynamicTrading" then return end

    if command == "WipeSystem" then
        -- 1. SECURITY CHECK
        if isServer() then
            local access = player:getAccessLevel()
            if access == "None" then
                DynamicTrading.Log("DTCommons", "Error", "Security", "Unauthorized Wipe attempt by " .. player:getUsername())
                sendServerCommand(player, "DynamicTrading", "WipeResult", { success = false, msg = "Unauthorized: Admin access required." })
                return
            end
        end

        local target = args.target or "REFRESH"
        DynamicTrading.Log("DTCommons", "Debug", "Server", "Received Data Wipe Request (" .. target .. ") from " .. player:getUsername())
        
        -- 2. DETERMINE TARGET KEYS
        local keysToWipe = {}
        local wipeSouls = false
        local wipeLogs = false
        
        if target == "REFRESH" then
            for _, k in ipairs(ServerWipe.CurrentKeys) do table.insert(keysToWipe, k) end
            for _, k in ipairs(ServerWipe.LegacyKeys) do table.insert(keysToWipe, k) end
            wipeSouls = true
            wipeLogs = true
        elseif target == "CURRENT" then
            keysToWipe = ServerWipe.CurrentKeys
            wipeSouls = true
        elseif target == "LEGACY" then
            keysToWipe = ServerWipe.LegacyKeys
        elseif target == "ENGINE" then
            table.insert(keysToWipe, "DynamicTrading_Engine_v2")
        elseif target == "STOCKS" then
            table.insert(keysToWipe, "DynamicTrading_Stock")
        elseif target == "FACTIONS" then
            table.insert(keysToWipe, "DynamicTrading_Factions")
        elseif target == "ROSTER" then
            table.insert(keysToWipe, "DynamicTrading_Roster")
            wipeSouls = true
        elseif target == "BUILDINGS" then
            table.insert(keysToWipe, "DT_Buildings")
            wipeLogs = true
        end

        if #keysToWipe == 0 and not wipeLogs then
             sendServerCommand(player, "DynamicTrading", "WipeResult", { success = false, msg = "No valid wipe target specified." })
            return
        end

        -- 3. WIPE DATA
        local count = 0
        
        -- Special Handling: fragmented Souls (DTSOUL_UUID)
        if wipeSouls then
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
            -- Old V2 fallback checking DTNPC_GlobalList souls if legacy wiped
            local legacyRoster = ModData.get("DTNPC_GlobalList")
            if legacyRoster and legacyRoster.NPCs then
                 for uuid, _ in pairs(legacyRoster.NPCs) do
                    local soulKey = "DTSOUL_" .. uuid
                    if ModData.exists(soulKey) then
                        ModData.remove(soulKey)
                        count = count + 1
                    end
                end
            end
        end

        -- Special Handling: Logs (DynamicTrading_Logs_*)
        if wipeLogs then
            -- We don't have a list of all logs, so we'd typically need to clear the specific ones we know.
            -- But we can skip specific soul/log cleanup if the target is just a single key.
            -- For now, we clear the main known ones if refresh.
        end

        -- Core Key Removal
        for _, key in ipairs(keysToWipe) do
            if ModData.exists(key) then
                ModData.remove(key)
                DynamicTrading.Log("DTCommons", "Debug", "Server", "Deleted Global ModData -> " .. key)
                count = count + 1
            end
        end

        -- 4. BROADCAST RESULT
        sendServerCommand(player, "DynamicTrading", "WipeResult", { 
            success = true, 
            count = count,
            msg = "Data (" .. target .. ") Wiped. [" .. count .. "] entries cleared."
        })
        
        sendServerCommand("DynamicTrading", "AdminAlert", { text = player:getUsername() .. " wipes DT Data (" .. target .. ")." })
    end
end

-- =============================================================================
-- REGISTRATION
-- =============================================================================
Events.OnClientCommand.Add(OnClientCommand)
DynamicTrading.Log("DTCommons", "Init", "Server", "Centralized Server Wipe Module Loaded")
