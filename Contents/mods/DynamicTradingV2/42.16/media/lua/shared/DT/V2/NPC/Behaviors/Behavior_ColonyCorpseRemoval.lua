DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Behaviors/Behavior_CorpseCleanup"

DTNPCLogic.Behaviors["ColonyCorpseRemoval"] = function(zombie, npcData)
    DTNPCLogic.RunCorpseCleanupBehavior(zombie, npcData, {
        colony = true,
        policyMode = "colony",
    })
end

return DTNPCLogic
