local T = require "tests/support/test"

local source = T.read(
    "DTHoomans", "server",
    "DTHoomans/DTHoomans_CaravanService.lua")
T.contains(source, "MaterializeCoreGroup",
    "caravan delegates physical representation to Hoomans")
T.contains(source, "TraderGeneration.GenerateForFaction",
    "caravan routes commercial requests through the shared facade")
T.contains(source, "groupSize = GROUP_SIZE",
    "caravan requests a multi-NPC group")
T.contains(source, "mobileControlMode = constants.MOBILE_CONTROL_STRATEGIC",
    "debug spawn preserves the requested site")
T.contains(source, "caravan_processing",
    "caravan processing remains observable")
T.contains(source, "caravan_ready",
    "caravan completion remains observable")
T.contains(source, "memberSpecs",
    "caravan transports the shared authored member presets")
T.contains(source, "GenerateCanonicalGroup",
    "caravan creates its canonical group through Core")
T.falsy(string.find(source, "CreateCanonicalActors", 1, true),
    "caravan does not create a parallel actor roster")
T.falsy(string.find(source, "GUARD_WEAPONS", 1, true),
    "provider does not retain a duplicate guard loadout")
T.falsy(string.find(source, "PNC.API.SetLoadout", 1, true),
    "caravan does not replace the native appearance loadout")
T.contains(source, "PendingSpawns[requestID] = state",
    "active transaction diagnostics retain the request identity")
T.falsy(string.find(source, "ProcessPendingNow", 1, true),
    "fragile deferred queue processor is not reintroduced")
T.falsy(string.find(source, "DebugProcessTraderQueue", 1, true),
    "obsolete debug queue command stays removed")

local authoritySource = T.read(
    "ProjectHoomans", "server",
    "PNC/Conversation/PNC_ConversationAuthority.lua")
T.contains(authoritySource, "function PNC.Conversation.Authority.ValidateLease",
    "Hoomans exposes the validated integration seam")
local knowledgeAPI = T.read(
    "ProjectHoomans", "server",
    "PNC/Knowledge/PNC_NPCKnowledgeAPI.lua")
    .. T.read(
        "ProjectHoomans", "server",
        "PNC/Knowledge/NPCKnowledgeAPI/PNC_NPCKnowledgeAPI_Mutations.lua")
T.contains(knowledgeAPI, "function API.DiscloseRelatedForPlayer",
    "Hoomans exposes the related identity disclosure API")

local required = {
    "PNC/Conversation/PNC_ConversationHistory",
    "PsychopatzCore/Conversation/PsychopatzConversationTextCatalog",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Context",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_BuildContext",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Validation",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Category",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Recruit",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_SettlementAdmission",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_AmbientVisit",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Departure",
    "PNC/Conversation/ConversationAuthority/PNC_ConversationAuthority_Choice",
}
PNC = {
    Conversation = {
        Authority = {
            Internal = {
                ValidateLease = function(player, record, token)
                    return player, record, token
                end,
            },
        },
    },
}
for _, moduleName in ipairs(required) do
    package.preload[moduleName] = function() return true end
end
T.load(
    "ProjectHoomans", "server",
    "PNC/Conversation/PNC_ConversationAuthority.lua")
local player, record, token =
    PNC.Conversation.Authority.ValidateLease("p", "r", "t")
T.equal(player, "p", "public Hoomans lease wrapper forwards player")
T.equal(record, "r", "public Hoomans lease wrapper forwards record")
T.equal(token, "t", "public Hoomans lease wrapper forwards token")

T.finish("dt_caravan_contract_smoke")
