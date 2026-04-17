require "ISUI/ISUIHandler"
require "DT/V1/Utils/DT_OptionsManager"
require "DT/Common/Reputation/DT_Reputation"
require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_RadioScan"

local function DT_RadioScanResponse(key, ...)
    return DynamicTrading.FlavorText.GetValue("RadioScan", "Responses", key, ...)
end

local function getRandomRadioScanText(kind)
    return DynamicTrading.FlavorText.GetRandom("RadioScan", kind)
end

local function applyIncomingRosterState(args)
    if not args or not args.id or not ModData or not ModData.get then
        return false
    end

    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData then
        return false
    end

    rosterData.Souls = rosterData.Souls or {}
    local soul = rosterData.Souls[args.id] or {}
    if args.name ~= nil then soul.name = args.name end
    if args.traderStatus ~= nil then soul.status = args.traderStatus end
    if args.traderState ~= nil then soul.state = args.traderState end
    if args.returnTime ~= nil then soul.returnTime = args.returnTime end
    if args.returnStatus ~= nil then soul.returnStatus = args.returnStatus end
    if args.contactVisitActive ~= nil then soul.contactVisitActive = args.contactVisitActive end
    if args.contactVisitMode ~= nil then soul.contactVisitMode = args.contactVisitMode end
    if args.contactVisitBackend ~= nil then soul.contactVisitBackend = args.contactVisitBackend end
    rosterData.Souls[args.id] = soul
    return true
end

local function handleContactVisitArrivalUI(args)
    local radioUI = DT_RadioWindow and DT_RadioWindow.EnsureOpen and DT_RadioWindow.EnsureOpen() or nil
    if radioUI and radioUI.signalPanel then
        radioUI.signalPanel.signalFoundPersist = true
    end
    if radioUI and radioUI.refreshList then
        radioUI.refreshList()
    end
    if radioUI and radioUI.logPanel and radioUI.logPanel.populateLogs then
        radioUI.logPanel:populateLogs()
    end

    DynamicTrading.Log(
        "DTV1",
        "Radio",
        "Sync",
        "Handled ContactVisitV1 arrival UI id=" .. tostring(args and args.id)
            .. " openedRadio=" .. tostring(radioUI ~= nil)
    )
end

