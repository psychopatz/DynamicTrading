local T = require "tests/support/test"

local commandHandler
local sent
local snapshotSent
local validated
local discovered
local allowValidation = true
local player = {
    getUsername = function() return "smoke-player" end,
}

Events = {
    OnClientCommand = {
        Add = function(handler) commandHandler = handler end,
    },
}
getSpecificPlayer = function() return nil end
isServer = function() return true end
sendServerCommand = function(target, module, command, args)
    sent = { target = target, module = module, command = command, args = args }
end
DTHoomans = {
    MOD_ID = "DTHoomans",
    SPAWN_COMMAND = "SpawnTrader",
}
DTCommon = {
    TraderService = {
        ForEach = function(callback)
            callback("dt_caravan_one", {
                g = "faction-one",
                p = "merchant_one",
                l = "merchant_one",
                m = { "merchant_one", "guard_one", "guard_two" },
            })
        end,
        GetRecord = function(traderID)
            return traderID == "dt_caravan_one" and {
                p = "merchant_one", l = "merchant_one",
                m = { "merchant_one", "guard_one", "guard_two" },
            } or nil
        end,
    },
}
PNC = {
    Registry = {
        Get = function(npcID)
            if npcID == "guard_one" then
                return { id = npcID, alive = true }
            end
            if npcID == "merchant_one" then
                return {
                    id = npcID,
                    identity = { displayName = "Rocco Patz" },
                }
            end
            return nil
        end,
    },
    Identity = {
        GetCharacterSummary = function(record)
            return { displayName = record and record.identity
                and record.identity.displayName }
        end,
    },
    NPCKnowledgeAPI = {
        DiscloseRelatedForPlayer = function(target, sourceNPCID,
            targetNPCID, options)
            validated = {
                player = target,
                npcID = sourceNPCID,
                targetNPCID = targetNPCID,
                token = options.conversationToken,
            }
            if not allowValidation then return nil, "invalid_lease" end
            discovered = {
                player = target,
                npcID = targetNPCID,
                topicID = options.topicID,
                origin = options.origin,
                requestID = options.requestID,
                conversationRequestID = options.conversationRequestID,
                requiredChoiceID = options.requiredChoiceID,
            }
            return {
                accepted = true,
                revealed = { "identity.name" },
                snapshot = { npcID = targetNPCID, revision = 1 },
            }
        end,
    },
    Network = {
        SendNPCKnowledge = function(target, snapshot, reason)
            snapshotSent = { target = target, snapshot = snapshot, reason = reason }
        end,
    },
    ServerCommandRouter = {
        CanUseDebug = function() return true end,
    },
}

T.load("DTHoomans", "server", "DTHoomans/DTHoomans_Server.lua")
T.truthy(commandHandler, "server command handler is registered")

commandHandler("DTHoomans", "TraderReferralRequest", player, {
    requestID = "choice-guard-one",
    guardNPCID = "guard_one",
    traderID = "dt_caravan_one",
    choiceID = "trader_referral",
    conversationToken = "lease-guard-one",
})
T.truthy(validated, "server validates the Hoomans conversation lease")
T.equal(validated.npcID, "guard_one", "lease validates the speaking guard")
T.equal(validated.targetNPCID, "merchant_one",
    "related knowledge targets the merchant")
T.equal(validated.token, "lease-guard-one",
    "related knowledge carries the active lease")
T.equal(discovered.npcID, "merchant_one",
    "knowledge discovery targets the merchant, not the guard")
T.equal(discovered.topicID, "identity_name",
    "referral discovers only the merchant identity topic")
T.equal(discovered.origin, "conversation",
    "referral uses the Hoomans conversation origin")
T.equal(discovered.conversationRequestID, "choice-guard-one",
    "referral binds knowledge to the native conversation outcome")
T.equal(discovered.requiredChoiceID, "trader_referral",
    "referral requires the native referral choice")
T.equal(snapshotSent.snapshot.npcID, "merchant_one",
    "learned merchant snapshot is transported to the player")
T.truthy(sent and sent.args.accepted, "referral response is accepted")
T.equal(sent.args.merchantName, "Rocco Patz",
    "referral response uses the native NPC identity")
T.equal(sent.args.knowledgeLearned, true,
    "referral response reports newly learned identity")

local firstSent = sent
commandHandler("DTHoomans", "TraderReferralRequest", player, {
    requestID = "choice-guard-one",
    guardNPCID = "guard_one",
    traderID = "dt_caravan_one",
    choiceID = "trader_referral",
    conversationToken = "lease-guard-one",
})
T.equal(sent, firstSent, "replayed referral request is bounded and ignored")

allowValidation = false
sent = nil
commandHandler("DTHoomans", "TraderReferralRequest", player, {
    requestID = "choice-guard-two",
    guardNPCID = "guard_one",
    traderID = "dt_caravan_one",
    choiceID = "trader_referral",
    conversationToken = "expired-lease",
})
T.falsy(sent.args.accepted, "invalid Hoomans lease cannot disclose identity")
T.equal(sent.args.reason, "invalid_lease",
    "invalid lease reason is returned to the client")

T.finish("dt_guard_referral_server_smoke")
