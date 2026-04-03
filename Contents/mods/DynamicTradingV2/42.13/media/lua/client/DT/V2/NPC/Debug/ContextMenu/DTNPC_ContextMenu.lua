-- ==============================================================================
-- DTNPC_ContextMenu.lua
-- Entry point for the debug NPC context menu modules.
-- Loads context menu modules in explicit dependency order.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.EntryLoaded then
    return DTNPCMenu
end

Menu.EntryLoaded = true
Menu.Modules = Menu.Modules or {}

require "ISUI/ISTextBox"
require "DT/V2/NPC/Debug/DTNPC_Debugger"

require "DT/V2/NPC/Debug/ContextMenu/DTNPC_ContextMenu_Helpers"
require "DT/V2/NPC/Debug/ContextMenu/DTNPC_ContextMenu_Orders"
require "DT/V2/NPC/Debug/ContextMenu/DTNPC_ContextMenu_Markers"
require "DT/V2/NPC/Debug/ContextMenu/DTNPC_ContextMenu_DebugActions"
require "DT/V2/NPC/Debug/ContextMenu/DTNPC_ContextMenu_Builder"

return DTNPCMenu
