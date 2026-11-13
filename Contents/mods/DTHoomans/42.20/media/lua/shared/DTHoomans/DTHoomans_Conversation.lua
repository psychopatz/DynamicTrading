DTHoomans = DTHoomans or {}
DTHoomans.Conversation = DTHoomans.Conversation or {}

local Integration = DTHoomans.Conversation
local TextCatalog = require
    "PsychopatzCore/Conversation/PsychopatzConversationTextCatalog"

local CATEGORY_ID = "dthoomans:caravan_referral"
local GUARD_ROLE = "guard"
local MERCHANT_ROLE = "trader"
local PROVIDER_ID = "dthoomans:caravan_roles"
local BLOCK_ID = "dthoomans:caravan_referral"

Integration.CATEGORY_ID = CATEGORY_ID
Integration.REFERRAL_CHOICE_ID = "trader_referral"

local TEXT_SOURCE = TextCatalog.Source({
    modID = "DTCommon",
    target = "dynamic_trading/caravan/referral/guard",
    domain = "dthoomans.conversation.dynamic_trading.caravan.referral.guard",
})

local function sameID(left, right)
    return tostring(left or "") ~= ""
        and tostring(left) == tostring(right)
end

local function recordRole(record, npcID)
    local ca = record and record.ca or nil
    local leaderID = record and (record.p or record.l) or nil
    local members = record and record.m or nil
    local memberIDs = record and record.memberIDs or nil
    local index
    local memberID

    if ca and sameID(ca.actorID, npcID) then
        return MERCHANT_ROLE
    end
    if sameID(leaderID, npcID) then return MERCHANT_ROLE end

    for index = 1, #(type(members) == "table" and members or {}) do
        memberID = members[index]
        if sameID(memberID, npcID) then return GUARD_ROLE end
    end
    for memberID, _ in pairs(
        type(memberIDs) == "table" and memberIDs or {}
    ) do
        if sameID(memberID, npcID) then return GUARD_ROLE end
    end
    return nil
end

local function roleFromService(npcID)
    local service = DTCommon and DTCommon.TraderService or nil
    local result
    if not service or type(service.ForEach) ~= "function" then
        return nil
    end
    service.ForEach(function(_, record)
        if not result then result = recordRole(record, npcID) end
    end)
    return result
end

local function roleFromAffiliation(npcID)
    local factions = PNC and PNC.Factions or nil
    if not factions
        or type(factions.GetNPCAffiliation) ~= "function"
    then
        return nil
    end
    local affiliation = factions.GetNPCAffiliation(npcID)
    local role = affiliation
        and tostring(affiliation.role or "") or ""
    if role == MERCHANT_ROLE or role == GUARD_ROLE then
        return role
    end
    return nil
end

function Integration.RoleForNPC(npcID)
    local role = roleFromAffiliation(npcID)
    if role then return role end

    local client = DTHoomans.Client
    if client
        and type(client.GetConversationTraderID) == "function"
    then
        local traderID = client.GetConversationTraderID(npcID)
        local leaderID = traderID
            and type(client.GetTraderLeaderID) == "function"
            and client.GetTraderLeaderID(traderID)
            or nil
        if traderID and sameID(leaderID, npcID) then
            return MERCHANT_ROLE
        end
        if traderID then return GUARD_ROLE end
    end

    return roleFromService(npcID)
end

local function categoryEligibility(category, context)
    if not category
        or tostring(category.id or "") ~= CATEGORY_ID
    then
        return true
    end
    local npcID = context and context.npcID or nil
    return Integration.RoleForNPC(npcID) == GUARD_ROLE,
        "dthoomans_referral_requires_guard"
end

local function registerReferral(conversations)
    -- PSDL owns the referral wording and semantic identity.  This adapter only
    -- projects the compiled plan into DTHoomans' existing category/block API;
    -- it does not author a second node/choice/outcome source.
    local registry = PsychopatzCore and PsychopatzCore.Conversation
        and PsychopatzCore.Conversation.Registry or nil
    local plan = registry and type(registry.ConvoPlan) == "function"
        and registry.ConvoPlan("trade.conversation.referral") or nil
    local payload = plan and plan.payload or nil
    local metadata = payload and payload.metadata or nil
    local runtime = metadata and metadata.runtime or nil
    if type(runtime) ~= "table" then
        return false, "psdl_referral_plan_unavailable"
    end
    local category = type(conversations.GetCategory) == "function"
        and conversations.GetCategory(CATEGORY_ID)
        or nil
    if not category then
        local ok = conversations.RegisterCategory(
            CATEGORY_ID,
            {
                ownerModID = DTHoomans.MOD_ID,
                labelKey = runtime.categoryKey or "category.caravan_referral",
                order = 705,
                textSource = TEXT_SOURCE,
            }
        )
        if not ok then
            return false, "caravan_category_registration_failed"
        end
    end

    local block = type(conversations.GetBlock) == "function"
        and conversations.GetBlock(BLOCK_ID)
        or nil
    if not block then
        local ok = conversations.RegisterBlock(
            BLOCK_ID,
            {
                schemaVersion = 1,
                ownerModID = DTHoomans.MOD_ID,
                category = CATEGORY_ID,
                audiences = {
                    "neutral",
                    "member",
                    "special",
                },
                priority = 1000,
                weight = 100,
                textSource = TEXT_SOURCE,
                entryNode = runtime.entryKey or "opening",
                nodes = {
                    opening = {
                        textKey = runtime.openingKey or "opening",
                        choices = {
                            {
                                id = runtime.choiceID or Integration.REFERRAL_CHOICE_ID,
                                textKey = runtime.choiceKey or "choice.trader_referral",
                                outcomes = {
                                    {
                                        id = "reply",
                                        weight = 100,
                                        responseKey = runtime.responseKey
                                            or "response.trader_referral",
                                        next = "$root",
                                    },
                                },
                            },
                        },
                    },
                },
            }
        )
        if not ok then
            return false, "caravan_block_registration_failed"
        end
    end

    local registry = PsychopatzCore and PsychopatzCore.Conversation
        and PsychopatzCore.Conversation.Registry or nil
    if registry
        and type(registry.RegisterCategoryEligibilityProvider)
            == "function"
        and not (
            registry.categoryEligibilityProviders
            and registry.categoryEligibilityProviders[PROVIDER_ID]
        )
    then
        local ok = registry.RegisterCategoryEligibilityProvider(
            PROVIDER_ID,
            { evaluate = categoryEligibility }
        )
        if not ok then
            return false,
                "caravan_eligibility_registration_failed"
        end
    end
    return true
end

local function registerDefinitions()
    local conversations = PNC and PNC.API
        and PNC.API.Conversations or nil
    if not conversations then
        return false, "conversation_api_unavailable"
    end

    local referralOK, referralReason =
        registerReferral(conversations)
    if not referralOK then return false, referralReason end

    print(
        "[DT][INFO] conversation_registered"
            .. " category=" .. CATEGORY_ID
            .. " block=" .. BLOCK_ID
            .. " provider=" .. PROVIDER_ID
    )
    return true
end

function Integration.Register()
    if Integration._registered then return true, "registered" end
    local registered, reason = registerDefinitions()
    Integration._registered = registered == true
    return registered, reason
end

if not Integration._registered then
    local registered, reason = Integration.Register()
    if not registered then
        print(
            "[DT][WARN] conversation_registration_failed reason="
                .. tostring(reason)
        )
    end
end

return Integration
