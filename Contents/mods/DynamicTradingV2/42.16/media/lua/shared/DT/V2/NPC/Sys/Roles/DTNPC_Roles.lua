-- ==============================================================================
-- DTNPC_Roles.lua
-- Entry point for shared NPC role and capability policy.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}
DTNPCRoles.Internal = DTNPCRoles.Internal or {}

if DTNPCRoles.EntryLoaded then
    return
end

DTNPCRoles.EntryLoaded = true

require "DT/V2/NPC/Sys/Roles/DTNPC_Roles_Identity"
require "DT/V2/NPC/Sys/Roles/DTNPC_Roles_Ownership"
require "DT/V2/NPC/Sys/Roles/DTNPC_Roles_Classification"
require "DT/V2/NPC/Sys/Roles/DTNPC_Roles_Home"
require "DT/V2/NPC/Sys/Roles/DTNPC_Roles_Requirements"
