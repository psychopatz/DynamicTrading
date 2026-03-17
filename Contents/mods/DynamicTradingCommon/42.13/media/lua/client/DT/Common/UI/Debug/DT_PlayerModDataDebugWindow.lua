-- ==============================================================================
-- DT_PlayerModDataDebugWindow.lua
-- Debug UI for browsing local player ModData with expandable table contents
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"

DT_PlayerModDataDebugWindow = ISCollapsableWindow:derive("DT_PlayerModDataDebugWindow")
DT_PlayerModDataDebugWindow.instance = nil

local function countKeys(value)
    if type(value) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(value) do
        count = count + 1
    end
    return count
end

local function keySortValue(key)
    local keyType = type(key)
    if keyType == "number" then
        return 1, key
    end
    if keyType == "string" then
        return 2, string.lower(key)
    end
    if keyType == "boolean" then
        return 3, key and 1 or 0
    end
    return 4, tostring(key)
end

local function getSortedKeys(value)
    local keys = {}
    if type(value) ~= "table" then
        return keys
    end

    for key in pairs(value) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        local rankA, sortA = keySortValue(a)
        local rankB, sortB = keySortValue(b)
        if rankA ~= rankB then
            return rankA < rankB
        end
        return sortA < sortB
    end)

    return keys
end

local function formatKey(key)
    local keyType = type(key)
    if keyType == "string" then
        return key
    end
    if keyType == "number" then
        return "[" .. tostring(key) .. "]"
    end
    if keyType == "boolean" then
        return "[" .. tostring(key) .. "]"
    end
    return "[" .. tostring(key) .. "]"
end

local function formatScalar(value)
    local valueType = type(value)
    if valueType == "string" then
        return "\"" .. value .. "\""
    end
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end
    if valueType == "nil" then
        return "nil"
    end
    return "<" .. valueType .. "> " .. tostring(value)
end

local function summarizeValue(value)
    local valueType = type(value)
    if valueType == "table" then
        return "{table} (" .. tostring(countKeys(value)) .. " keys)"
    end
    return formatScalar(value)
end

local function buildNodePath(parentPath, key)
    local keyText = formatKey(key)
    if not parentPath or parentPath == "" then
        return keyText
    end

    if string.sub(keyText, 1, 1) == "[" then
        return parentPath .. keyText
    end

    return parentPath .. "." .. keyText
end

local function appendDetails(lines, path, value, depth, visited)
    local indent = string.rep("  ", depth)
    local valueType = type(value)

    if valueType ~= "table" then
        table.insert(lines, indent .. path .. " = " .. formatScalar(value))
        return
    end

    if visited[value] then
        table.insert(lines, indent .. path .. " = {cycle}")
        return
    end

    visited[value] = true

    table.insert(lines, indent .. path .. " = {table}")
    for _, key in ipairs(getSortedKeys(value)) do
        local childValue = value[key]
        local childPath = formatKey(key)
        appendDetails(lines, childPath, childValue, depth + 1, visited)
    end
end

function DT_PlayerModDataDebugWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 820
    self.minimumHeight = 520
end

function DT_PlayerModDataDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local padding = 10
    local buttonHeight = 25
    local contentY = th + padding
    local contentHeight = self.height - th - (padding * 3) - buttonHeight
    local listWidth = math.floor(self.width * 0.58)

    self.listbox = ISScrollingListBox:new(padding, contentY, listWidth, contentHeight)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 22
    self.listbox.backgroundColor = { r = 0, g = 0, b = 0, a = 0.4 }
    self.listbox.doDrawItem = function(listbox, y, item, alt)
        return DT_PlayerModDataDebugWindow.drawNodeItem(listbox, y, item, alt)
    end
    self.listbox.onmousedown = function(target, item)
        if not DT_PlayerModDataDebugWindow.instance then
            return false
        end

        if target and target.items then
            for i, row in ipairs(target.items) do
                if row and row.item == item then
                    target.selected = i
                    break
                end
            end
        end

        DT_PlayerModDataDebugWindow.instance:onNodeSelected(item)
        return true
    end
    self.listbox:setAnchorLeft(true)
    self.listbox:setAnchorRight(false)
    self.listbox:setAnchorTop(true)
    self.listbox:setAnchorBottom(true)
    self:addChild(self.listbox)

    local detailsX = padding + listWidth + padding
    local detailsWidth = self.width - detailsX - padding
    self.details = ISRichTextPanel:new(detailsX, contentY, detailsWidth, contentHeight)
    self.details:initialise()
    self.details.backgroundColor = { r = 0, g = 0, b = 0, a = 0.4 }
    self.details.borderColor = { r = 1, g = 1, b = 1, a = 0.15 }
    self.details:addScrollBars()
    self.details:setAnchorLeft(true)
    self.details:setAnchorRight(true)
    self.details:setAnchorTop(true)
    self.details:setAnchorBottom(true)
    self:addChild(self.details)

    local buttonY = self.height - padding - buttonHeight
    self.btnRefresh = ISButton:new(padding, buttonY, 120, buttonHeight, "REFRESH", self, DT_PlayerModDataDebugWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 1 }
    self.btnRefresh:setAnchorLeft(true)
    self.btnRefresh:setAnchorTop(false)
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    self.btnCollapse = ISButton:new(padding + 130, buttonY, 150, buttonHeight, "COLLAPSE ALL", self, DT_PlayerModDataDebugWindow.onCollapseClick)
    self.btnCollapse:initialise()
    self.btnCollapse.backgroundColor = { r = 0.35, g = 0.35, b = 0.35, a = 1 }
    self.btnCollapse:setAnchorLeft(true)
    self.btnCollapse:setAnchorTop(false)
    self.btnCollapse:setAnchorBottom(true)
    self:addChild(self.btnCollapse)

    self.btnClose = ISButton:new(self.width - padding - 120, buttonY, 120, buttonHeight, "CLOSE", self, DT_PlayerModDataDebugWindow.onCloseClick)
    self.btnClose:initialise()
    self.btnClose:setAnchorLeft(false)
    self.btnClose:setAnchorRight(true)
    self.btnClose:setAnchorTop(false)
    self.btnClose:setAnchorBottom(true)
    self:addChild(self.btnClose)

    self:refreshData()
