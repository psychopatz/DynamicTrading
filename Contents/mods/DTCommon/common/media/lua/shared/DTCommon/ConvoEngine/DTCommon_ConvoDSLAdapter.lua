-- Dynamic Trading adopter bridge for PsychopatzCore's shared runtime .convo DSL engine
-- and server-authoritative ActorSocialAuthority relationship pipeline.
-- Enables Dynamic Trading traders to use actor-agnostic .convo branching stories and
-- earn/lose persistent approval, respect, familiarity, and morale identically to ProjectHoomans NPCs.
-- Kahlua2 / Lua 5.1 safe.

DTCommon = DTCommon or {}
DTCommon.ConvoDSL = DTCommon.ConvoDSL or {}

local Adapter = DTCommon.ConvoDSL
local CoreDSL = require "PsychopatzCore/ConvoEngine/ConvoDSL/ConvoDSL"
local OfferRealizer = CoreDSL.OfferRealizer

Adapter.VERSION = 1
Adapter.MOD_ID = "DTCommon"
Adapter.CoreDSL = CoreDSL

CoreDSL.RegisterModSource(Adapter.MOD_ID)

local function extractPersonality(traderRecord)
    if type(traderRecord) ~= "table" then return {} end
    if type(traderRecord.social) == "table" and type(traderRecord.social.personality) == "table" then
        return traderRecord.social.personality
    end
    if type(traderRecord.personality) == "table" then
        return traderRecord.personality
    end
    return {}
end

local function extractActorID(traderRecord)
    if type(traderRecord) ~= "table" then return nil end
    if type(traderRecord.ca) == "table" and traderRecord.ca.actorID then
        return tostring(traderRecord.ca.actorID)
    end
    if traderRecord.actorID then return tostring(traderRecord.actorID) end
    if traderRecord.id then return tostring(traderRecord.id) end
    return nil
end

function Adapter.ProjectTraderContext(traderRecord, baseContext)
    local ctx = {}
    if type(baseContext) == "table" then
        for k, v in pairs(baseContext) do ctx[k] = v end
    end
    ctx.actorRole = ctx.actorRole or "trader"
    local personality = extractPersonality(traderRecord)
    CoreDSL.ProjectPersonalityContext(personality, ctx)
    if type(traderRecord) == "table" then
        if traderRecord.archetype and not ctx.tradeArchetype then
            ctx.tradeArchetype = tostring(traderRecord.archetype)
        end
        if traderRecord.isCaravan ~= nil and ctx.tradeIsCaravan == nil then
            ctx.tradeIsCaravan = traderRecord.isCaravan == true
        end
    end
    return ctx
end

function Adapter.PickAutonomousChoice(storyID, nodeID, traderRecord, context, opts)
    local story = CoreDSL.GetStory(storyID)
    if type(story) ~= "table" or type(story.nodes) ~= "table" then return nil end
    local node = story.nodes[tostring(nodeID or story.initial or "start")]
    if type(node) ~= "table" or type(node.branchOffers) ~= "table" then return nil end
    local personality = extractPersonality(traderRecord)
    local ctx = Adapter.ProjectTraderContext(traderRecord, context)
    return OfferRealizer.PickAutonomous(node.branchOffers, personality, ctx, opts)
end

function Adapter.ResolveAndApplyReaction(storyID, nodeID, traderRecord, targetKey, context, opts)
    opts = type(opts) == "table" and opts or {}
    local ctx = Adapter.ProjectTraderContext(traderRecord, context)
    local reaction = CoreDSL.ResolveReaction(storyID, nodeID, ctx, opts)
    if not reaction then return nil, "reaction_not_found" end

    local actorID = opts.actorID or extractActorID(traderRecord)
    local appliedOk, appliedInfo = true, nil
    if opts.applyEffects ~= false and actorID and targetKey and tostring(targetKey) ~= "" then
        appliedOk, appliedInfo = CoreDSL.ApplyReactionEffects(actorID, tostring(targetKey), reaction, opts)
    end

    return reaction, appliedOk, appliedInfo
end

return Adapter
