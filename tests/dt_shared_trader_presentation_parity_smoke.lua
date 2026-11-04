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

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        ListActors = function() return { actorEntry } end,
        GetActor = function(id)
            return id == actorEntry.actorID and actorEntry or nil
        end,
        GetPortraitSpec = function() return actorEntry.portrait end,
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
    },
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
T.equal(#rows, 1, "shared trader view did not list the actor binding")
T.equal(rows[1].actorID, actorEntry.actorID,
    "shared trader view lost canonical actor identity")
T.equal(rows[1].factionPresentation.glyph, "N",
    "shared trader view lost Core faction presentation")
T.truthy(decorator, "DTCommon did not register one shared actor decorator")

local style = decorator.decorate(actorEntry, {})
T.equal(style.icon.glyph, "T",
    "trader decorator did not provide the shared trader icon")
T.equal(style.badge.glyph, "N",
    "trader decorator did not provide the faction badge")

print("dt_shared_trader_presentation_parity_smoke: PASS")
