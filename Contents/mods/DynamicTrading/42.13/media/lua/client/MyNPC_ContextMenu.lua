-- ==============================================================================
-- MyNPC_ContextMenu.lua
-- Client-side Logic: Context Menu for Orders and DEBUGGING.
-- UPDATED: Fixed "IsoPlayer vs Int" crash in ISTextBox.
-- ==============================================================================

MyNPCMenu = MyNPCMenu or {}

-- ==============================================================================
-- 1. HELPER FUNCTIONS
-- ==============================================================================

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

    sendClientCommand(player, "MyNPC", "Order", args)
    player:Say("Order (" .. MyNPC.GetBrain(npc).name .. "): " .. state)
end

-- Callback for the Input Box (The "OK" button logic)
-- Params passed from ISTextBox: target(self), button, param1, param2
local function onCoordInput(target, button, player, npc)
    if button.internal ~= "OK" then return end
    
    local text = button.parent.entry:getText()
    if not text or text == "" then return end
    
    -- Parse the text (Patterns look for numbers: "10820, 9463, 0" or just "10820 9463")
    local xStr, yStr, zStr = text:match("(%d+)[^%d]+(%d+)[^%d]*(%d*)")
    
    if xStr and yStr then
        local tx = tonumber(xStr)
        local ty = tonumber(yStr)
        local tz = tonumber(zStr) or 0 
        
        local args = {
            x = npc:getX(),
            y = npc:getY(),
            z = npc:getZ(),
            state = "GoTo",
            targetX = tx,
            targetY = ty,
            targetZ = tz
        }
        
        sendClientCommand(player, "MyNPC", "Order", args)
        player:Say("Sent GoTo: " .. tx .. ", " .. ty .. ", " .. tz)
    else
        player:Say("Invalid Coords! Use format: 10820,9463,0")
    end
end

-- Function to launch the Input Box
local function onOpenCoordBox(player, npc)
    -- Default text shows current player pos for reference
    local defaultText = math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0"
    
    -- ISTextBox:new(x, y, w, h, title, defaultText, target, onclick, playerNum, param1, param2)
    -- CRITICAL FIX: The 9th argument MUST be a number (player index), not the player object.
    -- We pass the player object as the 10th argument (Param1) so onCoordInput receives it.
    local modal = ISTextBox:new(0, 0, 280, 180, "Enter Target Coordinates (X,Y,Z):", defaultText, nil, onCoordInput, player:getPlayerNum(), player, npc)
    
    modal:initialise()
    modal:addToUIManager()
end

local function onSummon(player)
    sendClientCommand(player, "MyNPC", "Summon", {})
    player:Say("Signal Sent: Summoning Team...")
end

-- ==============================================================================
-- 3. MAIN MENU BUILDER
-- ==============================================================================

function MyNPCMenu.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    -- 1. IDENTIFY CLICKED SQUARE
    local square = nil
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then square = obj:getSquare(); break end
    end
    if not square then return end

    -- 2. SCAN FOR NPCs
    local npcList = {}
    local processedIDs = {} 

    local function scanSquare(sq)
        if not sq then return end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") then
                local brain = MyNPC.GetBrain(obj)
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

    -- 3. BUILD MENU
    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local brain = MyNPC.GetBrain(npc)
            local status = " [" .. (brain.state or "Idle") .. "]"
            
            local option = context:addOption("NPC: " .. brain.name .. status)
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)

            subMenu:addOption("Follow Me", npc, onOrder, "Follow", player)
            subMenu:addOption("Stop / Guard", npc, onOrder, "Stay", player)
            subMenu:addOption("Come Here (My Pos)", npc, onOrder, "GoTo", player)

            -- DEBUG MENU
            local debugOption = subMenu:addOption("DEBUG / TEST")
            local debugSub = subMenu:getNew(subMenu)
            context:addSubMenu(debugOption, debugSub)

            debugSub:addOption("TEST: Enter Coordinates...", player, onOpenCoordBox, npc)
            debugSub:addOption("TEST: Flee (Merchant Exit)", npc, onOrder, "Flee", player)
            debugSub:addOption("TEST: Attack Me", npc, onOrder, "Attack", player)
        end
    else
        local mOption = context:addOption("MyNPC Manager")
        local mSub = context:getNew(context)
        context:addSubMenu(mOption, mSub)
        mSub:addOption("Summon All Followers", player, onSummon)
    end
end

Events.OnFillWorldObjectContextMenu.Add(MyNPCMenu.OnFillWorldObjectContextMenu)