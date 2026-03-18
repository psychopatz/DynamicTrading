-- ==============================================================================
-- DT_NPC_Wardrobe.lua
-- Seed-based, deterministic wardrobe resolver.
-- Clothing data is stored per-archetype in:
-- DT/Common/ArchetypeDefinitions/{Archetype}/Definitions/DT_{Archetype}_Looks.lua
-- ==============================================================================

DT_NPC_Wardrobe = DT_NPC_Wardrobe or {}

DT_NPC_Wardrobe.SEED_MAX = 1000
DT_NPC_Wardrobe.DEFAULT_OUTFIT = {
    "Base.Tshirt_DefaultTEXTURE",
    "Base.Trousers_Denim",
    "Base.Shoes_Random"
}

local function copyArray(src)
    local dst = {}
    if not src then return dst end
    for i = 1, #src do
        dst[i] = src[i]
    end
    return dst
end

local function normalizeGender(isFemaleOrGender)
    if type(isFemaleOrGender) == "string" then
        if isFemaleOrGender == "Female" then return "Female" end
        return "Male"
    end
    return isFemaleOrGender and "Female" or "Male"
end

local function getLooksTable()
    DynamicTrading = DynamicTrading or {}
    DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}
    return DynamicTrading.ArchetypeLooks
end

local function ensureGeneralLooksLoaded()
    local looks = getLooksTable()
    if looks["General"] then return end

    local ok = pcall(require, "DT/Common/ArchetypeDefinitions/General/Definitions/DT_General_Looks")
    if (not ok) and (not DT_NPC_Wardrobe._warnedGeneralLooksLoad) then
        DT_NPC_Wardrobe._warnedGeneralLooksLoad = true
        DynamicTrading.Log("DTCommons", "NPC", "Warn", "Failed to load DT_General_Looks.lua. Using hardcoded failsafe outfit.")
    end
end

function DT_NPC_Wardrobe.RollIdentitySeed()
    return ZombRand(DT_NPC_Wardrobe.SEED_MAX) + 1
end

-- Alias for backward/future compatibility
DT_NPC_Wardrobe.RollLookSeed = DT_NPC_Wardrobe.RollIdentitySeed

function DT_NPC_Wardrobe.GetLookPool(category, isFemaleOrGender)
    local looks = getLooksTable()
    local cat = category or "General"
    local gender = normalizeGender(isFemaleOrGender)

    local byArchetype = looks[cat]
    local pool = byArchetype and byArchetype[gender]

    if not pool or #pool == 0 then
        ensureGeneralLooksLoaded()
        looks = getLooksTable()
        local fallback = looks["General"]
        pool = fallback and fallback[gender]
    end

    return pool
end

