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

function Sim.ProcessWorker(worker, currentHour)
    if not worker then return end

    Registry.RecalculateWorker(worker)

    local profile = Config.GetJobProfile(worker.jobType)
    local speedMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local lastHour = math.floor(worker.lastSimHour or currentHour)
    local deltaHours = math.max(0, currentHour - lastHour)

    Sites.RefreshWorkerSite(worker)
    local toolsReady = Registry.WorkerHasRequiredTools(worker)

    worker.siteState = worker.siteState or "Deferred"
    worker.toolState = toolsReady and "Ready" or "Missing"

    local caloriesPerHour = (worker.dailyCaloriesNeed or profile.dailyCaloriesNeed) / Config.HOURS_PER_DAY
    local hydrationPerHour = (worker.dailyHydrationNeed or profile.dailyHydrationNeed) / Config.HOURS_PER_DAY
    local hasCalories = (tonumber(worker.caloriesCached) or 0) > 0
    local hasHydration = (tonumber(worker.hydrationCached) or 0) > 0
    if deltaHours > 0 then
        hasCalories, hasHydration = Nutrition.ConsumeForHours(worker, caloriesPerHour, hydrationPerHour, deltaHours)
    end

    worker.starvationHours = hasCalories and 0 or (clampHours(worker.starvationHours) + deltaHours)
    worker.dehydrationHours = hasHydration and 0 or (clampHours(worker.dehydrationHours) + deltaHours)

    if worker.state ~= Config.States.Dead then
        if worker.dehydrationHours >= Config.DEFAULT_DEHYDRATION_DEATH_HOURS
            or worker.starvationHours >= Config.DEFAULT_STARVATION_DEATH_HOURS then
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
            worker.workProgress = clampHours(worker.workProgress) + (deltaHours * speedMultiplier)
            while worker.workProgress >= (profile.cycleHours or 24) do
                worker.workProgress = worker.workProgress - (profile.cycleHours or 24)
                for _, entry in ipairs(Output.GenerateForJob(profile)) do
                    Registry.AddOutputEntry(worker, entry)
                end
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
