require "DynamicTrading_Manager"
require "DynamicTrading_Config"

DT_RadioInteraction = {}

-- ==========================================================
-- HELPER: IDENTIFY RADIO TYPE
-- ==========================================================
function DT_RadioInteraction.GetDeviceType(obj)
    if not obj then return "Base.WalkieTalkie1" end

    -- 1. Inventory Item (Walkie Talkie)
    if instanceof(obj, "InventoryItem") then
        return obj:getFullType()
    end

    -- 2. World Object (Placed HAM Radio / IsoWaveSignal)
    if instanceof(obj, "IsoWaveSignal") or instanceof(obj, "IsoObject") then
        local sprite = obj:getSprite() and obj:getSprite():getName() or ""
        
        if sprite == "appliances_radio_01_5" then 
            return "Base.HamRadio2" -- Military HAM
        elseif sprite == "appliances_radio_01_4" then 
            return "Base.HamRadio1" -- Premium HAM
        elseif string.find(sprite, "makeshift") then
            return "Base.HamRadioMakeShift"
        end
        return "Base.HamRadio1"
    end

    return "Base.WalkieTalkie1"
end

-- ==========================================================
-- 1. SCAN LOGIC
-- ==========================================================
function DT_RadioInteraction.PerformScan(playerObj, deviceItem, isHam)
    local player = playerObj
    
    local deviceData = nil
    if isHam then
        -- For HAM, deviceItem is the IsoWaveSignal object
        deviceData = deviceItem:getDeviceData()
    else
        -- For Walkie, deviceItem is the InventoryItem
        deviceData = deviceItem:getDeviceData()
    end

    if not deviceData then 
        player:Say("This radio is broken.")
        return 
    end

    -- A. POWER CHECK (READ ONLY - NO DRAIN)
    if not isHam then
        -- 1. Must be turned on
        if not deviceData:getIsTurnedOn() then
            player:Say("I need to turn it on first.")
            return
        end
        
        -- 2. Battery Check
        -- We strictly READ the power. We do NOT modify it to avoid crashes.
        local currentPower = deviceData:getPower() -- Returns 0.0 to 1.0
        
        -- Check if dead (epsilon check for safety)
        if currentPower <= 0.001 then
            player:Say("The battery is dead.")
            player:playSound("Click")
            return
        end
        
    else
        -- HAM Radio Logic
        local hasPower = false
        if deviceData:getIsBatteryPowered() then
             if deviceData:getPower() > 0 then hasPower = true end
        else
             -- Grid Power
             if deviceItem:getSquare() and deviceItem:getSquare():haveElectricity() then
                 hasPower = true
             end
        end
        
        if not hasPower then
            player:Say("It needs power.")
            return
        end
    end

    player:playSound("RadioStatic")

    -- B. MATH & PROBABILITY
    local baseChance = SandboxVars.DynamicTrading.ScanBaseChance or 30
    
    -- Get Tier Multiplier
    local typeID = DT_RadioInteraction.GetDeviceType(deviceItem)
    local radioData = DynamicTrading.Config.GetRadioData(typeID)
    local tierMult = radioData.power or 0.5
    
    -- Ham Bonus
    if isHam then
        local hamBonus = SandboxVars.DynamicTrading.HamRadioBonus or 2.0
        tierMult = tierMult * hamBonus
    end
    
    -- Electricity Skill Bonus
    local elecLevel = player:getPerkLevel(Perks.Electricity)
    local skillBonus = 1.0 + (elecLevel * 0.05) -- +5% per level
    
    local finalChance = baseChance * tierMult * skillBonus
    if finalChance > 95 then finalChance = 95 end

    if isDebugEnabled() then
        print("[DT] Scan: " .. typeID .. " | Chance: " .. finalChance .. "%")
    end

    -- C. RESULT
    if ZombRand(100) + 1 <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            player:playSound("RadioZombies") 
            player:Say("Contact! Connected to " .. trader.name .. ".")
            HaloTextHelper.addTextWithArrow(player, "New Trader Found", true, HaloTextHelper.getColorGreen())
            
            -- Automatically open UI
            if DynamicTradingUI then
                DynamicTradingUI.ToggleWindow(trader.id, trader.archetype)
            end
        else
            player:Say("Static... signal lost.")
        end
    else
        local failLines = {"Static...", "Nothing...", "Just noise.", "No reply."}
        player:Say(failLines[ZombRand(#failLines)+1])
        HaloTextHelper.addTextWithArrow(player, "No Signal", false, HaloTextHelper.getColorRed())
    end
end

-- ==========================================================
-- 2. INVENTORY CONTEXT MENU
-- ==========================================================
local function OnFillInventoryObjectContextMenu(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)
    local radioItem = nil
    
    for _, v in ipairs(items) do
        local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end
        
        local id = item:getFullType()
        -- Ensure Config is loaded before checking
        if DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.RadioTiers[id] then
            radioItem = item
            break
        end
    end
    
    if radioItem then
        local option = context:addOption("Scan Trading Frequencies", 
            radioItem, 
            function(item) 
                -- Pass the item safely
                DT_RadioInteraction.PerformScan(player, item, false) 
            end
        )
        
        local d = radioItem:getDeviceData()
        if not d or not d:getIsTurnedOn() then
            option.notAvailable = true
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = "Radio must be turned ON."
            option.toolTip = tooltip
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)

-- ==========================================================
-- 3. WORLD OBJECT CONTEXT MENU (HAM)
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
         context:addOption("Scan Frequencies (HAM Radio)", 
            hamRadio,
            function(obj) 
                DT_RadioInteraction.PerformScan(player, obj, true) 
            end
        )
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)