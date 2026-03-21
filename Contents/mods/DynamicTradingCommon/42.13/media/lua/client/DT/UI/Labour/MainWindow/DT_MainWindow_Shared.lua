DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

Internal.Config = DT_Labour.Config
Internal.MoneyProvider = DT_MainWindow.MoneyProvider or {}
DynamicTrading.TradingProvider.AttachCore(Internal.MoneyProvider)
DT_MainWindow.MoneyProvider = Internal.MoneyProvider

function Internal.formatReserveValue(value)
    return string.format("%.0f", tonumber(value) or 0)
end

function Internal.formatDecimal(value, decimals)
    local places = tonumber(decimals) or 2
    return string.format("%." .. tostring(places) .. "f", tonumber(value) or 0)
end

function Internal.formatBool(value)
    return value and "Yes" or "No"
end

function Internal.formatCoords(x, y, z)
    if x == nil or y == nil then
        return "Unassigned"
    end

    return "("
        .. tostring(math.floor(tonumber(x) or 0))
        .. ", "
        .. tostring(math.floor(tonumber(y) or 0))
        .. ", "
        .. tostring(math.floor(tonumber(z) or 0))
        .. ")"
end

function Internal.getReserveDaysLeft(storedAmount, dailyNeed)
    local perDay = tonumber(dailyNeed) or 0
    if perDay <= 0 then
        return nil
    end

    local days = (tonumber(storedAmount) or 0) / perDay
    return math.max(0, days)
end

function Internal.getReserveHoursLeft(storedAmount, hourlyNeed)
    local perHour = tonumber(hourlyNeed) or 0
    if perHour <= 0 then
        return nil
    end

    return math.max(0, (tonumber(storedAmount) or 0) / perHour)
end

function Internal.formatDurationHours(hoursLeft)
    if hoursLeft == nil then
        return "n/a"
    end

    local safeHours = math.max(0, tonumber(hoursLeft) or 0)
    if safeHours <= 0 then
        return "empty now"
    end
    if safeHours < 1 then
        return "< 1h"
    end

    local roundedHours = math.floor(safeHours + 0.5)
    local days = math.floor(roundedHours / 24)
    local hours = roundedHours % 24
    if days <= 0 then
        return tostring(roundedHours) .. "h"
    end
    if hours <= 0 then
        return tostring(days) .. "d"
    end
    return tostring(days) .. "d " .. tostring(hours) .. "h"
end

function Internal.formatDaysAndEta(daysLeft, hoursLeft)
    if daysLeft == nil then
        return "n/a"
    end

    return Internal.formatDecimal(daysLeft, 2) .. "d (" .. Internal.formatDurationHours(hoursLeft) .. ")"
end

function Internal.getNextRefillHours(caloriesHoursLeft, hydrationHoursLeft)
    if caloriesHoursLeft and hydrationHoursLeft then
        return math.min(caloriesHoursLeft, hydrationHoursLeft)
    end
    return caloriesHoursLeft or hydrationHoursLeft
end

function Internal.getReserveBarData(storedAmount, dailyNeed)
    local stored = math.max(0, tonumber(storedAmount) or 0)
    local usage = math.max(0, tonumber(dailyNeed) or 0)
    if usage <= 0 then
        return {
            stored = stored,
            usage = usage,
            fillRatio = 0,
            overflow = 0,
            daysLeft = nil
        }
    end

    local rawRatio = stored / usage
    return {
        stored = stored,
        usage = usage,
        fillRatio = math.max(0, math.min(1, rawRatio)),
        overflow = math.max(0, stored - usage),
        daysLeft = math.max(0, rawRatio)
    }
end

function Internal.getHealthBarData(currentHp, maxHp)
    local safeMax = math.max(1, tonumber(maxHp) or 100)
    local safeCurrent = math.max(0, math.min(safeMax, tonumber(currentHp) or safeMax))
    return {
        stored = safeCurrent,
        usage = safeMax,
        fillRatio = safeCurrent / safeMax,
        overflow = 0,
        daysLeft = nil,
        captionText = safeCurrent <= 0 and "dead" or "current hp",
        summaryText = Internal.formatReserveValue(safeCurrent) .. " / " .. Internal.formatReserveValue(safeMax)
    }
