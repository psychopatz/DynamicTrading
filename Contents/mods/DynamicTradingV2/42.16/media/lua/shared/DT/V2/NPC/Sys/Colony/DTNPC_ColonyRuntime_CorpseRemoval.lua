DTNPCColonyRuntime = DTNPCColonyRuntime or {}

local Runtime = DTNPCColonyRuntime

if Runtime.CorpseRemovalLoaded then
    return Runtime
end

Runtime.CorpseRemovalLoaded = true

require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup"

function Runtime.GetCorpseDumpPoint(npcData)
    if DTNPCCorpseCleanup and DTNPCCorpseCleanup.GetCleanupAnchor then
        return DTNPCCorpseCleanup.GetCleanupAnchor(npcData, {
            mode = "colony",
        })
    end
    return Runtime.GetWorkPoint and Runtime.GetWorkPoint(npcData) or nil
end

function Runtime.AcquireCorpseRemovalTask(npcData)
    return DTNPCCorpseCleanup and DTNPCCorpseCleanup.AcquireTask and DTNPCCorpseCleanup.AcquireTask(npcData, {
        mode = "colony",
    }) or nil
end

function Runtime.RefreshCorpseRemovalTask(npcData, task, _, zombie)
    return DTNPCCorpseCleanup and DTNPCCorpseCleanup.RefreshTask and DTNPCCorpseCleanup.RefreshTask(npcData, task, zombie) or false
end

function Runtime.ReleaseCorpseRemovalTask(npcData, task)
    return DTNPCCorpseCleanup and DTNPCCorpseCleanup.AbortTask and DTNPCCorpseCleanup.AbortTask(npcData, task, nil) or false
end

function Runtime.PickupCorpseRemovalTask()
    return true
end

function Runtime.AbortCorpseRemovalTask(npcData, task, zombie)
    return DTNPCCorpseCleanup and DTNPCCorpseCleanup.AbortTask and DTNPCCorpseCleanup.AbortTask(npcData, task, zombie) or false
end

function Runtime.DropCorpseRemovalTask(npcData, task, _, zombie)
    return DTNPCCorpseCleanup and DTNPCCorpseCleanup.CommitTask and DTNPCCorpseCleanup.CommitTask(npcData, task, zombie) or false
end

return Runtime
