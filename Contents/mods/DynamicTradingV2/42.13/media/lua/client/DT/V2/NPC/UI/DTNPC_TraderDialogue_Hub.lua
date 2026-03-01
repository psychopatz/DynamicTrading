-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "UI/DT_ConversationUI"
require "DT/V2/NPC/DTNPC_TradingHandler"
require "DT/V2/UI/DT_TradingWindow_Wrapper"
require "DT/V2/Utils/DT_V2_OptionsManager"

local DEBUG_PREFIX = "[DT-V2-Hub]"

DTNPC_TraderDialogue_Hub = {}


function DTNPC_TraderDialogue_Hub.Init(ui, npc, player)
    if not ui then
        -- Open if not already open
        if DT_ConversationUI then
            -- We create a "fake" trader object from the NPC for the UI
            local brain = npc:getModData().DTNPCBrain
            local traderProxy = {
                id = (brain and brain.uuid) or npc:getPersistentOutfitID() or npc:getID(),
                name = brain and brain.name or "Survivor",
                archetype = brain and brain.archetypeID or brain.occupation or "Survivor",
                gender = npc:isFemale() and "Female" or "Male",
                portraitID = brain and brain.portraitID or 1,
                factionID = brain and brain.factionID,
                expirationTime = brain and brain.returnTime
            }
            
            -- [FIX] Safety checks for debug prints to prevent "concatenation with nil" crashes
            print("Trader ID: " .. tostring(traderProxy.id))
            print("Trader Name: " .. tostring(traderProxy.name))
            print("Trader Archetype: " .. tostring(traderProxy.archetype))
            print("Trader Gender: " .. tostring(traderProxy.gender))
            print("Trader Portrait ID: " .. tostring(traderProxy.portraitID))
            
            if traderProxy.factionID then
                print("Trader Faction ID: " .. traderProxy.factionID)
                
                -- [NEW] Request roster if faction data is not in cache
                local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions) 
                                    or (DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions)
                
                if not factionData or not factionData[traderProxy.factionID] then
                    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
                        print("[DT-V2-Hub] Faction data missing in cache, requesting Roster sync...")
                        DT_V2_RadarManager.RequestRoster()
                    end
                end
            else
                print("Trader Faction ID: nil")
            end

            if traderProxy.expirationTime then
                print("Trader Expiration Time: " .. traderProxy.expirationTime)
            else
                print("Trader Expiration Time: nil")
            end

            ui = DT_ConversationUI.Open(traderProxy, nil, nil, false, npc) -- isRadio = false
        else
            return
        end
    end
    
    if not npc or not player then return end
    
    -- 1. Intro Speech
    ui:speak("Hello. What can I do for you?")

    -- 2. Generate Options
    DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
end

function DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
    local options = {}
    
    -- OPTION 1: CHAT (First implementation)
    table.insert(options, {
        text = "Chat",
        message = "Got a minute to talk?",
        onSelect = function(ui)
            ui:speak("I'm holding down the fort here. Stay safe out there.")
            DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
        end
    })

    -- OPTION 2: TRADE (Always Visible)
    local brain = npc:getModData().DTNPCBrain
    local isTrading = false
    
    if brain and brain.status == "Trading" then
        isTrading = true
    else
        -- Fallback to Roster ModData if brain is missing or unsynced
        local id = (brain and brain.uuid) or npc:getPersistentOutfitID() or npc:getID()
        local rosterData = ModData.get("DynamicTrading_Roster")
        if rosterData and rosterData.Souls and rosterData.Souls[id] then
            if rosterData.Souls[id].status == "Trading" then
                isTrading = true
            end
        end
    end

    -- [CHANGE] We now insert the option regardless of isTrading status
    table.insert(options, {
        text = "Trade",
        message = "Let's see what you've got.",
        onSelect = function(ui)
            -- [CHANGE] Logic check happens here instead
            if isTrading then
                -- SUCCESS: Open Trade Window
                print(DEBUG_PREFIX .. " Trade option selected")
                
                local traderID = (brain and brain.uuid) or npc:getPersistentOutfitID() or npc:getID()
                local archetype = brain and brain.archetypeID or "General"
                
                -- Check if stock is already cached
                local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                                  or ModData.get("DynamicTrading_Stock")
                
                if stockData and stockData[traderID] then
                    -- Stock ready - close conversation UI and open trading window
                    print(DEBUG_PREFIX .. " Stock cached, opening TradingWindow")
                    ui:close()
                    DT_TradingWindow.ToggleWindowV2(traderID, archetype, npc)
                else
                    -- Request stock generation, then open window
                    print(DEBUG_PREFIX .. " Requesting stock generation...")
                    ui:speak("Let me check what I have in stock...")
                    
                    -- Request stock from server
                    local args = { traderID = traderID }
                    sendClientCommand(player, "DynamicTrading_V2", "GenerateStock", args)
                    
                    -- Store pending trade context
                    DTNPC_TraderDialogue_Hub.PendingTrade = {
                        traderID = traderID,
                        archetype = archetype,
                        npc = npc,
                        ui = ui,
                        startTime = getGameTime():getWorldAgeHours()
                    }
                end
            else
                -- FAILURE: Refusal Dialogue
                local refusals = {
                    "I'm not open for business right now. Just resting.",
                    "Shop's closed. I need a break.",
                    "Can't you see I'm busy? Come back later.",
                    "I'm off the clock. Stop bothering me.",
                    "Not now. Check back in a bit.",
                    "I don't have my stock organized yet.",
                    "Stop bothering me, I'm resting.",
                    "I'm just holding onto this spot for now. No trading."
                }
                
                -- Pick a random refusal
                local msg = refusals[ZombRand(#refusals) + 1]
                ui:speak(msg)
                
                -- Regenerate options so player can choose something else
                DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
            end
        end
    })


    -- OPTION 4: SETTINGS (Common UI)
    table.insert(options, {
        text = "Settings",
        message = "Can I adjust some settings real quick?",
        onSelect = function(ui)
            if DT_V2_OptionsManager then
                DT_V2_OptionsManager.ToggleWindow()
                -- Keep Hub open in background
                DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
            end
        end
    })

    -- OPTION 5: LEAVE
    table.insert(options, {
        text = "Leave",
        message = "I'll be going now. Good luck.",
        onSelect = function(ui)
            ui:close()
        end
    })
    
    ui:updateOptions(options)
end

-- =============================================================================
-- PENDING TRADE POLLING
-- =============================================================================
DTNPC_TraderDialogue_Hub.PendingTrade = nil

local function OnTick()
    if not DTNPC_TraderDialogue_Hub.PendingTrade then return end
    
    local pending = DTNPC_TraderDialogue_Hub.PendingTrade
    
    -- Check if UI is still valid
    local uiValid = pending.ui and pending.ui:getIsVisible()
    if not uiValid then
        print(DEBUG_PREFIX .. " Pending trade cancelled - UI closed")
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
        return
    end
    
    -- Check for stock arrival
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if stockData and stockData[pending.traderID] then
        print(DEBUG_PREFIX .. " Stock arrived! Opening TradingWindow")
        
        -- Close conversation UI
        pending.ui:close()
        
        -- Open trading window
        DT_TradingWindow.ToggleWindowV2(pending.traderID, pending.archetype, pending.npc)
        
        -- Clear pending
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
        return
    end
    
    -- Timeout check (~5 seconds)
    local gt = getGameTime()
    if gt and (gt:getWorldAgeHours() - pending.startTime) > 0.005 then
        print(DEBUG_PREFIX .. " Stock request timeout")
        if uiValid then
            pending.ui:speak("Sorry, I'm having trouble with my inventory right now.")
        end
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
    end
end

-- Register tick handler
Events.OnTick.Remove(OnTick)
Events.OnTick.Add(OnTick)

print(DEBUG_PREFIX .. " NPC Trader Dialogue Hub loaded")