function DT_NPC_Wardrobe.GetMappedLookIndex(category, isFemaleOrGender, seed)
    local pool = DT_NPC_Wardrobe.GetLookPool(category, isFemaleOrGender)
    if not pool or #pool == 0 then return 1 end

    local normalizedSeed = tonumber(seed) or 1
    if normalizedSeed < 1 then normalizedSeed = 1 end

    return ((normalizedSeed - 1) % #pool) + 1
end

function DT_NPC_Wardrobe.GetOutfitBySeed(category, isFemaleOrGender, seed)
    local pool = DT_NPC_Wardrobe.GetLookPool(category, isFemaleOrGender)
    if not pool or #pool == 0 then
        return copyArray(DT_NPC_Wardrobe.DEFAULT_OUTFIT), 1
    end

    local idx = DT_NPC_Wardrobe.GetMappedLookIndex(category, isFemaleOrGender, seed)
    local outfit = pool[idx]
    if not outfit then
        return copyArray(DT_NPC_Wardrobe.DEFAULT_OUTFIT), 1
    end

    return copyArray(outfit), idx
end

function DT_NPC_Wardrobe.GetOutfitByIndex(category, isFemaleOrGender, index)
    local pool = DT_NPC_Wardrobe.GetLookPool(category, isFemaleOrGender)
    if not pool or #pool == 0 then
        return copyArray(DT_NPC_Wardrobe.DEFAULT_OUTFIT), 1
    end

    local idx = tonumber(index) or 1
    if idx < 1 then idx = 1 end
    if idx > #pool then idx = #pool end

    local outfit = pool[idx]
    if not outfit then
        return copyArray(DT_NPC_Wardrobe.DEFAULT_OUTFIT), 1
    end

    return copyArray(outfit), idx
end

function DT_NPC_Wardrobe.GetRandomOutfit(category, isFemale)
    local seed = DT_NPC_Wardrobe.RollLookSeed()
    local outfit = DT_NPC_Wardrobe.GetOutfitBySeed(category, isFemale, seed)
    return outfit
end

-- ==============================================================================
-- Hair Style Resolution
-- ==============================================================================

function DT_NPC_Wardrobe.GetHairStyleBySeed(category, isFemaleOrGender, seed)
    local looks = getLooksTable()
    local cat = category or "General"
    local gender = normalizeGender(isFemaleOrGender)
    
    -- 1. Try archetype-specific pool first
    local archetype = looks[cat]
    if archetype and archetype.HairStyles then
        local pool = archetype.HairStyles[gender]
        if pool and #pool > 0 then
            local normalizedSeed = tonumber(seed) or 1
            if normalizedSeed < 1 then normalizedSeed = 1 end
            local idx = ((normalizedSeed - 1) % #pool) + 1
            local style = pool[idx]
            if style then return style end
        end
    end
    
    -- 2. Try General archetype fallback
    if cat ~= "General" then
        archetype = looks["General"]
        if archetype and archetype.HairStyles then
            local pool = archetype.HairStyles[gender]
            if pool and #pool > 0 then
                local normalizedSeed = tonumber(seed) or 1
                if normalizedSeed < 1 then normalizedSeed = 1 end
                local idx = ((normalizedSeed - 1) % #pool) + 1
                local style = pool[idx]
                if style then return style end
            end
        end
    end
    
    -- 3. Default to game API (catches modded hair styles)
    local gameStyles = getAllHairStyles(gender == "Female")
    if gameStyles and gameStyles:size() > 0 then
        local normalizedSeed = tonumber(seed) or 1
        if normalizedSeed < 1 then normalizedSeed = 1 end
        local idx = ((normalizedSeed - 1) % gameStyles:size())
        local style = gameStyles:get(idx)
        if style then return style end
    end
    
    -- 4. Absolute fallback
    return gender == "Female" and "Long" or "Short"
end

-- ==============================================================================
-- Beard Style Resolution (Male Only)
-- ==============================================================================

function DT_NPC_Wardrobe.GetBeardStyleBySeed(category, seed)
    local looks = getLooksTable()
    local cat = category or "General"
    
    -- 1. Try archetype-specific pool first
    local archetype = looks[cat]
    if archetype and archetype.BeardStyles then
        local pool = archetype.BeardStyles
        if pool and #pool > 0 then
            local normalizedSeed = tonumber(seed) or 1
            if normalizedSeed < 1 then normalizedSeed = 1 end
            local idx = ((normalizedSeed - 1) % #pool) + 1
            local style = pool[idx]
            return style -- Can be nil for clean-shaven
        end
    end
    
    -- 2. Try General archetype fallback
    if cat ~= "General" then
        archetype = looks["General"]
        if archetype and archetype.BeardStyles then
            local pool = archetype.BeardStyles
            if pool and #pool > 0 then
                local normalizedSeed = tonumber(seed) or 1
                if normalizedSeed < 1 then normalizedSeed = 1 end
                local idx = ((normalizedSeed - 1) % #pool) + 1
                local style = pool[idx]
                return style -- Can be nil for clean-shaven
            end
        end
    end
    
    -- 3. Default to game API (catches modded beard styles)
    local gameStyles = getAllBeardStyles()
    if gameStyles and gameStyles:size() > 0 then
        local normalizedSeed = tonumber(seed) or 1
        if normalizedSeed < 1 then normalizedSeed = 1 end
        local idx = ((normalizedSeed - 1) % (gameStyles:size() + 3)) -- +3 for clean-shaven variety
        if idx >= gameStyles:size() then
            return nil -- Clean-shaven
        end
        return gameStyles:get(idx)
    end
    
    -- 4. Default to clean-shaven
    return nil
end

-- ==============================================================================
-- Hair Color Resolution (Returns RGB table)
-- ==============================================================================

function DT_NPC_Wardrobe.GetHairColorBySeed(category, seed)
    local looks = getLooksTable()
    local cat = category or "General"
    
    local archetype = looks[cat]
    if not archetype or not archetype.HairColors then
        ensureGeneralLooksLoaded()
        looks = getLooksTable()
        archetype = looks["General"]
    end
    
    if not archetype or not archetype.HairColors then
        -- Fallback to dark brown
        return { r = 0.2, g = 0.1, b = 0.1 }
    end
    
    local pool = archetype.HairColors
    if not pool or #pool == 0 then
        return { r = 0.2, g = 0.1, b = 0.1 }
    end
    
    local normalizedSeed = tonumber(seed) or 1
    if normalizedSeed < 1 then normalizedSeed = 1 end
    local idx = ((normalizedSeed - 1) % #pool) + 1
    
    local color = pool[idx]
    if not color then
        return { r = 0.2, g = 0.1, b = 0.1 }
    end
    
    -- Return a copy to prevent modifications
    return {
        r = color.r or 0.2,
        g = color.g or 0.1,
        b = color.b or 0.1
    }
end
