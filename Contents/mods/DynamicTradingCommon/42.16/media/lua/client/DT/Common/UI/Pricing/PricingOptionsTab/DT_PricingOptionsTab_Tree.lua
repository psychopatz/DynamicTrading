local Internal = DT_PricingOptionsTabInternal

local function buildBranchStats()
    local stats = {}
    local masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}
    local itemKey
    local itemData
    local seen
    local tag
    local probe
    local entry

    for itemKey, itemData in pairs(masterList) do
        seen = {}
        for _, tag in ipairs(itemData.tags or {}) do
            probe = tag
            while probe do
                if not seen[probe] then
                    entry = stats[probe]
                    if not entry then
                        entry = {
                            count = 0,
                            samples = {},
                            sampleLookup = {}
                        }
                        stats[probe] = entry
                    end

                    entry.count = entry.count + 1
                    if #entry.samples < Internal.PREVIEW_SAMPLE_COUNT and not entry.sampleLookup[itemKey] then
                        entry.samples[#entry.samples + 1] = itemKey
                        entry.sampleLookup[itemKey] = true
                    end
                    seen[probe] = true
                end
                probe = string.match(probe, "^(.*)%.")
            end
        end
    end

    return stats
end

local function buildTreeNodes(state)
    local nodeMap = {}
    local rootTags = {}
    local stats = buildBranchStats()
    local knownTags = DynamicTrading.PriceConfig.GetKnownTags()
    local config = DynamicTrading.PriceConfig.GetData()
    local tag
    local node

    for tag in pairs(knownTags) do
        nodeMap[tag] = nodeMap[tag] or { tag = tag, childKeys = {} }
    end
    for tag in pairs(config.tagMultipliers or {}) do
        nodeMap[tag] = nodeMap[tag] or { tag = tag, childKeys = {} }
    end

    for tag, node in pairs(nodeMap) do
        node.childKeys = {}
        node.parentTag = string.match(tag, "^(.*)%.")
        node.depth = Internal.getDepth(tag)
        node.label = string.match(tag, "([^.]+)$") or tag
        node.count = stats[tag] and stats[tag].count or 0
        node.samples = stats[tag] and stats[tag].samples or {}
        node.directMultiplier = config.tagMultipliers[tag]
        node.effectiveMultiplier = DynamicTrading.PriceConfig.GetBranchMultiplierForTag(tag, config)
    end

    for tag, node in pairs(nodeMap) do
        if node.parentTag and nodeMap[node.parentTag] then
            nodeMap[node.parentTag].childKeys[#nodeMap[node.parentTag].childKeys + 1] = tag
        else
            rootTags[#rootTags + 1] = tag
        end
    end

    local function sortChildren(keys)
        table.sort(keys, function(left, right)
            local leftNode = nodeMap[left]
            local rightNode = nodeMap[right]
            local leftCount = leftNode and leftNode.count or 0
            local rightCount = rightNode and rightNode.count or 0
            if leftCount ~= rightCount then
                return leftCount > rightCount
            end
            return Internal.sortStrings(left, right)
        end)
    end

    sortChildren(rootTags)
    for _, node in pairs(nodeMap) do
        sortChildren(node.childKeys)
    end

    state.treeStats = stats
    state.nodeMap = nodeMap
    state.rootTags = rootTags
end

local function addVisibleNode(state, tag)
    local node = state.nodeMap and state.nodeMap[tag] or nil
    local childTag

    if not node then
        return
    end

    state.treeList:addItem(tag, node)
    if state.collapsed[tag] then
        return
    end

    for _, childTag in ipairs(node.childKeys or {}) do
        addVisibleNode(state, childTag)
    end
end

function Internal.refreshTree(state)
    local index
    local row
    local tag

    if not state.treeList then
        return
    end

    buildTreeNodes(state)

    if state.selectedTag and not state.nodeMap[state.selectedTag] then
        state.selectedTag = nil
    end

    state.treeList:clear()
    state.treeList.selected = -1

    for _, tag in ipairs(state.rootTags or {}) do
        addVisibleNode(state, tag)
    end

    if state.selectedTag then
        for index, row in ipairs(state.treeList.items or {}) do
            if row and row.item and row.item.tag == state.selectedTag then
                state.treeList.selected = index
                break
            end
        end
    end
end

function Internal.getSelectedNode(state)
    return state.selectedTag and state.nodeMap and state.nodeMap[state.selectedTag] or nil
end

function Internal.onTreeMouseDown(listbox, x, y)
    local state = listbox and listbox.parentState or nil
    local row
    local entry
    local isSameSelection

    if not state or not listbox or not listbox.rowAt then
        return
    end

    row = listbox:rowAt(x, y)
    if row == -1 then
        return
    end

    entry = listbox.items[row] and listbox.items[row].item or nil
    if not entry or not entry.tag then
        return
    end

    isSameSelection = (state.selectedTag == entry.tag)
    listbox.selected = row
    state.selectedTag = entry.tag
    state.selectedItemKey = nil

    if isSameSelection and entry.childKeys and #entry.childKeys > 0 then
        state.collapsed[entry.tag] = not state.collapsed[entry.tag]
    end

    Internal.persistTreeState(state)
    Internal.refreshAll(state)
end

function Internal.drawTreeItem(listbox, y, item, alt)
    local node = item and item.item or nil
    local width
    local state
    local indent
    local prefix
    local title
    local info

    if not node then
        return y + (listbox.itemheight or 24)
    end

    width = listbox.getWidth and listbox:getWidth() or listbox.width or 0

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.25, 0.35, 0.55, 0.9)
    elseif alt then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, width, listbox.itemheight, 0.05, 0, 0, 0)
    end

    state = listbox.parentState
    indent = 8 + ((node.depth or 0) * 18)
    prefix = "   "
    if node.childKeys and #node.childKeys > 0 then
        prefix = state and state.collapsed[node.tag] and "[+] " or "[-] "
    end

    title = prefix .. tostring(node.label)
    info = string.format("%d | %s", node.count or 0, Internal.formatMultiplier(node.effectiveMultiplier or 1.0))
    if node.directMultiplier ~= nil then
        info = info .. " *"
    end

    listbox:drawText(title, indent, y + 4, 0.9, 0.9, 0.9, 1, UIFont.Small)
    listbox:drawText(info, math.max(110, width - 100), y + 4, 0.7, 0.85, 0.7, 1, UIFont.Small)
    return y + listbox.itemheight
end
