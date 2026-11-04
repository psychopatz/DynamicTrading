if DTHoomans and DTHoomans.Enabled == false then return end

require "DTHoomans/DTHoomans_Context"
require "DTCommon/DTCommon_TraderPresentation"
require "DTCommon/DTCommon_TraderConversation"
require "DTHoomans/DTHoomans_Client"
require "DTHoomans/DTHoomans_TradePresentation"
require "DTHoomans/DTHoomans_RadioOS"
require "DTHoomans/DTHoomans_DebugAdapter"

-- DTCommon/Core own the conversation and identity presentation contracts.
-- Project Hoomans contributes only its bounded learned-identity cache and
-- request transport here; DTAbstract never loads this adapter.
local SurvivorWorldClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
if SurvivorWorldClient
    and type(SurvivorWorldClient.RegisterActorKnowledgeProvider) == "function"
then
    SurvivorWorldClient.RegisterActorKnowledgeProvider("DTHoomans", {
        get = function(actorID)
            local identity = PNC and PNC.NPCIdentityPresentation or nil
            local state = PNC and PNC.Network
                and PNC.Network.ClientState or nil
            local presentation = state and state.npcPresentations
                and state.npcPresentations[tostring(actorID)] or nil
            local knownName = identity
                and type(identity.GetKnownName) == "function"
                and identity.GetKnownName(actorID) or nil
            local faction = identity
                and type(identity.GetFaction) == "function"
                and identity.GetFaction(actorID) or nil
            local factionName = identity
                and type(identity.GetFactionName) == "function"
                and identity.GetFactionName(actorID) or nil
            return {
                state = presentation and presentation.state or "unknown",
                pending = presentation
                    and presentation.knowledgePending == true or false,
                nameKnown = knownName ~= nil and knownName ~= "",
                knownName = knownName,
                factionKnown = faction ~= nil,
                factionID = faction
                    and (faction.factionID or faction.id) or nil,
                factionName = factionName,
                revision = presentation
                    and tonumber(presentation.knowledgeRevision) or 0,
            }
        end,
        request = function(actorID)
            local client = PNC and PNC.Client or nil
            if not client or type(client.RequestNPCKnowledge) ~= "function" then
                return false, "pnc_knowledge_unavailable"
            end
            return client.RequestNPCKnowledge(actorID)
        end,
    })
end

if DTCommon and DTCommon.TraderConversation
    and type(DTCommon.TraderConversation.RegisterProviderTransport)
        == "function"
then
    DTCommon.TraderConversation.RegisterProviderTransport(
        "DTHoomans",
        function(traderID, entry, player, options)
            return DTHoomans.Client.RequestTraderConversation(
                traderID,
                options
            )
        end
    )
end

if DTCommon and DTCommon.TraderConversation
    and type(DTCommon.TraderConversation.RegisterExternalOpener)
        == "function"
then
    local loaded, openers = pcall(
        require,
        "PNC/Conversation/PNC_ConversationOpeners"
    )
    if loaded then
        DTCommon.TraderConversation.RegisterExternalOpener(openers)
    end
end
