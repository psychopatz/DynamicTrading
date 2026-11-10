-- Dynamic Trading's canonical faction profile.
--
-- Core owns the registry and validation contract. This module owns the
-- trader-specific profile data and is intentionally packaged in DTCommon's
-- version-agnostic common layer. Project Hoomans may consume the profile when
-- present, but does not define or require it.

DTCommon = DTCommon or {}

local Profiles = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldFactionProfiles"
local Constants = DTCommon

local PROFILE_ID = Constants.TRADER_PROFILE_ID or "DT.trader"
local SOURCE_ID = Constants.TRADER_PROFILE_SOURCE or "DynamicTrading"

local PROFILE = {
    label = "Trading Caravan",
    description = "A mobile survivor caravan focused on exchange, transport, and commercial relationships while travelling between settlements.",
    sourceMod = SOURCE_ID,
    allowedRoles = {
        leader = true,
        trader = true,
        guard = true,
        medic = true,
        mechanic = true,
        scavenger = true,
        laborer = true,
        civilian = true,
    },
    defaultRole = "civilian",
    policyDefaults = {
        aggression = 0.20,
        retaliation = 0.40,
        caution = 0.65,
        hospitality = 0.60,
        opportunism = 0.75,
        outsiderPolicy = "commercial",
        warThreshold = 76,
        peaceThreshold = 30,
    },
    capabilities = {
        mobile = true,
        commercial = true,
        dynamicTrading = true,
    },
    extensions = {
        DT = {
            providerID = "DT.trader",
            behavior = {
                hostileToOutsiders = false,
            },
            mobile = {
                enabled = true,
                roleOrder = {
                    "leader", "trader", "guard", "medic",
                    "mechanic", "scavenger", "laborer",
                },
                npcArchetype = "General",
                hostile = false,
            },
        },
    },
}

local registered, reason = Profiles.Register(PROFILE_ID, PROFILE)
if not registered and reason ~= "already_registered"
    and PsychopatzCore and PsychopatzCore.LogWarn
then
    PsychopatzCore.LogWarn(
        "Dynamic Trading faction profile registration failed: "
            .. tostring(reason)
    )
end

DTCommon.TraderProfileID = PROFILE_ID
DTCommon.TraderProfile = PROFILE

function DTCommon.IsTraderFaction(factionOrID)
    local archetypeID = type(factionOrID) == "table"
        and factionOrID.archetypeID or factionOrID
    return tostring(archetypeID or "") == PROFILE_ID
end

return PROFILE
