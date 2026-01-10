-- ==============================================================================
-- MyNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- UPDATED: Now saves Last Known X/Y/Z for summoning lost NPCs.
-- ==============================================================================

MyNPCManager = MyNPCManager or {}
MyNPCManager.Data = {} 

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

function MyNPCManager.Load()
    local globalData = ModData.getOrCreate("MyNPC_GlobalList")
    MyNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = MyNPCManager.Data
    print("[MyNPC] Manager Loaded. Tracking " .. tostring(getTableSize(MyNPCManager.Data)) .. " NPCs.")
end

function MyNPCManager.Save()
    local globalData = ModData.getOrCreate("MyNPC_GlobalList")
    globalData.NPCs = MyNPCManager.Data
end

Events.OnInitGlobalModData.Add(MyNPCManager.Load)

-- ==============================================================================
-- 2. REGISTRATION
-- ==============================================================================

function MyNPCManager.Register(zombie, brain)
    if not zombie or not brain then return end
    
    local id = zombie:getPersistentOutfitID()
    
    -- [NEW] Update Location Data
    brain.lastX = math.floor(zombie:getX())
    brain.lastY = math.floor(zombie:getY())
    brain.lastZ = math.floor(zombie:getZ())
    
    MyNPCManager.Data[id] = brain
    MyNPCManager.Save()
end

-- Used when we want to delete an NPC (e.g., re-summoning them)
function MyNPCManager.RemoveData(id)
    if MyNPCManager.Data[id] then
        MyNPCManager.Data[id] = nil
        MyNPCManager.Save()
    end
end

function MyNPCManager.Unregister(zombie)
    local id = zombie:getPersistentOutfitID()
    if MyNPCManager.Data[id] then
        MyNPCManager.Data[id] = nil
        MyNPCManager.Save()
        print("[MyNPC] NPC Died. Removed from DB: " .. id)
    end
end

Events.OnZombieDead.Add(MyNPCManager.Unregister)

-- ==============================================================================
-- 3. RESTORATION & TRACKING LOOP
-- ==============================================================================

local TICK_RATE = 20 -- Check every ~1 second
local tickCounter = 0

function MyNPCManager.OnTick()
    if isClient() then return end

    tickCounter = tickCounter + 1
    if tickCounter < TICK_RATE then return end
    tickCounter = 0

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local id = zombie:getPersistentOutfitID()
        local savedBrain = MyNPCManager.Data[id]
        
        if savedBrain then
            
            -- [NEW] UPDATE POSITION (Heartbeat)
            -- We update the coordinates in the DB so we always know where they were last seen.
            -- We assume they are alive if we see them here.
            savedBrain.lastX = math.floor(zombie:getX())
            savedBrain.lastY = math.floor(zombie:getY())
            savedBrain.lastZ = math.floor(zombie:getZ())
            
            -- 2. CHECK VISUALS
            local needsFix = true
            local visuals = zombie:getHumanVisual()
            if visuals then
                local skin = visuals:getSkinTexture()
                if skin then
                    skin = tostring(skin)
                    if string.find(skin, "MaleBody01") or string.find(skin, "FemaleBody01") then
                        needsFix = false
                    end
                end
            end
            
            if needsFix then
                MyNPC.ApplyVisuals(zombie, savedBrain)
                MyNPC.AttachBrain(zombie, savedBrain)
                if not zombie:isUseless() then
                    zombie:setUseless(true)
                    zombie:DoZombieStats()
                    zombie:setHealth(1.5)
                end
            end
        end
    end
end

Events.OnTick.Add(MyNPCManager.OnTick)

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end