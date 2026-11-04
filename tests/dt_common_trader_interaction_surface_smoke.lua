local T = require "tests/support/test"
T.addPackagePaths()

local actorEntry = {
    actorID = "actor:interaction:one",
    label = "Trader Ada",
    provider = "DTAbstract",
    providerState = "abstract",
    position = { x = 100, y = 200, z = 0 },
    factionID = "faction:interaction:one",
    factionName = "Northstar Caravan",
    factionPresentation = {
        factionID = "faction:interaction:one",
        displayName = "Northstar Caravan",
        archetypeID = "trader",
        glyph = "N",
    },
}
local guardEntry = {
    actorID = "actor:interaction:guard",
    label = "Northstar Guard",
    provider = "DTAbstract",
    providerState = "abstract",
    position = { x = 110, y = 210, z = 0 },
    factionID = actorEntry.factionID,
    factionName = actorEntry.factionName,
    role = "guard",
}

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        ListActors = function() return { actorEntry, guardEntry } end,
        GetActor = function(id)
            if id == actorEntry.actorID then return actorEntry end
            if id == guardEntry.actorID then return guardEntry end
            return nil
        end,
    }
end

local contexts = {}
package.preload[
    "PsychopatzCore/UI/Map/PsychopatzMapHost"
] = function()
    return {
        Contexts = {
            Register = function(id, definition)
                contexts[id] = definition
                return true
            end,
        },
    }
end

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldActorMap"
] = function()
    return {
        FindMarkerAt = function(x, y)
            if x == 100 and y == 200 then
                return {
                    entry = actorEntry,
                    actorID = actorEntry.actorID,
                    marker = {
                        hoverMetadata = {
                            traderID = "trader:interaction:one",
                        },
                    },
                }
            end
            if x == 110 and y == 210 then
                return {
                    entry = guardEntry,
                    actorID = guardEntry.actorID,
                    marker = {
                        hoverMetadata = {
                            traderID = "trader:interaction:one",
                        },
                    },
                }
            end
            return nil
        end,
    }
end

local requests = {}
DTCommon = {
    TraderPresentation = {
        ListTraderViews = function()
            return {
                {
                    traderID = "trader:interaction:one",
                    actorID = actorEntry.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                    name = actorEntry.label,
                    factionID = actorEntry.factionID,
                },
                {
                    traderID = "trader:interaction:one",
                    actorID = guardEntry.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                    name = guardEntry.label,
                    role = "guard",
                    talkAvailable = true,
                    tradeAvailable = false,
                },
            }
        end,
        GetTraderView = function(traderID)
            if traderID == "trader:interaction:one" then
                return {
                    traderID = traderID,
                    actorID = actorEntry.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                    name = actorEntry.label,
                    talkAvailable = true,
                    tradeAvailable = true,
                }
            end
            return nil
        end,
        GetTraderViewForActor = function(actorID)
            if actorID == guardEntry.actorID then
                return {
                    traderID = "trader:interaction:one",
                    actorID = guardEntry.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                    name = guardEntry.label,
                    talkAvailable = true,
                    tradeAvailable = false,
                }
            end
            return nil
        end,
    },
    TraderManager = {
        Request = function(action, traderID, args)
            requests[#requests + 1] = {
                action = action,
                traderID = traderID,
                args = args,
            }
            return true
        end,
    },
}

local Interaction = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderMapContext.lua"
)
T.truthy(Interaction, "shared trader map interaction module is missing")
local definition = contexts["DTCommon:TraderInteraction"]
T.truthy(definition, "shared trader map interaction context was not registered")

local optionDefinitions = {}
local options = {
    addOption = function(_, title, _, callback)
        optionDefinitions[#optionDefinitions + 1] = {
            title = title,
            onSelect = callback,
        }
    end,
}
definition.augment({ x = 100, y = 200, z = 0 }, options, 100, 200)
T.truthy(optionDefinitions[1],
    "trader map interaction did not add a Talk option")
T.truthy(optionDefinitions[2],
    "trader map interaction did not add a Trade option")
optionDefinitions[1].onSelect()
T.equal(requests[1].action, "talk",
    "map Talk did not use the shared trader manager request path")
optionDefinitions[2].onSelect()
T.equal(requests[2].action, "trade",
    "map Trade did not use the shared trader manager request path")

optionDefinitions = {}
definition.augment({ x = 110, y = 210, z = 0 }, options, 110, 210)
T.truthy(optionDefinitions[1],
    "guard map interaction did not add a Talk option")
T.falsy(optionDefinitions[2],
    "guard map interaction incorrectly added Trade")
optionDefinitions[1].onSelect()
T.equal(requests[3].action, "talk",
    "guard map Talk did not use the shared trader manager request path")
T.equal(requests[3].args.actorID, guardEntry.actorID,
    "guard map Talk opened the trader leader instead of the guard")

print("dt_common_trader_interaction_surface_smoke: PASS")
