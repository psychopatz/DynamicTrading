require "02_DynamicTrading_Manager"
require "01_DynamicTrading_Config"
require "client/Radio/DT_RadioWindow"
require "Utils/DT_AudioManager" 

DT_RadioInteraction = {}

-- ==========================================================
-- HELPER: IDENTIFY RADIO TIER (ROBUST)
-- ==========================================================
function DT_RadioInteraction.GetDeviceType(obj)
    if not obj then return nil end

    -- 1. HANDHELD (InventoryItem)
    -- Directly check if the item type exists in our Config
    if instanceof(obj, "InventoryItem") then
        local typeID = obj:getFullType()
        if DynamicTrading.Config.RadioTiers[typeID] then
            return typeID
        end
        return nil
    end

    -- 2. DROPPED ITEM (IsoWorldInventoryObject)
    -- This handles radios dropped on the floor (3D items)
    if instanceof(obj, "IsoWorldInventoryObject") then
        local item = obj:getItem()
        if item then
            local typeID = item:getFullType()
            if DynamicTrading.Config.RadioTiers[typeID] then
                return typeID
            end
        end
        return nil
    end

    -- 3. STATIONARY / MAP OBJECTS (IsoWaveSignal)
    -- This handles placed furniture radios
    if instanceof(obj, "IsoWaveSignal") then
        local data = obj:getDeviceData()
        
        -- CRITICAL: Filter out Receive-Only devices (TVs, Kitchen Radios)
        if not data or not data:getIsTwoWay() then
            return nil 
        end

        -- At this point, we KNOW it is a valid Two-Way radio.
        -- We try to guess the specific tier based on the sprite, 
        -- but if the sprite is unknown (due to rotation), we fallback to a safe default.
        
        local sprite = obj:getSprite() and obj:getSprite():getName() or ""
        
        -- specific matches
        if sprite == "appliances_radio_01_5" then return "Base.HamRadio2" end -- Military
        if string.find(sprite, "makeshift") then return "Base.HamRadioMakeShift" end
        
        -- Safe Fallback: If it's Two-Way but we don't recognize the sprite, treat as Standard Ham.
        -- This fixes the issue where rotating a radio broke the interaction.
        return "Base.HamRadio1"
    end

    return nil
end

-- ==========================================================
-- SCAN LOGIC
-- ==========================================================
function DT_RadioInteraction.PerformScan(playerObj, deviceItem, isHam)
    local player = playerObj
    
    -- 0. VALIDATE DEVICE TYPE
    local typeID = DT_RadioInteraction.GetDeviceType(deviceItem)
    if not typeID then
        player:Say("This radio cannot transmit on secure frequencies.")
        return false
    end

    -- 1. COOLDOWN CHECK
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        player:Say("I need to wait " .. math.ceil(timeRem) .. " minutes before scanning again.")
        if DT_AudioManager then DT_AudioManager.PlaySound("DT_RadioRandom", false, 0.1) end
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
    local scanLines = {
        "Mayday, do you copy?",
        "Tuning the dial...",
        "Searching the bands...",
        "Listening for static breaks...",
        "Adjusting gain...",
        "Sweeping channels...",
        "Checking for broadcasts..."
    }
    player:Say(scanLines[ZombRand(#scanLines)+1])

    -- 5. GATHER STATS
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
    local gameMode = getWorld():getGameMode()
    local isMultiplayer = (gameMode == "Multiplayer")

    if isMultiplayer then
        sendClientCommand(player, "DynamicTrading", "AttemptScan", args)
    else
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.AttemptScan then
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
        
        -- Strict check against Config List
        local typeID = DT_RadioInteraction.GetDeviceType(item)
        if typeID then
            radioItem = item
            break
        end
    end
    
    if radioItem then
        local option = context:addOption("Open Trader Network", 
            radioItem, 
            function(item) 
                if DT_RadioWindow then
                    DT_RadioWindow.ToggleWindow(item, false) 
                else
                    player:Say("Error: UI failed to load.")
                end
            end
        )
        
        local deviceIcon = getTexture("media/ui/Icon_MarketInfo.png")
        if deviceIcon and option then
            option.iconTexture = deviceIcon
        end
        
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
        -- Strict Check: Is this a Valid Two-Way Radio?
        if DT_RadioInteraction.GetDeviceType(obj) then
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
                if DT_RadioWindow then
                    DT_RadioWindow.ToggleWindow(obj, true)
                else
                    player:Say("Error: UI failed to load.")
                end
            end
        )
        
        local hamIcon = getTexture("media/ui/Icon_MarketInfo.png")
        if hamIcon and option then
            option.iconTexture = hamIcon
        end
        
        if not isOperational then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = "Radio must be ON and Powered."
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)