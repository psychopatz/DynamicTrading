DTHoomans = DTHoomans or {}
DTHoomans.Conversation = DTHoomans.Conversation or {}

local Integration = DTHoomans.Conversation
local CATEGORY_ID = "dthoomans:caravan_referral"
local TRADE_CATEGORY_ID = "projecthoomans:trade"
local TRADE_BLOCK_ID = "dthoomans:trade_basic"
local TRADE_PROVIDER_ID = "dynamictrading.trader"
-- Project Hoomans role tokens. "trader" is the token Project Hoomans stores on a
-- caravan merchant; DynamicTrading never invents its own role vocabulary.
local MERCHANT_ROLE = "trader"
local GUARD_ROLE = "guard"
local PROVIDER_ID = "dthoomans:caravan_roles"

Integration.CATEGORY_ID = CATEGORY_ID
Integration.REFERRAL_CHOICE_ID = "trader_referral"
Integration.TRADE_CATEGORY_ID = TRADE_CATEGORY_ID
Integration.TRADE_CHOICE_ID = "trade"

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

local function registerTradeChoiceProvider()
    local registry = PNC and PNC.Semantics
        and PNC.Semantics.DialogueChoiceRegistry or nil
    if type(registry) ~= "table" then
        local ok, loaded = pcall(require,
            "PNC/Semantics/SemanticDialogueSuggestions/PNC_SemanticDialogueSuggestions_Registry")
        registry = ok and loaded or nil
    end
    if not registry or type(registry.RegisterProvider) ~= "function" then
        return false, "choice_registry_unavailable"
    end
    return registry.RegisterProvider({
        id = TRADE_PROVIDER_ID,
        sourceKind = "dynamic_trading",
        order = 70,
        collect = function(context)
            context = type(context) == "table" and context or {}
            local activatedMods = getActivatedMods and getActivatedMods() or nil
            local actor = context.actorConversationContext or {}
            local roles = actor.roles or {}
            local npcID = context.npcID or actor.actorID
            local conversations = PNC and PNC.API
                and PNC.API.Conversations or nil
            local category = conversations
                and type(conversations.GetCategory) == "function"
                and conversations.GetCategory(TRADE_CATEGORY_ID)
            local role = Integration.RoleForNPC(npcID)
            if not activatedMods
                or type(activatedMods.contains) ~= "function"
                or activatedMods:contains("DTHoomans") ~= true
            then
                return {}
            end
            if not category or (role ~= MERCHANT_ROLE
                and roles.trader ~= true)
            then
                return {}
            end
            return {
                {
                    id = "dynamictrading.trade",
                    topic = "trade",
                    groupID = "conversation_branch",
                    source = { kind = "dynamic_trading" },
                    frame = {
                        kind = "semantic_click_frame",
                        candidateID = "dynamictrading.trade",
                        topic = "trade",
                        intent = "REQUEST",
                        speechAct = "REQUEST",
                        subject = "CONVERSATION_ACTION",
                        extensions = {
                            route = "conversation_category",
                            categoryID = TRADE_CATEGORY_ID,
                            topic = "trade",
                            providerID = TRADE_PROVIDER_ID,
                            role = MERCHANT_ROLE,
                        },
                        textKey =
                            "UI_PNC_Conversation_Suggestion_Trade_Utterance",
                        textFallback = "Let's trade.",
                        labelKey =
                            "UI_PNC_Conversation_Suggestion_Trade_Label",
                    },
                    display = {
                        labelKey =
                            "UI_PNC_Conversation_Suggestion_Trade_Label",
                        labelFallback = "Open trading",
                        utteranceKey =
                            "UI_PNC_Conversation_Suggestion_Trade_Utterance",
                        utteranceFallback = "Let's trade.",
                    },
                    visibility = "player",
                },
            }
        end,
    })
end

local function registerDefinitions()
    local conversations = PNC and PNC.API and PNC.API.Conversations
    local registeredCategory
    local registeredBlock
    local registeredTradeCategory
    local registeredTradeBlock
    local registeredProvider
    local registeredChoiceProvider
    local choiceProviderReason
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
    -- Project Hoomans owns the stable category and its disabled-with-reason
    -- contract. Dynamic Trading contributes only its block/provider under
    -- that category; it must not replace the category owner.
    registeredTradeCategory = conversations.GetCategory(TRADE_CATEGORY_ID)
    if not registeredTradeCategory then
        return false, "trade_category_registration_failed"
    end
    registeredTradeBlock = conversations.RegisterBlock(
        TRADE_BLOCK_ID,
        {
            schemaVersion = 1,
            ownerModID = DTHoomans.MOD_ID,
            category = TRADE_CATEGORY_ID,
            audiences = { "neutral", "member", "special" },
            priority = 1000,
            weight = 100,
            textSource = TEXT_SOURCE,
            entryNode = "opening_trade",
            nodes = {
                opening_trade = {
                    textKey = "opening.trade",
                    choices = {
                        {
                            id = Integration.TRADE_CHOICE_ID,
                            textKey = "choice.trade",
                            outcomes = {
                                {
                                    id = "trade",
                                    weight = 100,
                                    responseKey = "response.trade",
                                    next = "$root",
                                },
                            },
                        },
                    },
                },
            },
        }
    )
    if not registeredTradeBlock then
        return false, "trade_block_registration_failed"
    end
    registeredProvider = conversations
        .RegisterCategoryEligibilityProvider(PROVIDER_ID, {
            evaluate = categoryEligibility,
        })
    if not registeredProvider then
        return false, "caravan_eligibility_registration_failed"
    end
    registeredChoiceProvider, choiceProviderReason =
        registerTradeChoiceProvider()
    if not registeredChoiceProvider then
        print("[DT][WARN] choice_provider_registration_failed reason="
            .. tostring(choiceProviderReason))
    end
    print("[DT][INFO] conversation_registered category=" .. CATEGORY_ID
        .. " block=dthoomans:caravan_referral_basic"
        .. " provider=" .. PROVIDER_ID
        .. " tradeCategory=" .. TRADE_CATEGORY_ID
        .. " choiceProvider=" .. TRADE_PROVIDER_ID)
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
