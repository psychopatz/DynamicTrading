-- Generated; do not edit by hand.
return {
    {
        ["actionProviders"] = {
            {
                ["capabilityRequired"] = "DT.trade",
                ["effectID"] = "DT.trade",
                ["id"] = "DT.trade_action",
                ["order"] = 20,
                ["sourceKind"] = "dynamic_trading",
            },
            {
                ["effectID"] = "DT.referral",
                ["id"] = "DT.referral_action",
                ["order"] = 25,
                ["sourceKind"] = "dynamic_trading",
            },
            {
                ["effectID"] = "DT.rumors",
                ["id"] = "DT.rumors_action",
                ["order"] = 40,
                ["sourceKind"] = "dynamic_trading",
            },
        },
        ["concepts"] = {
            {
                ["aliases"] = {
                    "trade",
                    "barter",
                    "buy",
                    "sell",
                    "shop",
                    "goods",
                    "wares",
                },
                ["id"] = "concept.trade.open",
                ["kind"] = "intent",
                ["priority"] = 100,
            },
            {
                ["aliases"] = {
                    "rumor",
                    "news",
                    "stories",
                    "gossip",
                    "word on the road",
                    "road",
                    "road news",
                    "news on the road",
                    "any news",
                    "commercial news",
                    "what's the news",
                },
                ["id"] = "concept.trade.rumors",
                ["kind"] = "intent",
                ["priority"] = 80,
            },
            {
                ["aliases"] = {
                    "tell me a caravan story",
                    "caravan story",
                    "tell me a story",
                    "caravan stories",
                    "travel story",
                },
                ["id"] = "concept.trade.story",
                ["kind"] = "intent",
                ["priority"] = 85,
            },
            {
                ["aliases"] = {
                    "where are you heading",
                    "where are you going",
                    "what settlement are you going to",
                    "where is this caravan going",
                    "destination",
                    "next stop",
                },
                ["id"] = "concept.trade.destination",
                ["kind"] = "intent",
                ["priority"] = 90,
            },
            {
                ["aliases"] = {
                    "where did you come from",
                    "where are you from",
                    "origin",
                    "last stop",
                },
                ["id"] = "concept.trade.origin",
                ["kind"] = "intent",
                ["priority"] = 90,
            },
            {
                ["aliases"] = {
                    "where is the settlement",
                    "what settlement",
                    "which settlement",
                    "nearest settlement",
                },
                ["id"] = "concept.trade.settlement",
                ["kind"] = "intent",
                ["priority"] = 85,
            },
            {
                ["aliases"] = {
                    "where is the trader",
                    "where is the merchant",
                    "where can i find the trader",
                },
                ["id"] = "concept.trade.trader_location",
                ["kind"] = "intent",
                ["priority"] = 90,
            },
            {
                ["aliases"] = {
                    "whereabouts",
                    "routes",
                    "route",
                    "direction",
                    "which way",
                    "what route",
                    "where are you travelling",
                },
                ["id"] = "concept.trade.whereabouts",
                ["kind"] = "intent",
                ["priority"] = 70,
            },
            {
                ["aliases"] = {
                    "who are you",
                    "who is in charge",
                    "who runs this caravan",
                    "who handles trading",
                    "what is your name",
                    "what's your name",
                    "tell me your name",
                    "your name",
                    "leader",
                    "merchant",
                    "guard",
                },
                ["id"] = "concept.trade.who",
                ["kind"] = "intent",
                ["priority"] = 60,
            },
            {
                ["aliases"] = {
                    "hello",
                    "hi",
                    "greetings",
                    "good day",
                    "hey",
                    "howdy",
                },
                ["id"] = "concept.social.greeting",
                ["kind"] = "social",
                ["priority"] = 50,
            },
            {
                ["aliases"] = {
                    "goodbye",
                    "farewell",
                    "see you",
                    "bye",
                    "take care",
                    "safe travels",
                },
                ["id"] = "concept.social.farewell",
                ["kind"] = "social",
                ["priority"] = 50,
            },
        },
        ["id"] = "pack.DT.trader_story",
        ["ownerModID"] = "DynamicTrading",
        ["patterns"] = {
            {
                ["emit"] = {
                    ["intent"] = "FAREWELL",
                    ["speechAct"] = "act.trade.farewell",
                },
                ["id"] = "pattern.trade.concept_farewell",
                ["match"] = {
                    {
                        ["concept"] = "concept.social.farewell",
                    },
                },
                ["priority"] = 90,
            },
            {
                ["emit"] = {
                    ["intent"] = "GREETING",
                    ["speechAct"] = "act.trade.greeting",
                },
                ["id"] = "pattern.trade.concept_greeting",
                ["match"] = {
                    {
                        ["concept"] = "concept.social.greeting",
                    },
                },
                ["priority"] = 90,
            },
            {
                ["emit"] = {
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_who",
                    ["topic"] = "identity",
                },
                ["id"] = "pattern.trade.concept_who",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.who",
                    },
                },
                ["priority"] = 85,
            },
            {
                ["emit"] = {
                    ["factClass"] = "trader_location",
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_who",
                    ["topic"] = "identity",
                },
                ["id"] = "pattern.trade.concept_trader_location",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.trader_location",
                    },
                },
                ["priority"] = 88,
            },
            {
                ["emit"] = {
                    ["factClass"] = "destination",
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_whereabouts",
                    ["topic"] = "whereabouts",
                },
                ["id"] = "pattern.trade.concept_destination",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.destination",
                    },
                },
                ["priority"] = 86,
            },
            {
                ["emit"] = {
                    ["factClass"] = "origin",
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_whereabouts",
                    ["topic"] = "whereabouts",
                },
                ["id"] = "pattern.trade.concept_origin",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.origin",
                    },
                },
                ["priority"] = 86,
            },
            {
                ["emit"] = {
                    ["factClass"] = "settlement",
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_whereabouts",
                    ["topic"] = "whereabouts",
                },
                ["id"] = "pattern.trade.concept_settlement",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.settlement",
                    },
                },
                ["priority"] = 86,
            },
            {
                ["emit"] = {
                    ["factClass"] = "whereabouts",
                    ["intent"] = "QUESTION",
                    ["speechAct"] = "act.trade.ask_whereabouts",
                    ["topic"] = "whereabouts",
                },
                ["id"] = "pattern.trade.concept_whereabouts",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.whereabouts",
                    },
                },
                ["priority"] = 80,
            },
            {
                ["emit"] = {
                    ["factClass"] = "road_news",
                    ["intent"] = "GOSSIP",
                    ["speechAct"] = "act.trade.ask_rumors",
                    ["topic"] = "rumors",
                },
                ["id"] = "pattern.trade.concept_rumors",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.rumors",
                    },
                },
                ["priority"] = 75,
            },
            {
                ["emit"] = {
                    ["factClass"] = "caravan_story",
                    ["intent"] = "GOSSIP",
                    ["speechAct"] = "act.trade.ask_story",
                    ["topic"] = "story",
                },
                ["id"] = "pattern.trade.concept_story",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.story",
                    },
                },
                ["priority"] = 82,
            },
            {
                ["capabilitiesRequired"] = {
                    "DT.trade",
                },
                ["emit"] = {
                    ["intent"] = "TRADE",
                    ["speechAct"] = "act.trade.request",
                    ["topic"] = "trade",
                },
                ["id"] = "pattern.trade.concept_open",
                ["match"] = {
                    {
                        ["concept"] = "concept.trade.open",
                    },
                },
                ["priority"] = 95,
            },
            {
                ["capabilitiesRequired"] = {
                    "DT.trade",
                },
                ["emit"] = {
                    ["intent"] = "TRADE",
                    ["speechAct"] = "act.trade.request",
                },
                ["id"] = "pattern.trade.open",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "trade",
                    },
                },
                ["priority"] = 100,
            },
            {
                ["capabilitiesRequired"] = {
                    "DT.trade",
                },
                ["emit"] = {
                    ["intent"] = "TRADE",
                    ["speechAct"] = "act.trade.request",
                },
                ["id"] = "pattern.trade.buy",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "buy",
                    },
                },
                ["priority"] = 90,
            },
            {
                ["capabilitiesRequired"] = {
                    "DT.trade",
                },
                ["emit"] = {
                    ["intent"] = "TRADE",
                    ["speechAct"] = "act.trade.request",
                },
                ["id"] = "pattern.trade.sell",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "sell",
                    },
                },
                ["priority"] = 90,
            },
            {
                ["emit"] = {
                    ["factClass"] = "road_news",
                    ["intent"] = "GOSSIP",
                    ["speechAct"] = "act.trade.ask_rumors",
                },
                ["id"] = "pattern.trade.rumors",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "news",
                    },
                },
                ["priority"] = 80,
            },
            {
                ["emit"] = {
                    ["intent"] = "GREETING",
                    ["speechAct"] = "act.trade.greeting",
                },
                ["id"] = "pattern.trade.greeting_hello",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "hello",
                    },
                },
                ["priority"] = 50,
            },
            {
                ["emit"] = {
                    ["intent"] = "GREETING",
                    ["speechAct"] = "act.trade.greeting",
                },
                ["id"] = "pattern.trade.greeting_hi",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "hi",
                    },
                },
                ["priority"] = 50,
            },
            {
                ["emit"] = {
                    ["intent"] = "FAREWELL",
                    ["speechAct"] = "act.trade.farewell",
                },
                ["id"] = "pattern.trade.farewell",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "bye",
                    },
                },
                ["priority"] = 50,
            },
            {
                ["emit"] = {
                    ["intent"] = "FAREWELL",
                    ["speechAct"] = "act.trade.farewell",
                },
                ["id"] = "pattern.trade.farewell_goodbye",
                ["match"] = {
                    {
                        ["kind"] = "literal",
                        ["value"] = "goodbye",
                    },
                },
                ["priority"] = 55,
            },
        },
        ["speechActs"] = {
            {
                ["definition"] = {
                    ["id"] = "act.trade.request",
                    ["intent"] = "TRADE",
                },
                ["id"] = "act.trade.request",
                ["metadata"] = {
                    ["priority"] = 100,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.ask_rumors",
                    ["intent"] = "GOSSIP",
                },
                ["id"] = "act.trade.ask_rumors",
                ["metadata"] = {
                    ["priority"] = 80,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.ask_story",
                    ["intent"] = "GOSSIP",
                },
                ["id"] = "act.trade.ask_story",
                ["metadata"] = {
                    ["priority"] = 85,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.ask_whereabouts",
                    ["intent"] = "QUESTION",
                },
                ["id"] = "act.trade.ask_whereabouts",
                ["metadata"] = {
                    ["priority"] = 70,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.ask_who",
                    ["intent"] = "QUESTION",
                },
                ["id"] = "act.trade.ask_who",
                ["metadata"] = {
                    ["priority"] = 75,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.greeting",
                    ["intent"] = "GREETING",
                },
                ["id"] = "act.trade.greeting",
                ["metadata"] = {
                    ["priority"] = 50,
                },
            },
            {
                ["definition"] = {
                    ["id"] = "act.trade.farewell",
                    ["intent"] = "FAREWELL",
                },
                ["id"] = "act.trade.farewell",
                ["metadata"] = {
                    ["priority"] = 50,
                },
            },
        },
        ["version"] = 2,
    },
}
