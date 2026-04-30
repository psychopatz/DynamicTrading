require "ISUI/ISComboBox"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

DT_ManualUI_Filters = DT_ManualUI_Filters or {}
local Filters = DT_ManualUI_Filters

Filters.ModNameCache = Filters.ModNameCache or {}
Filters.CanonicalModIDCache = Filters.CanonicalModIDCache or {}

function Filters.NormalizeKey(value)
    return string.lower(tostring(value or "")):gsub("%s+", "")
end

local function isCallable(value)
    return type(value) == "function"
end

local function safeTrim(value)
    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function safeCall(callback)
    if not callback then
        return nil
    end

    local ok, result = pcall(callback)
    if ok then
        return result
    end

    return nil
end

local function getActiveMods()
    if getActivatedMods then
        local activated = safeCall(function()
            return getActivatedMods()
        end)

        if activated then
            return activated
        end
    end

    return nil
end

local function getActiveModCount(activeMods)
    if not activeMods then
        return 0
    end

    if activeMods.size then
        local count = safeCall(function()
            return activeMods:size()
        end)

        return math.max(0, math.floor(tonumber(count) or 0))
    end

    if type(activeMods) == "table" then
        return #activeMods
    end

    return 0
end

local function getActiveModAt(activeMods, index)
    if not activeMods then
        return nil
    end

    if activeMods.get then
        local value = safeCall(function()
            return activeMods:get(index)
        end)

        value = safeTrim(value)
        return value ~= "" and value or nil
    end

    if type(activeMods) == "table" then
        local value = safeTrim(activeMods[index + 1])
        return value ~= "" and value or nil
    end

    return nil
end

function Filters.GetCanonicalModID(modID)
    local raw = safeTrim(modID)

    if raw == "" then
        return ""
    end

    local normalized = Filters.NormalizeKey(raw)
    local cached = Filters.CanonicalModIDCache[normalized]
    if cached and cached ~= "" then
        return cached
    end

    local activeMods = getActiveMods()
    local count = getActiveModCount(activeMods)

    for index = 0, count - 1 do
        local activeID = getActiveModAt(activeMods, index)
        if activeID and Filters.NormalizeKey(activeID) == normalized then
            Filters.CanonicalModIDCache[normalized] = activeID
            return activeID
        end
    end

    Filters.CanonicalModIDCache[normalized] = raw
    return raw
end

local function getJavaStringValue(object, methodName)
    if not object or not methodName then
        return nil
    end

    local method = object[methodName]
    if not isCallable(method) then
        return nil
    end

    local value = safeCall(function()
        return method(object)
    end)

    value = safeTrim(value)
    return value ~= "" and value or nil
end

local function getTableStringValue(source, key)
    if type(source) ~= "table" then
        return nil
    end

    local value = safeTrim(source[key])
    return value ~= "" and value or nil
end

local function getRegisteredAudienceDisplayName(modID)
    local manuals = DynamicTrading and DynamicTrading.Manuals or nil
    local canonicalID = Filters.GetCanonicalModID(modID)
    local normalized = Filters.NormalizeKey(modID)
    local canonicalNormalized = Filters.NormalizeKey(canonicalID)

    if not manuals or normalized == "" then
        return nil
    end

    local registries = {
        manuals.AudienceDisplayNames,
        manuals.ModDisplayNames,
        manuals.RuntimeAudienceLabels,
        manuals.RuntimeAudienceNames,
    }

    for _, registry in ipairs(registries) do
        if type(registry) == "table" then
            local direct = safeTrim(registry[modID])
            if direct ~= "" then
                return direct
            end

            local canonical = safeTrim(registry[canonicalID])
            if canonical ~= "" then
                return canonical
            end

            local normalizedHit = safeTrim(registry[normalized])
            if normalizedHit ~= "" then
                return normalizedHit
            end

            local canonicalNormalizedHit = safeTrim(registry[canonicalNormalized])
            if canonicalNormalizedHit ~= "" then
                return canonicalNormalizedHit
            end
        end
    end

    if isCallable(manuals.GetAudienceDisplayName) then
        local result = safeCall(function()
            return manuals.GetAudienceDisplayName(canonicalID)
        end)

        result = safeTrim(result)
        if result ~= "" then
            return result
        end

        result = safeCall(function()
            return manuals.GetAudienceDisplayName(modID)
        end)

        result = safeTrim(result)
        if result ~= "" then
            return result
        end
    end

    if isCallable(manuals.GetModDisplayName) then
        local result = safeCall(function()
            return manuals.GetModDisplayName(canonicalID)
        end)

        result = safeTrim(result)
        if result ~= "" then
            return result
        end

        result = safeCall(function()
            return manuals.GetModDisplayName(modID)
        end)

        result = safeTrim(result)
        if result ~= "" then
            return result
        end
    end

    return nil
