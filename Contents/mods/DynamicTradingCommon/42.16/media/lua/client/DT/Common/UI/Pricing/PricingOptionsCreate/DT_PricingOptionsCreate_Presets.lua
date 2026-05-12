local Internal = DT_PricingOptionsTabInternal
local CreateInternal = DT_PricingOptionsCreateInternal

function CreateInternal.GetKnownPresetNames(state)
    local names = {}
    local seen = {}

    local function add(name)
        local text = Internal.trim(name)
        if text == "" or seen[text] then
            return
        end
        seen[text] = true
        names[#names + 1] = text
    end

    if DT_ConfigManager and DT_ConfigManager.getKnownPricePresets then
        for _, name in ipairs(DT_ConfigManager.getKnownPricePresets() or {}) do
            add(name)
        end
    end

    if DT_ConfigManager and DT_ConfigManager.getLastPricePresetName then
        add(DT_ConfigManager.getLastPricePresetName())
    end

    if state and state.presetEntry then
        add(state.presetEntry:getText())
    end

    if #names == 0 then
        add("default")
    end

    table.sort(names, Internal.sortStrings)
    return names
end

function CreateInternal.RefreshPresetSelector(state, preferredName)
    local names
    local desired
    local selectedIndex
    local index
    local name

    if not state or not state.presetCombo then
        return
    end

    names = CreateInternal.GetKnownPresetNames(state)
    state.presetCombo:clear()
    for _, name in ipairs(names) do
        state.presetCombo:addOption(name)
    end

    desired = Internal.trim(preferredName or (state.presetEntry and state.presetEntry:getText()) or "")
    selectedIndex = 1
    for index, name in ipairs(names) do
        if name == desired then
            selectedIndex = index
            break
        end
    end
    state.presetCombo.selected = selectedIndex
end

function CreateInternal.GetSelectedPresetName(state)
    local selected

    if not state or not state.presetCombo then
        return ""
    end

    selected = state.presetCombo.selected or 1
    if state.presetCombo.getOptionText then
        return Internal.trim(state.presetCombo:getOptionText(selected) or "")
    end
    return ""
end
