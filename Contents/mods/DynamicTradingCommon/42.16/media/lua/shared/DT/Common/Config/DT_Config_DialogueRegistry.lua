-- =============================================================================
-- 3. DIALOGUE REGISTRY
-- =============================================================================
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}

local function MergeNestedTables(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return source
    end

    for key, value in pairs(source) do
        local existing = target[key]
        if type(existing) == "table" and type(value) == "table" and not existing[1] and not value[1] then
            MergeNestedTables(existing, value)
        else
            target[key] = value
        end
    end

    return target
end

-- New RegisterDialogue for In-Code Translations
function DynamicTrading.RegisterDialogue(archetypeID, dialogueType, data)
    if not archetypeID or not dialogueType or not data then return end
    
    DynamicTrading.Dialogue.Archetypes[archetypeID] = DynamicTrading.Dialogue.Archetypes[archetypeID] or {}
    local archTable = DynamicTrading.Dialogue.Archetypes[archetypeID]
    
    archTable[dialogueType] = archTable[dialogueType] or {}

    -- Merge translations (supports overrides and cross-file loading)
    for lang, lines in pairs(data) do
        if type(archTable[dialogueType][lang]) == "table" and type(lines) == "table" then
            archTable[dialogueType][lang] = MergeNestedTables(archTable[dialogueType][lang], lines)
        else
            archTable[dialogueType][lang] = lines
        end
    end

    if archetypeID == "Player" and DynamicTrading.Debug then
         DynamicTrading.Log("DTCommons", "Dialogue", "Debug", "Registered Player Dialogue: " .. dialogueType)
    end
end

-- Detection Helper: Returns the current game language code (e.g., "EN", "PH", "RU")
function DynamicTrading.GetLanguage()
    if Translator and Translator.getLanguage() then
        return Translator.getLanguage():toString()
    end
    return "EN" -- Default fallback
end
