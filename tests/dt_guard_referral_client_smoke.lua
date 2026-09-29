local T = require "tests/support/test"

local commandHandlers = {}
local sentCommand
local opened
local queued
local player = {}
local view = {
    spec = {
        npcID = "guard_one",
        context = {
            conversationLifecycleState = { token = "lease-guard-one" },
        },
    },
    session = {
        queueMessage = function(_, speaker, payload, metadata)
            queued = { speaker = speaker, payload = payload, metadata = metadata }
        end,
    },
}

Events = {
    OnServerCommand = {
        Add = function(handler) commandHandlers[#commandHandlers + 1] = handler end,
    },
    OnFillWorldObjectContextMenu = { Add = function() end },
    OnGameStart = { Add = function() end },
}
DTCommon = {
    MOD_ID = "DTCommon",
    T = function(_, fallback) return fallback end,
    TraderService = {
        ForEach = function(callback)
            callback("dt_caravan_one", {
                p = "merchant_one", l = "merchant_one",
                m = { "merchant_one", "guard_one", "guard_two" },
            })
        end,
    },
    Client = {
        OpenTrader = function(traderID, options)
            opened = { traderID = traderID, options = options }
            return true
        end,
        Snapshots = {},
    },
}
PNC = {
    Const = {
        MODULE = "ProjectHoomans",
        CMD_CONVERSATION_OUTCOME = "ConversationOutcome",
    },
    Semantics = { DialogueInput = { ActiveView = view } },
}
PsychopatzCore = { Conversation = { instance = view } }
DTHoomans = { MOD_ID = "DTHoomans" }
getSpecificPlayer = function() return player end
sendClientCommand = function(current, module, command, args)
    sentCommand = { player = current, module = module, command = command, args = args }
end

T.load("DTHoomans", "client", "DTHoomans/DTHoomans_Context.lua")
T.load("DTHoomans", "client", "DTHoomans/DTHoomans_Client.lua")
DTHoomans.Client.BindTrader(
    "dt_caravan_one", "merchant_one",
    { "merchant_one", "guard_one", "guard_two" }
)

local function dispatch(module, command, args)
    for _, handler in ipairs(commandHandlers) do
        handler(module, command, args)
    end
end

dispatch("ProjectHoomans", "ConversationOutcome", {
    requestID = "choice-guard-one",
    success = true,
    npcID = "guard_one",
    choiceID = "trader_referral",
})
T.truthy(sentCommand, "guard trade requests a server referral")
T.equal(sentCommand.module, "DTHoomans", "referral uses DT authority")
T.equal(sentCommand.command, "TraderReferralRequest",
    "referral uses the dedicated command")
T.equal(sentCommand.args.guardNPCID, "guard_one",
    "referral identifies the speaking guard")
T.equal(sentCommand.args.traderID, "dt_caravan_one",
    "referral carries the mapped caravan")
T.equal(sentCommand.args.choiceID, "trader_referral",
    "referral carries the dedicated guard choice")
T.equal(sentCommand.args.conversationToken, "lease-guard-one",
    "referral carries the active Hoomans lease")

dispatch("DTHoomans", "TraderReferral", {
    accepted = true,
    guardNPCID = "guard_one",
    traderID = "dt_caravan_one",
    merchantNPCID = "merchant_one",
    merchantName = "Rocco Patz",
    knowledgeLearned = true,
})
T.truthy(queued, "server referral is appended to Hoomans conversation")
T.equal(queued.speaker, "npc", "referral is spoken by the guard")
T.contains(queued.payload.text, "Rocco Patz",
    "referral contains the authoritative merchant name")
T.equal(queued.metadata.knowledgeLearned, true,
    "referral preserves knowledge result metadata")

sentCommand = nil
queued = nil
dispatch("ProjectHoomans", "ConversationOutcome", {
    requestID = "choice-merchant-one",
    success = true,
    npcID = "merchant_one",
    choiceID = "trade",
})
T.equal(sentCommand, nil, "merchant trade does not request a referral")
T.truthy(opened, "merchant trade opens the native trading window")
T.equal(opened.traderID, "dt_caravan_one",
    "merchant trade uses the correct trader record")
T.equal(opened.options.npcID, "merchant_one",
    "merchant trade keeps the merchant NPC target")

T.finish("dt_guard_referral_client_smoke")
