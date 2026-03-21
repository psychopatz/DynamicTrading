require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/DT_Labour_Nutrition"
require "DT/Common/Labour/DT_Labour_Output"
require "DT/Common/Labour/DT_Labour_Presentation"

DT_Labour = DT_Labour or {}
DT_Labour.Sim = DT_Labour.Sim or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Nutrition = DT_Labour.Nutrition
local Output = DT_Labour.Output
local Presentation = DT_Labour.Presentation
local Sim = DT_Labour.Sim

if isClient() and not isServer() then
    return Sim
end

Sim.tickCounter = Sim.tickCounter or 0
Sim.lastProcessedHour = Sim.lastProcessedHour or -1

local function clampHours(value)
    return math.max(0, tonumber(value) or 0)
end

local function clampCheckpoint(value, fallback)
    local safeValue = math.floor(tonumber(value) or tonumber(fallback) or 0)
    return math.max(0, safeValue)
end

local function clampHp(value, maxHp)
    local safeMax = math.max(1, tonumber(maxHp) or Config.DEFAULT_WORKER_MAX_HP or 100)
    return math.max(0, math.min(safeMax, tonumber(value) or safeMax))
end

local function applyInterval(workableHours, hp, maxHp, intervalHours, hasCalories, hasHydration, canWork)
    if intervalHours <= 0 then
        return workableHours, hp
    end

    if canWork and hasCalories and hasHydration then
        workableHours = workableHours + intervalHours
    end

    if hasCalories and hasHydration then
        hp = clampHp(hp + (intervalHours * (Config.WORKER_HP_REGEN_PER_HOUR or 1)), maxHp)
    else
        hp = clampHp(hp - (intervalHours * (Config.WORKER_HP_LOSS_PER_HOUR or 1)), maxHp)
    end

    return workableHours, hp
end

local function processNutrition(worker, currentHour, dailyCaloriesNeed, dailyHydrationNeed, canWork)
    local lastHour = math.floor(worker.lastSimHour or currentHour)
    local currentCheckpoint = Config.GetMealCheckpointCountAtHour(currentHour)
    local previousCheckpoint = clampCheckpoint(
        worker.lastNutritionCheckpoint,
        Config.GetMealCheckpointCountAtHour(lastHour)
    )

    if previousCheckpoint > currentCheckpoint then
        previousCheckpoint = currentCheckpoint
    end

    local hasCalories = (tonumber(worker.caloriesCached) or 0) > 0
    local hasHydration = (tonumber(worker.hydrationCached) or 0) > 0
    local maxHp = math.max(1, tonumber(worker.maxHp) or Config.DEFAULT_WORKER_MAX_HP or 100)
    local hp = clampHp(worker.hp, maxHp)
    local workableHours = 0
    local segmentStart = lastHour

    for checkpoint = previousCheckpoint + 1, currentCheckpoint do
        local checkpointHour = Config.GetMealCheckpointHourByCount(checkpoint)
        local intervalHours = math.max(0, math.min(currentHour, checkpointHour) - segmentStart)
        workableHours, hp = applyInterval(
            workableHours,
            hp,
            maxHp,
            intervalHours,
            hasCalories,
            hasHydration,
            canWork
        )
        segmentStart = math.max(segmentStart, checkpointHour)

        local meal = Config.GetMealProfileByCheckpoint(checkpoint) or {}
        hasCalories, hasHydration = Nutrition.ConsumeAmounts(
            worker,
            (tonumber(dailyCaloriesNeed) or 0) * (tonumber(meal.caloriesShare) or 0),
            (tonumber(dailyHydrationNeed) or 0) * (tonumber(meal.hydrationShare) or 0)
        )
    end

    local tailHours = math.max(0, currentHour - segmentStart)
    workableHours, hp = applyInterval(
        workableHours,
        hp,
        maxHp,
        tailHours,
        hasCalories,
        hasHydration,
        canWork
    )

    worker.lastNutritionCheckpoint = currentCheckpoint
    worker.hp = hp

    return workableHours, hasCalories, hasHydration, hp
end

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local speedMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local lastHour = math.floor(worker.lastSimHour or currentHour)
    local deltaHours = math.max(0, currentHour - lastHour)

    if worker.state == Config.States.Dead then
        worker.jobEnabled = false
        worker.lastNutritionCheckpoint = Config.GetMealCheckpointCountAtHour(currentHour)
        if deltaHours > 0 then
            worker.lastSimHour = currentHour
        end
        Registry.RecalculateWorker(worker)
        return
    end

    Sites.RefreshWorkerSite(worker)
    local toolsReady = Registry.WorkerHasRequiredTools(worker)

    worker.siteState = worker.siteState or "Deferred"
    worker.toolState = toolsReady and "Ready" or "Missing"

    local dailyCaloriesNeed = Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    local dailyHydrationNeed = Config.GetEffectiveDailyHydrationNeed(worker, profile)
    local canWork = worker.jobEnabled and toolsReady
    local workableHours, hasCalories, hasHydration, hp = processNutrition(
        worker,
        currentHour,
        dailyCaloriesNeed,
        dailyHydrationNeed,
        canWork
    )

    worker.starvationHours = 0
    worker.dehydrationHours = 0

    if hp <= 0 then
        worker.state = Config.States.Dead
        worker.jobEnabled = false
    elseif not worker.jobEnabled then
        worker.state = Config.States.Idle
    elseif not toolsReady then
        worker.state = Config.States.MissingTool
    elseif not hasHydration then
        worker.state = Config.States.Dehydrated
    elseif not hasCalories then
        worker.state = Config.States.Starving
    else
        worker.state = Config.States.Working
        worker.workProgress = clampHours(worker.workProgress) + (workableHours * speedMultiplier)
        while worker.workProgress >= (profile.cycleHours or 24) do
            worker.workProgress = worker.workProgress - (profile.cycleHours or 24)
            for _, entry in ipairs(Output.GenerateForJob(profile)) do
                Registry.AddOutputEntry(worker, entry)
            end
        end
    end

    if deltaHours > 0 then
        worker.lastSimHour = currentHour
    end
    Registry.RecalculateWorker(worker)
end

function Sim.ProcessAllWorkers(currentHour)
    currentHour = currentHour or Config.GetCurrentHour()
    local data = Registry.GetData()
    for _, worker in pairs(data.Workers or {}) do
        Sim.ProcessWorker(worker, currentHour)
    end
    Registry.Save()
end

function Sim.OnTick()
    Sim.tickCounter = Sim.tickCounter + 1
    if Sim.tickCounter < Config.SIM_TICK_RATE then
        return
    end

    Sim.tickCounter = 0
    local currentHour = Config.GetCurrentHour()
    if currentHour == Sim.lastProcessedHour then
        return
    end

    Sim.lastProcessedHour = currentHour
    Sim.ProcessAllWorkers(currentHour)
end

Events.OnTick.Add(Sim.OnTick)

return Sim
