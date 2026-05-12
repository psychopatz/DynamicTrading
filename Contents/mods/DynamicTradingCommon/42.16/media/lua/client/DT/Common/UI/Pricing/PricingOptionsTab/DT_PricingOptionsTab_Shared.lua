local Internal = DT_PricingOptionsTabInternal

Internal.MAX_SEARCH_RESULTS = 25
Internal.PREVIEW_SAMPLE_COUNT = 5

function Internal.trim(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

function Internal.lower(value)
    return string.lower(tostring(value or ""))
end

function Internal.formatMultiplier(value)
    return string.format("x%.3f", tonumber(value) or 1.0)
end

function Internal.formatPrice(value)
    return tostring(math.floor((tonumber(value) or 0) + 0.5))
end

function Internal.sortStrings(left, right)
    return Internal.lower(left) < Internal.lower(right)
end

function Internal.getDepth(tag)
    local _, count

    if not tag or tag == "" then
        return 0
    end

    _, count = string.gsub(tag, "%.", "")
    return count
end

function Internal.getItemDisplayName(itemKey, itemData, cache)
    local displayName
    local scriptItem

    cache = cache or {}
    if cache[itemKey] ~= nil then
        return cache[itemKey]
    end

    displayName = itemKey
    if itemData and itemData.item then
        scriptItem = getScriptManager():getItem(itemData.item)
        if scriptItem and scriptItem:getDisplayName() then
            displayName = scriptItem:getDisplayName()
        end
    end

    cache[itemKey] = displayName
    return displayName
end

function Internal.persistTreeState(state)
    local collapsed = {}
    local tag
    local isCollapsed

    for tag, isCollapsed in pairs(state.collapsed or {}) do
        if isCollapsed then
            collapsed[#collapsed + 1] = tag
        end
    end
    table.sort(collapsed, Internal.sortStrings)

    if DT_ConfigManager and DT_ConfigManager.setPriceCollapsedTags then
        DT_ConfigManager.setPriceCollapsedTags(collapsed)
    end
    if DT_ConfigManager and DT_ConfigManager.setPriceEditorSelection then
        DT_ConfigManager.setPriceEditorSelection(state.selectedTag or "")
    end
end

function Internal.setStatus(state, text, isError)
    if not state.statusLabel then
        return
    end

    state.statusLabel:setName(tostring(text or ""))
    if isError then
        state.statusLabel:setColor(1, 0.45, 0.45)
    else
        state.statusLabel:setColor(0.75, 0.85, 0.75)
    end
end

function Internal.sendPriceCommand(command, args)
    local player = getPlayer and getPlayer() or nil

    if not player and getSpecificPlayer then
        player = getSpecificPlayer(0)
    end
    if not player then
        return false
    end

    sendClientCommand(player, "DynamicTrading", command, args or {})
    return true
end

function Internal.relayoutScrollWidget(widget)
    local width
    local height
    local scrollW

    if not widget then
        return
    end

    width = widget.getWidth and widget:getWidth() or widget.width or 0
    height = widget.getHeight and widget:getHeight() or widget.height or 0

    if widget.vscroll then
        scrollW = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 13
        if widget.vscroll.setX then
            widget.vscroll:setX(math.max(0, width - scrollW))
        end
        if widget.vscroll.setY then
            widget.vscroll:setY(0)
        end
        if widget.vscroll.setHeight then
            widget.vscroll:setHeight(height)
        end
    end
end

function Internal.relayoutRichText(widget)
    if not widget then
        return
    end

    Internal.relayoutScrollWidget(widget)
    if widget.paginate then
        widget:paginate()
    end
end
