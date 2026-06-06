-- ==============================================================================
-- DT_Dialogue_Ambient_Config.lua
-- Client-side display settings for overhead NPC ambient dialogue.
-- Dialogue content is loaded from DynamicTradingCommon archetype files.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbientConfig = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig or {}
DTNPCClient.AmbientDialogueConfig = DTNPCClient.DialogueAmbientConfig

local Config = DTNPCClient.DialogueAmbientConfig

Config.TriggerDistance = Config.TriggerDistance or 4.0
Config.MaxDrawDistance = Config.MaxDrawDistance or 18.0
Config.FloorTolerance = Config.FloorTolerance or 1
Config.DisplayTimeMs = Config.DisplayTimeMs or 4200
Config.InitialDelayMinMs = Config.InitialDelayMinMs or 500
Config.InitialDelayMaxMs = Config.InitialDelayMaxMs or 2200
Config.RepeatDelayMinMs = Config.RepeatDelayMinMs or 9000
Config.RepeatDelayMaxMs = Config.RepeatDelayMaxMs or 16000
Config.FloatSpeed = Config.FloatSpeed or 28
Config.ResolveRetryMs = Config.ResolveRetryMs or 1000
Config.StaleTrackMs = Config.StaleTrackMs or 15000
Config.UpdateRate = Config.UpdateRate or 6
Config.TextYOffset = Config.TextYOffset or 170

Config.SentimentColors = Config.SentimentColors or {
    neutral = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
    friendly = { r = 0.75, g = 1.0, b = 0.75, a = 1.0 },
    trading = { r = 1.0, g = 0.87, b = 0.35, a = 1.0 },
    resting = { r = 0.72, g = 0.86, b = 1.0, a = 1.0 },
    warning = { r = 1.0, g = 0.68, b = 0.35, a = 1.0 },
    angry = { r = 1.0, g = 0.45, b = 0.45, a = 1.0 },
    hostile = { r = 1.0, g = 0.45, b = 0.45, a = 1.0 },
}

function Config.GetSentimentColor(sentiment)
    return Config.SentimentColors[sentiment]
        or Config.SentimentColors.neutral
        or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
end