end

function Internal.getWorkerGender(worker)
    return worker and worker.isFemale and "Female" or "Male"
end

function Internal.getWorkerPortraitTexture(worker)
    if not worker then
        return nil
    end

    local archetype = tostring(worker.archetypeID or "General")
    local gender = Internal.getWorkerGender(worker)
    local seed = tonumber(worker.identitySeed) or 1
    local portraitID = 1
    local pathFolder = "media/ui/Portraits/" .. archetype .. "/" .. gender .. "/"

    if DynamicTrading and DynamicTrading.Portraits then
        if DynamicTrading.Portraits.GetMappedID then
            portraitID = DynamicTrading.Portraits.GetMappedID(archetype, gender, seed)
        end
        if DynamicTrading.Portraits.GetPathFolder then
            pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
        end
    end

    local tex = getTexture(pathFolder .. tostring(portraitID) .. ".png")
    if tex then
        return tex
    end

    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

function Internal.getJobDisplayName(worker, profile)
    local sourceProfile = profile or (Internal.Config.GetJobProfile and Internal.Config.GetJobProfile(worker and worker.jobType)) or {}
    return tostring(sourceProfile.displayName or worker.jobType or worker.profession or "Unknown")
end

function Internal.getNpcConditionLabel(worker)
    local state = tostring(worker and worker.state or "Idle")
    if state == "Dehydrated" then
        return "Dehydrated"
    end
    if state == "Starving" then
        return "Starving"
    end
    if state == "Dead" then
        return "Dead"
    end
    return "Stable"
end

function Internal.formatWorkerListSubtitle(worker)
    local npcCondition = Internal.getNpcConditionLabel(worker)
    local jobType = Internal.getJobDisplayName(worker)
    local state = tostring(worker.state or "Idle")
    return npcCondition .. " | " .. jobType .. " | " .. state
end

