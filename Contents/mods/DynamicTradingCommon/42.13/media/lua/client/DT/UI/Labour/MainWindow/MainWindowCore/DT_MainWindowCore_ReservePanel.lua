DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local LabourProfileCard = ISPanel:derive("LabourProfileCard")

function LabourProfileCard:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.18 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.08 }
    o.caloriesDisplayRatio = 0
    o.hydrationDisplayRatio = 0
    o.healthDisplayRatio = 0
    o.tirednessDisplayRatio = 0
    o.activityDisplayRatio = 0
    o.workerDisplayCache = {}
    return o
end

function LabourProfileCard:initialise()
    ISPanel.initialise(self)

    self.btnInventory = ISButton:new(0, 0, 96, 24, "Inventory", self, self.onOpenInventory)
    self.btnInventory:initialise()
    self.btnInventory:setEnable(false)
    self:addChild(self.btnInventory)
end

function LabourProfileCard:setOwnerWindow(window)
    self.ownerWindow = window
end

function LabourProfileCard:onOpenInventory()
    if self.ownerWindow and self.ownerWindow.onOpenInventory then
        self.ownerWindow:onOpenInventory()
    end
end

function LabourProfileCard:setWorker(worker)
    self.worker = worker
    self.profile = worker and Internal.Config.GetJobProfile and Internal.Config.GetJobProfile(worker.jobType) or nil
    if not worker then
        self.portraitTex = nil
        self.caloriesData = nil
        self.hydrationData = nil
        self.healthData = nil
        self.tirednessData = nil
        self.activityData = nil
        self.caloriesTargetRatio = 0
        self.hydrationTargetRatio = 0
        self.healthTargetRatio = 0
        self.tirednessTargetRatio = 0
        self.activityTargetRatio = 0
        if self.btnInventory then
            self.btnInventory:setEnable(false)
        end
        return
    end

    if self.btnInventory then
        self.btnInventory:setEnable(true)
    end

    local profile = self.profile or {}
    local config = Internal.Config
    local dailyCaloriesNeed = config.GetEffectiveDailyCaloriesNeed and config.GetEffectiveDailyCaloriesNeed(worker, profile)
        or tonumber(worker.dailyCaloriesNeed)
        or tonumber(profile.dailyCaloriesNeed)
        or 0
    local dailyHydrationNeed = config.GetEffectiveDailyHydrationNeed and config.GetEffectiveDailyHydrationNeed(worker, profile)
        or tonumber(worker.dailyHydrationNeed)
        or tonumber(profile.dailyHydrationNeed)
        or 0
    local carryoverCalories = math.max(0, tonumber(worker.carryoverCalories) or tonumber(worker.caloriesOverflow) or 0)
    local carryoverHydration = math.max(0, tonumber(worker.carryoverHydration) or tonumber(worker.hydrationOverflow) or 0)
    local provisionCalories = math.max(0, tonumber(worker.provisionCaloriesReserve) or tonumber(worker.storedCalories) or 0)
    local provisionHydration = math.max(0, tonumber(worker.provisionHydrationReserve) or tonumber(worker.storedHydration) or 0)
    local currentCaloriesBuffer = math.max(0, tonumber(worker.currentCaloriesBuffer) or tonumber(worker.caloriesCached) or 0)
    local currentHydrationBuffer = math.max(0, tonumber(worker.currentHydrationBuffer) or tonumber(worker.hydrationCached) or 0)

    self.caloriesData = Internal.getNutritionBarData("Calories", currentCaloriesBuffer, carryoverCalories, provisionCalories, dailyCaloriesNeed)
    self.hydrationData = Internal.getNutritionBarData("Hydration", currentHydrationBuffer, carryoverHydration, provisionHydration, dailyHydrationNeed)
    self.healthData = Internal.getHealthBarData(worker.hp, worker.maxHp)
    self.tirednessData = DT_Labour and DT_Labour.Tiredness and DT_Labour.Tiredness.GetBarData and DT_Labour.Tiredness.GetBarData(worker) or nil
    self.activityData = Internal.getWorkerProgressData and Internal.getWorkerProgressData(worker, profile) or nil
    self.caloriesTargetRatio = self.caloriesData.fillRatio
    self.hydrationTargetRatio = self.hydrationData.fillRatio
    self.healthTargetRatio = self.healthData.fillRatio
    self.tirednessTargetRatio = self.tirednessData and self.tirednessData.fillRatio or 0
    self.activityTargetRatio = self.activityData and self.activityData.fillRatio or 0
    self.portraitTex = Internal.getWorkerPortraitTexture(worker)

    local workerID = tostring(worker.workerID or "")
    local cachedRatios = self.workerDisplayCache[workerID]
    if cachedRatios then
        self.caloriesDisplayRatio = tonumber(cachedRatios.calories) or self.caloriesTargetRatio
        self.hydrationDisplayRatio = tonumber(cachedRatios.hydration) or self.hydrationTargetRatio
        self.healthDisplayRatio = tonumber(cachedRatios.health) or self.healthTargetRatio
        self.tirednessDisplayRatio = tonumber(cachedRatios.tiredness) or self.tirednessTargetRatio
        self.activityDisplayRatio = tonumber(cachedRatios.activity) or self.activityTargetRatio
        return
    end

    self.caloriesDisplayRatio = self.caloriesTargetRatio
    self.hydrationDisplayRatio = self.hydrationTargetRatio
    self.healthDisplayRatio = self.healthTargetRatio
    self.tirednessDisplayRatio = self.tirednessTargetRatio
    self.activityDisplayRatio = self.activityTargetRatio
