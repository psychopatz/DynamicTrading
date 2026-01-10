-- ==============================================================================
-- MyNPC_ContextMenu.lua
-- Client-side Logic: Context Menu for Orders and SUMMONING.
-- UPDATED: Added "Summon Lost NPCs" when clicking the ground.
-- ==============================================================================

MyNPCMenu = MyNPCMenu or {}

local function onOrder(npc, state, player)
    if not npc or not player then return end
    local args = { x = npc:getX(), y = npc:getY(), z = npc:getZ(), state = state }
    if state == "GoTo" then
        args.targetX, args.targetY, args.targetZ = player:getX(), player:getY(), player:getZ()
    end
    sendClientCommand(player, "MyNPC", "Order", args)
    player:Say("Order: " .. state)
end

local function onSummon(player)
    sendClientCommand(player, "MyNPC", "Summon", {})
    player:Say("Signal Sent: Summoning Team...")
end

function MyNPCMenu.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    -- 1. IDENTIFY CLICKED SQUARE
    local square = nil
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then square = obj:getSquare(); break end
    end
    if not square then return end

    -- 2. SCAN FOR NPC (Existing Logic)
    local foundNPC = nil
    local function checkSquare(sq)
        if not sq then return nil end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") and MyNPC.GetBrain(obj) then return obj end
        end
        return nil
    end

    foundNPC = checkSquare(square)
    -- Check neighbors if not found
    if not foundNPC then
        local sx, sy, sz = square:getX(), square:getY(), square:getZ()
        for x = -1, 1 do
            for y = -1, 1 do
                if not (x==0 and y==0) then
                    local neighbor = getCell():getGridSquare(sx+x, sy+y, sz)
                    foundNPC = checkSquare(neighbor)
                    if foundNPC then break end
                end
            end
            if foundNPC then break end
        end
    end

    -- 3. ADD OPTIONS
    
    if foundNPC then
        -- IF CLICKED AN NPC: Show Order Menu
        local brain = MyNPC.GetBrain(foundNPC)
        local option = context:addOption("NPC: " .. brain.name)
        local subMenu = context:getNew(context)
        context:addSubMenu(option, subMenu)
        subMenu:addOption("Follow Me", foundNPC, onOrder, "Follow", player)
        subMenu:addOption("Stop / Guard", foundNPC, onOrder, "Stay", player)
        subMenu:addOption("Come Here", foundNPC, onOrder, "GoTo", player)
    else
        -- IF CLICKED GROUND: Show "Manage NPCs" Menu
        -- Use a SubMenu to keep it clean
        local mOption = context:addOption("MyNPC Manager")
        local mSub = context:getNew(context)
        context:addSubMenu(mOption, mSub)
        
        mSub:addOption("Summon All Followers", player, onSummon)
    end
end

Events.OnFillWorldObjectContextMenu.Add(MyNPCMenu.OnFillWorldObjectContextMenu)