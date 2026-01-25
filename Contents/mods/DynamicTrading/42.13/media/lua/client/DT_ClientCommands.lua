require "ISUI/ISUIHandler"

-- =============================================================================
-- 1. HANDLE SERVER RESPONSES (SCAN RESULTS)
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "ScanResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        local myName = player:getUsername()
        local targetName = args.targetUser or "Unknown"
        local isMe = (myName == targetName)
        
        -- ==========================================================
        -- SCENARIO A: I PERFORMED THE SCAN (Full Feedback)
        -- ==========================================================
        if isMe then
            -- 1. SUCCESS (Green)
            if args.status == "SUCCESS" then
                getSoundManager():PlaySound("DT_RadioRandom", false, 0.1)
                player:Say("Connected: " .. (args.name or "Unknown"))
                
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, "New Signal Found", true, HaloTextHelper.getColorGreen())
                end
            
            -- 2. FAILURE: LIMIT REACHED (Red)
            elseif args.status == "LIMIT_REACHED" then
                -- player:playSound("RadioStatic")
                
                local failMsg = "Network Exhausted. Try again tomorrow."
                player:Say("The airwaves are dead... no more traders today.")
                
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, failMsg, true, HaloTextHelper.getColorRed())
                end
                
            -- 3. FAILURE: RNG / BAD LUCK / COOLDOWN (Red)
            else
                local failLines = {
                    "Just static...",
                    "Signal too weak.",
                    "Connection lost.",
                    "Dead air.",
                    "No response.",
                    "White noise..."
                }
                local text = failLines[ZombRand(#failLines)+1]
                
                player:Say(text)
                
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, text, true, HaloTextHelper.getColorRed())
                end
            end

        -- ==========================================================
        -- SCENARIO B: SOMEONE ELSE SCANNED (Network Broadcast)
        -- ==========================================================
        else
            -- Check Sandbox Setting: Is Public Network enabled?
            local publicNetwork = SandboxVars.DynamicTrading.PublicNetwork
            if not publicNetwork then return end -- If false, ignore others completely.

            -- If Public, we only care about SUCCESS (Don't spam me when others fail)
            if args.status == "SUCCESS" then
                if HaloTextHelper then
                    local msg = targetName .. " located: " .. (args.name or "Unknown")
                    -- Show as a general notification (no arrow, just text on screen)
                    HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
                end
            end
        end

    elseif command == "TransactionResult" then
        if args.success and DynamicTradingUI and DynamicTradingUI.instance then
            local ui = DynamicTradingUI.instance
            local trader = DynamicTrading.Manager.GetTrader(ui.traderID, ui.archetype)
            
            -- 1. NPC Response Dialogue
            local npcMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, ui.isBuying, args)
            ui:queueMessage(npcMsg, false, false, 15, "DT_Cashier")
         
            -- 2. FIX: Immediate UI Refresh (Fixes sell list not updating)
            ui:populateList()
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- 2. INITIALIZATION (SYNC ON JOIN)
-- =============================================================================
-- [FIX] Switched to OnCreatePlayer to ensure Network Handshake is ready.
-- This ensures that when you log back in, the Client immediately asks the
-- Server for the current Traders, Daily Limit, and Event status.
local function RequestInitialSync(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    
    -- Only run for the local player client
    if player and player:isLocalPlayer() then
        sendClientCommand(player, "DynamicTrading", "RequestFullState", {})
        print("[DynamicTrading] Client: Connected. Requesting full server state sync.")
    end
end

Events.OnCreatePlayer.Add(RequestInitialSync)