end

local function getPZModInfo(modID)
    local canonicalID = Filters.GetCanonicalModID(modID)
    local idsToTry = {
        canonicalID,
        safeTrim(modID),
    }

    local lookupFunctions = {
        "getModInfoByID",
        "getModInfo",
    }

    for _, id in ipairs(idsToTry) do
        if id and id ~= "" then
            for _, functionName in ipairs(lookupFunctions) do
                local lookup = _G and _G[functionName] or nil

                if isCallable(lookup) then
                    local info = safeCall(function()
                        return lookup(id)
                    end)

                    if info then
                        return info
                    end
                end
            end
        end
    end

    return nil
end

local function getPZModDisplayName(modID)
    local info = getPZModInfo(modID)

    if not info then
        return nil
    end

    local methodNames = {
        "getName",
        "getTitle",
        "getDisplayName",
    }

    for _, methodName in ipairs(methodNames) do
        local value = getJavaStringValue(info, methodName)
        if value then
            return value
        end
    end

    local tableKeys = {
        "name",
        "title",
        "displayName",
        "display_name",
    }

    for _, key in ipairs(tableKeys) do
        local value = getTableStringValue(info, key)
        if value then
            return value
        end
    end

    return nil
end

local function splitCamelCase(text)
    text = tostring(text or "")

    local result = ""
    local previous = ""

    for index = 1, #text do
        local current = string.sub(text, index, index)

        if index > 1
            and current:match("%u")
            and previous ~= ""
            and previous:match("[%l%d]") then
            result = result .. " "
        end

        result = result .. current
        previous = current
    end

    return result
end

local function isShortAcronym(word)
    word = tostring(word or "")

    if word == "" then
        return false
    end

    return #word <= 5 and word == string.upper(word) and word:find("%a") ~= nil
end

local function capitalizeWord(word)
    word = tostring(word or "")

    if word == "" then
        return ""
    end

    if isShortAcronym(word) then
        return word
    end

    local first = string.sub(word, 1, 1)
    local rest = string.sub(word, 2)

    return string.upper(first) .. string.lower(rest)
end

local function humanizeModID(modID)
    local canonicalID = Filters.GetCanonicalModID(modID)
    local text = safeTrim(canonicalID ~= "" and canonicalID or modID)

    if text == "" then
        return "Unknown Mod"
    end

    text = text:gsub("_", " ")
    text = text:gsub("-", " ")
    text = text:gsub("%.", " ")
    text = splitCamelCase(text)

    local words = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(words, capitalizeWord(word))
    end

    if #words <= 0 then
        return tostring(canonicalID ~= "" and canonicalID or modID or "Unknown Mod")
    end

    return table.concat(words, " ")
end

function Filters.GetModDisplayName(modID)
    local id = safeTrim(modID)

    if id == "" then
        return "Unknown Mod"
    end

    local canonicalID = Filters.GetCanonicalModID(id)
    local normalized = Filters.NormalizeKey(canonicalID ~= "" and canonicalID or id)

    local cached = Filters.ModNameCache[normalized]
    if cached and cached ~= "" then
        return cached
    end

    local resolved =
        getRegisteredAudienceDisplayName(id)
        or getPZModDisplayName(id)
        or humanizeModID(id)

    resolved = safeTrim(resolved)
    if resolved == "" then
        resolved = canonicalID ~= "" and canonicalID or id
    end

    Filters.ModNameCache[normalized] = resolved
    return resolved
end

function Filters.GetAudienceLabel(audience)
    return Filters.GetModDisplayName(audience)
end

