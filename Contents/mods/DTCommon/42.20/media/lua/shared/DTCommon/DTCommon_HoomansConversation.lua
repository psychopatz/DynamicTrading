-- Generic DynamicTrading contribution to ProjectHoomans conversation.
--
-- This adapter is provider-agnostic: an abstract Core actor and a physical
-- Hoomans trader use the same Hoomans category/block/suggestion contracts.
-- Registration is lazy/idempotent so DTCommon does not require PNC load order.

DTCommon = DTCommon or {}
DTCommon.HoomansConversation = DTCommon.HoomansConversation or {}

local Integration = DTCommon.HoomansConversation

Integration.TRADE_CATEGORY_ID = "projecthoomans:trade"
Integration.TRADE_BLOCK_ID = "dtcommon:trade_basic"
Integration.TRADE_PROVIDER_ID = "dynamictrading.trader"
Integration.ELIGIBILITY_PROVIDER_ID = "dtcommon:trader_role"
Integration.TRADE_CHOICE_ID = "trade"

local TEXT_SOURCE = {
    modID = "DTCommon",
    pathPattern =
        "media/conversation/trader/shared/{language}/basic.json",
    domain = "dtcommon.conversation.trader.shared.basic",
}

local function sameID(left, right)
    return tostring(left or "") ~= ""
        and tostring(left) == tostring(right)
end

function Integration.IsTraderActor(npcID)
    local service = DTCommon and DTCommon.TraderService or nil
    local found = false
    if not service or type(service.ForEach) ~= "function" then
        return false
    end
    service.ForEach(function(_, record)
        if found or type(record) ~= "table" then return end
        local ca = type(record.ca) == "table" and record.ca or {}
        if sameID(ca.actorID, npcID)
            or sameID(record.p, npcID)
            or sameID(record.l, npcID)
        then
            found = true
        end
    end)
    return found
end

local function categoryEligibility(category, context)
    if not category
        or tostring(category.id or "")
            ~= Integration.TRADE_CATEGORY_ID
    then
        return true
    end
    local actor = context and context.actorConversationContext or {}
    local roles = type(actor.roles) == "table" and actor.roles or {}
    local npcID = context and (
        context.npcID or actor.actorID
    ) or nil
    if roles.trader == true
        or Integration.IsTraderActor(npcID)
    then
        return true
    end
    return false, "dynamictrading_trade_requires_trader"
end

local function choiceRegistry()
    local registry = PNC and PNC.Semantics
        and PNC.Semantics.DialogueChoiceRegistry or nil
    if type(registry) == "table" then return registry end
    local ok
    ok, registry = pcall(
        require,
        "PNC/Semantics/SemanticDialogueSuggestions/"
            .. "PNC_SemanticDialogueSuggestions_Registry"
    )
    return ok and registry or nil
end

local function registerChoiceProvider()
    local registry = choiceRegistry()
    if not registry or type(registry.RegisterProvider) ~= "function" then
        return false, "choice_registry_unavailable"
    end
    return registry.RegisterProvider({
        id = Integration.TRADE_PROVIDER_ID,
        sourceKind = "dynamic_trading",
        order = 70,
        collect = function(context)
            context = type(context) == "table" and context or {}
            local actor = context.actorConversationContext or {}
            local roles = type(actor.roles) == "table"
                and actor.roles or {}
            local npcID = context.npcID or actor.actorID
            local conversations = PNC and PNC.API
                and PNC.API.Conversations or nil
            local category = conversations
                and type(conversations.GetCategory) == "function"
                and conversations.GetCategory(
                    Integration.TRADE_CATEGORY_ID
                ) or nil
            if not category or (
                roles.trader ~= true
                and not Integration.IsTraderActor(npcID)
            ) then
                return {}
            end
            return {
                {
                    id = "dynamictrading.trade",
                    topic = "trade",
                    groupID = context.activeHubID == "whats_up"
                        and "semantic_hub.whats_up"
                        or "conversation_branch",
                    semanticOwner = Integration.TRADE_PROVIDER_ID,
                    contextReason = "enabled_trader_provider",
                    eligibility = {
                        status = "allowed",
                        allowed = true,
                        reason = "enabled_trader_provider",
                    },
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
                            categoryID =
                                Integration.TRADE_CATEGORY_ID,
                            topic = "trade",
                            providerID =
                                Integration.TRADE_PROVIDER_ID,
                            role = "trader",
                            hubID = context.activeHubID == "whats_up"
                                and "whats_up" or nil,
                            hubAvenue =
                                context.activeHubID == "whats_up"
                                or nil,
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

function Integration.Register()
    local conversations = PNC and PNC.API
        and PNC.API.Conversations or nil
    if not conversations then
        return false, "conversation_api_unavailable"
    end

    local category = type(conversations.GetCategory) == "function"
        and conversations.GetCategory(
            Integration.TRADE_CATEGORY_ID
        ) or nil
    if not category then
        local registered, reason = conversations.RegisterCategory(
            Integration.TRADE_CATEGORY_ID,
            {
                ownerModID = "DTCommon",
                labelKey = "category.trade",
                order = 700,
                textSource = TEXT_SOURCE,
            }
        )
        if not registered then
            return false, reason
                or "trade_category_registration_failed"
        end
    end

    local block = type(conversations.GetBlock) == "function"
        and conversations.GetBlock(
            Integration.TRADE_BLOCK_ID
        ) or nil
    if not block then
        local registered, reason = conversations.RegisterBlock(
            Integration.TRADE_BLOCK_ID,
            {
                schemaVersion = 1,
                ownerModID = "DTCommon",
                category = Integration.TRADE_CATEGORY_ID,
                audiences = {
                    "neutral",
                    "member",
                    "special",
                },
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
        if not registered then
            return false, reason
                or "trade_block_registration_failed"
        end
    end

    local registry = PNC and PNC.Conversation
        and PNC.Conversation.Registry or nil
    if registry
        and type(registry.RegisterCategoryEligibilityProvider)
            == "function"
        and not (
            registry.categoryEligibilityProviders
            and registry.categoryEligibilityProviders[
                Integration.ELIGIBILITY_PROVIDER_ID
            ]
        )
    then
        local registered = registry.RegisterCategoryEligibilityProvider(
            Integration.ELIGIBILITY_PROVIDER_ID,
            { evaluate = categoryEligibility }
        )
        if not registered then
            return false, "trade_eligibility_registration_failed"
        end
    end

    local choice = choiceRegistry()
    if not choice then return false, "choice_registry_unavailable" end
    if not (
        type(choice.GetProvider) == "function"
        and choice.GetProvider(
            Integration.TRADE_PROVIDER_ID
        )
    ) then
        local registered, reason = registerChoiceProvider()
        if not registered then
            return false, reason
                or "trade_choice_provider_registration_failed"
        end
    end

    Integration._registered = true
    return true, "registered"
end

return Integration
