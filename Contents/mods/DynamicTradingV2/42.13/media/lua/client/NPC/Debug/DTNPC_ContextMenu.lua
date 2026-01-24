-- ==============================================================================
-- DTNPC_ContextMenu.lua
-- Client-side Logic: Context Menu for Orders and DEBUGGING.
-- Build 42 Compatible.
-- FIXED: Coordinate parsing to properly convert string to numbers
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
require "NPC/Debug/DTNPC_Debugger"

-- ==============================================================================
-- 1. HELPER FUNCTIONS
-- ==============================================================================

local function getBrain(zombie)
    if not zombie then return nil end
    
    if DTNPCClient and DTNPCClient.GetBrain then
        local brain = DTNPCClient.GetBrain(zombie)
        if brain then return brain end
    end
    
    if DTNPC and DTNPC.GetBrain then
        return DTNPC.GetBrain(zombie)
    end
    
    return nil
end

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

-- ==============================================================================
-- 2. COMMAND SENDERS
-- ==============================================================================

local function onOrder(npc, state, player)
    if not npc or not player then return end
    
    local args = {
        x = npc:getX(),
        y = npc:getY(),
        z = npc:getZ(),
        state = state
    }

    if state == "GoTo" then
        args.targetX = player:getX()
        args.targetY = player:getY()
        args.targetZ = player:getZ()
    end

    sendClientCommand(player, "DTNPC", "Order", args)
    
    local brain = getBrain(npc)
    if brain then
        brain.state = state
        if state == "GoTo" then
            brain.tasks = {{x = args.targetX, y = args.targetY, z = args.targetZ}}
        else
            brain.tasks = {}
        end
        
        if DTNPC and DTNPC.AttachBrain then
             DTNPC.AttachBrain(npc, brain)
        end
        
        player:Say("Order (" .. brain.name .. "): " .. state)
    end
end

local function onCoordInput(target, button, player, npc)
    if button.internal ~= "OK" then return end
    
    local text = button.parent.entry:getText()
    if not text or text == "" then return end
    
    -- FIXED: More robust parsing that handles spaces and converts to numbers properly
    local parts = {}
    for num in string.gmatch(text, "[%d%.%-]+") do
        table.insert(parts, tonumber(num))
    end
    
    if #parts >= 2 then
        local tx = parts[1]
        local ty = parts[2]
        local tz = parts[3] or 0
        
        -- Ensure values are valid numbers
        if tx and ty and tz then
            local args = {
                x = npc:getX(),
                y = npc:getY(),
                z = npc:getZ(),
                state = "GoTo",
                targetX = tx,
                targetY = ty,
                targetZ = tz
            }
            
            print("[DTNPC] Sending GoTo command with coords: " .. tx .. "," .. ty .. "," .. tz)
            sendClientCommand(player, "DTNPC", "Order", args)
            
            -- Update local brain immediately
            local brain = getBrain(npc)
            if brain then
                brain.state = "GoTo"
                brain.tasks = {{x = tx, y = ty, z = tz}}
                if DTNPC and DTNPC.AttachBrain then
                    DTNPC.AttachBrain(npc, brain)
                end
            end
            
            player:Say("Sent GoTo: " .. math.floor(tx) .. ", " .. math.floor(ty) .. ", " .. math.floor(tz))
        else
            player:Say("Invalid Coords! Numbers not recognized.")
        end
    else
        player:Say("Invalid Coords! Use format: 10820,9463,0")
    end
end

local function onOpenCoordBox(player, npc)
    local defaultText = math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0"
    local modal = ISTextBox:new(0, 0, 280, 180, "Enter Target Coordinates (X,Y,Z):", defaultText, nil, onCoordInput, player:getPlayerNum(), player, npc)
    modal:initialise()
    modal:addToUIManager()
end

local function onSummon(player)
    sendClientCommand(player, "DTNPC", "Summon", {})
    player:Say("Signal Sent: Summoning Team...")