function Filters.GetViewModeManuals(viewMode)
    local manualsAPI = DynamicTrading and DynamicTrading.Manuals or nil

    if not manualsAPI then
        return {}
    end

    local active = manualsAPI.GetActiveAudienceState and manualsAPI.GetActiveAudienceState() or nil
    local mode = tostring(viewMode or "manuals")

    if mode == "updates" and manualsAPI.GetOrderedUpdateManuals then
        return manualsAPI.GetOrderedUpdateManuals(active) or {}
    end

    if manualsAPI.GetOrderedLibraryManuals then
        return manualsAPI.GetOrderedLibraryManuals(active) or {}
    end

    if manualsAPI.GetOrderedManuals then
        return manualsAPI.GetOrderedManuals(active, mode == "updates" and "updates" or "manuals") or {}
    end

    local manuals = {}
    local registry = manualsAPI.Registry or {}

    for _, manual in pairs(registry) do
        local visible = true

        if manualsAPI.IsManualVisible then
            visible = manualsAPI.IsManualVisible(manual, active)
        end

        if visible then
            table.insert(manuals, manual)
        end
    end

    table.sort(manuals, function(left, right)
        local leftSort = tonumber(left and left.sortOrder) or 0
        local rightSort = tonumber(right and right.sortOrder) or 0

        if leftSort ~= rightSort then
            return leftSort < rightSort
        end

        local leftIndex = tonumber(left and left.orderIndex) or 0
        local rightIndex = tonumber(right and right.orderIndex) or 0

        if leftIndex ~= rightIndex then
            return leftIndex < rightIndex
        end

        return string.lower(tostring(left and left.title or "")) < string.lower(tostring(right and right.title or ""))
    end)

    return manuals
end

function Filters.BuildOptions(manuals)
    local options = {
        {
            key = "scope:all",
            mode = "scope",
            value = "all",
            label = "All Mods",
        }
    }

    local audienceSeen = {}

    for _, manual in ipairs(manuals or {}) do
        for _, audience in ipairs(type(manual and manual.audiences) == "table" and manual.audiences or {}) do
            local normalizedAudience = Filters.NormalizeKey(audience)

            if normalizedAudience ~= "" then
                audienceSeen[normalizedAudience] = audience
            end
        end
    end

    local audiences = {}
    for normalizedAudience, originalAudience in pairs(audienceSeen) do
        table.insert(audiences, {
            normalized = normalizedAudience,
            original = originalAudience,
            label = Filters.GetAudienceLabel(originalAudience),
        })
    end

    table.sort(audiences, function(left, right)
        return tostring(left.label or "") < tostring(right.label or "")
    end)

    for _, audience in ipairs(audiences) do
        table.insert(options, {
            key = "audience:" .. audience.normalized,
            mode = "audience",
            value = audience.normalized,
            label = audience.label,
        })
    end

    return options
end

function Filters.HasOptionKey(options, key)
    local target = tostring(key or "")

    if target == "" then
        return false
    end

    for _, option in ipairs(options or {}) do
        if tostring(option.key or "") == target then
            return true
        end
    end

    return false
end

function Filters.GetDefaultFilterKey(options)
    return "scope:all"
end

function Filters.EnsureValidFilterKey(key, options)
    if Filters.HasOptionKey(options, key) then
        return key
    end

    return Filters.GetDefaultFilterKey(options)
end

function Filters.ManualHasAudience(manual, audienceKey)
    local target = Filters.NormalizeKey(audienceKey)

    if target == "" then
        return false
    end

    for _, audience in ipairs(type(manual and manual.audiences) == "table" and manual.audiences or {}) do
        if Filters.NormalizeKey(audience) == target then
            return true
        end
    end

    return false
end

function Filters.MatchesFilter(manual, filterKey)
    local key = tostring(filterKey or "scope:all")

    if key == "" or key == "scope:all" then
        return true
    end

    local mode, value = key:match("^([^:]+):(.+)$")
    mode = tostring(mode or "")
    value = tostring(value or "")

    if mode == "audience" then
        return Filters.ManualHasAudience(manual, value)
    end

    return true
end

function Filters.Apply(manuals, filterKey)
    local filtered = {}

    for _, manual in ipairs(manuals or {}) do
        if Filters.MatchesFilter(manual, filterKey) then
            table.insert(filtered, manual)
        end
    end

    return filtered
end

