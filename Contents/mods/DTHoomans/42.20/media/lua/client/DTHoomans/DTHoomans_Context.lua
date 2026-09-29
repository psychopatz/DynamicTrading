DTHoomans = DTHoomans or {}
DTHoomans.Client = DTHoomans.Client or {}

local Client = DTHoomans.Client
Client.TraderByNPC = Client.TraderByNPC or {}
Client.ConversationTraderByNPC = Client.ConversationTraderByNPC or {}
Client.TraderLeaderByID = Client.TraderLeaderByID or {}

local MAX_CONVERSATION_MEMBERS = 24

local function normalizedID(value)
    value = tostring(value or "")
    return value ~= "" and value or nil
end

-- The context provider is deliberately merchant-only. Conversation outcomes
-- use the wider map so a guard can refer the player to the merchant without
-- exposing a Trade context option on every armed escort.
function Client.BindTrader(traderID, leaderNPCID, memberNPCIDs)
    traderID = normalizedID(traderID)
    leaderNPCID = normalizedID(leaderNPCID)
    if not traderID or not leaderNPCID then return false end

    Client.TraderLeaderByID[traderID] = leaderNPCID
    Client.TraderByNPC[leaderNPCID] = traderID
    Client.ConversationTraderByNPC[leaderNPCID] = traderID

    local count = 0
    for _, memberNPCID in ipairs(type(memberNPCIDs) == "table"
        and memberNPCIDs or {}) do
        if count >= MAX_CONVERSATION_MEMBERS then break end
        memberNPCID = normalizedID(memberNPCID)
        if memberNPCID then
            Client.ConversationTraderByNPC[memberNPCID] = traderID
            count = count + 1
        end
    end
    return true
end

function Client.RefreshTraderMap()
    Client.TraderByNPC = {}
    Client.ConversationTraderByNPC = {}
    Client.TraderLeaderByID = {}
    if not DTCommon or not DTCommon.TraderService then return end
    DTCommon.TraderService.ForEach(function(traderID, record)
        if record and (record.p or record.l) then
            Client.BindTrader(traderID, record.p or record.l, record.m)
        end
    end)
end

function Client.GetTraderID(npcID)
    npcID = tostring(npcID or "")
    if npcID == "" then return nil end
    local traderID = Client.TraderByNPC[npcID]
    if not traderID then
        -- ModData can become available after the provider is registered and
        -- the spawn response can arrive between context-menu passes.
        Client.RefreshTraderMap()
        traderID = Client.TraderByNPC[npcID]
    end
    return traderID
end

function Client.GetConversationTraderID(npcID)
    npcID = normalizedID(npcID)
    if not npcID then return nil end
    local traderID = Client.ConversationTraderByNPC[npcID]
    if not traderID then
        Client.RefreshTraderMap()
        traderID = Client.ConversationTraderByNPC[npcID]
    end
    return traderID
end

function Client.GetTraderLeaderID(traderID)
    traderID = normalizedID(traderID)
    if not traderID then return nil end
    local leaderNPCID = Client.TraderLeaderByID[traderID]
    if not leaderNPCID then
        Client.RefreshTraderMap()
        leaderNPCID = Client.TraderLeaderByID[traderID]
    end
    return leaderNPCID
end

local Provider = { id = "dynamic_trading" }

function Provider.isEnabled(entry)
    return Client.GetTraderID(entry and entry.id) ~= nil
end

function Provider.addOptions(menu, entry)
    local traderID = Client.GetTraderID(entry and entry.id)
    if not traderID then return end
    menu:addOption(DTCommon.T("DTHoomans_Trade", "Trade"), nil, function()
        print("[DT][INFO] trade_option npc=" .. tostring(entry and entry.id)
            .. " trader=" .. tostring(traderID))
        if DTCommon and DTCommon.Client then
            DTCommon.Client.OpenTrader(traderID, {
                mode = "trade",
                npcID = entry and entry.id,
            })
        end
    end)
end

local function registerProvider()
    if not PNC or not PNC.ContextHub then
        -- Project Hoomans is an external integration boundary. Its mod.info
        -- load order should make the hub available, but fail closed if not.
        pcall(require, "PNC/UI/Context/PNC_ContextHub")
    end
    if PNC and PNC.ContextHub
        and type(PNC.ContextHub.RegisterProvider) == "function"
    then
        PNC.ContextHub.RegisterProvider(Provider)
    end
end

registerProvider()

return Provider
