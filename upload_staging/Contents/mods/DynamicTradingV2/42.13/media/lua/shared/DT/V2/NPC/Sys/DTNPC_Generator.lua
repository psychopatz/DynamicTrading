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
    local identitySeed = mvpData.identitySeed
    if (not identitySeed) and DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollIdentitySeed then
        identitySeed = DT_NPC_Wardrobe.RollIdentitySeed()
    end

    local npcData = {
        name = mvpData.name,
        isFemale = mvpData.isFemale,
        outfit = mvpData.outfit,
        identitySeed = identitySeed,
        hairStyle = mvpData.hairStyle,
        beardStyle = mvpData.beardStyle,
        
        -- Default stats
        state = "Idle",
        incapState = nil,
        preIncapStatus = nil,
        master = options.masterName,
        masterID = options.masterID,
        tasks = {},
        isMVP = true,
        visualID = ZombRand(1000000),
        archetypeID = mvpData.archetypeID or options.occupation or "General",
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
    
    -- 2. Pick deterministic identity seed
    local occupation = options.occupation or "General"
    local identitySeed = 1
    if DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollIdentitySeed then
        identitySeed = DT_NPC_Wardrobe.RollIdentitySeed()
    end
    
    -- 3. Build npcData with minimal visual data
    -- Hair/beard styles and colors are resolved from identitySeed + archetype in ApplyVisuals
    local npcData = {
        name = name,
        isFemale = isFemale,
        identitySeed = identitySeed,
        
        -- Logic
        state = "Idle",
        incapState = nil,
        preIncapStatus = nil,
        master = options.masterName,
        masterID = options.masterID,
        tasks = {},
        visualID = ZombRand(1000000),
        archetypeID = occupation,
    }

    
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