end

local function onMarkNPC(player, npc)
    if not npc or not player then return end
    
    local brain = getBrain(npc)
    if not brain then
        player:Say("Cannot mark: No brain data")
        return
    end
    
    if not EventMarkerHandler then
        player:Say("EventMarkerHandler not available!")
        return
    end
    
    local id = npc:getPersistentOutfitID()
    local x = npc:getX()
    local y = npc:getY()
    
    local color = {r=0.2, g=1, b=0.2}
    local icon = "friend.png"
    
    if brain.state == "Follow" then
        color = {r=0.2, g=0.8, b=1}
        icon = "crew.png"
    elseif brain.state == "Stay" or brain.state == "Guard" then
        color = {r=1, g=1, b=0.2}
        icon = "defend.png"
    elseif brain.state == "GoTo" then
        color = {r=1, g=0.5, b=0.2}
        icon = "loot.png"
    elseif brain.isHostile then
        color = {r=1, g=0.2, b=0.2}
        icon = "raid.png"
    end
    
    local distance = calculateDistance(player, npc)
    local distText = string.format("%.0fm away", distance)
    local description = brain.name .. " - " .. (brain.state or "Idle") .. " - " .. distText
    
    EventMarkerHandler.set(
        "npc_" .. id,
        icon,
        1800,
        x,
        y,
        color,
        description
    )
    
    player:Say("Marked NPC: " .. brain.name)
end

local function onMarkAllNPCs(player)
    if not EventMarkerHandler then
        player:Say("EventMarkerHandler not available!")
        return
    end
    
    local count = 0
    
    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            local brain = entry.brain
            if brain and brain.lastX and brain.lastY then
                local color = {r=0.2, g=1, b=0.2}
                local icon = "friend.png"
                
                if brain.state == "Follow" then
                    color = {r=0.2, g=0.8, b=1}
                    icon = "crew.png"
                elseif brain.state == "Stay" or brain.state == "Guard" then
                    color = {r=1, g=1, b=0.2}
                    icon = "defend.png"
                elseif brain.state == "GoTo" then
                    color = {r=1, g=0.5, b=0.2}
                    icon = "loot.png"
                elseif brain.isHostile then
                    color = {r=1, g=0.2, b=0.2}
                    icon = "raid.png"
                end
                
                local dx = player:getX() - brain.lastX
                local dy = player:getY() - brain.lastY
                local distance = math.sqrt(dx * dx + dy * dy)
                local distText = string.format("%.0fm away", distance)
                
                local description = brain.name .. " - " .. (brain.state or "Idle") .. " - " .. distText
                
                EventMarkerHandler.set(
                    "npc_" .. id,
                    icon,
                    1800,
                    brain.lastX,
                    brain.lastY,
                    color,
                    description
                )
                
                count = count + 1
            end
        end
    end
    
    player:Say("Marked " .. count .. " NPCs")
end

local function onClearNPCMarkers(player)
    if not EventMarkerHandler then
        player:Say("EventMarkerHandler not available!")
        return
    end
    
    local count = 0
    for markerId, _ in pairs(EventMarkerHandler.markers) do
        if string.sub(markerId, 1, 4) == "npc_" then
            EventMarkerHandler.remove(markerId)
            count = count + 1
        end
    end
    
    player:Say("Cleared " .. count .. " NPC markers")
end

-- ==============================================================================
-- 3. MAIN MENU BUILDER
-- ==============================================================================

