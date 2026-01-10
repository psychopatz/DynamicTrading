-- ==============================================================================
-- MyNPC_ContextMenu.lua
-- Client-side Logic: Context Menu for Orders and SUMMONING.
-- UPDATED: Detects ALL NPCs in the clicked area and lists them (Sorted by Distance).
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

local function onSummon(player)
    sendClientCommand(player, "MyNPC", "Summon", {})
    player:Say("Signal Sent: Summoning Team...")
end

-- ==============================================================================
-- 2. MAIN MENU LOGIC
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

    -- 2. SCAN FOR ALL NPCs (Center + Neighbors)
    local npcList = {}
    local processedIDs = {} -- To prevent duplicates if they straddle tiles

    local function scanSquare(sq)
        if not sq then return end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") then
                local brain = MyNPC.GetBrain(obj)
                if brain then
                    -- Identify by ID to ensure uniqueness
                    local id = obj:getPersistentOutfitID() or obj:getID()
                    if not processedIDs[id] then
                        table.insert(npcList, obj)
                        processedIDs[id] = true
                    end
                end
            end
        end
    end

    -- Scan Center
    scanSquare(square)

    -- Scan Neighbors (3x3 grid around click)
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                local neighbor = getCell():getGridSquare(sx + x, sy + y, sz)
                scanSquare(neighbor)
            end
        end
    end

    -- 3. SORT BY DISTANCE (Closest to player appears first)
    table.sort(npcList, function(a, b)
        return calculateDistance(player, a) < calculateDistance(player, b)
    end)

    -- 4. BUILD MENU
    if #npcList > 0 then
        -- Generate a menu entry for EACH found NPC
        for _, npc in ipairs(npcList) do
            local brain = MyNPC.GetBrain(npc)
            local status = brain.state == "Stay" and " [Guard]" or ""
            
            -- Parent Option: "NPC: Bob [Guard]"
            local option = context:addOption("NPC: " .. brain.name .. status)
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)

            -- Commands
            subMenu:addOption("Follow Me", npc, onOrder, "Follow", player)
            subMenu:addOption("Stop / Guard", npc, onOrder, "Stay", player)
            subMenu:addOption("Come Here", npc, onOrder, "GoTo", player)
        end
    else
        -- IF CLICKED GROUND (No NPCs found): Show Manager
        local mOption = context:addOption("MyNPC Manager")
        local mSub = context:getNew(context)
        context:addSubMenu(mOption, mSub)
        
        mSub:addOption("Summon All Followers", player, onSummon)
    end
end

Events.OnFillWorldObjectContextMenu.Add(MyNPCMenu.OnFillWorldObjectContextMenu)