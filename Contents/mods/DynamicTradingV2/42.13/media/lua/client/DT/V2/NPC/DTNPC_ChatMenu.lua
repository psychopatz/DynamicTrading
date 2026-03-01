-- ==============================================================================
-- DTNPC_ChatMenu.lua
-- Dedicated context menu for NPC interactions (Production).
-- ==============================================================================

local function getBrain(zombie)
    if not zombie then return nil end
    local modData = zombie:getModData()
    return modData and modData.DTNPCBrain
end

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
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
                        -- Check distance (e.g., within 3 meters)
                        if calculateDistance(player, obj) < 3.0 then
                            table.insert(npcList, obj)
                            processedIDs[id] = true
                        end
                    end
                end
            end
        end
    end

    scanSquare(square)
    -- Also scan neighbors for ease of clicking
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz))
            end
        end
    end

    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local brain = getBrain(npc)
            local name = brain and brain.name or "Survivor"
            
            context:addOption("Talk to " .. name, npc, function(n)
                local id = n:getPersistentOutfitID() or n:getID()
                
                -- Delegate all interaction logic to the Dialogue Hub
                if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
                    DTNPC_TraderDialogue_Hub.Init(nil, npc, player)
                else
                    print("Error: DTNPC_TraderDialogue_Hub not found")
                end
            end)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
