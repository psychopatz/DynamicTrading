-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "UI/DT_ConversationUI"
require "DT/V2/NPC/DTNPC_TradingHandler"
require "DT/V2/UI/DT_TradingWindow_Wrapper"

local DEBUG_PREFIX = "[DT-V2-Hub]"

DTNPC_TraderDialogue_Hub = {}


function DTNPC_TraderDialogue_Hub.Init(ui, npc, player)
    if not ui then
        -- Open if not already open
        if DT_ConversationUI then
            -- We create a "fake" trader object from the NPC for the UI
            local brain = npc:getModData().DTNPCBrain
            local traderProxy = {
                id = npc:getPersistentOutfitID() or npc:getID(),
                name = brain and brain.name or "Survivor",
                archetype = brain and brain.archetypeID or brain.occupation or "Survivor",
                gender = npc:isFemale() and "Female" or "Male",
                portraitID = brain and brain.portraitID or 1,
                factionID = brain and brain.factionID,
                expirationTime = brain and brain.returnTime
            }
            print("Trader Name: " .. traderProxy.name)
            print("Trader Archetype: " .. traderProxy.archetype)
            print("Trader Gender: " .. traderProxy.gender)
            print("Trader Portrait ID: " .. traderProxy.portraitID)
            print("Trader Faction ID: " .. traderProxy.factionID)
            print("Trader Expiration Time: " .. traderProxy.expirationTime)

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

    -- OPTION 2: TRADE (Conditional)
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

    if isTrading then
        table.insert(options, {
            text = "Trade",
            message = "Let's see what you've got.",
            onSelect = function(ui)
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
            end
        })
    end


    -- OPTION 3: QUEST (Placeholder)
    table.insert(options, {
        text = "Quest",
        message = "Got any work for me?",
        onSelect = function(ui)
            ui:speak("Nothing at the moment. Check back later.")
            DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
        end
    })

    -- OPTION 4: LEAVE
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
