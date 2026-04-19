require "DT/Common/Dialogue/DT_Dialogue_Core"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.RadioTracker = DynamicTrading.Dialogue.RadioTracker or {}

local Core = DynamicTrading.Dialogue.Core

local function requireTrackingDialogue(archetype)
    pcall(require, "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Tracking")
    pcall(require, "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Tracking")
    if archetype and archetype ~= "" and archetype ~= "General" then
        pcall(require, "DT/Common/ArchetypeDefinitions/" .. tostring(archetype) .. "/Dialogue/DT_" .. tostring(archetype) .. "_Tracking")
    end
end

local function replaceTokens(text, trader, context)
    local args = {
        traderName = trader and trader.name or "Trader",
    }
    text = Core.FormatMessage(text, args)

    local location = context and context.location or {}
    local replacements = {
        npc = trader and trader.name or "Trader",
        coords = context and context.coordsText or "unknown coordinates",
        site = context and context.siteDescription or "out in the open",
        town = location.town or "Unknown",
        county = location.county or "Unknown",
        zone = location.zoneLabel or "open ground",
        room = location.roomLabel or "outside",
        building = location.buildingLabel or "the area",
    }

    for key, value in pairs(replacements) do
        text = string.gsub(text, "{" .. tostring(key) .. "}", tostring(value or ""))
    end

    text = string.gsub(text, "%s+([%.,%!%?])", "%1")
    text = string.gsub(text, "%s+", " ")
    return text
end

function DynamicTrading.Dialogue.RadioTracker.GeneratePlayerRequest(trader, context)
    requireTrackingDialogue(trader and (trader.archetypeID or trader.archetype) or nil)
    local pool = Core.GetDialoguePool("Player", "Tracking", "Request")
    local rawText = Core.PickRandom(pool) or "{npc}, send me your coordinates."
    return replaceTokens(rawText, trader, context)
end

function DynamicTrading.Dialogue.RadioTracker.GeneratePlayerAway(trader, context)
    requireTrackingDialogue(trader and (trader.archetypeID or trader.archetype) or nil)
    local pool = Core.GetDialoguePool("Player", "Tracking", "Away")
    local rawText = Core.PickRandom(pool) or "Wait... I think I'm losing the signal. Am I going the wrong way?"
    return replaceTokens(rawText, trader, context)
end

function DynamicTrading.Dialogue.RadioTracker.GeneratePlayerApproach(trader, context, stage)
    requireTrackingDialogue(trader and (trader.archetypeID or trader.archetype) or nil)
    local subContext = tostring(stage or "Approach100")
    local pool = Core.GetDialoguePool("Player", "Tracking", subContext)
    local rawText = Core.PickRandom(pool) or "I'm getting close now, {npc}."
    return replaceTokens(rawText, trader, context)
end

function DynamicTrading.Dialogue.RadioTracker.GenerateReply(trader, context)
    local archetype = trader and (trader.archetypeID or trader.archetype) or "General"
    requireTrackingDialogue(archetype)
    local subContext = context and context.isLive and "ReplyLive" or "ReplyLastKnown"
    local pool = Core.GetDialoguePool(archetype, "Tracking", subContext)
    local rawText = Core.PickRandom(pool) or "Best lead I've got is {coords}, {site}."

    local distance = context and context.distance or 0
    if distance > 1000 and context and context.location and context.location.county and context.location.county ~= "Unknown" then
        rawText = rawText .. " I'm way out in {county}."
    end

    return replaceTokens(rawText, trader, context)
end

function DynamicTrading.Dialogue.RadioTracker.GenerateApproachReply(trader, context, stage)
    local archetype = trader and (trader.archetypeID or trader.archetype) or "General"
    requireTrackingDialogue(archetype)
    local subContext = tostring(stage or "Approach100")
    local pool = Core.GetDialoguePool(archetype, "Tracking", subContext)
    local rawText = Core.PickRandom(pool) or "Keep coming."
    return replaceTokens(rawText, trader, context)
end

function DynamicTrading.Dialogue.RadioTracker.GenerateAwayReply(trader, context)
    local archetype = trader and (trader.archetypeID or trader.archetype) or "General"
    requireTrackingDialogue(archetype)
    local pool = Core.GetDialoguePool(archetype, "Tracking", "Away")
    local rawText = Core.PickRandom(pool) or "Yeah, you're fading out man. Pick it up."
    return replaceTokens(rawText, trader, context)
end

return DynamicTrading.Dialogue.RadioTracker