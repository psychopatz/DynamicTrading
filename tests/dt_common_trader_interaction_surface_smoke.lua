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

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        ListActors = function() return { actorEntry } end,
        GetActor = function(id)
            return id == actorEntry.actorID and actorEntry or nil
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

print("dt_common_trader_interaction_surface_smoke: PASS")
