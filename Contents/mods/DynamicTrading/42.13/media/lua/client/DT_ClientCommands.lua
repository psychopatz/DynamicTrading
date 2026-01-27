require "ISUI/ISUIHandler"
require "Utils/DT_AudioManager"

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
                if DT_AudioManager then DT_AudioManager.PlaySound("DT_RadioRandom", false, 0.1) end
                player:Say("Connected: " .. (args.name or "Unknown"))
                
                -- [FIX] Force UI Animation and List Refresh immediately
                if DT_RadioWindow and DT_RadioWindow.instance and DT_RadioWindow.instance:isVisible() then
                    -- Access panel via children
                    if DT_RadioWindow.instance.signalPanel then DT_RadioWindow.instance.signalPanel.signalFoundPersist = true end
                    if DT_RadioWindow.instance.refreshList then DT_RadioWindow.instance.refreshList() end
                end
                
                if HaloTextHelper then
                    local alias = args.name or "Unknown"
                    HaloTextHelper.addTextWithArrow(player, "Signal Acquired: " .. alias, true, HaloTextHelper.getColorGreen())
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
                        "Anyone trading out there? Come in.",
                        "This is a survivor looking to trade. Copy?",
                        "Calling any merchants on this frequency.",
                        "Hello? Anyone running a market today?",
                        "Any traders alive out there?",
                        "Trying to reach a trading post. Respond.",
                        "If anyone's selling, I'm listening.",
                        "Merchant frequency check. Over.",
                        "Looking for supplies. Any traders?",
                        "Broadcasting for trade. Anyone home?",
                        "This is an open call for merchants.",
                        "Any caravans or traders nearby?",
                        "Trying all channels… looking for trade.",
                        "Anyone buying or selling out there?",
                        "This is a survivor seeking commerce.",
                        "Requesting trade contact. Over.",
                        "Any safe zones or traders responding?",
                        "Looking to barter. Respond if you can.",
                        "Calling any active traders.",
                        "If you can hear this, answer back."
                    }

                    local failState = {
                        "Harsh static crackles through the speaker.",
                        "The signal fades into white noise.",
                        "A burst of interference drowns everything out.",
                        "The radio hisses, then goes silent.",
                        "Only distorted static replies.",
                        "The channel collapses into noise.",
                        "A low hum replaces the signal.",
                        "The transmission cuts off abruptly.",
                        "Heavy interference blocks the channel.",
                        "The radio pops and crackles erratically.",
                        "Nothing but dead air.",
                        "The signal drops mid-transmission.",
                        "A wall of static answers back.",
                        "The frequency is completely jammed.",
                        "The radio squeals, then quiets.",
                        "Broken noise pulses through the speaker.",
                        "The channel is overwhelmed by interference.",
                        "A weak hiss lingers, then fades.",
                        "The signal fails to connect.",
                        "Silence. No reply."
                    }


                local textSay = failLines[ZombRand(#failLines)+1]
                local textHalo = failState[ZombRand(#failState)+1]
                
                player:Say(textSay)
                
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, textHalo, true, HaloTextHelper.getColorRed())
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
                    local msg = "Signal Acquired by " .. targetName .. ": " .. (args.name or "Unknown")
                    -- Show as a general notification (no arrow, just text on screen)
                    HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
                end
            end
        end

    elseif command == "TransactionResult" then
        if DynamicTradingUI and DynamicTradingUI.instance then
            local ui = DynamicTradingUI.instance
            if args.success then
                local trader = DynamicTrading.Manager.GetTrader(ui.traderID, ui.archetype)
                
                -- 1. NPC Response Dialogue
                local npcMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, ui.isBuying, args)
                ui:queueMessage(npcMsg, false, false, 15, "DT_Cashier")
             
                -- 2. FIX: Immediate UI Refresh (Fixes sell list not updating)
                ui:populateList()
            else
                -- [NEW] Show Failure Message
                ui:queueMessage(args.msg or "Transaction Failed", true, false, 0)
                if HaloTextHelper and getSpecificPlayer(0) then
                    HaloTextHelper.addTextWithArrow(getSpecificPlayer(0), args.msg or "Failed", true, HaloTextHelper.getColorRed())
                end
            end
        end

    elseif command == "UpdateCooldown" then
        -- [NEW] Targeted Sync from Server
        if args.time then
            DynamicTrading.CooldownManager.ClientCache = args.time
            -- Force UI update if open
            if DT_RadioWindow and DT_RadioWindow.instance then DT_RadioWindow.instance:updateButtonState() end
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