-- ==============================================================================
-- MyNPC_Spawn.lua
-- Server-side Logic: Handles creating the NPC entity.
-- FIXED: Using 'addZombiesInOutfit' (Native B42 Function) for 100% compatibility.
-- ==============================================================================

MyNPCSpawn = MyNPCSpawn or {}

-- ==============================================================================
-- 1. THE SPAWNER FUNCTION
-- ==============================================================================

function MyNPCSpawn.SpawnNPC(player)
    if not player then return end
    
    local x = player:getX()
    local y = player:getY()
    local z = player:getZ()

    -- 1. Define Parameters
    local spawnX = x + 2
    local spawnY = y + 2
    local outfit = "Naked" -- We will dress them ourselves in ApplyVisuals
    local femaleChance = 50
    
    -- 2. Spawn using the native global function
    -- Arg signature for B42: x, y, z, count, outfit, femaleChance, crawler, fallOnFront, fakeDead, knockedDown, invulnerable, sitting, health
    local zombieList = addZombiesInOutfit(spawnX, spawnY, z, 1, outfit, femaleChance, false, false, false, false, false, false, 1)
    
    if not zombieList or zombieList:size() == 0 then
        print("[MyNPC] Error: Failed to spawn zombie.")
        return
    end

    -- 3. Get the Zombie Object
    local zombie = zombieList:get(0)
    
    -- 4. Generate Random Stats (The Brain)
    local isFemale = zombie:isFemale() -- Use the gender the game gave us
    local brain = {
        name = MyNPC.GenerateName(isFemale),
        isFemale = isFemale,
        hairStyle = nil, 
        outfit = {
            "Base.Tshirt_White",
            "Base.Jeans_Black",
            "Base.Shoes_Sneakers"
        },
        state = "Follow",
        master = player:getUsername(),
        masterID = player:getOnlineID()
    }

    -- 5. Attach Data & Apply Look
    MyNPC.AttachBrain(zombie, brain)
    MyNPC.ApplyVisuals(zombie, brain)

    -- 6. Strip Default Zombie Behavior
    zombie:setUseless(true) 
    zombie:DoZombieStats()   
    zombie:setHealth(1.5)    

    print("[MyNPC] Spawned NPC: " .. brain.name .. " at " .. spawnX .. "," .. spawnY)
end

-- ==============================================================================
-- 2. COMMAND HANDLER
-- ==============================================================================

local function onClientCommand(module, command, player, args)
    if module == "MyNPC" and command == "Spawn" then
        MyNPCSpawn.SpawnNPC(player)
    end
end

Events.OnClientCommand.Add(onClientCommand)