function Filters.ContainsManual(manuals, manualId)
    local target = tostring(manualId or "")

    if target == "" then
        return false
    end

    for _, manual in ipairs(manuals or {}) do
        if tostring(manual and manual.id or "") == target then
            return true
        end
    end

    return false
end

function Filters.GetPreferredFilterKeyForManual(manual, options)
    if not manual then
        return nil
    end

    for _, audience in ipairs(type(manual.audiences) == "table" and manual.audiences or {}) do
        local audienceKey = "audience:" .. Filters.NormalizeKey(audience)

        if Filters.HasOptionKey(options, audienceKey) then
            return audienceKey
        end
    end

    return Filters.HasOptionKey(options, "scope:all") and "scope:all" or nil
end

local function clearCombo(combo)
    if not combo then
        return
    end

    if combo.clear then
        combo:clear()
        return
    end

    combo.options = {}
    combo.optionData = {}
    combo.selected = 1
end

local function setControlBounds(control, x, y, width, height)
    if not control then
        return
    end

    if control.setX then
        control:setX(x)
    else
        control.x = x
    end

    if control.setY then
        control:setY(y)
    else
        control.y = y
    end

    if control.setWidth then
        control:setWidth(width)
    else
        control.width = width
    end

    if control.setHeight then
        control:setHeight(height)
    else
        control.height = height
    end
end

