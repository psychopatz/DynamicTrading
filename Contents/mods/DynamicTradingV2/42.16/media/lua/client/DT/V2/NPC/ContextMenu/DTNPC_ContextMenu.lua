-- ==============================================================================
-- DTNPC_ContextMenu.lua
-- Entry point for production NPC context menu modules.
-- ==============================================================================

pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")

DTNPCContextMenu = DTNPCContextMenu or {}
DTNPCContextMenu.Internal = DTNPCContextMenu.Internal or {}
DTNPCContextMenu.Providers = DTNPCContextMenu.Providers or {}

if DTNPCContextMenu.EntryLoaded then
    return
end

DTNPCContextMenu.EntryLoaded = true

require "DT/V2/NPC/ContextMenu/DTNPC_ContextMenu_Core"
require "DT/V2/NPC/ContextMenu/DTNPC_ContextMenu_Providers"
require "DT/V2/NPC/ContextMenu/Providers/DTNPC_ContextMenuProvider_Talk"
require "DT/V2/NPC/ContextMenu/Providers/DTNPC_ContextMenuProvider_FollowMethod"
require "DT/V2/NPC/ContextMenu/Providers/DTNPC_ContextMenuProvider_JobUI"
require "DT/V2/NPC/ContextMenu/DTNPC_ContextMenu_Production"
