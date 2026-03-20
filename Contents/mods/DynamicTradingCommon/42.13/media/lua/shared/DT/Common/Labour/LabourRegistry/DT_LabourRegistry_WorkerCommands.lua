DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry

function Registry.SetWorkerState(worker, state)
    if worker then
        worker.state = state
    end
end

function Registry.SetWorkerJobEnabled(worker, enabled)
    if worker then
        worker.jobEnabled = enabled == true
    end
end

function Registry.SetWorkerJobType(worker, jobType)
    if not worker then return end
    worker.jobType = Config.NormalizeJobType(jobType)
    worker.profession = worker.jobType
    worker.workProgress = 0
end

return Registry
