if DTHoomans and DTHoomans.Enabled == false then return end

require "DTHoomans/DTHoomans_Context"
require "DTCommon/DTCommon_TraderPresentation"
require "DTCommon/DTCommon_TraderConversation"
require "DTHoomans/DTHoomans_Client"
require "DTHoomans/DTHoomans_TradePresentation"
require "DTHoomans/DTHoomans_RadioOS"
require "DTHoomans/DTHoomans_DebugAdapter"

-- Project Hoomans owns the learned-identity adapter used by Core's shared
-- actor-map hover. DTHoomans may load before the Hoomans map composition root,
-- so make the one shared adapter available at the provider boundary too.
pcall(require, "PNC/UI/Map/PNC_MapCoreActorKnowledge")

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
