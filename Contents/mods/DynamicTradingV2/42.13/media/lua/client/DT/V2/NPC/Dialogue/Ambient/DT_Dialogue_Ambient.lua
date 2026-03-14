-- ==============================================================================
-- DT_Dialogue_Ambient.lua
-- Entry point for V2 NPC ambient dialogue modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

require "ISUI/ISUIElement"
require "DT/Common/Dialogue/DT_Dialogue_Ambient"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Config"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Shared"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Tracking"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Speech"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Debug"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Manager"
require "DT/V2/NPC/Dialogue/Ambient/DT_Dialogue_Ambient_Events"