end

function DT_PlayerModDataDebugWindow:prerender()
    ISCollapsableWindow.prerender(self)
end

function DT_PlayerModDataDebugWindow:onResize()
    ISCollapsableWindow.onResize(self)

    local th = self:titleBarHeight()
    local padding = 10
    local buttonHeight = 25
    local contentY = th + padding
    local contentHeight = self.height - th - (padding * 3) - buttonHeight
    local listWidth = math.floor(self.width * 0.58)
    local detailsX = padding + listWidth + padding
    local detailsWidth = self.width - detailsX - padding
    local buttonY = self.height - padding - buttonHeight

    if self.listbox then
        self.listbox:setX(padding)
        self.listbox:setY(contentY)
        self.listbox:setWidth(listWidth)
        self.listbox:setHeight(contentHeight)
    end

    if self.details then
        self.details:setX(detailsX)
        self.details:setY(contentY)
        self.details:setWidth(detailsWidth)
        self.details:setHeight(contentHeight)
    end

    if self.btnRefresh then
        self.btnRefresh:setY(buttonY)
    end

    if self.btnCollapse then
        self.btnCollapse:setY(buttonY)
    end

    if self.btnClose then
        self.btnClose:setX(self.width - padding - 120)
        self.btnClose:setY(buttonY)
    end
end

function DT_PlayerModDataDebugWindow:refreshData()
    local player = getPlayer()
    if not player then
        self.rootData = {}
        self:populateTree()
        self:setDetailsText("No local player found.")
        return
    end

    self.rootData = player:getModData() or {}
    self:populateTree()

    if self.selectedPath and self.nodeIndexByPath[self.selectedPath] then
        self:updateDetails(self.nodeByPath[self.selectedPath])
    else
        self:setDetailsText("Select a key to inspect it. Click table entries to expand/collapse their contents.")
    end
end

function DT_PlayerModDataDebugWindow:populateTree()
    if not self.listbox then
        return
    end

    self.listbox:clear()
    self.nodeByPath = {}
    self.nodeIndexByPath = {}

    local rootValue = self.rootData or {}
    local keys = getSortedKeys(rootValue)
    for _, key in ipairs(keys) do
        local path = buildNodePath("", key)
        self:addTreeNode(key, rootValue[key], 0, path, {})
    end

    if self.selectedPath and self.nodeIndexByPath[self.selectedPath] then
        self.listbox.selected = self.nodeIndexByPath[self.selectedPath]
    else
        self.selectedPath = nil
    end
end

function DT_PlayerModDataDebugWindow:addTreeNode(key, value, depth, path, visited)
    visited = visited or {}

    local isTable = type(value) == "table"
    local hasCycle = isTable and visited[value] == true
    local expandable = isTable and not hasCycle and countKeys(value) > 0
    local childCount = isTable and countKeys(value) or 0
    local node = {
        key = key,
        keyText = formatKey(key),
        value = value,
        depth = depth,
        path = path,
        valueType = type(value),
        expandable = expandable,
        childCount = childCount,
        hasCycle = hasCycle,
        summary = hasCycle and "{cycle}" or summarizeValue(value),
    }

    self.listbox:addItem(node.keyText, node)
    local index = #self.listbox.items
    self.nodeByPath[path] = node
    self.nodeIndexByPath[path] = index

    if not expandable or not self.expandedPaths[path] then
        return
    end

    local nextVisited = {}
    for tableRef, _ in pairs(visited) do
        nextVisited[tableRef] = true
    end
    nextVisited[value] = true

    for _, childKey in ipairs(getSortedKeys(value)) do
        local childPath = buildNodePath(path, childKey)
        self:addTreeNode(childKey, value[childKey], depth + 1, childPath, nextVisited)
    end