end

local function animateRatio(currentValue, targetValue)
    local current = tonumber(currentValue) or 0
    local target = tonumber(targetValue) or 0
    local delta = target - current
    if math.abs(delta) < 0.01 then
        return target
    end
    return current + (delta * 0.18)
end

function LabourProfileCard:drawReserveBar(x, y, width, height, label, color, data, displayRatio)
    local safeData = data or { stored = 0, usage = 0, carryover = 0, provisionReserve = 0, daysLeft = nil }
    self:drawRect(x, y, width, height, 0.35, 0.08, 0.08, 0.08)
    self:drawRectBorder(x, y, width, height, 0.2, 1, 1, 1)

    local fillWidth = math.floor((width - 4) * math.max(0, math.min(1, displayRatio or 0)))
    if fillWidth > 0 then
        self:drawRect(x + 2, y + 2, fillWidth, height - 4, 0.9, color.r, color.g, color.b)
    end

    local labelWidth = getTextManager():MeasureStringX(UIFont.Small, label)
    self:drawText(label, x + math.max(8, (width - labelWidth) / 2), y + 2, 0.95, 0.95, 0.95, 1, UIFont.Small)

    local daysText = safeData.captionText or Internal.formatDaysAndEta(safeData.daysLeft, safeData.daysLeft and (safeData.daysLeft * 24) or nil)
    local totalsText = safeData.summaryText
        or ("Reserve " .. Internal.formatReserveValue(safeData.provisionReserve or safeData.stored)
            .. " | Carryover " .. Internal.formatReserveValue(safeData.carryover or safeData.overflow or 0))
    self:drawText(daysText, x, y + height + 4, 0.86, 0.86, 0.86, 1, UIFont.Small)
    self:drawTextRight(totalsText, x + width, y + height + 4, 0.66, 0.66, 0.66, 1, UIFont.Small)
end

function LabourProfileCard:storeDisplayState()
    if not self.worker then
        return
    end

    local workerID = tostring(self.worker.workerID or "")
    if workerID == "" then
        return
    end

    self.workerDisplayCache[workerID] = {
        calories = self.caloriesDisplayRatio,
        hydration = self.hydrationDisplayRatio,
        health = self.healthDisplayRatio,
        tiredness = self.tirednessDisplayRatio,
        activity = self.activityDisplayRatio
    }
end

