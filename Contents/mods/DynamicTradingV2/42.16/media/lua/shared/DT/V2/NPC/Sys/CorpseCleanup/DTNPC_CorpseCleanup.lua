DTNPCCorpseCleanup = DTNPCCorpseCleanup or {}
DTNPCCorpseCleanup.Internal = DTNPCCorpseCleanup.Internal or {}

if DTNPCCorpseCleanup.EntryLoaded then
    return DTNPCCorpseCleanup
end

DTNPCCorpseCleanup.EntryLoaded = true

require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup_Common"
require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup_Scan"
require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup_Classify"
require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup_Policy"
require "DT/V2/NPC/Sys/CorpseCleanup/DTNPC_CorpseCleanup_Core"

return DTNPCCorpseCleanup