function Internal.buildToolInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.toolLedger or {}) do
        parts[#parts + 1] = tostring(entry.displayName or entry.fullType or "Unknown Tool")
    end

    if #parts == 0 then
        return "None assigned yet."
    end

    return table.concat(parts, ", ")
end

function Internal.buildSupplyInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.nutritionLedger or {}) do
        local name = tostring(entry.displayName or entry.fullType or "Supply")
        local calories = Internal.formatReserveValue(entry.caloriesRemaining)
        local hydration = Internal.formatReserveValue(entry.hydrationRemaining)
        parts[#parts + 1] = name .. " [" .. calories .. " cal, " .. hydration .. " hyd]"
    end

    if #parts == 0 then
        return "None stored yet."
    end

    return table.concat(parts, ", ")
end

function Internal.getPlayerWealth(player)
    if DT_MainWindow.MoneyProvider and DT_MainWindow.MoneyProvider.getPlayerWealth then
        return DT_MainWindow.MoneyProvider:getPlayerWealth(player)
    end
    return 0
end

function Internal.getOwnerUsername()
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if config.GetOwnerUsername then
        return config.GetOwnerUsername(player)
    end
    return "local"
end

function Internal.appendHeldItem(targetList, seenIDs, itemObj)
    if not itemObj or not itemObj.getID then
        return
    end

    local itemID = itemObj:getID()
    if itemID == nil or seenIDs[itemID] then
        return
    end

    seenIDs[itemID] = true
    targetList[#targetList + 1] = itemObj
end

function Internal.getHeldItems()
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if not player then
        return {}
    end

    local items = {}
    local seenIDs = {}
    Internal.appendHeldItem(items, seenIDs, player.getPrimaryHandItem and player:getPrimaryHandItem() or nil)
    Internal.appendHeldItem(items, seenIDs, player.getSecondaryHandItem and player:getSecondaryHandItem() or nil)
    return items
end

function Internal.resolveWorkerSummaries()
    if isClient() and not isServer() then
        return DT_MainWindow.cachedWorkers or {}
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerSummariesForOwner then
        return DT_Labour.Registry.GetWorkerSummariesForOwner(Internal.getOwnerUsername())
    end

    return {}
end

function Internal.resolveWorkerDetail(workerID)
    if not workerID then
        return nil
    end

    if isClient() and not isServer() then
        local cache = DT_MainWindow.cachedDetails or {}
        return cache[workerID]
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerDetailsForOwner then
        return DT_Labour.Registry.GetWorkerDetailsForOwner(Internal.getOwnerUsername(), workerID)
    end

    return nil
end

function DT_MainWindow:sendLabourCommand(command, args)
    local config = Internal.Config
    local player = config.GetPlayerObject and config.GetPlayerObject() or nil
    if not player then
        return false
    end

    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end

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
    return o
end

function LabourProfileCard:initialise()
    ISPanel.initialise(self)
end

function LabourProfileCard:setWorker(worker)
    self.worker = worker
    self.profile = worker and Internal.Config.GetJobProfile and Internal.Config.GetJobProfile(worker.jobType) or nil
    if not worker then
        self.portraitTex = nil
        self.caloriesData = nil
        self.hydrationData = nil
        self.healthData = nil
        self.caloriesTargetRatio = 0
        self.hydrationTargetRatio = 0
        self.healthTargetRatio = 0
        return
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

    self.caloriesData = Internal.getReserveBarData(worker.caloriesCached, dailyCaloriesNeed)
    self.hydrationData = Internal.getReserveBarData(worker.hydrationCached, dailyHydrationNeed)
    self.healthData = Internal.getHealthBarData(worker.hp, worker.maxHp)
    self.caloriesTargetRatio = self.caloriesData.fillRatio
    self.hydrationTargetRatio = self.hydrationData.fillRatio
    self.healthTargetRatio = self.healthData.fillRatio
    self.portraitTex = Internal.getWorkerPortraitTexture(worker)
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
    local safeData = data or { stored = 0, usage = 0, overflow = 0, daysLeft = nil }
    self:drawRect(x, y, width, height, 0.35, 0.08, 0.08, 0.08)
    self:drawRectBorder(x, y, width, height, 0.2, 1, 1, 1)

    local fillWidth = math.floor((width - 4) * math.max(0, math.min(1, displayRatio or 0)))
    if fillWidth > 0 then
        self:drawRect(x + 2, y + 2, fillWidth, height - 4, 0.9, color.r, color.g, color.b)
    end

    local labelWidth = getTextManager():MeasureStringX(UIFont.Small, label)
    self:drawText(label, x + math.max(8, (width - labelWidth) / 2), y + 2, 0.95, 0.95, 0.95, 1, UIFont.Small)

    local daysText = safeData.captionText or Internal.formatDaysAndEta(safeData.daysLeft, safeData.daysLeft and (safeData.daysLeft * 24) or nil)
    local totalsText = safeData.summaryText or (Internal.formatReserveValue(safeData.stored) .. " stored | Overflow " .. Internal.formatReserveValue(safeData.overflow))
    self:drawText(daysText, x, y + height + 4, 0.86, 0.86, 0.86, 1, UIFont.Small)
    self:drawTextRight(totalsText, x + width, y + height + 4, 0.66, 0.66, 0.66, 1, UIFont.Small)
end

function LabourProfileCard:prerender()
    ISPanel.prerender(self)

    local pad = 12
    if not self.worker then
        self:drawTextCentre("Select a worker to inspect labour reserves and daily upkeep.", self.width / 2, self.height / 2 - 8, 0.65, 0.65, 0.65, 0.9, UIFont.Medium)
        return
    end

    self.caloriesDisplayRatio = animateRatio(self.caloriesDisplayRatio, self.caloriesTargetRatio)
    self.hydrationDisplayRatio = animateRatio(self.hydrationDisplayRatio, self.hydrationTargetRatio)
    self.healthDisplayRatio = animateRatio(self.healthDisplayRatio, self.healthTargetRatio)

    local portraitSize = math.min(104, self.height - (pad * 2))
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
        Internal.getJobDisplayName(worker, profile) .. " | " .. tostring(worker.state or "Idle"),
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
end

Internal.LabourReservePanel = LabourProfileCard
