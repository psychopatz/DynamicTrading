-- ==============================================================================
-- DT_Dialogue_Ambient_Shared.lua
-- Shared ambient dialogue state, globals, and constants.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local Ambient = DTNPCClient.DialogueAmbient

ISDTNPCAmbientDialogueManager = ISDTNPCAmbientDialogueManager or ISUIElement:derive("ISDTNPCAmbientDialogueManager")

Ambient.FONT_DIALOGUE = Ambient.FONT_DIALOGUE or UIFont.Small
Ambient.textManager = Ambient.textManager or getTextManager()
Ambient.Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig

DTNPCClient.DialogueAmbientManagers = DTNPCClient.DialogueAmbientManagers or DTNPCClient.AmbientDialogueManagers or {}
DTNPCClient.AmbientDialogueManagers = DTNPCClient.DialogueAmbientManagers
DTNPCClient.DialogueAmbientTracked = DTNPCClient.DialogueAmbientTracked or DTNPCClient.AmbientDialogueTracked or {}
DTNPCClient.AmbientDialogueTracked = DTNPCClient.DialogueAmbientTracked
