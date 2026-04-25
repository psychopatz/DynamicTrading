-- =============================================================================
-- DYNAMIC TRADING: CORE INITIALIZATION
-- =============================================================================
-- This file ensures the global DynamicTrading table and its core registration
-- functions are defined BEFORE any subdirectory scripts auto-load alphabetically.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = DynamicTrading.Config or {}
DynamicTrading.Config.MasterList = DynamicTrading.Config.MasterList or {} 
DynamicTrading.Config.Tags = DynamicTrading.Config.Tags or {}
DynamicTrading.Config.NPCMovement = DynamicTrading.Config.NPCMovement or {
    walkSpeed = 0.06,
    runSpeed = 0.09
}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {
    Registry = {},
    Order = {},
    RegistrationCounter = 0,
    RuntimeAudienceFlags = {},
}

local function dtManualLower(value)
    return string.lower(tostring(value or ""))
end

local function dtManualContains(list, value)
    for _, existing in ipairs(list or {}) do
        if existing == value then
            return true
        end
    end
    return false
end

local function dtManualAddUnique(list, value)
    if value and value ~= "" and not dtManualContains(list, value) then
        table.insert(list, value)
    end
end

local function dtManualNormalizeAudience(value)
    local normalized = dtManualLower(value):gsub("%s+", "")
    if normalized == "" then
        return nil
    end
    if normalized == "all" or normalized == "shared" or normalized == "universal" then
        return "common"
    end
    if normalized == "dynamictrading" or normalized == "dtv1" then
        return "v1"
    end
    if normalized == "dynamictradingv2" or normalized == "dtv2" then
        return "v2"
    end
    if normalized == "dynamiccolonies" then
        return "colony"
    end
    return normalized
end

local function dtManualNormalizeAudienceList(id, data)
    local audiences = {}
    local raw = data.audiences or data.modules or data.targets or data.audience or data.module or data.target or data.version

    if type(raw) == "table" then
        for _, value in ipairs(raw) do
            dtManualAddUnique(audiences, dtManualNormalizeAudience(value))
        end
    elseif raw ~= nil then
        dtManualAddUnique(audiences, dtManualNormalizeAudience(raw))
    end

    if #audiences > 0 then
        return audiences
    end

    local normalizedId = dtManualLower(id)
    if string.sub(normalizedId, 1, 3) == "dc_" then
        return { "colony" }
    end
    if string.find(normalizedId, "v1", 1, true) then
        return { "v1" }
    end
    if string.find(normalizedId, "v2", 1, true) then
        return { "v2" }
    end
    return { "common" }
end

local function dtManualTokenizeVersion(value)
    local tokens = {}
    for part in string.gmatch(tostring(value or ""), "[%w]+") do
        local numeric = tonumber(part)
        table.insert(tokens, numeric ~= nil and numeric or dtManualLower(part))
    end
    return tokens
end

local function dtManualDefaultSortOrder(manualId, audiences, orderIndex, isWhatsNew)
    local primary = audiences and audiences[1] or "common"
    local base = 300000

    if primary == "v1" or primary == "v2" then
        base = 100000
    elseif primary == "colony" then
        base = 200000
    end

    if isWhatsNew == true or dtManualLower(manualId) == "dt_whats_new" then
        base = 0
    end

    return base + math.max(0, tonumber(orderIndex) or 0)
end

