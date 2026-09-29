DTHoomans = DTHoomans or {}
DTHoomans.Conversation = DTHoomans.Conversation or {}

local Integration = DTHoomans.Conversation
local CATEGORY_ID = "dthoomans:caravan_referral"
local TRADE_CATEGORY_ID = "projecthoomans:trade"
-- Project Hoomans role tokens. "trader" is the token Project Hoomans stores on a
-- caravan merchant; DynamicTrading never invents its own role vocabulary.
local MERCHANT_ROLE = "trader"
local GUARD_ROLE = "guard"
local PROVIDER_ID = "dthoomans:caravan_roles"

Integration.CATEGORY_ID = CATEGORY_ID
Integration.REFERRAL_CHOICE_ID = "trader_referral"

local TEXT_SOURCE = {
    modID = DTHoomans.MOD_ID,
    pathPattern = "media/conversation/caravan/shared/{language}/basic.json",
    domain = "dthoomans.conversation.caravan.shared.basic",
}

local function sameID(left, right)
    return tostring(left or "") ~= ""
        and tostring(left) == tostring(right)
end

local function recordRole(record, npcID)
    local leaderID = record and (record.p or record.l) or nil
    local members = record and record.m or nil
    local memberIDs = record and record.memberIDs or nil
    local index
    local memberID
    if sameID(leaderID, npcID) then return MERCHANT_ROLE end
    for index = 1, #(type(members) == "table" and members or {}) do
        memberID = members[index]
        if sameID(memberID, npcID) then return GUARD_ROLE end
    end
    for memberID, _ in pairs(type(memberIDs) == "table" and memberIDs or {}) do
        if sameID(memberID, npcID) then return GUARD_ROLE end
    end
    return nil
end

local function roleFromService(npcID)
    local service = DTCommon and DTCommon.TraderService or nil
    local result
    if not service or type(service.ForEach) ~= "function" then return nil end
    service.ForEach(function(_, record)
        if not result then result = recordRole(record, npcID) end
    end)
    return result
end

-- Project Hoomans' own affiliation role is authoritative where the faction
-- service is present (server and server-command paths). Client-side conversation
-- keeps using the DT caravan binding below, because PNC.Factions is server-only.
local function roleFromAffiliation(npcID)
    local factions = PNC and PNC.Factions or nil
    local affiliation
    local role
    if not factions or type(factions.GetNPCAffiliation) ~= "function" then
        return nil
    end
    affiliation = factions.GetNPCAffiliation(npcID)
    role = affiliation and tostring(affiliation.role or "") or ""
    if role == MERCHANT_ROLE or role == GUARD_ROLE then return role end
    return nil
end

function Integration.RoleForNPC(npcID)
    local role = roleFromAffiliation(npcID)
    local client = DTHoomans.Client
    local traderID
    local leaderID
    if role then return role end
    if client and type(client.GetConversationTraderID) == "function" then
        traderID = client.GetConversationTraderID(npcID)
        leaderID = traderID
            and type(client.GetTraderLeaderID) == "function"
            and client.GetTraderLeaderID(traderID) or nil
        if traderID and sameID(leaderID, npcID) then
            return MERCHANT_ROLE
        end
        if traderID then return GUARD_ROLE end
    end
    return roleFromService(npcID)
end

local function categoryEligibility(category, context)
    local categoryID = category and category.id or ""
    local npcID = context and context.npcID or nil
    local role
    if categoryID ~= TRADE_CATEGORY_ID
        and categoryID ~= CATEGORY_ID
    then
        return true
    end
    role = Integration.RoleForNPC(npcID)
    if categoryID == TRADE_CATEGORY_ID then
        return role == MERCHANT_ROLE, "dthoomans_trade_requires_merchant"
    end
    return role == GUARD_ROLE, "dthoomans_referral_requires_guard"
end

local function registerDefinitions()
    local conversations = PNC and PNC.API and PNC.API.Conversations
    local registeredCategory
    local registeredBlock
    local registeredProvider
    if not conversations then return false, "conversation_api_unavailable" end
    registeredCategory = conversations.RegisterCategory(
        CATEGORY_ID,
        {
            ownerModID = DTHoomans.MOD_ID,
            labelKey = "category.caravan_referral",
            order = 705,
            textSource = TEXT_SOURCE,
        }
    )
    if not registeredCategory then
        return false, "caravan_category_registration_failed"
    end
    registeredBlock = conversations.RegisterBlock(
        "dthoomans:caravan_referral_basic",
        {
            schemaVersion = 1,
            ownerModID = DTHoomans.MOD_ID,
            category = CATEGORY_ID,
            audiences = { "neutral", "member", "special" },
            priority = 1000,
            weight = 100,
            textSource = TEXT_SOURCE,
            entryNode = "opening",
            nodes = {
                opening = {
                    textKey = "opening",
                    choices = {
                        {
                            id = Integration.REFERRAL_CHOICE_ID,
                            textKey = "choice.trader_referral",
                            outcomes = {
                                {
                                    id = "reply",
                                    weight = 100,
                                    responseKey = "response.trader_referral",
                                    next = "$root",
                                },
                            },
                        },
                    },
                },
            },
        }
    )
    if not registeredBlock then
        return false, "caravan_block_registration_failed"
    end
    registeredProvider = conversations
        .RegisterCategoryEligibilityProvider(PROVIDER_ID, {
            evaluate = categoryEligibility,
        })
    if not registeredProvider then
        return false, "caravan_eligibility_registration_failed"
    end
    print("[DT][INFO] conversation_registered category=" .. CATEGORY_ID
        .. " block=dthoomans:caravan_referral_basic"
        .. " provider=" .. PROVIDER_ID
        .. " tradeGate=" .. TRADE_CATEGORY_ID)
    return true
end

if not Integration._registered then
    local registered, reason = registerDefinitions()
    Integration._registered = registered == true
    if not registered then
        print("[DT][WARN] conversation_registration_failed reason="
            .. tostring(reason))
    end
end

return Integration
