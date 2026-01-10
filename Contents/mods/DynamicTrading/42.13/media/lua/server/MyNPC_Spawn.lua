-- ==============================================================================
-- MyNPC_Spawn.lua
-- Server-side Logic: Spawning, Commands, and SUMMONING.
-- UPDATED: Default state is now "Stay" (Guard). Added task queue init.
-- ==============================================================================

MyNPCSpawn = MyNPCSpawn or {}

function MyNPCSpawn.SpawnNPC(player, existingBrain)
    if not player then return end
    
    local x, y, z = player:getX(), player:getY(), player:getZ()
    local spawnX, spawnY = x + 2, y + 2
    local outfitStr, femaleChance = "Naked", 50
    
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfitStr, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then return end

    local zombie = zombieList:get(0)
    
    local brain = existingBrain
    
    if not brain then
        local isFemale = zombie:isFemale()
        local myOutfit = MyNPC.GetOutfit(isFemale, "Casual")
        brain = {
            name = MyNPC.GenerateName(isFemale),
            isFemale = isFemale,
            hairStyle = nil, 
            outfit = myOutfit,
            state = "Stay", -- CHANGED: Default is now Stay/Guard
            master = player:getUsername(),
            masterID = player:getOnlineID(),
            tasks = {} -- NEW: The Task Queue
        }
    else
        -- Keep existing state if summoning, but ensure tasks table exists
        if not brain.tasks then brain.tasks = {} end
    end

    MyNPC.AttachBrain(zombie, brain)
    MyNPC.ApplyVisuals(zombie, brain)

    if MyNPCManager then
        MyNPCManager.Register(zombie, brain)
    end

    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(1.5)    

    print("[MyNPC] Spawned/Summoned: " .. brain.name)
end

function MyNPCSpawn.SummonAll(player)
    if not MyNPCManager then return end
    local username = player:getUsername()
    local cell = getCell()
    local toTeleport = {}
    local toRecreate = {}
    
    for id, brain in pairs(MyNPCManager.Data) do
        if brain.master == username then
            local foundObj = nil
            local zombieList = cell:getZombieList()
            for i=0, zombieList:size()-1 do
                local z = zombieList:get(i)
                if z:getPersistentOutfitID() == id then
                    foundObj = z
                    break
                end
            end
            
            if foundObj then
                table.insert(toTeleport, foundObj)
            else
                brain.oldID = id 
                table.insert(toRecreate, brain)
            end
        end
    end
    
    for _, npc in ipairs(toTeleport) do
        npc:setX(player:getX() + 1)
        npc:setY(player:getY() + 1)
        npc:setZ(player:getZ())
        npc:setLastX(player:getX())
        npc:setLastY(player:getY())
    end
    
    for _, brain in ipairs(toRecreate) do
        MyNPCManager.RemoveData(brain.oldID)
        MyNPCSpawn.SpawnNPC(player, brain)
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= "MyNPC" then return end

    if command == "Spawn" then
        MyNPCSpawn.SpawnNPC(player, nil)
    end

    if command == "Summon" then
        MyNPCSpawn.SummonAll(player)
    end

    if command == "Order" then
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        if square then
            local movingObjects = square:getMovingObjects()
            for i=0, movingObjects:size()-1 do
                local obj = movingObjects:get(i)
                if instanceof(obj, "IsoZombie") then
                    local brain = MyNPC.GetBrain(obj)
                    if brain then
                        brain.state = args.state
                        
                        -- CLEAR TASKS ON NEW ORDER
                        brain.tasks = {} 
                        
                        -- If GoTo, add it as the first task immediately
                        if args.state == "GoTo" then
                           table.insert(brain.tasks, {x = math.floor(args.targetX), y = math.floor(args.targetY), z = math.floor(args.targetZ or 0)})
                        end

                        MyNPC.AttachBrain(obj, brain)
                        if MyNPCManager then MyNPCManager.Register(obj, brain) end
                        break
                    end
                end
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)