function LabourProfileCard:prerender()
    ISPanel.prerender(self)

    local pad = 12
    local inventoryButtonHeight = (self.btnInventory and self.btnInventory:getHeight()) or 24
    local inventoryButtonGap = self.btnInventory and 8 or 0
    if not self.worker then
        self:drawTextCentre("Select a worker to inspect labour reserves and daily upkeep.", self.width / 2, self.height / 2 - 8, 0.65, 0.65, 0.65, 0.9, UIFont.Medium)
        return
    end

    self.caloriesDisplayRatio = animateRatio(self.caloriesDisplayRatio, self.caloriesTargetRatio)
    self.hydrationDisplayRatio = animateRatio(self.hydrationDisplayRatio, self.hydrationTargetRatio)
    self.healthDisplayRatio = animateRatio(self.healthDisplayRatio, self.healthTargetRatio)
    self.tirednessDisplayRatio = animateRatio(self.tirednessDisplayRatio, self.tirednessTargetRatio)
    self.activityDisplayRatio = animateRatio(self.activityDisplayRatio, self.activityTargetRatio)
    self:storeDisplayState()

    local portraitSize = math.min(104, self.height - (pad * 2) - inventoryButtonHeight - inventoryButtonGap)
    portraitSize = math.max(72, portraitSize)
    local portraitX = pad
    local portraitY = pad + 10
    local barsX = portraitX + portraitSize + 18
    local barsWidth = self.width - barsX - pad
    local barHeight = 24
    local topY = pad
    local worker = self.worker
    local profile = self.profile or {}

    self:drawText(tostring(worker.name or "Worker"), barsX, topY, 0.95, 0.97, 1, 1, UIFont.Large)
    topY = topY + 24
    self:drawText(
        Internal.getJobDisplayName(worker, profile) .. " | " .. Internal.getWorkerStateLabel(worker),
        barsX,
        topY,
        0.68,
        0.8,
        1,
        1,
        UIFont.Small
    )
    topY = topY + 38

    self:drawRect(portraitX, portraitY, portraitSize, portraitSize, 0.08, 1, 1, 1)
    if self.portraitTex then
        self:drawTextureScaled(self.portraitTex, portraitX + 3, portraitY + 3, portraitSize - 6, portraitSize - 6, 1, 1, 1, 1)
    end
    self:drawRectBorder(portraitX, portraitY, portraitSize, portraitSize, 0.25, 1, 1, 1)

    if self.btnInventory then
        self.btnInventory:setX(portraitX)
        self.btnInventory:setY(portraitY + portraitSize + 8)
        self.btnInventory:setWidth(portraitSize)
        self.btnInventory:setHeight(inventoryButtonHeight)
    end

    local nextButtonY = portraitY + portraitSize + 8 + inventoryButtonHeight + 6
    if self.ownerWindow and self.ownerWindow.btnCycleJob then
        self.ownerWindow.btnCycleJob:setX(portraitX)
        self.ownerWindow.btnCycleJob:setY(nextButtonY)
        self.ownerWindow.btnCycleJob:setWidth(portraitSize)
        self.ownerWindow.btnCycleJob:setHeight(inventoryButtonHeight)
    end

    self:drawReserveBar(
        barsX,
        topY,
        barsWidth,
        barHeight,
        "Health",
        { r = 0.74, g = 0.24, b = 0.24 },
        self.healthData,
        self.healthDisplayRatio
    )

    topY = topY + 44

    self:drawReserveBar(
        barsX,
        topY,
        barsWidth,
        barHeight,
        "Hunger",
        { r = 0.48, g = 0.30, b = 0.14 },
        self.caloriesData,
        self.caloriesDisplayRatio
    )

    topY = topY + 44

    self:drawReserveBar(
        barsX,
        topY,
        barsWidth,
        barHeight,
        "Hydration",
        { r = 0.36, g = 0.74, b = 1.00 },
        self.hydrationData,
        self.hydrationDisplayRatio
    )

    topY = topY + 44

    if self.tirednessData then
        self:drawReserveBar(
            barsX,
            topY,
            barsWidth,
            barHeight,
            "Tiredness",
            { r = 0.69, g = 0.33, b = 0.86 },
            self.tirednessData,
            self.tirednessDisplayRatio
        )

        topY = topY + 44
    end

    if self.activityData then
        self:drawReserveBar(
            barsX,
            topY,
            barsWidth,
            barHeight,
            tostring(self.activityData.displayText or self.activityData.label or "Working"),
            self.activityData.color or { r = 0.78, g = 0.78, b = 0.78 },
            self.activityData,
            self.activityDisplayRatio
        )
    end
end

Internal.LabourReservePanel = LabourProfileCard
