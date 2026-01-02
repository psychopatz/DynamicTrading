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
-- SCAN LOGIC (Called from UI)
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
    
    -- Must be turned ON
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
        -- Walkie
        if deviceData:getPower() > 0.001 then hasPower = true end
    end

    if not hasPower then
        player:Say("Signal lost... check power.")
        return false
    end

    -- 4. PERFORM SCAN
    player:playSound("RadioStatic")
    DynamicTrading.Manager.SetScanTimestamp(player) 

    local baseChance = SandboxVars.DynamicTrading.ScanBaseChance or 30
    local typeID = DT_RadioInteraction.GetDeviceType(deviceItem)
    local radioData = DynamicTrading.Config.GetRadioData(typeID)
    local tierMult = radioData.power or 0.5
    
    if isHam then tierMult = tierMult * (SandboxVars.DynamicTrading.HamRadioBonus or 2.0) end
    
    local elecLevel = player:getPerkLevel(Perks.Electricity)
    local skillBonus = 1.0 + (elecLevel * 0.05)
    local finalChance = baseChance * tierMult * skillBonus
    if finalChance > 95 then finalChance = 95 end

    -- 5. RESULT
    if ZombRand(100) + 1 <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            player:playSound("RadioZombies") 
            player:Say("Connected: " .. trader.name)
            HaloTextHelper.addTextWithArrow(player, "New Signal Found", true, HaloTextHelper.getColorGreen())
            return true 
        end
    else
        local failLines = {"Static...", "Just noise.", "No response.", "Dead air."}
        player:Say(failLines[ZombRand(#failLines)+1])
    end
    
    return false 
end

-- ==========================================================
-- CONTEXT MENU: INVENTORY (Walkie Talkie)
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
                DynamicTradingTraderListUI.ToggleWindow(item, false) 
            end
        )
        
        local d = radioItem:getDeviceData()
        -- Must be ON and have Power
        if not d or not d:getIsTurnedOn() or d:getPower() <= 0.001 then
            option.notAvailable = true
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = "Radio must be ON and have Power."
            option.toolTip = tooltip
        end
    end
end

-- ==========================================================
-- CONTEXT MENU: WORLD OBJECT (Ham Radio)
-- ==========================================================
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
                DynamicTradingTraderListUI.ToggleWindow(obj, true) 
            end
        )
        
        if not isOperational then
            option.notAvailable = true
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = "Radio must be ON and Powered."
            option.toolTip = tooltip
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)