end

function DT_PlayerModDataDebugWindow:onNodeSelected(node)
    if not node then
        return
    end

    self.selectedPath = node.path
    self:updateDetails(node)

    if node.expandable then
        self.expandedPaths[node.path] = not self.expandedPaths[node.path]
        self:populateTree()
        if self.selectedPath and self.nodeIndexByPath[self.selectedPath] then
            self.listbox.selected = self.nodeIndexByPath[self.selectedPath]
        end
    end
end

function DT_PlayerModDataDebugWindow:updateDetails(node)
    if not node then
        self:setDetailsText("Select a key to inspect it.")
        return
    end

    local lines = {}
    table.insert(lines, "Path: " .. tostring(node.path))
    table.insert(lines, "Type: " .. tostring(node.valueType))
    table.insert(lines, "Summary: " .. tostring(node.summary))

    if node.valueType == "table" then
        table.insert(lines, "Key Count: " .. tostring(node.childCount))
        table.insert(lines, "")
        table.insert(lines, "Contents:")
        appendDetails(lines, node.keyText, node.value, 0, {})
    else
        table.insert(lines, "")
        table.insert(lines, "Value:")
        table.insert(lines, formatScalar(node.value))
    end

    self:setDetailsText(table.concat(lines, " <LINE> "))
end

function DT_PlayerModDataDebugWindow:setDetailsText(text)
    if not self.details then
        return
    end

    self.details:setText(" <RGB:0.9,0.9,0.9> " .. tostring(text or ""))
    self.details:paginate()
end

function DT_PlayerModDataDebugWindow:clearExpandedPaths()
    self.expandedPaths = {}
end

function DT_PlayerModDataDebugWindow:onRefreshClick()
    self:refreshData()
end

function DT_PlayerModDataDebugWindow:onCollapseClick()
    self:clearExpandedPaths()
    self:populateTree()
    if self.selectedPath and self.nodeByPath[self.selectedPath] then
        self:updateDetails(self.nodeByPath[self.selectedPath])
    else
        self:setDetailsText("Select a key to inspect it. Click table entries to expand/collapse their contents.")
    end
end

function DT_PlayerModDataDebugWindow:onCloseClick()
    self:close()
end

function DT_PlayerModDataDebugWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_PlayerModDataDebugWindow.drawNodeItem(listbox, y, item, alt)
    local node = item.item
    if not node then
        return y + listbox.itemheight
    end

    if item.selected then
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.25, 0.4, 0.65, 0.85)
    elseif alt then
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.05, 0, 0, 0)
    end

    local prefix = "   "
    if node.expandable then
        local expanded = DT_PlayerModDataDebugWindow.instance
            and DT_PlayerModDataDebugWindow.instance.expandedPaths
            and DT_PlayerModDataDebugWindow.instance.expandedPaths[node.path]
        prefix = expanded and "[-]" or "[+]"
    elseif node.valueType == "table" then
        prefix = "[ ]"
    end

    local indent = 10 + (node.depth * 18)
    local keyR, keyG, keyB = 0.95, 0.95, 0.95
    local valueR, valueG, valueB = 0.7, 0.7, 0.7

    if node.valueType == "table" then
        keyR, keyG, keyB = 0.55, 0.85, 1.0
    elseif node.valueType == "string" then
        valueR, valueG, valueB = 0.7, 1.0, 0.7
    elseif node.valueType == "number" then
        valueR, valueG, valueB = 1.0, 0.9, 0.4
    elseif node.valueType == "boolean" then
        valueR, valueG, valueB = 1.0, 0.65, 0.65
    end

    listbox:drawText(prefix .. " " .. node.keyText, indent, y + 3, keyR, keyG, keyB, 1, UIFont.Small)
    listbox:drawText(node.summary, indent + 165, y + 3, valueR, valueG, valueB, 0.9, UIFont.Small)

    return y + listbox.itemheight
end

function DT_PlayerModDataDebugWindow.Open()
    if DT_PlayerModDataDebugWindow.instance then
        DT_PlayerModDataDebugWindow.instance:setVisible(true)
        DT_PlayerModDataDebugWindow.instance:addToUIManager()
        DT_PlayerModDataDebugWindow.instance:refreshData()
        return
    end

    local width = 980
    local height = 620
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local window = DT_PlayerModDataDebugWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_PlayerModDataDebugWindow.instance = window
    window:refreshData()
end

function DT_PlayerModDataDebugWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Player ModData Browser"
    o.resizable = true
    o.expandedPaths = {}
    o.nodeByPath = {}
    o.nodeIndexByPath = {}
    o.selectedPath = nil
    o.rootData = {}
    return o
end