if DT_ManualUI and not DT_ManualUI._manualFilterPatched then
    DT_ManualUI._manualFilterPatched = true

    local originalInitialise = DT_ManualUI.initialise
    function DT_ManualUI:initialise()
        if originalInitialise then
            originalInitialise(self)
        end

        self.manualFilterKey = self.manualFilterKey or nil
        self.manualFilterOptions = self.manualFilterOptions or {}
        self.manualFilterOptionKeys = self.manualFilterOptionKeys or {}
        self.allVisibleManuals = self.allVisibleManuals or {}
    end

    local originalCreateChildren = DT_ManualUI.createChildren
    function DT_ManualUI:createChildren()
        if originalCreateChildren then
            originalCreateChildren(self)
        end

        if self.manualFilterCombo then
            return
        end

        local metrics = DT_ManualUI_Utils.getLayoutMetrics(self)
        local filterWidth = math.min(math.max(170, math.floor((metrics.rightWidth or 300) * 0.34)), 260)

        self.manualFilterCombo = ISComboBox:new(
            metrics.rightX,
            metrics.searchBarY,
            filterWidth,
            metrics.toolbarHeight,
            self,
            self.onManualFilterComboChanged
        )
        self.manualFilterCombo:initialise()
        self.manualFilterCombo:instantiate()
        self:addChild(self.manualFilterCombo)

        self:refreshManualFilterCombo()
        self:refreshLayout()
    end

    local originalRefreshLayout = DT_ManualUI.refreshLayout
    function DT_ManualUI:refreshLayout()
        if originalRefreshLayout then
            originalRefreshLayout(self)
        end

        if not self.manualFilterCombo or not self.searchEntry or not self.btnSearch or not self.btnClear or not self.btnHome then
            return
        end

        local metrics = DT_ManualUI_Utils.getLayoutMetrics(self)
        local rightWidth = math.max(240, tonumber(metrics.rightWidth) or 240)
        local filterWidth = math.min(math.max(170, math.floor(rightWidth * 0.34)), 260)

        if rightWidth < 520 then
            filterWidth = math.min(190, math.max(140, math.floor(rightWidth * 0.38)))
        end

        local gap = 8
        local buttonsStartX = metrics.rightX + metrics.rightWidth - 160
        local searchX = metrics.rightX + filterWidth + gap
        local searchWidth = math.max(80, buttonsStartX - searchX - gap)

        setControlBounds(self.manualFilterCombo, metrics.rightX, metrics.searchBarY, filterWidth, metrics.toolbarHeight)
        setControlBounds(self.searchEntry, searchX, metrics.searchBarY, searchWidth, metrics.toolbarHeight)

        self.btnSearch:setX(metrics.rightX + metrics.rightWidth - 160)
        self.btnSearch:setY(metrics.searchBarY)
        self.btnClear:setX(metrics.rightX + metrics.rightWidth - 105)
        self.btnClear:setY(metrics.searchBarY)
        self.btnHome:setX(metrics.rightX + metrics.rightWidth - 50)
        self.btnHome:setY(metrics.searchBarY)
    end

    local originalLoadManualData = DT_ManualUI.loadManualData
    function DT_ManualUI:loadManualData()
        if originalLoadManualData then
            originalLoadManualData(self)
        end

        self.allVisibleManuals = Filters.GetViewModeManuals(self.viewMode)
        self.manualFilterOptions = Filters.BuildOptions(self.allVisibleManuals)
        self.manualFilterKey = Filters.EnsureValidFilterKey(self.manualFilterKey, self.manualFilterOptions)

        self:refreshManualFilterCombo()
        self:applyManualFilter(true)

        if self.refreshSupportBannerState then
            self:refreshSupportBannerState()
        end
    end

    local originalOpenLocation = DT_ManualUI.openLocation
    function DT_ManualUI:openLocation(args)
        args = args or {}

        local requestedFilterKey = args.manualFilterKey or args.filterKey

        if requestedFilterKey then
            self.manualFilterKey = Filters.EnsureValidFilterKey(requestedFilterKey, self.manualFilterOptions)
            self:applyManualFilter(true)
            self:refreshManualFilterCombo()
        elseif args.manualId and self.allManuals then
            local manual = self.allManuals[args.manualId]
            local preferredKey = Filters.GetPreferredFilterKeyForManual(manual, self.manualFilterOptions)

            if preferredKey
                and preferredKey ~= self.manualFilterKey
                and not Filters.ContainsManual(self.manuals, args.manualId) then
                self.manualFilterKey = preferredKey
                self:applyManualFilter(true)
                self:refreshManualFilterCombo()
            end
        end

        if originalOpenLocation then
            return originalOpenLocation(self, args)
        end

        return nil
    end

    function DT_ManualUI:applyManualFilter(preserveCurrent)
        self.manuals = Filters.Apply(self.allVisibleManuals or {}, self.manualFilterKey)

        if preserveCurrent == true then
            return
        end

        if self.currentManualId and not Filters.ContainsManual(self.manuals, self.currentManualId) then
            self.currentManualId = nil
            self.currentPageId = nil
            self.currentReleaseVersion = nil
            self.currentManualType = "manual"
            self.currentPopupVersion = ""
            self.highlightSectionId = nil
        end
    end

    function DT_ManualUI:refreshManualFilterCombo()
        local combo = self.manualFilterCombo

        if not combo then
            return
        end

        self._refreshingManualFilterCombo = true
        clearCombo(combo)

        self.manualFilterOptionKeys = {}
        local selectedIndex = 1
        local options = self.manualFilterOptions or {}

        if #options == 0 then
            options = {
                {
                    key = "scope:all",
                    label = "All Mods",
                }
            }
            self.manualFilterOptions = options
            self.manualFilterKey = "scope:all"
        end

        for index, option in ipairs(options) do
            combo:addOption(tostring(option.label or option.key or "Mod Filter"))
            self.manualFilterOptionKeys[index] = option.key

            if tostring(option.key or "") == tostring(self.manualFilterKey or "") then
                selectedIndex = index
            end
        end

        combo.selected = selectedIndex
        self._refreshingManualFilterCombo = false
    end

    function DT_ManualUI:onManualFilterComboChanged()
        if self._refreshingManualFilterCombo then
            return
        end

        local combo = self.manualFilterCombo
        local selectedIndex = tonumber(combo and combo.selected) or 1
        local key = self.manualFilterOptionKeys and self.manualFilterOptionKeys[selectedIndex] or nil

        if not key or key == self.manualFilterKey then
            return
        end

        self.manualFilterKey = key
        self:applyManualFilter(false)

        if self.refreshSupportBannerState then
            self:refreshSupportBannerState()
        end

        if self.refreshNavigation then
            self:refreshNavigation()
        end

        if self.searchEntry and self.searchEntry.getText and tostring(self.searchEntry:getText() or "") ~= "" then
            self:runSearch(self.searchEntry:getText())
        elseif self.refreshResults then
            self.results = {}
            self:refreshResults()
        end

        if self.refreshContent then
            self:refreshContent()
        end

        if self.refreshLayout then
            self:refreshLayout()
        end
    end
end

return Filters