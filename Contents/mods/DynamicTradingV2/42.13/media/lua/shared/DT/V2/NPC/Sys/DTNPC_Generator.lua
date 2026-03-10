-- ==============================================================================
-- DTNPC_Generator.lua
-- The Factory: Manages the creation of NPC Data structures.
-- Decoupled from spawning logic to allow flexible generation strategies.
-- ==============================================================================

DTNPCGenerator = DTNPCGenerator or {}

require "DT/Common/NPC/DT_NPC_Wardrobe"
require "DT/Common/NPC/DT_NPC_Archetypes"

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
        if DT_NPC_Archetypes and DT_NPC_Archetypes.GetRandom then
            mvp = DT_NPC_Archetypes.GetRandom()
        end
    end
    
    if mvp then
        return DTNPCGenerator.CreateMVPData(mvp, options)
    end
    
    -- 2. Standard Generation
    return DTNPCGenerator.CreateStandardData(options)
end

-- ==============================================================================
-- 3. SPECIFIC BUILDERS
-- ==============================================================================

function DTNPCGenerator.CreateMVPData(mvpData, options)
    local lookSeed = mvpData.lookSeed
    if (not lookSeed) and DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollLookSeed then
        lookSeed = DT_NPC_Wardrobe.RollLookSeed()
    end

    local npcData = {
        name = mvpData.name,
        isFemale = mvpData.isFemale,
        outfit = mvpData.outfit,
        lookSeed = lookSeed,
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
        visualID = ZombRand(1000000),
        archetypeID = mvpData.archetypeID or options.occupation or "General",
        portraitID = mvpData.portraitID or 1
    }

    
    return npcData
end


function DTNPCGenerator.CreateStandardData(options)
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
    
    -- 2. Pick deterministic look seed
    local occupation = options.occupation or "General"
    local lookSeed = 1
    if DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollLookSeed then
        lookSeed = DT_NPC_Wardrobe.RollLookSeed()
    end
    
    -- 3. Build npcData with minimal visual data
    -- Hair/beard styles and colors are resolved from lookSeed + archetype in ApplyVisuals
    local npcData = {
        name = name,
        isFemale = isFemale,
        lookSeed = lookSeed,
        
        -- Logic
        state = "Stay",
        master = options.masterName,
        masterID = options.masterID,
        tasks = {},
        walkSpeed = options.walkSpeed or 0.06,
        runSpeed = options.runSpeed or 0.09,
        visualID = ZombRand(1000000),
        archetypeID = occupation,
        portraitID = 1 -- Default fallback
    }

        -- We use a seed between 1 and 1000 from the unified system.
        -- The client will modulo this against their local texture count.
        npcData.portraitID = DynamicTrading.Portraits.RollPortraitSeed()

    
    return npcData
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
