require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "ISUI/ISPanel"
require "ISUI/ISComboBox"
require "DT/Common/Buildings/DT_Buildings"

local BuildingList = ISScrollingListBox:derive("DT_BuildingsWindow_BuildingList")

function BuildingList:doDrawItem(y, item, alt)
    local entry = item and item.item or {}
    local background = item.selected and 0.18 or (alt and 0.06 or 0.03)
    self:drawRect(0, y, self.width, self.itemheight, 0.9, background, background, background)

    if entry.icon then
        self:drawTextureScaledAspect(entry.icon, 6, y + 6, 32, 32, 1, 1, 1, 1)
    end

    local titleX = 46
    local title = tostring(entry.displayName or entry.buildingType or "Building")
    local subtitle = "Count: " .. tostring(entry.currentCount or 0) .. " | Max L" .. tostring(entry.maxLevel or 0)
    if entry.enabled ~= true then
        subtitle = "Coming Soon"
    end

    self:drawText(title, titleX, y + 6, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(subtitle, titleX, y + 24, 0.72, 0.72, 0.72, 1, UIFont.Small)
    return y + self.itemheight
end

DT_BuildingsWindow = ISCollapsableWindow:derive("DT_BuildingsWindow")
DT_BuildingsWindow.instance = DT_BuildingsWindow.instance or nil
DT_BuildingsWindow.cachedSnapshot = DT_BuildingsWindow.cachedSnapshot or nil
DT_BuildingsWindow.EventsAdded = DT_BuildingsWindow.EventsAdded or false

local function copyArray(source)
    local copy = {}
    for _, entry in ipairs(source or {}) do
        copy[#copy + 1] = entry
    end
    return copy
end

local function buildRequirementState(isReady, reason)
    return {
        ready = isReady == true,
        reason = reason
    }
end

local function getBuilderConstructionLevel(builder)
    local level = tonumber(builder and builder.jobSkillLevel)
    if level == nil and type(builder and builder.skills) == "table" and type(builder.skills.Construction) == "table" then
        level = tonumber(builder.skills.Construction.level)
    end
    return math.max(0, math.floor(level or 0))
end

function DT_BuildingsWindow:getOwnerWindow()
    if self.ownerWindow and self.ownerWindow.sendLabourCommand then
        return self.ownerWindow
    end
    return DT_MainWindow and DT_MainWindow.instance or nil
end

function DT_BuildingsWindow:getBuilderOptions()
    local options = {}
    local workers = DT_MainWindow and DT_MainWindow.cachedWorkers or {}
    local labourConfig = DT_Labour and DT_Labour.Config or {}
    local deadState = tostring(labourConfig.States and labourConfig.States.Dead or "Dead")
    local builderJobType = tostring(labourConfig.JobTypes and labourConfig.JobTypes.Builder or "Builder")

    for _, worker in ipairs(workers or {}) do
        local normalizedJob = labourConfig.NormalizeJobType and labourConfig.NormalizeJobType(worker.jobType) or tostring(worker.jobType or "")
        if tostring(worker.state or "") ~= deadState and normalizedJob == builderJobType then
            options[#options + 1] = worker
        end
    end

    table.sort(options, function(a, b)
        return tostring(a.name or a.workerID or "") < tostring(b.name or b.workerID or "")
    end)
    return options
end

function DT_BuildingsWindow:getSelectedBuilder()
    local builders = self.builderOptions or {}
    local index = self.builderCombo and self.builderCombo.selected or 1
    if not index or index <= 0 then
        return nil
    end
    return builders[math.max(1, math.floor(index or 1))]
end

function DT_BuildingsWindow:getSelectedBuilding()
    local item = self.buildingList and self.buildingList.items and self.buildingList.items[self.buildingList.selected or 1]
    return item and item.item or nil
end

function DT_BuildingsWindow:selectBuildingByType(buildingType)
    if not self.buildingList or not self.buildingList.items then
        return nil
    end

    local wantedType = tostring(buildingType or "")
    if wantedType == "" then
        return nil
    end

    for index, row in ipairs(self.buildingList.items) do
        local entry = row and row.item or nil
        if entry and tostring(entry.buildingType or "") == wantedType then
            self.buildingList.selected = index
            self.selectedBuildingType = wantedType
            return entry
        end
    end

    return nil
end

function DT_BuildingsWindow:requestSnapshot()
    if isClient() and not isServer() then
        local ownerWindow = self:getOwnerWindow()
        if ownerWindow and ownerWindow.sendLabourCommand then
            ownerWindow:sendLabourCommand("RequestOwnerBuildings", {})
        end
        if DT_System and DT_System.RequestOwnedFactionStatus then
            DT_System.RequestOwnedFactionStatus()
        end
        return
    end

    DT_BuildingsWindow.cachedSnapshot = DT_Buildings and DT_Buildings.BuildOwnerSnapshot
        and DT_Buildings.BuildOwnerSnapshot((DT_Labour and DT_Labour.Config and DT_Labour.Config.GetPlayerObject and DT_Labour.Config.GetPlayerObject()) or "local")
        or nil
    self:refreshFromSnapshot()
end

function DT_BuildingsWindow:refreshBuilderCombo()
    self.builderOptions = self:getBuilderOptions()
    if not self.builderCombo then
        return
    end

    self.builderCombo:clear()
    for _, worker in ipairs(self.builderOptions or {}) do
        local label = tostring(worker.name or worker.workerID or "Builder")
        label = label .. " | Const Lv " .. tostring(getBuilderConstructionLevel(worker))
        label = label .. " | Tool: " .. tostring(worker.toolState or "Missing")
        if worker.assignedProjectID then
            label = label .. " | Busy"
        end
        if worker.housingState then
            label = label .. " | " .. tostring(worker.housingState)
        end
        self.builderCombo:addOption(label, worker)
    end

    if #(self.builderOptions or {}) > 0 then
        self.builderCombo.selected = math.min(math.max(1, self.builderCombo.selected or 1), #self.builderOptions)
    else
        self.builderCombo.selected = 0
    end
end

function DT_BuildingsWindow:refreshFromSnapshot()
    self.snapshot = DT_BuildingsWindow.cachedSnapshot or self.snapshot or nil
    if not self.buildingList then
        return
    end

    local previousType = self.selectedBuildingType
    local currentEntry = self:getSelectedBuilding()
    if not previousType and currentEntry then
        previousType = currentEntry.buildingType
    end

    self:refreshBuilderCombo()
    self.buildingList:clear()

    for _, entry in ipairs(self.snapshot and self.snapshot.buildings or {}) do
        local texture = getTexture and getTexture(entry.iconPath) or nil
        entry.icon = texture
        self.buildingList:addItem(entry.displayName or entry.buildingType, entry)
    end

    if self.buildingList.items and #self.buildingList.items > 0 then
        if not self:selectBuildingByType(previousType) then
            self.buildingList.selected = math.min(math.max(1, self.buildingList.selected or 1), #self.buildingList.items)
            local selectedEntry = self:getSelectedBuilding()
            self.selectedBuildingType = selectedEntry and selectedEntry.buildingType or nil
        end
    else
        self.buildingList.selected = 0
        self.selectedBuildingType = nil
    end
    self:updateDetail()
end

local function findCurrentLevel(instanceList)
    local best = 0
    for _, instance in ipairs(instanceList or {}) do
        best = math.max(best, math.floor(tonumber(instance.level) or 0))
    end
    return best
end

local function findUpgradeableLevel(entry)
    for _, instance in ipairs(entry.instances or {}) do
        local currentLevel = math.floor(tonumber(instance.level) or 0)
        if currentLevel < math.floor(tonumber(entry.maxLevel) or 0) then
            return currentLevel + 1
        end
    end
    return nil
end

local function getLevelData(entry, level)
    for _, levelEntry in ipairs(entry and entry.levels or {}) do
        if math.floor(tonumber(levelEntry.level) or 0) == math.floor(tonumber(level) or 0) then
            return levelEntry
        end
    end
    return nil
end

local function getBuilderRequirementState(builder)
    if not builder then
        return buildRequirementState(false, "Assign a recruit to the Builder job first.")
    end
    if builder.assignedProjectID then
        return buildRequirementState(
            false,
            tostring(builder.name or builder.workerID or "That builder")
                .. " is already assigned to "
                .. tostring(builder.assignedProjectBuildingType or "another project")
                .. " L"
                .. tostring(builder.assignedProjectTargetLevel or 1)
                .. "."
        )
    end
    if getBuilderConstructionLevel(builder) <= 0 then
        return buildRequirementState(false, "That worker has no Construction skill.")
    end
    if tostring(builder.toolState or "") ~= "Ready" then
        return buildRequirementState(false, "That builder is missing the required hammer and saw.")
    end
    return buildRequirementState(true, nil)
end

local function appendPreviewSection(text, title, preview)
    text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> " .. tostring(title or "Preview") .. " <LINE> "

    if not preview or preview.available ~= true then
        text = text .. " <RGB:0.85,0.55,0.55> " .. tostring((preview and preview.reason) or "Unavailable.") .. " <LINE> "
        return text
    end

    text = text .. " <RGB:0.72,0.72,0.72> Target Level: <RGB:1,1,1> " .. tostring(preview.targetLevel or 0) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Work Points: <RGB:1,1,1> " .. tostring(preview.workPoints or 0) .. " <LINE> "
    if preview.effects and preview.effects.recoveryMultiplier then
        text = text .. " <RGB:0.72,0.72,0.72> Recovery Multiplier: <RGB:1,1,1> x"
            .. tostring(preview.effects.recoveryMultiplier or 1)
            .. " <LINE> "
    end
    if preview.effects and preview.effects.housingSlots then
        text = text .. " <RGB:0.72,0.72,0.72> Housing Slots: <RGB:1,1,1> "
            .. tostring(preview.effects.housingSlots or 0)
            .. " <LINE> "
    end

    local recipeEntries = preview.recipeAvailability and preview.recipeAvailability.entries or {}
    if #recipeEntries <= 0 then
        text = text .. " <RGB:0.62,0.62,0.62> No materials required. <LINE> "
    else
        for _, recipeEntry in ipairs(recipeEntries) do
            local ok = recipeEntry.satisfied == true
            local r = ok and "0.75" or "0.95"
            local g = ok and "0.85" or "0.55"
            local b = ok and "0.75" or "0.55"
            text = text .. " <RGB:" .. r .. "," .. g .. "," .. b .. "> - "
                .. tostring(recipeEntry.count or 0)
                .. " x "
                .. tostring(recipeEntry.displayName or recipeEntry.fullType or "Item")
                .. " <RGB:0.72,0.72,0.72> ("
                .. tostring(recipeEntry.available or 0)
                .. " available) <LINE> "
        end
    end

    if preview.canStart == true then
        text = text .. " <RGB:0.72,0.9,0.72> Materials Ready <LINE> "
    else
        text = text .. " <RGB:0.9,0.65,0.65> " .. tostring(preview.reason or "Missing required materials.") .. " <LINE> "
    end

    return text
end

function DT_BuildingsWindow:updateDetail()
    if not self.detailText then
        return
    end

    local snapshot = self.snapshot or {}
    local entry = self:getSelectedBuilding()
    local builder = self:getSelectedBuilder()

    if not entry then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> No building selected. ")
        self.detailText:paginate()
        if self.btnStartNew then self.btnStartNew:setEnable(false) end
        if self.btnUpgrade then self.btnUpgrade:setEnable(false) end
        return
    end

    local currentLevel = findCurrentLevel(entry.instances or {})
    local newBuildPreview = entry.newBuildPreview or nil
    local upgradePreview = entry.upgradePreview or nil
    local nextUpgradeLevel = upgradePreview and upgradePreview.available == true and upgradePreview.targetLevel or nil
    local nextLevelForDisplay = (upgradePreview and upgradePreview.available == true and upgradePreview.targetLevel)
        or (newBuildPreview and newBuildPreview.available == true and newBuildPreview.targetLevel)
        or 1
    local nextLevelData = getLevelData(entry, nextLevelForDisplay)
    local builderRequirement = getBuilderRequirementState(builder)
    local canStartNew = entry.enabled == true
        and builderRequirement.ready == true
        and newBuildPreview
        and newBuildPreview.available == true
        and newBuildPreview.canStart == true
    local canUpgrade = entry.enabled == true
        and builderRequirement.ready == true
        and upgradePreview
        and upgradePreview.available == true
        and upgradePreview.canStart == true
    local text = ""

    text = text .. " <RGB:1,1,1> <SIZE:Medium> " .. tostring(entry.displayName or entry.buildingType or "Building") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Enabled: <RGB:1,1,1> " .. tostring(entry.enabled == true and "Yes" or "No") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Instances: <RGB:1,1,1> " .. tostring(entry.currentCount or 0) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Highest Level: <RGB:1,1,1> " .. tostring(currentLevel) .. " / " .. tostring(entry.maxLevel or 0) .. " <LINE> "

    if snapshot.housing then
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Housing <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Housed: <RGB:1,1,1> "
            .. tostring(snapshot.housing.housedCount or 0)
            .. " / "
            .. tostring(snapshot.housing.capacity or 0)
            .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Unhoused: <RGB:1,1,1> " .. tostring(snapshot.housing.unhousedCount or 0) .. " <LINE> "
    end

    if builder then
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Selected Builder <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Name: <RGB:1,1,1> " .. tostring(builder.name or builder.workerID or "Builder") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Construction: <RGB:1,1,1> Lv " .. tostring(getBuilderConstructionLevel(builder)) .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Tool State: <RGB:1,1,1> " .. tostring(builder.toolState or "Missing") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Housing: <RGB:1,1,1> " .. tostring(builder.housingState or "Unhoused") .. " <LINE> "
        if builder.assignedProjectID then
            text = text .. " <RGB:0.72,0.72,0.72> Project: <RGB:1,1,1> "
                .. tostring(builder.assignedProjectBuildingType or "Project")
                .. " L"
                .. tostring(builder.assignedProjectTargetLevel or 1)
                .. " <LINE> "
        end
        if builderRequirement.ready == true then
            text = text .. " <RGB:0.72,0.9,0.72> Builder Ready <LINE> "
        else
            text = text .. " <RGB:0.9,0.65,0.65> " .. tostring(builderRequirement.reason or "Builder is not ready.") .. " <LINE> "
        end
    else
        text = text .. " <LINE> <RGB:0.85,0.55,0.55> No Builder worker is currently available. Assign a recruit to the Builder job first. <LINE> "
    end

    if nextLevelData then
        text = text .. " <LINE> <RGB:0.72,0.72,0.72> Highest Defined Target: <RGB:1,1,1> " .. tostring(nextLevelForDisplay) .. " <LINE> "
    end

    text = appendPreviewSection(text, "Start New", newBuildPreview)
    text = appendPreviewSection(text, "Upgrade", upgradePreview)

    text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Active Projects <LINE> "
    local anyProject = false
    for _, project in ipairs(snapshot.activeProjects or {}) do
        if tostring(project.buildingType or "") == tostring(entry.buildingType or "") and tostring(project.status or "") == "Active" then
            anyProject = true
            text = text .. " <RGB:0.8,0.8,0.8> "
                .. tostring(project.assignedBuilderName or project.assignedBuilderID or "Builder")
                .. ": "
                .. tostring(math.floor((tonumber(project.progressWorkPoints) or 0) + 0.5))
                .. " / "
                .. tostring(project.requiredWorkPoints or 0)
                .. " WP toward L"
                .. tostring(project.targetLevel or 1)
                .. " <LINE> "
        end
    end
    if not anyProject then
        text = text .. " <RGB:0.62,0.62,0.62> No active projects for this building. <LINE> "
    end

    self.detailText:setText(text)
    self.detailText:paginate()

    if self.btnStartNew then
        self.btnStartNew:setEnable(canStartNew == true)
    end
    if self.btnUpgrade then
        self.btnUpgrade:setEnable(canUpgrade == true and nextUpgradeLevel ~= nil)
    end
end

function DT_BuildingsWindow:onBuildingSelected()
    local entry = self:getSelectedBuilding()
    self.selectedBuildingType = entry and entry.buildingType or nil
    self:updateDetail()
end

function DT_BuildingsWindow:onBuilderChanged()
    self:updateDetail()
end

function DT_BuildingsWindow:startProject(mode)
    local entry = self:getSelectedBuilding()
    local builder = self:getSelectedBuilder()
    local ownerWindow = self:getOwnerWindow()
    if not entry or not builder or not ownerWindow or not ownerWindow.sendLabourCommand then
        return
    end

    ownerWindow:sendLabourCommand("StartBuildingProject", {
        workerID = builder.workerID,
        buildingType = entry.buildingType,
        mode = mode
    })
end

function DT_BuildingsWindow:onStartNew()
    self:startProject("build")
end

function DT_BuildingsWindow:onUpgrade()
    self:startProject("upgrade")
end

function DT_BuildingsWindow:onRefresh()
    self:requestSnapshot()
end

function DT_BuildingsWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local leftW = 270
    local contentH = self.height - th - (pad * 2) - 90
    local rightX = leftW + (pad * 2)
    local rightW = self.width - rightX - pad

    self.buildingList = BuildingList:new(pad, th + pad, leftW, contentH)
    self.buildingList:initialise()
    self.buildingList:instantiate()
    self.buildingList.itemheight = 44
    self.buildingList.target = self
    self.buildingList.onmousedown = function(target, item)
        if target and target.items then
            for i, row in ipairs(target.items) do
                if row and (row == item or row.item == item) then
                    target.selected = i
                    break
                end
            end
        end
        self:onBuildingSelected()
        return true
    end
    self.buildingList:setAnchorLeft(true)
    self.buildingList:setAnchorTop(true)
    self.buildingList:setAnchorBottom(true)
    self:addChild(self.buildingList)

    self.detailPanel = ISPanel:new(rightX, th + pad, rightW, contentH)
    self.detailPanel:initialise()
    self.detailPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailPanel:setAnchorRight(true)
    self.detailPanel:setAnchorBottom(true)
    self:addChild(self.detailPanel)

    self.detailText = ISRichTextPanel:new(8, 8, rightW - 16, contentH - 16)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.detailText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.detailText.clip = true
    self.detailText.autosetheight = false
    self.detailText:addScrollBars()
    self.detailPanel:addChild(self.detailText)

    self.builderCombo = ISComboBox:new(pad, self.height - 70, 280, 24, self, self.onBuilderChanged)
    self.builderCombo:initialise()
    self.builderCombo:setAnchorBottom(true)
    self:addChild(self.builderCombo)

    self.btnRefresh = ISButton:new(310, self.height - 70, 90, 24, "Refresh", self, self.onRefresh)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    self.btnStartNew = ISButton:new(410, self.height - 70, 120, 24, "Start New", self, self.onStartNew)
    self.btnStartNew:initialise()
    self.btnStartNew:setAnchorBottom(true)
    self:addChild(self.btnStartNew)

    self.btnUpgrade = ISButton:new(540, self.height - 70, 120, 24, "Upgrade", self, self.onUpgrade)
    self.btnUpgrade:initialise()
    self.btnUpgrade:setAnchorBottom(true)
    self:addChild(self.btnUpgrade)

    self.builderOptions = {}
    self:refreshBuilderCombo()
    self:requestSnapshot()
end

function DT_BuildingsWindow:prerender()
    ISCollapsableWindow.prerender(self)
    self.autoRefreshFrames = (tonumber(self.autoRefreshFrames) or 0) + 1
    if self.autoRefreshFrames >= 180 then
        self.autoRefreshFrames = 0
        self:requestSnapshot()
    end
end

function DT_BuildingsWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_BuildingsWindow:new(x, y, width, height, ownerWindow)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Buildings"
    o.resizable = true
    o.ownerWindow = ownerWindow
    o.autoRefreshFrames = 0
    return o
end

function DT_BuildingsWindow.Open(ownerWindow)
    if DT_BuildingsWindow.instance then
        DT_BuildingsWindow.instance.ownerWindow = ownerWindow or DT_BuildingsWindow.instance.ownerWindow
        DT_BuildingsWindow.instance:setVisible(true)
        DT_BuildingsWindow.instance:addToUIManager()
        DT_BuildingsWindow.instance:bringToTop()
        DT_BuildingsWindow.instance:requestSnapshot()
        DT_BuildingsWindow.instance:updateDetail()
        return DT_BuildingsWindow.instance
    end

    local width = 980
    local height = 640
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2
    local window = DT_BuildingsWindow:new(x, y, width, height, ownerWindow)
    window:initialise()
    window:instantiate()
    window:addToUIManager()
    window:bringToTop()
    DT_BuildingsWindow.instance = window
    return window
end

if not DT_BuildingsWindow.EventsAdded then
    Events.OnServerCommand.Add(function(module, command, args)
        if module ~= "DynamicTrading_V2" then
            return
        end
        if command ~= "SyncBuildingsSnapshot" then
            return
        end
        DT_BuildingsWindow.cachedSnapshot = args and args.snapshot or nil
        if DT_BuildingsWindow.instance and DT_BuildingsWindow.instance:getIsVisible() then
            DT_BuildingsWindow.instance:refreshFromSnapshot()
        end
    end)
    DT_BuildingsWindow.EventsAdded = true
end

return DT_BuildingsWindow
