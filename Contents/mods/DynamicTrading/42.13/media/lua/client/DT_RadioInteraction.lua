require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTradingTraderListUI" 

DT_RadioInteraction = {}

-- ==========================================================
-- HELPER: IDENTIFY RADIO TIER
-- ==========================================================
function DT_RadioInteraction.GetDeviceType(obj)
    if not obj then return "Base.WalkieTalkie1" end

    if instanceof(obj, "InventoryItem") then
        return obj:getFullType()
    end

    if instanceof(obj, "IsoWaveSignal") or instanceof(obj, "IsoObject") then
        local sprite = obj:getSprite() and obj:getSprite():getName() or ""
        if sprite == "appliances_radio_01_5" then return "Base.HamRadio2" 
        elseif sprite == "appliances_radio_01_4" then return "Base.HamRadio1" 
        elseif string.find(sprite, "makeshift") then return "Base.HamRadioMakeShift" end
        return "Base.HamRadio1"
    end
    return "Base.WalkieTalkie1"
end

-- ==========================================================
-- SCAN LOGIC
-- ==========================================================
function DT_RadioInteraction.PerformScan(playerObj, deviceItem, isHam)
    local player = playerObj
    
    -- 1. COOLDOWN CHECK
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        player:Say("I need to wait " .. math.ceil(timeRem) .. " minutes before scanning again.")
        player:playSound("Click")
        return false 
    end

    -- 2. GET DATA
    local deviceData = deviceItem:getDeviceData()
    if not deviceData then return false end

    -- 3. POWER & STATE CHECK
    local hasPower = false
    
    if not deviceData:getIsTurnedOn() then
        player:Say("I need to turn it on first.")
        return false
    end

    if isHam then
        if deviceData:getIsBatteryPowered() then
            if deviceData:getPower() > 0 then hasPower = true end
        else
            if deviceItem:getSquare() and deviceItem:getSquare():haveElectricity() then hasPower = true end
        end
    else
        if deviceData:getPower() > 0.001 then hasPower = true end
    end

    if not hasPower then
        player:Say("Signal lost... check power.")
        return false
    end

    -- 4. PERFORM SCAN (VISUALS)
    player:playSound("RadioStatic")
    
    local scanLines = {
        "Scanning frequencies...",
        "Tuning the dial...",
        "Searching the bands...",
        "Listening for static breaks...",
        "Adjusting gain...",
        "Sweeping channels...",
        "Checking for broadcasts..."
    }
    player:Say(scanLines[ZombRand(#scanLines)+1])

    if HaloTextHelper then
        HaloTextHelper.addTextWithArrow(player, "Scanning...", true, HaloTextHelper.getColorWhite())
    end

    -- 5. GATHER STATS
    local typeID = DT_RadioInteraction.GetDeviceType(deviceItem)
    local radioData = DynamicTrading.Config.GetRadioData(typeID)
    local radioTier = radioData.power or 0.5
    
    if isHam then 
        radioTier = radioTier * (SandboxVars.DynamicTrading.HamRadioBonus or 2.0) 
    end
    
    local elecLevel = player:getPerkLevel(Perks.Electricity)
    local skillBonus = 1.0 + (elecLevel * 0.05)

    -- 6. PREPARE ARGUMENTS
    local args = {
        radioTier = radioTier,
        skillBonus = skillBonus
    }

    -- 7. EXECUTE (SP vs MP BRIDGE)
    -- We use getGameMode() because getCore():isMultiplayer() can crash on some threads,
    -- and isClient() is true for both SP and MP Client.
    local gameMode = getWorld():getGameMode()
    local isMultiplayer = (gameMode == "Multiplayer")

    if isMultiplayer then
        -- [MULTIPLAYER PATH]
        -- Send network packet to the remote server.
        sendClientCommand(player, "DynamicTrading", "AttemptScan", args)
    else
        -- [SINGLEPLAYER PATH]
        -- Direct function call to bypass the missing network layer.
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.AttemptScan then
            print("[DynamicTrading] SP Mode: Calling AttemptScan directly.")
            DynamicTrading.ServerCommands.AttemptScan(player, args)
        else
            print("[DynamicTrading] Error: ServerCommands table missing in Singleplayer!")
            player:Say("Error: Mod logic not loaded.")
        end
    end
    
    return true 
end

-- ==========================================================
-- CONTEXT MENUS
-- ==========================================================
local function OnFillInventoryObjectContextMenu(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)
    local radioItem = nil
    
    for _, v in ipairs(items) do
        local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end
        
        local id = item:getFullType()
        if DynamicTrading.Config and DynamicTrading.Config.RadioTiers[id] then
            radioItem = item
            break
        end
    end
    
    if radioItem then
        local option = context:addOption("Open Trader Network", 
            radioItem, 
            function(item) 
                if not DynamicTradingTraderListUI then require "DynamicTradingTraderListUI" end
                if DynamicTradingTraderListUI then
                    DynamicTradingTraderListUI.ToggleWindow(item, false) 
                else
                    player:Say("Error: UI failed to load.")
                end
            end
        )
        
        local d = radioItem:getDeviceData()
        if not d or not d:getIsTurnedOn() or d:getPower() <= 0.001 then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = "Radio must be ON and have Power."
        end
    end
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    local hamRadio = nil
    
    for _, obj in ipairs(worldObjects) do
        if instanceof(obj, "IsoWaveSignal") then
            hamRadio = obj
            break
        end
    end
    
    if hamRadio then
         local data = hamRadio:getDeviceData()
         local isOperational = false
         
         if data and data:getIsTurnedOn() then
             if data:getIsBatteryPowered() then
                 if data:getPower() > 0 then isOperational = true end
             elseif hamRadio:getSquare() and hamRadio:getSquare():haveElectricity() then
                 isOperational = true
             end
         end

         local option = context:addOption("Open Trader Network (HAM)", 
            hamRadio,
            function(obj) 
                if not DynamicTradingTraderListUI then require "DynamicTradingTraderListUI" end
                if DynamicTradingTraderListUI then
                    DynamicTradingTraderListUI.ToggleWindow(obj, true)
                else
                    player:Say("Error: UI failed to load.")
                end
            end
        )
        
        if not isOperational then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = "Radio must be ON and Powered."
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)