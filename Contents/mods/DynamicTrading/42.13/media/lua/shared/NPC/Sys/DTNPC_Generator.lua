-- ==============================================================================
-- DTNPC_Generator.lua
-- The Factory: Manages the creation of NPC Brains.
-- Decoupled from spawning logic to allow flexible generation strategies.
-- ==============================================================================

DTNPCGenerator = DTNPCGenerator or {}

require "NPC/Templates/DTNPC_Presets"
require "NPC/Templates/DTNPC_MVP"

-- ==============================================================================
-- 1. CONFIGURATION
-- ==============================================================================

DTNPCGenerator.MVPChance = 10 -- 1 in 10 chance to spawn an MVP (if available)

-- ==============================================================================
-- 2. GENERATION
-- ==============================================================================

function DTNPCGenerator.Generate(options)
    options = options or {}
    
    -- 1. Try MVP Roll
    local mvp = nil
    if options.forceMVP or (ZombRand(100) < DTNPCGenerator.MVPChance) then
        if DTNPC_MVP and DTNPC_MVP.GetRandom then
            mvp = DTNPC_MVP.GetRandom()
        end
    end
    
    if mvp then
        return DTNPCGenerator.CreateMVPBrain(mvp, options)
    end
    
    -- 2. Standard Generation
    return DTNPCGenerator.CreateStandardBrain(options)
end

-- ==============================================================================
-- 3. SPECIFIC BUILDERS
-- ==============================================================================

function DTNPCGenerator.CreateMVPBrain(mvpData, options)
    local brain = {
        name = mvpData.name,
        isFemale = mvpData.isFemale,
        outfit = mvpData.outfit,
        hairStyle = mvpData.hairStyle,
        beardStyle = mvpData.beardStyle,
        
        -- Default stats
        state = "Stay",
        master = options.masterName,
        masterID = options.masterID,
        tasks = {},
        walkSpeed = options.walkSpeed or 0.06,
        runSpeed = options.runSpeed or 0.09,
        isMVP = true,
        visualID = ZombRand(1000000) -- Unique ID for this specific look
    }
    
    return brain
end


function DTNPCGenerator.CreateStandardBrain(options)
    local isFemale = (ZombRand(2) == 0)
    
    -- 1. Generate Base Survivor info using Game Engine if possible
    local survivorDesc = nil
    local name = ""
    local survivor = nil
    
    if SurvivorFactory then
        survivor = SurvivorFactory.CreateSurvivor()
        if survivor then
            isFemale = survivor:isFemale()
            name = survivor:getForename() .. " " .. survivor:getSurname()
        end
    end
    
    if name == "" then
       name = DTNPCGenerator.GenerateRandomName(isFemale)
    end
    
    -- 2. Pick Costume
    local occupation = options.occupation or "General"
    local outfit = DTNPCPresets.GetRandomOutfit(occupation, isFemale)
    
    -- 3. Visuals Persistence (Fixes MP Reshuffling)
    local hairStyle = nil
    local hairStyles = getAllHairStyles(isFemale)
    if hairStyles and hairStyles:size() > 0 then
        local idx = ZombRand(hairStyles:size())
        hairStyle = hairStyles:get(idx) -- Save the STRING ID
    end
    
    local beardStyle = nil
    if not isFemale then
        local beardStyles = getAllBeardStyles()
        if beardStyles and beardStyles:size() > 0 then
             local idx = ZombRand(beardStyles:size())
             beardStyle = beardStyles:get(idx) -- Save the STRING ID
        end
    end
    
    local brain = {
        name = name,
        isFemale = isFemale,
        outfit = outfit,
        
        -- Saved Visuals
        hairStyle = hairStyle, 
        beardStyle = beardStyle,
        
        -- Logic
        state = "Stay",
        master = options.masterName,
        masterID = options.masterID,
        tasks = {},
        walkSpeed = options.walkSpeed or 0.06,
        runSpeed = options.runSpeed or 0.09,
        visualID = ZombRand(1000000) -- Unique ID for this specific look
    }
    
    return brain
end

-- ==============================================================================
-- 4. UTILITIES
-- ==============================================================================

function DTNPCGenerator.GenerateRandomName(isFemale)
    -- Fallback simple name generator if SurvivorFactory fails
    local maleNames = {"Bob", "Jim", "Mike", "Steve", "Alex", "Zed", "Arthur", "John"}
    local femaleNames = {"Alice", "Jane", "Sarah", "Emily", "Kate", "Rose", "Anna"}
    local surNames = {"Smith", "Jones", "Doe", "Miller", "Wilson", "Taylor"}
    
    local list = isFemale and femaleNames or maleNames
    
    local first = list[ZombRand(#list) + 1]
    local last = surNames[ZombRand(#surNames) + 1]
    
    return first .. " " .. last
end
