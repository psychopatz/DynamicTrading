-- Standalone Dynamic Trading Semantic and Story Pack for PsychopatzCore.
--
-- Registers trader/guard concepts, speech acts, patterns, relationship-aware
-- dialogue blocks, rumors, stories, and trade action providers directly into
-- PsychopatzCore without any Project Hoomans dependency.

DTCommon = DTCommon or {}
local Pack = {}
DTCommon.SemanticPack = Pack

Pack.PACK_ID = "pack.dynamictrading.trader_story"

local function registerPack()
    local Semantics = PsychopatzCore and PsychopatzCore.Semantics or nil
    if not Semantics or type(Semantics.RegisterPack) ~= "function" then
        return false, "core_semantics_unavailable"
    end

    local packSpec = {
        id = Pack.PACK_ID,
        ownerModID = "DynamicTrading",
        version = 1,
        capabilitiesRequired = { "dynamictrading.trade" },

        -- 1. Semantic Concepts
        concepts = {
            {
                id = "concept.trade.open",
                aliases = { "trade", "barter", "buy", "sell", "shop", "goods", "wares" },
                kind = "intent",
                priority = 100,
            },
            {
                id = "concept.trade.rumors",
                aliases = { "rumor", "news", "stories", "gossip", "word on the road", "road" },
                kind = "intent",
                priority = 80,
            },
            {
                id = "concept.trade.whereabouts",
                aliases = { "where are you heading", "where did you come from", "routes", "settlement", "destination" },
                kind = "intent",
                priority = 70,
            },
            {
                id = "concept.trade.who",
                aliases = { "who are you", "who is in charge", "who runs this caravan", "leader", "merchant", "guard" },
                kind = "intent",
                priority = 60,
            },
            {
                id = "concept.social.greeting",
                aliases = { "hello", "hi", "greetings", "good day", "hey", "howdy" },
                kind = "social",
                priority = 50,
            },
            {
                id = "concept.social.farewell",
                aliases = { "goodbye", "farewell", "see you", "bye", "take care", "safe travels" },
                kind = "social",
                priority = 50,
            },
        },

        -- 2. Speech Acts
        speechActs = {
            {
                definition = { id = "act.trade.request", intent = "TRADE" },
                metadata = { priority = 100 },
            },
            {
                definition = { id = "act.trade.ask_rumors", intent = "GOSSIP" },
                metadata = { priority = 80 },
            },
            {
                definition = { id = "act.trade.ask_whereabouts", intent = "QUESTION" },
                metadata = { priority = 70 },
            },
            {
                definition = { id = "act.trade.greeting", intent = "GREETING" },
                metadata = { priority = 50 },
            },
            {
                definition = { id = "act.trade.farewell", intent = "FAREWELL" },
                metadata = { priority = 50 },
            },
        },

        -- 3. Patterns
        patterns = {
            {
                id = "pattern.trade.open",
                priority = 100,
                match = { { kind = "literal", value = "trade" } },
                emit = { intent = "TRADE", speechAct = "act.trade.request" },
            },
            {
                id = "pattern.trade.buy",
                priority = 90,
                match = { { kind = "literal", value = "buy" } },
                emit = { intent = "TRADE", speechAct = "act.trade.request" },
            },
            {
                id = "pattern.trade.sell",
                priority = 90,
                match = { { kind = "literal", value = "sell" } },
                emit = { intent = "TRADE", speechAct = "act.trade.request" },
            },
            {
                id = "pattern.trade.rumors",
                priority = 80,
                match = { { kind = "literal", value = "news" } },
                emit = { intent = "GOSSIP", speechAct = "act.trade.ask_rumors" },
            },
            {
                id = "pattern.trade.greeting_hello",
                priority = 50,
                match = { { kind = "literal", value = "hello" } },
                emit = { intent = "GREETING", speechAct = "act.trade.greeting" },
            },
            {
                id = "pattern.trade.greeting_hi",
                priority = 50,
                match = { { kind = "literal", value = "hi" } },
                emit = { intent = "GREETING", speechAct = "act.trade.greeting" },
            },
            {
                id = "pattern.trade.farewell",
                priority = 50,
                match = { { kind = "literal", value = "bye" } },
                emit = { intent = "FAREWELL", speechAct = "act.trade.farewell" },
            },
        },

        -- 4. Action Providers
        actionProviders = {
            {
                id = "dynamictrading.trade_action",
                sourceKind = "dynamic_trading",
                capabilityRequired = "dynamictrading.trade",
                order = 20,
                collect = function(ctx)
                    ctx = type(ctx) == "table" and ctx or {}
                    local role = ctx.traderRole or "trader"
                    if role == "guard" then return {} end
                    return {
                        {
                            id = "dynamictrading.trade",
                            topic = "trade",
                            capabilityRequired = "dynamictrading.trade",
                            sourceKind = "dynamic_trading",
                            semanticOwner = "dynamictrading.trader",
                            textKey = "UI_DT_Trade",
                            fallbackText = "Trade with merchant",
                            order = 20,
                        },
                    }
                end,
            },
            {
                id = "dynamictrading.referral_action",
                sourceKind = "dynamic_trading",
                capabilityRequired = "dynamictrading.trade",
                order = 25,
                collect = function(ctx)
                    ctx = type(ctx) == "table" and ctx or {}
                    local role = ctx.traderRole or "trader"
                    if role ~= "guard" then return {} end
                    return {
                        {
                            id = "dynamictrading.referral",
                            topic = "referral",
                            capabilityRequired = "dynamictrading.trade",
                            sourceKind = "dynamic_trading",
                            semanticOwner = "dynamictrading.guard",
                            textKey = "UI_DT_Referral",
                            fallbackText = "Ask who handles trades",
                            order = 25,
                        },
                    }
                end,
            },
            {
                id = "dynamictrading.rumors_action",
                sourceKind = "dynamic_trading",
                capabilityRequired = "dynamictrading.trade",
                order = 40,
                collect = function(ctx)
                    return {
                        {
                            id = "dynamictrading.rumors",
                            topic = "rumors",
                            capabilityRequired = "dynamictrading.trade",
                            sourceKind = "dynamic_trading",
                            semanticOwner = "dynamictrading.trader",
                            textKey = "UI_DT_Rumors",
                            fallbackText = "Ask for news from the road",
                            order = 40,
                        },
                    }
                end,
            },
        },

        -- 5. Dialogue Blocks (relationship-aware conversation content)
        dialogueBlocks = {
            ["dt_block_greeting_friend"] = {
                category = "greeting",
                priority = 200,
                weight = 100,
                gates = {
                    { field = "relationship.approval", op = ">=", value = 25 },
                },
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Greeting_Friend",
                        fallback = "Good to see you again, friend! What can I trade for you today?",
                        choices = {
                            {
                                id = "choice_trade",
                                textKey = "UI_DT_Trade",
                                fallback = "Open trade",
                                capabilityRequired = "dynamictrading.trade",
                                outcomes = {
                                    { id = "open_trade", responseKey = "DTCommon_Talk_Opening_Trade" },
                                },
                            },
                            {
                                id = "choice_rumors",
                                textKey = "UI_DT_Rumors",
                                fallback = "Any news from the road?",
                                outcomes = {
                                    { id = "tell_rumor", responseKey = "DTCommon_Talk_Rumors_Friend" },
                                },
                            },
                        },
                    },
                },
            },
            ["dt_block_greeting_neutral"] = {
                category = "greeting",
                priority = 100,
                weight = 100,
                gates = {
                    { field = "relationship.approval", op = ">=", value = -15 },
                },
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Greeting_Neutral",
                        fallback = "Welcome. Looking to buy or sell?",
                        choices = {
                            {
                                id = "choice_trade",
                                textKey = "UI_DT_Trade",
                                fallback = "Open trade",
                                capabilityRequired = "dynamictrading.trade",
                                outcomes = {
                                    { id = "open_trade", responseKey = "DTCommon_Talk_Opening_Trade" },
                                },
                            },
                        },
                    },
                },
            },
            ["dt_block_greeting_wary"] = {
                category = "greeting",
                priority = 50,
                weight = 100,
                gates = {},
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Greeting_Wary",
                        fallback = "Keep your hands where I can see them. Make it quick.",
                        choices = {
                            {
                                id = "choice_trade",
                                textKey = "UI_DT_Trade",
                                fallback = "Let's trade",
                                capabilityRequired = "dynamictrading.trade",
                                outcomes = {
                                    { id = "open_trade", responseKey = "DTCommon_Talk_Opening_Trade" },
                                },
                            },
                        },
                    },
                },
            },
            ["dt_block_rumors_friend"] = {
                category = "rumor",
                priority = 200,
                gates = {
                    { field = "relationship.approval", op = ">=", value = 20 },
                },
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Rumors_Friend",
                        fallback = "Between you and me, word is the northern supply lines are drying up. Stock up on ammo while you can.",
                    },
                },
            },
            ["dt_block_rumors_neutral"] = {
                category = "rumor",
                priority = 100,
                gates = {},
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Rumors_Neutral",
                        fallback = "The roads are rough. More infected moving through the valley every week.",
                    },
                },
            },
            ["dt_block_farewell_friend"] = {
                category = "farewell",
                priority = 200,
                gates = {
                    { field = "relationship.approval", op = ">=", value = 20 },
                },
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Farewell_Friend",
                        fallback = "Safe travels out there, friend. Until our next deal.",
                    },
                },
            },
            ["dt_block_farewell_neutral"] = {
                category = "farewell",
                priority = 100,
                gates = {},
                entryNode = "opening",
                nodes = {
                    opening = {
                        textKey = "DTCommon_Talk_Farewell_Neutral",
                        fallback = "Watch your back out there.",
                    },
                },
            },
        },
    }

    local registered, reason = Semantics.RegisterPack(packSpec)
    if not registered then
        print("[DT][WARN] semantic_pack_registration_failed reason=" .. tostring(reason))
        return false, reason
    end
    print("[DT][INFO] semantic_pack_registered id=" .. Pack.PACK_ID)
    Pack._registered = true
    return true
end

function Pack.Init()
    if not Pack._registered then
        registerPack()
    end
end

Pack.Init()

return Pack
