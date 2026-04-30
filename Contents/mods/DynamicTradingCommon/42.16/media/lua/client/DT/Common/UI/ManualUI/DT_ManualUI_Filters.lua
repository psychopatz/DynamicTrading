require "ISUI/ISComboBox"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

DT_ManualUI_Filters = DT_ManualUI_Filters or {}
local Filters = DT_ManualUI_Filters

local AUDIENCE_LABELS = {
    dynamictradingcommon = "Dynamic Trading Common",
    dynamictrading = "Dynamic Trading V1",
    dynamictradingv1 = "Dynamic Trading V1",
    dynamictradingv2 = "Dynamic Trading V2",
    dynamiccolonies = "Dynamic Colonies",
    dt = "Dynamic Trading",
    dc = "Dynamic Colonies",
}

function Filters.NormalizeKey(value)
    return string.lower(tostring(value or "")):gsub("%s+", "")
end

local function isAllUpper(text)
    text = tostring(text or "")
    if text == "" then
        return false
    end

    return text == string.upper(text) and text:find("%a") ~= nil
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

local function capitalizeWord(word)
    word = tostring(word or "")

    if word == "" then
        return ""
    end

    if isAllUpper(word) and #word <= 5 then
        return word
    end

    local first = string.sub(word, 1, 1)
    local rest = string.sub(word, 2)

    return string.upper(first) .. string.lower(rest)
end

local function humanizeModID(value)
    local text = tostring(value or "")

    if text == "" then
        return "Unknown Mod"
    end

    if AUDIENCE_LABELS[Filters.NormalizeKey(text)] then
        return AUDIENCE_LABELS[Filters.NormalizeKey(text)]
    end

    text = text:gsub("_", " ")
    text = text:gsub("-", " ")
    text = splitCamelCase(text)

    local words = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(words, capitalizeWord(word))
    end

    if #words <= 0 then
        return tostring(value or "Unknown Mod")
    end

    return table.concat(words, " ")
end

function Filters.GetAudienceLabel(audience)
    local normalized = Filters.NormalizeKey(audience)
    return AUDIENCE_LABELS[normalized] or humanizeModID(audience)
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