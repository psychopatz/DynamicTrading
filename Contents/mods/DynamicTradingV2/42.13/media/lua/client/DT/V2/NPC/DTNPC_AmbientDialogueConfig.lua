-- ==============================================================================
-- DTNPC_AmbientDialogueConfig.lua
-- Modular ambient dialogue pools for client-only overhead NPC chatter.
-- Schema supports either:
--   { dialogue = "Text", sentiment = "neutral" }
-- or tuple style:
--   { "Text", "neutral" }
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.AmbientDialogueConfig = DTNPCClient.AmbientDialogueConfig or {}

local Config = DTNPCClient.AmbientDialogueConfig

Config.TriggerDistance = Config.TriggerDistance or 4.0
Config.MaxDrawDistance = Config.MaxDrawDistance or 18.0
Config.FloorTolerance = Config.FloorTolerance or 1
Config.DisplayTimeMs = Config.DisplayTimeMs or 4200
Config.CooldownMs = Config.CooldownMs or 14000
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
    hostile = { r = 1.0, g = 0.45, b = 0.45, a = 1.0 },
}

Config.Registry = Config.Registry or {
    Combo = {
        Trading = {
            Attack = {
                { "Back off. I'm busy surviving, not bargaining.", "hostile" },
                { "Bad timing. Handle the dead first, trade later.", "warning" },
            },
            AttackRange = {
                { "Keep low. I'm covering this spot.", "warning" },
                { "No shopping while rounds are flying.", "hostile" },
            },
        },
    },
    Status = {
        Trading = {
            { "Fresh stock today. Take a look while it lasts.", "trading" },
            { "If you're buying, now's a good time.", "trading" },
            { "I've got goods moving. Don't wait too long.", "trading" },
            { "Looking to trade? I've got a few things worth seeing.", "trading" },
            { "Business is open. Let's keep it quick and clean.", "trading" },
        },
        Resting = {
            { "I'm resting right now. Come back when I'm back on shift.", "resting" },
            { "Taking a breather. The road's been rough today.", "resting" },
            { "Not trading yet. Just trying to stay on my feet.", "resting" },
            { "Give me a minute. I'm off the clock for now.", "resting" },
            { "Quiet day. I'm keeping my head down and getting some rest.", "resting" },
        },
        Working = {
            { "Keeping watch and staying busy.", "friendly" },
            { "Working right now. Stay sharp out there.", "friendly" },
            { "I'm on task. Make it quick if you need something.", "warning" },
        },
        Away = {
            { "Just passing through. Don't expect me to stay long.", "warning" },
            { "I'm on the move. Catch me later.", "warning" },
        },
        Default = {
            { "Still breathing. That's something.", "neutral" },
            { "You need something?", "neutral" },
            { "Another day in Knox Country.", "neutral" },
        },
    },
    State = {
        Idle = {
            { "Just keeping an eye on things.", "neutral" },
            { "Quiet for now. Let's keep it that way.", "neutral" },
        },
        Guard = {
            { "I'm watching this area. Stay alert.", "warning" },
            { "Holding this position. Don't draw trouble over here.", "warning" },
        },
        Trading = {
            { "Come closer if you're here to trade.", "trading" },
            { "I've got some stock ready to move.", "trading" },
        },
        Follow = {
            { "I'm with you. Lead the way.", "friendly" },
            { "Keep moving. I'll stay close.", "friendly" },
        },
        Flee = {
            { "Not now. I need to move.", "warning" },
            { "Run first, talk later.", "warning" },
        },
        Attack = {
            { "Stay back unless you're helping.", "hostile" },
            { "This is not the time for chatter.", "hostile" },
        },
        AttackRange = {
            { "Keep your head down.", "warning" },
            { "Distance is life right now.", "warning" },
        },
        Default = {
            { "Stay safe.", "neutral" },
        },
    },
}

function Config.NormalizeEntry(entry)
    if not entry then return nil end

    if type(entry) == "string" then
        return { dialogue = entry, sentiment = "neutral" }
    end

    if type(entry) ~= "table" then
        return nil
    end

    local dialogue = entry.dialogue or entry[1]
    if not dialogue or dialogue == "" then
        return nil
    end

    return {
        dialogue = dialogue,
        sentiment = entry.sentiment or entry[2] or "neutral"
    }
end

function Config.GetSentimentColor(sentiment)
    return Config.SentimentColors[sentiment]
        or Config.SentimentColors.neutral
        or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
end

function Config.GetPool(npcData)
    local registry = Config.Registry or {}
    local status = npcData and npcData.status or "Default"
    local state = npcData and npcData.state or "Default"

    local comboPool = registry.Combo
        and registry.Combo[status]
        and registry.Combo[status][state]
    if comboPool and #comboPool > 0 then
        return comboPool
    end

    local statusPool = registry.Status and registry.Status[status]
    if statusPool and #statusPool > 0 then
        return statusPool
    end

    local statePool = registry.State and registry.State[state]
    if statePool and #statePool > 0 then
        return statePool
    end

    local defaultStatusPool = registry.Status and registry.Status.Default
    if defaultStatusPool and #defaultStatusPool > 0 then
        return defaultStatusPool
    end

    local defaultStatePool = registry.State and registry.State.Default
    if defaultStatePool and #defaultStatePool > 0 then
        return defaultStatePool
    end

    return nil
end

function Config.GetDialogueForNPC(npcData)
    local pool = Config.GetPool(npcData)
    if not pool or #pool == 0 then
        return nil
    end

    local entry = Config.NormalizeEntry(pool[ZombRand(#pool) + 1])
    if not entry then
        return nil
    end

    return entry
end
