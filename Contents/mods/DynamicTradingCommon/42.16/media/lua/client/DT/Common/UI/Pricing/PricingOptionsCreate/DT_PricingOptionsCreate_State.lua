local CreateInternal = DT_PricingOptionsCreateInternal

function CreateInternal.NewBox(panel, x, y, width, height, alpha)
    local box = ISPanel:new(x, y, width, height)
    box:initialise()
    box:instantiate()
    box.backgroundColor = { r = 0, g = 0, b = 0, a = alpha or 0.18 }
    box.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
    panel:addChild(box)
    return box
end

function CreateInternal.NewState(owner, panel)
    local state
    local storedCollapsed

    state = {
        owner = owner,
        panel = panel,
        collapsed = {},
        selectedTag = DT_ConfigManager and DT_ConfigManager.getPriceEditorSelection and DT_ConfigManager.getPriceEditorSelection() or nil,
        selectedItemKey = nil,
        nodeMap = {},
        rootTags = {},
        displayNameCache = {},
        resultRows = {},
        searchOverflowCount = 0
    }

    storedCollapsed = DT_ConfigManager and DT_ConfigManager.getPriceCollapsedTags and DT_ConfigManager.getPriceCollapsedTags() or {}
    for _, tag in ipairs(storedCollapsed) do
        state.collapsed[tag] = true
    end

    return state
end
