-- =============================================================================
-- 4. DYNAMIC LOADER
-- =============================================================================
local function isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

local defaultArchetypeList = {
    "Angler", "Athlete", "Bartender", "Blacksmith", "Brewer", "Burglar", "Butcher",
    "Carpenter", "Chef", "Demo", "Designer", "Doctor", "Electrician", "Farmer", "Foreman",
    "Geek", "Gunrunner", "Herbalist", "Hiker", "Hunter", "Janitor", "Librarian", "Mechanic",
    "LotteryAgent", "Musician", "Office", "Painter", "Pawnbroker", "Pharmacist", "Pyro",
    "Quartermaster", "RoadWarrior", "Scavenger", "Sheriff", "Smuggler",
    "Survivalist", "Tailor", "Teacher", "Tribal", "Welder",
    "General", "Player" -- Meta archetypes
}

if isCurrencyExpandedActive() then
    defaultArchetypeList[#defaultArchetypeList + 1] = "Bandit"
end

DynamicTrading.Config.ArchetypeList = DynamicTrading.Config.ArchetypeList or {}
for _, id in ipairs(defaultArchetypeList) do
    if DynamicTrading.RegisterArchetypeModule then
        DynamicTrading.RegisterArchetypeModule(id)
    else
        local exists = false
        for _, currentID in ipairs(DynamicTrading.Config.ArchetypeList) do
            if currentID == id then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(DynamicTrading.Config.ArchetypeList, id)
        end
    end
end

local languages = {
    "AR", "CA", "CH", "CN", "CS", "DA", "DE", "EN", "ES", "FI",
    "FR", "HU", "ID", "IT", "JP", "KO", "NL", "NO", "PH", "PL",
    "PT", "PTBR", "RO", "RU", "TH", "TR", "UA"
}
local dialogueTypes = { "Greetings", "Buying", "Selling", "Sell_ask", "Idle", "Request", "Tracking" }
local ambientDialogueStatuses = { "Default", "Trading", "Resting", "Working", "Away" }

-- Debug Flag
DynamicTrading.Debug = false

-- Helper to check file existence to avoid console spam
local function FileExists(path)
    local fullPath = "media/lua/shared/" .. path .. ".lua"
    local exists = false
    local checked = false
    
    if getZomboidFileSystem then
        local fs = getZomboidFileSystem()
        if fs then
            local file = fs:getFile(fullPath)
            if file and file:exists() then exists = true end
            checked = true
        end
    elseif ZomboidFileSystem and ZomboidFileSystem.instance then
            local file = ZomboidFileSystem.instance:getFile(fullPath)
            if file and file:exists() then exists = true end
            checked = true
    elseif fileExists then
            -- Some environments have this global
            if fileExists(fullPath) then exists = true end
            checked = true
    end
    
    -- Fallback: If we couldn't check (API missing), try to load anyway to be safe
    if not checked then 
        exists = true 
    end
    
    return exists
end

function DynamicTrading.LoadArchetypes()
    DynamicTrading.Log("DTCommons", "Core", "Init", "Starting Dynamic Archetype Loading...")
    local totalLoaded = 0
    local errors = 0
    
    for _, id in ipairs(DynamicTrading.Config.ArchetypeList) do
        if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Debug", "Processing Archetype: " .. id) end

        -- 1. Load Archetype Definition (Item Data)
        local itemPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Items/DT_" .. id
        -- Items are mandatory, so we still want to know if they fail, but checking existence first is cleaner
        if FileExists(itemPath) then
             local itemOk, err = pcall(require, itemPath)
             if not itemOk then
                  DynamicTrading.Log("DTCommons", "Core", "Error", "Failed to load Item Definition for " .. id .. ": " .. tostring(err))
                  errors = errors + 1
             end
        else
             -- Warn if definition is missing entirely, as this might be critical
             if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Warn", "Missing Item Definition for: " .. id) end
        end

        -- 1b. Load Archetype Looks (optional, shared by server/client for deterministic wardrobe mapping)
        local looksPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Definitions/DT_" .. id .. "_Looks"
        if FileExists(looksPath) then
            local looksOk, looksErr = pcall(require, looksPath)
            if not looksOk then
                DynamicTrading.Log("DTCommons", "Core", "Error", "Failed to load Looks Definition for " .. id .. ": " .. tostring(looksErr))
                errors = errors + 1
            end
        end

        local skillsPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Definitions/DT_" .. id .. "_Skills"
        if FileExists(skillsPath) then
            local skillsOk, skillsErr = pcall(require, skillsPath)
            if not skillsOk then
                DynamicTrading.Log("DTCommons", "Core", "Error", "Failed to load Skill Definition for " .. id .. ": " .. tostring(skillsErr))
                errors = errors + 1
            else
                totalLoaded = totalLoaded + 1
            end
        end

        local equipmentPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Definitions/DT_" .. id .. "_Equipments"
        if FileExists(equipmentPath) then
            local equipmentOk, equipmentErr = pcall(require, equipmentPath)
            if not equipmentOk then
                DynamicTrading.Log("DTCommons", "Core", "Error", "Failed to load Equipment Definition for " .. id .. ": " .. tostring(equipmentErr))
                errors = errors + 1
            else
                totalLoaded = totalLoaded + 1
            end
        end
        
        -- 2. Load Dialogues and Translations
        for _, dType in ipairs(dialogueTypes) do
            local baseDialoguePath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/DT_" .. id .. "_" .. dType
            
            -- Attempt base require (English/Default)
            if FileExists(baseDialoguePath) then
                local success, dErr = pcall(require, baseDialoguePath)
                if success then
                    if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Debug", "   >> Loaded " .. dType .. " (Base)") end
                    totalLoaded = totalLoaded + 1
                end
            end
            
            -- Attempt Translation loading
            for _, lang in ipairs(languages) do
                local transPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/Translations/" .. lang .. "/DT_" .. id .. "_" .. dType .. "_" .. lang
                
                if FileExists(transPath) then
                    local tSuccess, _ = pcall(require, transPath)
                    if tSuccess then
                        if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Debug", "   >> Loaded " .. dType .. " (" .. lang .. ")") end
                    end
                end
            end
        end

        -- 2b. Load Ambient Dialogues
        for _, statusType in ipairs(ambientDialogueStatuses) do
            local baseAmbientPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/Ambient/DT_" .. id .. "_Ambient_" .. statusType

            if FileExists(baseAmbientPath) then
                local success, _ = pcall(require, baseAmbientPath)
                if success then
                    if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Debug", "   >> Loaded Ambient " .. statusType .. " (Base)") end
                    totalLoaded = totalLoaded + 1
                end
            end

            for _, lang in ipairs(languages) do
                local transPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/Ambient/Translations/" .. lang .. "/DT_" .. id .. "_Ambient_" .. statusType .. "_" .. lang

                if FileExists(transPath) then
                    local tSuccess, _ = pcall(require, transPath)
                    if tSuccess then
                        if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Core", "Debug", "   >> Loaded Ambient " .. statusType .. " (" .. lang .. ")") end
                    end
                end
            end
        end
    end
    
    DynamicTrading.Log("DTCommons", "Core", "Init", "Dynamic Loading Complete. Total Modules: " .. totalLoaded .. " | Errors: " .. errors)
end