function DTNPCMenu.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local square = nil
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then square = obj:getSquare(); break end
    end
    if not square then return end

    local npcList = {}
    local processedIDs = {} 

    local function scanSquare(sq)
        if not sq then return end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") then
                local brain = getBrain(obj)
                if brain then
                    local id = obj:getPersistentOutfitID() or obj:getID()
                    if not processedIDs[id] then
                        table.insert(npcList, obj)
                        processedIDs[id] = true
                    end
                end
            end
        end
    end

    scanSquare(square)
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz))
            end
        end
    end

    table.sort(npcList, function(a, b)
        return calculateDistance(player, a) < calculateDistance(player, b)
    end)

    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local brain = getBrain(npc)
            if not brain then brain = { name = "Unknown", state = "Unknown" } end
            local status = " [" .. (brain.state or "Idle") .. "]"
            
            local option = context:addOption("NPC: " .. brain.name .. status)
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)

            subMenu:addOption("Follow Me", npc, onOrder, "Follow", player)
            subMenu:addOption("Stop / Guard", npc, onOrder, "Stay", player)
            subMenu:addOption("Come Here (My Pos)", npc, onOrder, "GoTo", player)
            
            if EventMarkerHandler then
                subMenu:addOption("Mark NPC Location", player, onMarkNPC, npc)
            end

            local debugOption = subMenu:addOption("DEBUG / TEST")
            local debugSub = subMenu:getNew(subMenu)
            context:addSubMenu(debugOption, debugSub)

            debugSub:addOption("TEST: Enter Coordinates...", player, onOpenCoordBox, npc)
            debugSub:addOption("TEST: Flee (Merchant Exit)", npc, onOrder, "Flee", player)
            debugSub:addOption("TEST: Attack Me (Melee)", npc, onOrder, "Attack", player)
            debugSub:addOption("TEST: Attack Me (Gun)", npc, onOrder, "AttackRange", player)
            
            debugSub:addOption("DEBUG: Inspect Data", nil, function()
                DTNPC_Debugger.OnOpenWindow()
                if DTNPC_Debugger.instance then
                    local id = npc:getPersistentOutfitID()
                    local list = DTNPC_Debugger.instance.npcList
                    for i, listEntry in ipairs(list.items) do
                        if listEntry.item and listEntry.item.id == id then
                            list.selected = i
                            DTNPC_Debugger.instance:onSelectNPC(listEntry.item)
                            break
                        end
                    end
                end
            end)
        end
    else
        local mOption = context:addOption("[DEBUG]NPC Manager")
        local mSub = context:getNew(context)
        context:addSubMenu(mOption, mSub)
        mSub:addOption("Summon All Followers", player, onSummon)
        
        local function onSpawn(p)
            local occupations = {
                "General", "Farmer", "Butcher", "Doctor", "Mechanic", "Survivalist", 
                "Gunrunner", "Foreman", "Scavenger", "Tailor", "Electrician", "Welder", 
                "Chef", "Herbalist", "Smuggler", "Librarian", "Angler", "Sheriff", 
                "Bartender", "Teacher", "Hunter", "Quartermaster", "Musician", "Janitor", 
                "Carpenter", "Pawnbroker", "Pyro", "Athlete", "Pharmacist", "Hiker", 
                "Burglar", "Blacksmith", "Tribal", "Painter", "RoadWarrior", "Designer", 
                "Office", "Geek", "Brewer", "Demo"
            }
            local occ = occupations[ZombRand(#occupations) + 1]
            sendClientCommand(p, "DTNPC", "Spawn", { occupation = occ })
        end
        
        mSub:addOption("Spawn Random NPC", player, onSpawn)
        
        if EventMarkerHandler then
            local markerOption = mSub:addOption("NPC Markers")
            local markerSub = mSub:getNew(mSub)
            context:addSubMenu(markerOption, markerSub)
            
            markerSub:addOption("Mark All NPCs", player, onMarkAllNPCs)
            markerSub:addOption("Clear All NPC Markers", player, onClearNPCMarkers)
        end
        
        mSub:addOption("Open NPC Global Debugger", nil, DTNPC_Debugger.OnOpenWindow)
    end
end

Events.OnFillWorldObjectContextMenu.Add(DTNPCMenu.OnFillWorldObjectContextMenu)