function DynamicTrading.Manuals.CompareReleaseVersions(left, right)
    local leftTokens = dtManualTokenizeVersion(left)
    local rightTokens = dtManualTokenizeVersion(right)
    local count = math.max(#leftTokens, #rightTokens)

    for index = 1, count do
        local leftValue = leftTokens[index]
        local rightValue = rightTokens[index]

        if leftValue == nil and rightValue == nil then
            return 0
        end
        if leftValue == nil then
            return -1
        end
        if rightValue == nil then
            return 1
        end

        if type(leftValue) == type(rightValue) then
            if leftValue < rightValue then
                return -1
            end
            if leftValue > rightValue then
                return 1
            end
        else
            local leftText = tostring(leftValue)
            local rightText = tostring(rightValue)
            if leftText < rightText then
                return -1
            end
            if leftText > rightText then
                return 1
            end
        end
    end

    return 0
end

function DynamicTrading.Manuals.GetActiveAudienceState()
    local active = {
        common = true,
        v1 = false,
        v2 = false,
        colony = false,
        currency = false,
    }
    local flags = DynamicTrading.Manuals.RuntimeAudienceFlags or {}

    local activated = getActivatedMods and getActivatedMods() or nil
    if activated and activated.contains then
        active.v1 = activated:contains("DynamicTrading") or flags.v1 == true
        active.v2 = activated:contains("DynamicTradingV2") or flags.v2 == true
        active.colony = activated:contains("DynamicColonies") or flags.colony == true
        active.currency = activated:contains("CurrencyExpanded") or flags.currency == true
    else
        active.v1 = flags.v1 == true
        active.v2 = flags.v2 == true
        active.colony = flags.colony == true
        active.currency = flags.currency == true
    end

    return active
end

function DynamicTrading.Manuals.MarkAudienceActive(audience, enabled)
    local normalized = dtManualNormalizeAudience(audience)
    if not normalized then
        return
    end

    local flags = DynamicTrading.Manuals.RuntimeAudienceFlags or {}
    DynamicTrading.Manuals.RuntimeAudienceFlags = flags

    if enabled == nil then
        flags[normalized] = true
    else
        flags[normalized] = enabled == true
    end
end

function DynamicTrading.Manuals.IsManualVisible(manual, active)
    if not manual then
        return false
    end

    if manual.hidden == true then
        return false
    end

    local audiences = manual.audiences or { "common" }
    active = active or DynamicTrading.Manuals.GetActiveAudienceState()

    for _, audience in ipairs(audiences) do
        if audience == "common" or audience == "all" then
            return true
        end
        if active[audience] == true then
            return true
        end
    end

    return false
end

function DynamicTrading.Manuals.IsUpdateManual(manual)
    return manual and (manual.isWhatsNew == true or manual.manualType == "whats_new")
end

function DynamicTrading.Manuals.GetOrderedManuals(active, viewMode)
    local registry = DynamicTrading.Manuals.Registry or {}
    local order = DynamicTrading.Manuals.Order or {}
    local manuals = {}
    local seen = {}

    local function tryInsert(manualId)
        local manual = registry[manualId]
        if not manual or seen[manualId] then
            return
        end
        seen[manualId] = true
        local isVisible = DynamicTrading.Manuals.IsManualVisible(manual, active)
        local isUpdate = DynamicTrading.Manuals.IsUpdateManual(manual)
        local matchesView = true

        if viewMode == "manuals" then
            matchesView = isUpdate ~= true and manual.showInLibrary ~= false
        elseif viewMode == "updates" then
            matchesView = isUpdate == true
        end

        if isVisible and matchesView then
            table.insert(manuals, manual)
        end
    end

    for _, manualId in ipairs(order) do
        tryInsert(manualId)
    end

    for manualId in pairs(registry) do
        tryInsert(manualId)
    end

    table.sort(manuals, function(a, b)
        local leftSort = tonumber(a.sortOrder) or 0
        local rightSort = tonumber(b.sortOrder) or 0
        if leftSort ~= rightSort then
            return leftSort < rightSort
        end

        local leftIndex = tonumber(a.orderIndex) or 0
        local rightIndex = tonumber(b.orderIndex) or 0
        if leftIndex ~= rightIndex then
            return leftIndex < rightIndex
        end

        return dtManualLower(a.title) < dtManualLower(b.title)
    end)

    return manuals
end

function DynamicTrading.Manuals.GetOrderedLibraryManuals(active)
    return DynamicTrading.Manuals.GetOrderedManuals(active, "manuals")
end

function DynamicTrading.Manuals.GetOrderedUpdateManuals(active)
    return DynamicTrading.Manuals.GetOrderedManuals(active, "updates")
end

function DynamicTrading.Manuals.GetDefaultManual(manuals)
    local fallback = nil

    for _, manual in ipairs(manuals or {}) do
        if not fallback then
            fallback = manual
        end
        if manual.isWhatsNew ~= true then
            return manual
        end
    end

    return fallback
end

function DynamicTrading.Manuals.GetLatestWhatsNewManual(active)
    local latest = nil

    for _, manual in ipairs(DynamicTrading.Manuals.GetOrderedUpdateManuals(active)) do
        local isCandidate = manual and (manual.manualType == "whats_new" or manual.isWhatsNew == true or manual.autoOpenOnUpdate == true)
        if isCandidate then
            local manualVersion = tostring(manual.popupVersion or manual.releaseVersion or "")
            if not latest then
                latest = manual
            else
                local latestVersion = tostring(latest.popupVersion or latest.releaseVersion or "")
                local compare = DynamicTrading.Manuals.CompareReleaseVersions(manualVersion, latestVersion)
                if compare > 0 or (compare == 0 and (tonumber(manual.sortOrder) or 0) < (tonumber(latest.sortOrder) or 0)) then
                    latest = manual
                end
            end
        end
    end

    return latest
end

function DynamicTrading.Manuals.GetLatestManualByType(manualType, active)
    local latest = nil
    local registry = DynamicTrading.Manuals.Registry or {}
    local normalizedType = dtManualLower(manualType)

    for _, manual in pairs(registry) do
        if manual and dtManualLower(manual.manualType) == normalizedType and DynamicTrading.Manuals.IsManualVisible(manual, active) then
            if not latest then
                latest = manual
            else
                local leftVersion = tostring(manual.popupVersion or manual.releaseVersion or "")
                local rightVersion = tostring(latest.popupVersion or latest.releaseVersion or "")
                local compare = DynamicTrading.Manuals.CompareReleaseVersions(leftVersion, rightVersion)
                if compare > 0 or (compare == 0 and (tonumber(manual.sortOrder) or 0) < (tonumber(latest.sortOrder) or 0)) then
                    latest = manual
                end
            end
        end
    end

    return latest
end

-- CORE MODULES
require "DT/Common/DT_Logger"
require "DT/Common/Pricing/DT_PriceConfig"


-- 0. CUSTOM SIGNALS
-- Definitions for custom events to handle engine simulation phases.
-- Added to LuaEventManager so other modules can hook via Events.OnDynamicTrading...
if LuaEventManager then
    if not LuaEventManager.OnDynamicTradingDailySimulation then
        LuaEventManager.AddEvent("OnDynamicTradingDailySimulation")
    end
    if not LuaEventManager.OnDynamicTradingHourlyTick then
        LuaEventManager.AddEvent("OnDynamicTradingHourlyTick")
    end
    -- UI & Network Sync Events
    if not LuaEventManager.OnDynamicTradingTraderUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingTraderUpdated")
    end
    if not LuaEventManager.OnDynamicTradingFactionUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingFactionUpdated")
    end
    if not LuaEventManager.OnDynamicTradingStockUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingStockUpdated")
    end
    if not LuaEventManager.OnDynamicTradingTradeCompleted then
        LuaEventManager.AddEvent("OnDynamicTradingTradeCompleted")
    end
    if not LuaEventManager.OnDynamicTradingPriceConfigUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingPriceConfigUpdated")
    end
    if not LuaEventManager.OnDynamicTradingPriceConfigActionResult then
        LuaEventManager.AddEvent("OnDynamicTradingPriceConfigActionResult")
    end
    if not LuaEventManager.OnDynamicTradingLogsUpdated then
        LuaEventManager.AddEvent("OnDynamicTradingLogsUpdated")
    end
end

-- 1. STATIC CONFIGURATION (Commonly referenced)

DynamicTrading.Config.RadioTiers = {
    ["Base.WalkieTalkie1"]          = { power = 0.5, capacity = 1, desc = "Weak Signal (Toy)" },
    ["Base.WalkieTalkieMakeShift"]  = { power = 0.6, capacity = 1, desc = "Weak Signal (Makeshift)" },
    ["Base.WalkieTalkie2"]          = { power = 0.8, capacity = 2, desc = "Average Signal" },
    ["Base.WalkieTalkie3"]          = { power = 1.0, capacity = 3, desc = "Good Signal" },
    ["Base.WalkieTalkie4"]          = { power = 1.2, capacity = 4, desc = "Strong Signal" },
    ["Base.WalkieTalkie5"]          = { power = 1.5, capacity = 5, desc = "Military Grade" },
    ["Base.HamRadioMakeShift"]      = { power = 1.2, capacity = 8, desc = "Stationary (Makeshift)" },
    ["Base.HamRadio1"]              = { power = 1.5, capacity = 12, desc = "Stationary (Premium)" },
    ["Base.HamRadio2"]              = { power = 2.0, capacity = 20, desc = "Stationary (Military)" },
    ["Base.ManPackRadio"]           = { power = 1.5, capacity = 10, desc = "Military Manpack" }
}

function DynamicTrading.GetNPCWalkSpeed()
    local movement = DynamicTrading.Config and DynamicTrading.Config.NPCMovement
    return (movement and movement.walkSpeed) or 0.06
end

function DynamicTrading.GetNPCRunSpeed()
    local movement = DynamicTrading.Config and DynamicTrading.Config.NPCMovement
    return (movement and movement.runSpeed) or 0.09
end

-- 2. REGISTRATION API

function DynamicTrading.RegisterTag(tag, data)
    if not tag or not data then return end
    if not data.priceMult then data.priceMult = 1.0 end
    if not data.weight then data.weight = 50 end
    DynamicTrading.Config.Tags[tag] = data
end

function DynamicTrading.RegisterArchetype(id, data)
    if not id or not data then return end
    data.name = data.name or id
    data.allocations = data.allocations or {} 
    data.wants = data.wants or {} 
    data.forbid = data.forbid or {} 
    DynamicTrading.Archetypes[id] = data
end

function DynamicTrading.AddItem(uniqueID, data)
    if not uniqueID or not data then return end
    if not data.basePrice then data.basePrice = 10 end
    if not data.tags then data.tags = { "Misc" } end
    local hasValid = false
    for _, t in ipairs(data.tags) do if t then hasValid = true break end end
    if not hasValid then table.insert(data.tags, "Misc") end
    if not data.stockRange then data.stockRange = {min=1, max=5} end
    DynamicTrading.Config.MasterList[uniqueID] = data
    DynamicTrading.Config.ItemRegistryRevision = (tonumber(DynamicTrading.Config.ItemRegistryRevision) or 0) + 1
    if DynamicTrading.ItemUsabilityRanker and DynamicTrading.ItemUsabilityRanker.Invalidate then
        DynamicTrading.ItemUsabilityRanker.Invalidate("item_registry_changed")
    end
    if isDebugEnabled() then
        DynamicTrading.Log("DTCommons", "Init", "Item", "Registered Item: " .. tostring(uniqueID))
    end
end

function DynamicTrading.RegisterManual(id, data)
    if not id or type(data) ~= "table" then
        return
    end

    local existing = DynamicTrading.Manuals.Registry[id]
    if not existing then
        DynamicTrading.Manuals.RegistrationCounter = (DynamicTrading.Manuals.RegistrationCounter or 0) + 1
    end

    local orderIndex = existing and existing.orderIndex or DynamicTrading.Manuals.RegistrationCounter
    local audiences = dtManualNormalizeAudienceList(id, data)
    local isWhatsNew = data.isWhatsNew == true or data.is_whats_new == true
    local sortOrder = tonumber(data.sortOrder or data.sort_order)
    local manualType = dtManualLower(data.manualType or data.manual_type or data.type or "")
    local popupVersion = tostring(data.popupVersion or data.popup_version or data.releaseVersion or data.release_version or "")

    if manualType == "" then
        if isWhatsNew then
            manualType = "whats_new"
        else
            manualType = "manual"
        end
    end

    local chapters = {}
    for _, chapter in ipairs(type(data.chapters) == "table" and data.chapters or {}) do
        table.insert(chapters, {
            id = chapter.id,
            title = chapter.title,
            description = chapter.description,
        })
    end

    local pages = {}
    for _, page in ipairs(type(data.pages) == "table" and data.pages or {}) do
        local blocks = {}
        for _, block in ipairs(type(page.blocks) == "table" and page.blocks or {}) do
            table.insert(blocks, block)
        end

        table.insert(pages, {
            id = page.id,
            chapterId = page.chapterId or page.chapter_id,
            title = page.title,
            keywords = type(page.keywords) == "table" and page.keywords or {},
            blocks = blocks,
        })
    end

    local manual = {
        id = tostring(id),
        title = tostring(data.title or id),
        description = tostring(data.description or ""),
        icon = data.icon,
        startPageId = data.startPageId or data.start_page_id,
        chapters = chapters,
        pages = pages,
        audiences = audiences,
        sortOrder = sortOrder or dtManualDefaultSortOrder(id, audiences, orderIndex, isWhatsNew),
        orderIndex = orderIndex,
        releaseVersion = tostring(data.releaseVersion or data.release_version or ""),
        popupVersion = popupVersion,
        autoOpenOnUpdate = data.autoOpenOnUpdate == true or data.auto_open_on_update == true,
        isWhatsNew = isWhatsNew,
        manualType = manualType,
        showInLibrary = data.showInLibrary ~= false and data.show_in_library ~= false and isWhatsNew ~= true,
        bannerTitle = tostring(data.bannerTitle or data.banner_title or ""),
        bannerText = tostring(data.bannerText or data.banner_text or ""),
        bannerActionLabel = tostring(data.bannerActionLabel or data.banner_action_label or ""),
        supportUrl = tostring(data.supportUrl or data.support_url or ""),
        source = data.source,
    }

    DynamicTrading.Manuals.Registry[id] = manual

    local alreadyTracked = false
    for _, existingId in ipairs(DynamicTrading.Manuals.Order) do
        if existingId == id then
            alreadyTracked = true
            break
        end
    end

    if not alreadyTracked then
        table.insert(DynamicTrading.Manuals.Order, id)
    end
end

function DynamicTrading.GetMasterListCount()
    local count = 0
    if DynamicTrading.Config and DynamicTrading.Config.MasterList then
        for _ in pairs(DynamicTrading.Config.MasterList) do count = count + 1 end
    end
    return count
end

DynamicTrading.Log("DTCommons", "Init", "Core", "Core initialized. Items Registered so far: " .. DynamicTrading.GetMasterListCount())
