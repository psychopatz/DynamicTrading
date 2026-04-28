-- =============================================================================
-- 2. ARCHETYPE REGISTRY
-- =============================================================================
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}
DynamicTrading.Config = DynamicTrading.Config or {}
DynamicTrading.Config.ArchetypeList = DynamicTrading.Config.ArchetypeList or {}
DynamicTrading.RosterPoolEntries = DynamicTrading.RosterPoolEntries or {}

local function containsValue(list, target)
    for _, value in ipairs(list or {}) do
        if value == target then
            return true
        end
    end
    return false
end

local function appendUnique(list, value)
    if type(value) ~= "string" or value == "" then
        return
    end

    if not containsValue(list, value) then
        table.insert(list, value)
    end
end

local function normalizeFactionList(list)
    if type(list) ~= "table" then
        return nil
    end

    local normalized = {}
    for _, factionID in ipairs(list) do
        appendUnique(normalized, factionID)
    end

    if #normalized == 0 then
        return nil
    end

    return normalized
end

local function normalizeStringList(list)
    if type(list) == "string" then
        list = { list }
    end

    if type(list) ~= "table" then
        return nil
    end

    local normalized = {}
    local seen = {}

    for _, value in ipairs(list) do
        local text = tostring(value or "")
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
        if text ~= "" then
            local key = string.lower(text)
            if not seen[key] then
                seen[key] = true
                normalized[#normalized + 1] = text
            end
        end
    end

    if #normalized == 0 then
        return nil
    end

    return normalized
end

local function resolveArchetypeData(idOrData)
    if type(idOrData) == "table" then
        return idOrData
    end

    if type(idOrData) == "string" and DynamicTrading.Archetypes then
        return DynamicTrading.Archetypes[idOrData]
    end

    return nil
end

local function normalizeArchetypeText(value)
    local text = string.lower(tostring(value or ""))
    text = string.gsub(text, "[%s%-%_]+", "")
    return text
end

local function collectArchetypeHints(idOrData)
    local hints = {}
    local seen = {}

    local function push(value)
        local normalized = normalizeArchetypeText(value)
        if normalized ~= "" and not seen[normalized] then
            seen[normalized] = true
            hints[#hints + 1] = normalized
        end
    end

    local data = resolveArchetypeData(idOrData)
    if type(idOrData) == "string" then
        push(idOrData)
    elseif type(idOrData) == "table" then
        push(idOrData.id)
        push(idOrData.archetypeID)
        push(idOrData.archetype)
        push(idOrData.occupation)
        push(idOrData.role)
        push(idOrData.name)
    end

    if type(data) == "table" and data ~= idOrData then
        push(data.id)
        push(data.name)
    end

    return hints, data
end

local function normalizeRosterPoolEntry(id, data)
    if type(data) ~= "table" then
        return nil
    end

    local archetypeID = data.archetypeID or data.archetype
    if type(archetypeID) ~= "string" or archetypeID == "" then
        return nil
    end

    local normalized = {
        id = id or data.id or archetypeID,
        archetypeID = archetypeID,
        minCount = math.max(0, math.floor(tonumber(data.minCount or data.count or 1) or 0)),
        priority = math.floor(tonumber(data.priority) or 100)
    }

    if type(data.factionID) == "string" and data.factionID ~= "" then
        normalized.allowedFactions = { data.factionID }
    else
        normalized.allowedFactions = normalizeFactionList(data.allowedFactions)
    end

    return normalized
end

local function normalizeArchetypeSpecialization(id, data)
    if type(data) ~= "table" then
        return nil
    end

    local source = type(data.specialization) == "table" and data.specialization or nil
    local spec = nil

    if source then
        spec = {}
        for key, value in pairs(source) do
            spec[key] = value
        end
    end

    if type(data.specialTradeProfile) == "string" and data.specialTradeProfile ~= "" then
        spec = spec or {}
        spec.role = spec.role or data.specialTradeProfile
    end

    if data.contactReputationRequired ~= nil then
        spec = spec or {}
        spec.contactReputationRequired = data.contactReputationRequired
    end

    if data.neverRecruitable == true then
        spec = spec or {}
        spec.neverRecruitable = true
    end

    if type(data.stockSourceArchetypeID) == "string" and data.stockSourceArchetypeID ~= "" then
        spec = spec or {}
        spec.stockSourceArchetypeID = data.stockSourceArchetypeID
    end

    if data.inventoryStockKeywords ~= nil then
        spec = spec or {}
        spec.inventoryStockKeywords = data.inventoryStockKeywords
    end

    if data.fallbackStockKeywords ~= nil then
        spec = spec or {}
        spec.fallbackStockKeywords = data.fallbackStockKeywords
    end

    if data.rosterPool ~= nil then
        spec = spec or {}
        spec.rosterPool = data.rosterPool
    end

    if not spec then
        return nil
    end

    spec.id = tostring(spec.id or id or data.id or data.name or spec.role or "SpecializedArchetype")
    spec.role = tostring(spec.role or spec.id)

    if spec.contactReputationRequired ~= nil then
        spec.contactReputationRequired = math.max(0, tonumber(spec.contactReputationRequired) or 0)
    end

    spec.neverRecruitable = spec.neverRecruitable == true
    spec.stockSourceArchetypeID = type(spec.stockSourceArchetypeID) == "string"
            and spec.stockSourceArchetypeID ~= ""
            and spec.stockSourceArchetypeID
        or tostring(id or data.id or "General")
    spec.inventoryStockKeywords = normalizeStringList(spec.inventoryStockKeywords)
    spec.fallbackStockKeywords = normalizeStringList(spec.fallbackStockKeywords or spec.inventoryStockKeywords)
    spec.mergeLiveInventoryStock = spec.mergeLiveInventoryStock ~= false and spec.inventoryStockKeywords ~= nil

    if type(spec.rosterPool) == "table" then
        local rosterPool = {}
        for key, value in pairs(spec.rosterPool) do
            rosterPool[key] = value
        end
        rosterPool.archetypeID = rosterPool.archetypeID or tostring(id or data.id or "General")
        rosterPool.allowedFactions = rosterPool.allowedFactions or data.allowedFactions
        rosterPool.factionID = rosterPool.factionID or data.preferredFactionID
        spec.rosterPool = normalizeRosterPoolEntry(spec.id .. "_RosterPool", rosterPool)
    else
        spec.rosterPool = nil
    end

    return spec
end

function DynamicTrading.RegisterArchetypeModule(id)
    appendUnique(DynamicTrading.Config.ArchetypeList, id)
end

function DynamicTrading.RegisterRosterPoolEntry(id, data)
    local normalized = normalizeRosterPoolEntry(id, data)
    if not normalized then
        return
    end

    DynamicTrading.RosterPoolEntries[normalized.id] = normalized
end

function DynamicTrading.GetRosterPoolEntriesForFaction(factionID)
    local entries = {}
    local targetFactionID = tostring(factionID or "Independent")

    for _, entry in pairs(DynamicTrading.RosterPoolEntries or {}) do
        local allowedFactions = entry.allowedFactions
        local isAllowedFaction = true

        if type(allowedFactions) == "table" and #allowedFactions > 0 then
            isAllowedFaction = containsValue(allowedFactions, targetFactionID)
        end

        if isAllowedFaction
            and (not DynamicTrading.IsArchetypeAllowedForFaction
                or DynamicTrading.IsArchetypeAllowedForFaction(entry.archetypeID, targetFactionID)) then
            table.insert(entries, entry)
        end
    end

    table.sort(entries, function(a, b)
        if a.priority == b.priority then
            return tostring(a.id) < tostring(b.id)
        end
        return a.priority < b.priority
    end)

    return entries
end

function DynamicTrading.GetArchetypeData(id)
    return resolveArchetypeData(id)
end

function DynamicTrading.GetArchetypePreferredFaction(id)
    local data = DynamicTrading.GetArchetypeData(id)
    if not data then
        return nil
    end

    if type(data.preferredFactionID) == "string" and data.preferredFactionID ~= "" then
        return data.preferredFactionID
    end

    if type(data.allowedFactions) == "table" and data.allowedFactions[1] then
        return data.allowedFactions[1]
    end

    return nil
end

function DynamicTrading.GetArchetypeFactionWealthFloor(id)
    local data = DynamicTrading.GetArchetypeData(id)
    local minWealth = data and tonumber(data.minFactionWealth) or 0
    if minWealth < 0 then
        minWealth = 0
    end

    return math.floor(minWealth)
end

function DynamicTrading.IsArchetypeAllowedForFaction(id, factionID)
    local data = DynamicTrading.GetArchetypeData(id)
    local allowedFactions = data and data.allowedFactions or nil

    if type(allowedFactions) ~= "table" or #allowedFactions == 0 then
        return true
    end

    local targetFactionID = tostring(factionID or "Independent")
    for _, allowedID in ipairs(allowedFactions) do
        if allowedID == targetFactionID then
            return true
        end
    end

    return false
end

function DynamicTrading.IsArchetypeBuyTabEnabled(idOrData)
    local data = resolveArchetypeData(idOrData)
    return not (data and data.disableBuyTab == true)
end

function DynamicTrading.IsArchetypeSellTabEnabled(idOrData)
    local data = resolveArchetypeData(idOrData)
    return not (data and data.disableSellTab == true)
end

function DynamicTrading.IsArchetypeWildcardStockEnabled(idOrData)
    local data = resolveArchetypeData(idOrData)
    return not (data and data.disableWildcardStock == true)
end

function DynamicTrading.GetArchetypeSpecialization(idOrData)
    local data = resolveArchetypeData(idOrData)
    if type(data) == "table" and type(data.specialization) == "table" then
        return data.specialization
    end
    return nil
end

function DynamicTrading.GetArchetypeStockSourceID(idOrData, defaultValue)
    local specialization = DynamicTrading.GetArchetypeSpecialization(idOrData)
    if specialization and type(specialization.stockSourceArchetypeID) == "string" and specialization.stockSourceArchetypeID ~= "" then
        return specialization.stockSourceArchetypeID
    end
    return tostring(defaultValue or (type(idOrData) == "string" and idOrData) or "General")
end

function DynamicTrading.GetArchetypeInventoryStockKeywords(idOrData)
    local specialization = DynamicTrading.GetArchetypeSpecialization(idOrData)
    return specialization and specialization.inventoryStockKeywords or nil
end

function DynamicTrading.GetArchetypeFallbackStockKeywords(idOrData)
    local specialization = DynamicTrading.GetArchetypeSpecialization(idOrData)
    return specialization and specialization.fallbackStockKeywords or nil
end

function DynamicTrading.IsLotteryAgent(idOrData)
    local hints, data = collectArchetypeHints(idOrData)
    local specialization = DynamicTrading.GetArchetypeSpecialization(data or idOrData)
    if specialization and tostring(specialization.role or "") == "lottery" then
        return true
    end

    if type(data) == "table" and data.specialTradeProfile == "lottery" then
        return true
    end

    for _, hint in ipairs(hints) do
        if string.find(hint, "lottery", 1, true) or string.find(hint, "lotto", 1, true) then
            return true
        end
    end

    return false
end

function DynamicTrading.GetArchetypeContactRequiredReputation(idOrData, defaultValue)
    local _, data = collectArchetypeHints(idOrData)
    local specialization = DynamicTrading.GetArchetypeSpecialization(data or idOrData)
    if type(specialization) == "table" and specialization.contactReputationRequired ~= nil then
        return math.max(0, tonumber(specialization.contactReputationRequired) or 0)
    end

    if type(data) == "table" and data.contactReputationRequired ~= nil then
        return math.max(0, tonumber(data.contactReputationRequired) or 0)
    end

    if DynamicTrading.IsLotteryAgent(idOrData) then
        return 0
    end

    return math.max(0, tonumber(defaultValue) or 0)
end

function DynamicTrading.IsArchetypeNeverRecruitable(idOrData)
    local _, data = collectArchetypeHints(idOrData)
    local specialization = DynamicTrading.GetArchetypeSpecialization(data or idOrData)
    if type(specialization) == "table" and specialization.neverRecruitable == true then
        return true
    end

    if type(data) == "table" and data.neverRecruitable == true then
        return true
    end

    return DynamicTrading.IsLotteryAgent(idOrData)
end

-- The Core Function: Preserves your ID schema
function DynamicTrading.RegisterArchetype(id, data)
    if not id then 
        DynamicTrading.Log("DTCommons", "Core", "Error", "Archetype registered without ID.")
        return 
    end
    if not data then return end
    
    -- Ensure the ID is inside the data table too, just in case,
    -- but primarily use it as the Table Key for lookups.
    data.id = id
    data.name = data.name or id
    data.allocations = type(data.allocations) == "table" and data.allocations or {}
    data.expertTags = type(data.expertTags) == "table" and data.expertTags or {}
    data.wants = type(data.wants) == "table" and data.wants or {}
    data.forbid = type(data.forbid) == "table" and data.forbid or {}
    data.allowedFactions = normalizeFactionList(data.allowedFactions)

    if type(data.preferredFactionID) == "string" and data.preferredFactionID ~= "" then
        data.allowedFactions = data.allowedFactions or {}
        appendUnique(data.allowedFactions, data.preferredFactionID)
    end

    data.minFactionWealth = math.max(0, math.floor(tonumber(data.minFactionWealth) or 0))
    data.specialization = normalizeArchetypeSpecialization(id, data)
    if data.specialization and data.specialization.contactReputationRequired ~= nil and data.contactReputationRequired == nil then
        data.contactReputationRequired = data.specialization.contactReputationRequired
    end
    if data.specialization and data.specialization.neverRecruitable == true then
        data.neverRecruitable = true
    end
    if data.contactReputationRequired ~= nil then
        data.contactReputationRequired = math.max(0, tonumber(data.contactReputationRequired) or 0)
    end
    data.neverRecruitable = data.neverRecruitable == true
    data.disableBuyTab = data.disableBuyTab == true
    data.disableSellTab = data.disableSellTab == true
    data.disableWildcardStock = data.disableWildcardStock == true

    DynamicTrading.RegisterArchetypeModule(id)
    DynamicTrading.Archetypes[id] = data
    if data.specialization and data.specialization.rosterPool then
        DynamicTrading.RegisterRosterPoolEntry(data.specialization.rosterPool.id, data.specialization.rosterPool)
    end
    
    DynamicTrading.Log("DTCommons", "Core", "Info", "Registered Archetype: " .. id)
end
