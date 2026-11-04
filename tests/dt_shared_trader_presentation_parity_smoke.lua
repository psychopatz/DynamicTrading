local T = require "tests/support/test"
T.addPackagePaths()

local actorEntry = {
    actorID = "actor:parity:one",
    label = "Trader Ada",
    provider = "DTAbstract",
    providerState = "abstract",
    position = { x = 100, y = 200, z = 0 },
    factionID = "faction:parity:one",
    factionName = "Northstar Caravan",
    factionPresentation = {
        factionID = "faction:parity:one",
        displayName = "Northstar Caravan",
        archetypeID = "trader",
        glyph = "N",
    },
    portrait = { actorID = "actor:parity:one", face = {} },
    journey = { state = "idle" },
}
local guardEntry = {
    actorID = "actor:parity:guard",
    label = "Northstar Guard",
    provider = "DTAbstract",
    providerState = "abstract",
    position = { x = 104, y = 201, z = 0 },
    factionID = actorEntry.factionID,
    factionName = actorEntry.factionName,
    factionPresentation = actorEntry.factionPresentation,
    role = "guard",
    portrait = { actorID = "actor:parity:guard", face = {} },
    journey = { state = "idle" },
}

local listActorCalls = 0
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        ListActors = function()
            listActorCalls = listActorCalls + 1
            return { actorEntry, guardEntry }
        end,
        GetActor = function(id)
            if id == actorEntry.actorID then return actorEntry end
            if id == guardEntry.actorID then return guardEntry end
            return nil
        end,
        GetPortraitSpec = function(actor)
            return actor and actor.portrait or actorEntry.portrait
        end,
    }
end

local decorator
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
] = function()
    return {
        RegisterDecorator = function(_, definition)
            decorator = definition
            return true
        end,
    }
end

local record = {
    n = "Trader Ada",
    s = "READY",
    ca = {
        actorID = actorEntry.actorID,
        provider = "DTAbstract",
        providerState = "abstract",
        factionID = actorEntry.factionID,
        role = "trader",
    },
    m = { actorEntry.actorID, guardEntry.actorID },
}
DTCommon = {
    Storage = { GetData = function() return { r = 1 } end },
    TraderService = {
        ForEach = function(callback) callback("trader:parity:one", record) end,
    },
}

local Presentation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderPresentation.lua"
)

T.truthy(Presentation.ListTraderViews,
    "shared trader view model is missing")
local rows = Presentation.ListTraderViews(true, 1)
T.equal(#rows, 2, "shared trader view did not list the full actor roster")
T.equal(rows[1].actorID, actorEntry.actorID,
    "shared trader view lost canonical actor identity")
T.equal(rows[1].factionPresentation.glyph, "N",
    "shared trader view lost Core faction presentation")
T.equal(rows[2].actorID, guardEntry.actorID,
    "shared trader view lost the guard actor")
T.equal(rows[2].role, "guard",
    "shared trader view did not preserve the guard role")
T.falsy(rows[2].tradeAvailable,
    "guard presentation incorrectly exposed trade")
T.truthy(decorator, "DTCommon did not register one shared actor decorator")

local style = decorator.decorate(actorEntry, {})
T.equal(style.icon.glyph, "T",
    "trader decorator did not provide the shared trader icon")
T.equal(style.badge.glyph, "N",
    "trader decorator did not provide the faction badge")

local guardStyle = decorator.decorate(guardEntry, {})
T.equal(guardStyle.hoverMetadata.factionRole, "guard",
    "shared actor decorator lost the guard faction role")
T.equal(guardStyle.badge.glyph, "N",
    "guard decorator did not provide the shared faction badge")
T.equal(listActorCalls, 1,
    "actor-map decoration rebuilt the complete trader view for every marker")

print("dt_shared_trader_presentation_parity_smoke: PASS")
