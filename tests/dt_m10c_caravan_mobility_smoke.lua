local T = require "tests/support/test"

local caravanSource = T.read(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CaravanService.lua")
local lifecyclePath = T.repository
    .. "/Contents/mods/DTHoomans/42.20/media/lua/server/DTHoomans/"
    .. "DTHoomans_CaravanLifecycle.lua"
local lifecycleFile = io.open(lifecyclePath, "r")
T.falsy(lifecycleFile,
    "parallel DTHoomans caravan lifecycle file has been removed")
if lifecycleFile then lifecycleFile:close() end
local initSource = T.read(
    "DTHoomans", "server",
    "DTHoomans/00_DTHoomans_Server_Init.lua")
local scorerSource = T.read(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CommercialMobility.lua")

T.contains(caravanSource,
    'mobilityIntent = state.mobilityIntent',
    "production caravans accept DTCommon-managed mobility ownership")
T.contains(caravanSource,
    '"dynamic_trading_managed"',
    "production caravans default to the DT-managed mobility intent")
T.falsy(string.find(caravanSource,
    "mobilityIntent = constants.MOBILE_MOBILITY_INTENT_COMMERCIAL",
    1, true),
    "production caravans must not re-enable Hoomans autonomous commercial routing")
T.contains(caravanSource,
    "mobileControlMode = constants.MOBILE_CONTROL_STRATEGIC",
    "production caravans remain under strategic Hoomans control")
T.falsy(string.find(caravanSource, "leader stays at the base", 1, true),
    "base-less caravan source has no hidden leader/base contract")
T.falsy(string.find(initSource, "DTHoomans_CaravanLifecycle", 1, true),
    "server composition does not load a parallel caravan lifecycle")
T.contains(initSource, "DTHoomans/DTHoomans_CommercialMobility",
    "production server composition loads the economic scorer")
T.contains(scorerSource, "RegisterOpportunityScorer",
    "economic scorer uses the generic Hoomans registration seam")

local registrations = {}
local marketReads = 0
PNC = {
    CommercialMobilityService = {
        RegisterOpportunityScorer = function(name, scorer)
            registrations[#registrations + 1] = {
                name = name,
                scorer = scorer,
            }
            return true, "scorer_registered"
        end,
    },
    Factions = {
        Registry = {
            byID = {
                old_caravan = {
                    id = "old_caravan",
                    status = "active",
                    tags = { dynamicTrading = true },
                    mobile = { active = true },
                },
            },
        },
        UpdateMobileGroup = function(id, patch)
            local faction = PNC.Factions.Registry.byID[id]
            for key, value in pairs(patch or {}) do
                faction.mobile[key] = value
            end
            return true, "updated"
        end,
    },
}
DTCommon = {
    SettlementMarket = {
        Get = function(id)
            marketReads = marketReads + 1
            T.equal(id, "community_market",
                "scorer reads the candidate canonical community market")
            return {
                categories = {
                    Food = { supply = 0.2, demand = 0.9 },
                    Medical = { supply = 0.5, demand = 0.6 },
                },
            }
        end,
    },
    MarketEvents = {
        ListActive = function()
            return {}, { activeEventCount = 1 }
        end,
    },
}
DTHoomans = {}
T.load(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CommercialMobility.lua")
T.equal(DTHoomans.CommercialMobility.MigrateExistingCaravans(), 1,
    "existing DT caravans receive the intent lazily and idempotently")
T.equal(PNC.Factions.Registry.byID.old_caravan.mobile.mobilityIntent,
    "dynamic_trading_managed",
    "lazy migration transfers route authority without recreating the caravan")

T.equal(#registrations, 1,
    "production scorer registers exactly once")
T.equal(registrations[1].name, "dynamic_trading",
    "scorer registration is bounded and named by its consumer")
local score = registrations[1].scorer(
    { archetypeID = "trader" },
    { communityID = "community_market" },
    { at = 10 }
)
T.truthy(score > 0,
    "bounded market scarcity produces a positive commercial opportunity")
T.truthy(score <= 25, "economic opportunity score is bounded")
T.equal(marketReads, 1,
    "scorer performs one compact market read without registry scanning")

T.finish("dt_m10c_caravan_mobility_smoke")