-- =============================================================================
-- 1. HANDLE SERVER RESPONSES (SCAN RESULTS)
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "ScanResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        DynamicTrading.Log(
            "DTV1",
            "Radio",
            "Sync",
            "ScanResult received status=" .. tostring(args and args.status)
                .. " source=" .. tostring(args and args.source)
                .. " id=" .. tostring(args and args.id)
                .. " targetUser=" .. tostring(args and args.targetUser)
        )

        local myName = player:getUsername()
        local unknownText = DT_RadioScanResponse("Unknown")
        local targetName = args.targetUser or unknownText
        local isMe = (myName == targetName)
        
        -- ==========================================================
        -- SCENARIO A: I PERFORMED THE SCAN (Full Feedback)
        -- ==========================================================
        if isMe then
            -- 1. SUCCESS (Green)
            if args.status == "SUCCESS" then
                if DT_AudioManager then DT_AudioManager.PlaySound("DT_RadioRandom", false, 0.1) end
                player:Say(DT_RadioScanResponse("Connected", args.name or unknownText))

                if args.source == "ContactVisitV1" then
                    local applied = applyIncomingRosterState(args)
                    DynamicTrading.Log(
                        "DTV1",
                        "Radio",
                        "Sync",
                        "Applied ContactVisitV1 roster state id=" .. tostring(args.id)
                            .. " applied=" .. tostring(applied)
                            .. " status=" .. tostring(args.traderStatus)
                            .. " returnTime=" .. tostring(args.returnTime)
                    )
                end
                
                if args.id then
                    if args.source == "ContactVisitV1" and DynamicTrading.Manager.RegisterRadioSignal then
                        local registered = DynamicTrading.Manager.RegisterRadioSignal(args.id, player, {
                            logMessage = "Contact arrival: " .. tostring(args.name or "Unknown Trader") .. " is now broadcasting on your frequency.",
                            logCategory = "good",
                        })
                        local hasDiscovered = DynamicTrading.Manager.HasDiscovered and DynamicTrading.Manager.HasDiscovered(args.id, player) or false
                        local discoveredCount = DynamicTrading.Manager.GetDiscoveredCount and DynamicTrading.Manager.GetDiscoveredCount(player) or -1
                        local activeSignals = DynamicTrading.Manager.GetActiveRadioTraders and DynamicTrading.Manager.GetActiveRadioTraders(player) or {}
                        local trader = DynamicTrading.Manager.GetTrader and DynamicTrading.Manager.GetTrader(args.id) or nil
                        DynamicTrading.Log(
                            "DTV1",
                            "Radio",
                            "ContactVisit",
                            "Arrival registration id=" .. tostring(args.id)
                                .. " registered=" .. tostring(registered)
                                .. " discovered=" .. tostring(hasDiscovered)
                                .. " discoveredCount=" .. tostring(discoveredCount)
                                .. " activeSignals=" .. tostring(#activeSignals)
                                .. " traderStatus=" .. tostring(trader and trader.status or "nil")
                                .. " returnTime=" .. tostring(trader and trader.returnTime or "nil")
                        )
                    else
                        DynamicTrading.Manager.DiscoverTrader(args.id, player)
                    end
                end

                if args.source == "ContactVisitV1" then
                    sendClientCommand(player, "DynamicTrading", "RequestFullState", {})
                    handleContactVisitArrivalUI(args)
                end

                -- [FIX] Force UI Animation and List Refresh immediately
                if DT_RadioWindow and DT_RadioWindow.instance and DT_RadioWindow.instance:getIsVisible() then
                    -- Access panel via children
                    if DT_RadioWindow.instance.signalPanel then DT_RadioWindow.instance.signalPanel.signalFoundPersist = true end
                    if DT_RadioWindow.instance.refreshList then DT_RadioWindow.instance.refreshList() end
                end
                
                if HaloTextHelper then
                    local alias = args.name or unknownText
                    HaloTextHelper.addTextWithArrow(player, DT_RadioScanResponse("SignalAcquired", alias), true, HaloTextHelper.getColorGreen())
                end
            
            -- 2. FAILURE: LIMIT REACHED (Red)
            elseif args.status == "LIMIT_REACHED" then
                -- player:playSound("RadioStatic")
                
                local failMsg = DT_RadioScanResponse("NetworkExhausted")
                player:Say(DT_RadioScanResponse("AirwavesDead"))
                
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, failMsg, true, HaloTextHelper.getColorRed())
                end
                
            -- 3. FAILURE: RNG / BAD LUCK / COOLDOWN (Red)
            else
                local textSay = getRandomRadioScanText("FailLines")
                local textHalo = getRandomRadioScanText("FailStates")
                
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
                    local msg = DT_RadioScanResponse("PublicSignalAcquired", targetName, args.name or unknownText)
                    -- Show as a general notification (no arrow, just text on screen)
                    HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
                end
            end
        end

    elseif command == "TransactionResult" then
        if DT_TradingWindow and DT_TradingWindow.instance then
            local ui = DT_TradingWindow.instance
            if args.success then
                local isBuy = (args.isBuy == true)
                if args.isBuy == nil then isBuy = ui.isBuying end

                local trader = nil
                if ui.dataProvider and ui.dataProvider.getTrader then
                    trader = ui.dataProvider:getTrader(ui.traderID, ui.archetype)
                end
                if not trader and DynamicTrading.Manager and DynamicTrading.Manager.GetTrader then
                    trader = DynamicTrading.Manager.GetTrader(ui.traderID, ui.archetype)
                end

                args.traderID = args.traderID or (trader and (trader.traderID or trader.uuid or trader.id)) or ui.traderID
                args.factionID = args.factionID or (trader and trader.factionID)

                if DT_Reputation then
                    DT_Reputation.ApplyTradeResult(args, trader, isBuy)
                end
                
                -- 1. NPC Response Dialogue
                local npcMsg = DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, args)
                ui:queueMessage(npcMsg, false, false, 15, "DT_Cashier", "transaction")
             
                -- 2. FIX: Immediate UI Refresh (Fixes sell list not updating)
                ui:populateList()
            else
                -- [NEW] Show Failure Message
                ui:queueMessage(args.msg or "Transaction Failed", true, false, 0, nil, "transaction")
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
            if DT_RadioWindow and DT_RadioWindow.instance and DT_RadioWindow.instance.updateButtonState then 
                DT_RadioWindow.instance:updateButtonState() 
            end
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
        DynamicTrading.Log("DTV1", "Network", "Init", "Client: Connected. Requesting full server state sync.")
    end
end

Events.OnCreatePlayer.Add(RequestInitialSync)
