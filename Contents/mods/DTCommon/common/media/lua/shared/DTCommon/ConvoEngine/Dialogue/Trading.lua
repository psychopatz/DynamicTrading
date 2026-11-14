-- Generated; do not edit by hand.
return {
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "trade",
                },
                ["labelFallback"] = "Open trading",
                ["labelKey"] = "convo.action.trade.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Open trading",
                    },
                    ["TL"] = {
                        "Buksan ang kalakalan",
                    },
                },
            },
            ["familyID"] = "action.trade",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Let's trade.",
                                ["id"] = "default",
                                ["templateID"] = "convo.action.trade.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Let's trade.",
                                    },
                                    ["TL"] = {
                                        "Magpalitan tayo.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "TRADE",
                ["patternID"] = "pattern.trade.concept_open",
                ["speechAct"] = "TRADE",
                ["subject"] = "TRADE",
                ["topic"] = "trade",
            },
            ["namespace"] = "action",
            ["textRoles"] = {
                {
                    ["fallback"] = "Open trading",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.action.trade.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Open trading",
                        },
                        ["TL"] = {
                            "Buksan ang kalakalan",
                        },
                    },
                },
                {
                    ["fallback"] = "Let's trade.",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.action.trade.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Let's trade.",
                        },
                        ["TL"] = {
                            "Magpalitan tayo.",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "action.trade",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "trade",
            ["sourceId"] = "action.trade",
            ["sourcePath"] = "adopters/dt/dialogue/trading/action_trade.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "action",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "trade",
                },
                ["label"] = {
                    ["EN"] = {
                        "Open trading",
                    },
                    ["TL"] = {
                        "Buksan ang kalakalan",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "TRADE",
                ["patternID"] = "pattern.trade.concept_open",
                ["speechAct"] = "TRADE",
                ["subject"] = "TRADE",
                ["topic"] = "trade",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "trade",
                    ["id"] = "action.trade",
                    ["intent"] = "TRADE",
                    ["order"] = 80,
                    ["patternID"] = "pattern.trade.concept_open",
                    ["speechAct"] = "TRADE",
                    ["subject"] = "TRADE",
                    ["topic"] = "trade",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Let's trade.",
                                    },
                                    ["TL"] = {
                                        "Magpalitan tayo.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "action.trade",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Let's trade.",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.action.trade.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/action_trade.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Open trading",
                ["role"] = "button_label",
                ["templateID"] = "convo.action.trade.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Open trading",
                    },
                    ["TL"] = {
                        "Buksan ang kalakalan",
                    },
                },
            },
            {
                ["fallback"] = "Let's trade.",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.action.trade.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Let's trade.",
                    },
                    ["TL"] = {
                        "Magpalitan tayo.",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["labelFallback"] = "Ask where they are headed",
                ["labelKey"] = "convo.question.destination.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask where they are headed",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila patungo",
                    },
                },
            },
            ["familyID"] = "question.destination",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Where are you heading?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.destination.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Where are you heading?",
                                    },
                                    ["TL"] = {
                                        "Saan kayo patungo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_destination",
                ["speechAct"] = "QUESTION",
                ["subject"] = "DESTINATION",
                ["topic"] = "whereabouts",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask where they are headed",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.destination.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask where they are headed",
                        },
                        ["TL"] = {
                            "Itanong kung saan sila patungo",
                        },
                    },
                },
                {
                    ["fallback"] = "Where are you heading?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.destination.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Where are you heading?",
                        },
                        ["TL"] = {
                            "Saan kayo patungo?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.destination",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "destination",
            ["sourceId"] = "question.destination",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_destination.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask where they are headed",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila patungo",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_destination",
                ["speechAct"] = "QUESTION",
                ["subject"] = "DESTINATION",
                ["topic"] = "whereabouts",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "whereabouts",
                    ["id"] = "question.destination",
                    ["intent"] = "QUESTION",
                    ["order"] = 20,
                    ["patternID"] = "pattern.trade.concept_destination",
                    ["speechAct"] = "QUESTION",
                    ["subject"] = "DESTINATION",
                    ["topic"] = "whereabouts",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Where are you heading?",
                                    },
                                    ["TL"] = {
                                        "Saan kayo patungo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.destination",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Where are you heading?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.destination.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_destination.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask where they are headed",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.destination.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask where they are headed",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila patungo",
                    },
                },
            },
            {
                ["fallback"] = "Where are you heading?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.destination.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Where are you heading?",
                    },
                    ["TL"] = {
                        "Saan kayo patungo?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["labelFallback"] = "Ask where they came from",
                ["labelKey"] = "convo.question.origin.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask where they came from",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila nanggaling",
                    },
                },
            },
            ["familyID"] = "question.origin",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Where did you come from?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.origin.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Where did you come from?",
                                    },
                                    ["TL"] = {
                                        "Saan kayo nanggaling?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_origin",
                ["speechAct"] = "QUESTION",
                ["subject"] = "ORIGIN",
                ["topic"] = "whereabouts",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask where they came from",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.origin.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask where they came from",
                        },
                        ["TL"] = {
                            "Itanong kung saan sila nanggaling",
                        },
                    },
                },
                {
                    ["fallback"] = "Where did you come from?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.origin.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Where did you come from?",
                        },
                        ["TL"] = {
                            "Saan kayo nanggaling?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.origin",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "origin",
            ["sourceId"] = "question.origin",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_origin.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask where they came from",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila nanggaling",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_origin",
                ["speechAct"] = "QUESTION",
                ["subject"] = "ORIGIN",
                ["topic"] = "whereabouts",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "whereabouts",
                    ["id"] = "question.origin",
                    ["intent"] = "QUESTION",
                    ["order"] = 30,
                    ["patternID"] = "pattern.trade.concept_origin",
                    ["speechAct"] = "QUESTION",
                    ["subject"] = "ORIGIN",
                    ["topic"] = "whereabouts",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Where did you come from?",
                                    },
                                    ["TL"] = {
                                        "Saan kayo nanggaling?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.origin",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Where did you come from?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.origin.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_origin.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask where they came from",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.origin.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask where they came from",
                    },
                    ["TL"] = {
                        "Itanong kung saan sila nanggaling",
                    },
                },
            },
            {
                ["fallback"] = "Where did you come from?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.origin.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Where did you come from?",
                    },
                    ["TL"] = {
                        "Saan kayo nanggaling?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "gossip",
                },
                ["labelFallback"] = "Ask for news from the road",
                ["labelKey"] = "convo.question.rumors.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask for news from the road",
                    },
                    ["TL"] = {
                        "Magtanong ng balita mula sa daan",
                    },
                },
            },
            ["familyID"] = "question.rumors",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Any news from the road?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.rumors.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Any news from the road?",
                                    },
                                    ["TL"] = {
                                        "May balita ba mula sa daan?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "GOSSIP",
                ["patternID"] = "pattern.trade.concept_rumors",
                ["speechAct"] = "GOSSIP",
                ["subject"] = "RUMORS",
                ["topic"] = "gossip",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask for news from the road",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.rumors.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask for news from the road",
                        },
                        ["TL"] = {
                            "Magtanong ng balita mula sa daan",
                        },
                    },
                },
                {
                    ["fallback"] = "Any news from the road?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.rumors.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Any news from the road?",
                        },
                        ["TL"] = {
                            "May balita ba mula sa daan?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.rumors",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "rumors",
            ["sourceId"] = "question.rumors",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_rumors.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "gossip",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask for news from the road",
                    },
                    ["TL"] = {
                        "Magtanong ng balita mula sa daan",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "GOSSIP",
                ["patternID"] = "pattern.trade.concept_rumors",
                ["speechAct"] = "GOSSIP",
                ["subject"] = "RUMORS",
                ["topic"] = "gossip",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "gossip",
                    ["id"] = "question.rumors",
                    ["intent"] = "GOSSIP",
                    ["order"] = 50,
                    ["patternID"] = "pattern.trade.concept_rumors",
                    ["speechAct"] = "GOSSIP",
                    ["subject"] = "RUMORS",
                    ["topic"] = "gossip",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Any news from the road?",
                                    },
                                    ["TL"] = {
                                        "May balita ba mula sa daan?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.rumors",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Any news from the road?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.rumors.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_rumors.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask for news from the road",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.rumors.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask for news from the road",
                    },
                    ["TL"] = {
                        "Magtanong ng balita mula sa daan",
                    },
                },
            },
            {
                ["fallback"] = "Any news from the road?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.rumors.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Any news from the road?",
                    },
                    ["TL"] = {
                        "May balita ba mula sa daan?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["labelFallback"] = "Ask about the nearest settlement",
                ["labelKey"] = "convo.question.settlement.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask about the nearest settlement",
                    },
                    ["TL"] = {
                        "Itanong ang pinakamalapit na pamayanan",
                    },
                },
            },
            ["familyID"] = "question.settlement",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Where is the nearest settlement?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.settlement.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Where is the nearest settlement?",
                                    },
                                    ["TL"] = {
                                        "Nasaan ang pinakamalapit na pamayanan?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_settlement",
                ["speechAct"] = "QUESTION",
                ["subject"] = "SETTLEMENT",
                ["topic"] = "whereabouts",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask about the nearest settlement",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.settlement.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask about the nearest settlement",
                        },
                        ["TL"] = {
                            "Itanong ang pinakamalapit na pamayanan",
                        },
                    },
                },
                {
                    ["fallback"] = "Where is the nearest settlement?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.settlement.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Where is the nearest settlement?",
                        },
                        ["TL"] = {
                            "Nasaan ang pinakamalapit na pamayanan?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.settlement",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "settlement",
            ["sourceId"] = "question.settlement",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_settlement.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask about the nearest settlement",
                    },
                    ["TL"] = {
                        "Itanong ang pinakamalapit na pamayanan",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_settlement",
                ["speechAct"] = "QUESTION",
                ["subject"] = "SETTLEMENT",
                ["topic"] = "whereabouts",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "whereabouts",
                    ["id"] = "question.settlement",
                    ["intent"] = "QUESTION",
                    ["order"] = 40,
                    ["patternID"] = "pattern.trade.concept_settlement",
                    ["speechAct"] = "QUESTION",
                    ["subject"] = "SETTLEMENT",
                    ["topic"] = "whereabouts",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Where is the nearest settlement?",
                                    },
                                    ["TL"] = {
                                        "Nasaan ang pinakamalapit na pamayanan?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.settlement",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Where is the nearest settlement?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.settlement.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_settlement.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask about the nearest settlement",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.settlement.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask about the nearest settlement",
                    },
                    ["TL"] = {
                        "Itanong ang pinakamalapit na pamayanan",
                    },
                },
            },
            {
                ["fallback"] = "Where is the nearest settlement?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.settlement.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Where is the nearest settlement?",
                    },
                    ["TL"] = {
                        "Nasaan ang pinakamalapit na pamayanan?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "story",
                },
                ["labelFallback"] = "Ask for a caravan story",
                ["labelKey"] = "convo.question.story.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask for a caravan story",
                    },
                    ["TL"] = {
                        "Humingi ng kuwento ng karaban",
                    },
                },
            },
            ["familyID"] = "question.story",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Tell me a caravan story.",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.story.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Tell me a caravan story.",
                                    },
                                    ["TL"] = {
                                        "Magkuwento kayo tungkol sa karaban.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "GOSSIP",
                ["patternID"] = "pattern.trade.concept_story",
                ["speechAct"] = "GOSSIP",
                ["subject"] = "STORY",
                ["topic"] = "story",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask for a caravan story",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.story.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask for a caravan story",
                        },
                        ["TL"] = {
                            "Humingi ng kuwento ng karaban",
                        },
                    },
                },
                {
                    ["fallback"] = "Tell me a caravan story.",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.story.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Tell me a caravan story.",
                        },
                        ["TL"] = {
                            "Magkuwento kayo tungkol sa karaban.",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.story",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "story",
            ["sourceId"] = "question.story",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_story.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "story",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask for a caravan story",
                    },
                    ["TL"] = {
                        "Humingi ng kuwento ng karaban",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "GOSSIP",
                ["patternID"] = "pattern.trade.concept_story",
                ["speechAct"] = "GOSSIP",
                ["subject"] = "STORY",
                ["topic"] = "story",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "story",
                    ["id"] = "question.story",
                    ["intent"] = "GOSSIP",
                    ["order"] = 70,
                    ["patternID"] = "pattern.trade.concept_story",
                    ["speechAct"] = "GOSSIP",
                    ["subject"] = "STORY",
                    ["topic"] = "story",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Tell me a caravan story.",
                                    },
                                    ["TL"] = {
                                        "Magkuwento kayo tungkol sa karaban.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.story",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Tell me a caravan story.",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.story.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_story.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask for a caravan story",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.story.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask for a caravan story",
                    },
                    ["TL"] = {
                        "Humingi ng kuwento ng karaban",
                    },
                },
            },
            {
                ["fallback"] = "Tell me a caravan story.",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.story.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Tell me a caravan story.",
                    },
                    ["TL"] = {
                        "Magkuwento kayo tungkol sa karaban.",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "identity",
                },
                ["labelFallback"] = "Ask who they are",
                ["labelKey"] = "convo.question.trader.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask who they are",
                    },
                    ["TL"] = {
                        "Itanong kung sino sila",
                    },
                },
            },
            ["familyID"] = "question.trader",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Who are you?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.trader.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Who are you?",
                                    },
                                    ["TL"] = {
                                        "Sino kayo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_who",
                ["speechAct"] = "QUESTION",
                ["subject"] = "TRADER",
                ["topic"] = "identity",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask who they are",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.trader.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask who they are",
                        },
                        ["TL"] = {
                            "Itanong kung sino sila",
                        },
                    },
                },
                {
                    ["fallback"] = "Who are you?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.trader.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "Who are you?",
                        },
                        ["TL"] = {
                            "Sino kayo?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.trader",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "trader",
            ["sourceId"] = "question.trader",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_trader.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "identity",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask who they are",
                    },
                    ["TL"] = {
                        "Itanong kung sino sila",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_who",
                ["speechAct"] = "QUESTION",
                ["subject"] = "TRADER",
                ["topic"] = "identity",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "identity",
                    ["id"] = "question.trader",
                    ["intent"] = "QUESTION",
                    ["order"] = 10,
                    ["patternID"] = "pattern.trade.concept_who",
                    ["speechAct"] = "QUESTION",
                    ["subject"] = "TRADER",
                    ["topic"] = "identity",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "Who are you?",
                                    },
                                    ["TL"] = {
                                        "Sino kayo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.trader",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Who are you?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.trader.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_trader.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask who they are",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.trader.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask who they are",
                    },
                    ["TL"] = {
                        "Itanong kung sino sila",
                    },
                },
            },
            {
                ["fallback"] = "Who are you?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.trader.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "Who are you?",
                    },
                    ["TL"] = {
                        "Sino kayo?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["labelFallback"] = "Ask about their travels",
                ["labelKey"] = "convo.question.whereabouts.affordance.label",
                ["textRole"] = "button_label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask about their travels",
                    },
                    ["TL"] = {
                        "Itanong ang kanilang ruta",
                    },
                },
            },
            ["familyID"] = "question.whereabouts",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "What route are you travelling?",
                                ["id"] = "default",
                                ["templateID"] = "convo.question.whereabouts.say.1.default",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "What route are you travelling?",
                                    },
                                    ["TL"] = {
                                        "Anong ruta ang tinatahak ninyo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_whereabouts",
                ["speechAct"] = "QUESTION",
                ["subject"] = "WHEREABOUTS",
                ["topic"] = "whereabouts",
            },
            ["namespace"] = "question",
            ["textRoles"] = {
                {
                    ["fallback"] = "Ask about their travels",
                    ["role"] = "button_label",
                    ["templateID"] = "convo.question.whereabouts.affordance.label",
                    ["translations"] = {
                        ["EN"] = {
                            "Ask about their travels",
                        },
                        ["TL"] = {
                            "Itanong ang kanilang ruta",
                        },
                    },
                },
                {
                    ["fallback"] = "What route are you travelling?",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.question.whereabouts.say.1.default",
                    ["translations"] = {
                        ["EN"] = {
                            "What route are you travelling?",
                        },
                        ["TL"] = {
                            "Anong ruta ang tinatahak ninyo?",
                        },
                    },
                    ["variantID"] = "default",
                },
            },
        },
        ["id"] = "question.whereabouts",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "whereabouts",
            ["sourceId"] = "question.whereabouts",
            ["sourcePath"] = "adopters/dt/dialogue/trading/question_whereabouts.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "question",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["affordance"] = {
                ["consumers"] = {
                    "player",
                },
                ["groups"] = {
                    "whereabouts",
                },
                ["label"] = {
                    ["EN"] = {
                        "Ask about their travels",
                    },
                    ["TL"] = {
                        "Itanong ang kanilang ruta",
                    },
                },
                ["textRole"] = "button_label",
            },
            ["invoke"] = {
                ["intent"] = "QUESTION",
                ["patternID"] = "pattern.trade.concept_whereabouts",
                ["speechAct"] = "QUESTION",
                ["subject"] = "WHEREABOUTS",
                ["topic"] = "whereabouts",
            },
            ["metadata"] = {
                ["textNamespace"] = "UI_DT_Conversation_Suggestion",
                ["ui"] = {
                    ["domain"] = "whereabouts",
                    ["id"] = "question.whereabouts",
                    ["intent"] = "QUESTION",
                    ["order"] = 60,
                    ["patternID"] = "pattern.trade.concept_whereabouts",
                    ["speechAct"] = "QUESTION",
                    ["subject"] = "WHEREABOUTS",
                    ["topic"] = "whereabouts",
                },
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "default",
                                ["text"] = {
                                    ["EN"] = {
                                        "What route are you travelling?",
                                    },
                                    ["TL"] = {
                                        "Anong ruta ang tinatahak ninyo?",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = nil,
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "question.whereabouts",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "What route are you travelling?",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.question.whereabouts.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/question_whereabouts.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Ask about their travels",
                ["role"] = "button_label",
                ["templateID"] = "convo.question.whereabouts.affordance.label",
                ["translations"] = {
                    ["EN"] = {
                        "Ask about their travels",
                    },
                    ["TL"] = {
                        "Itanong ang kanilang ruta",
                    },
                },
            },
            {
                ["fallback"] = "What route are you travelling?",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.question.whereabouts.say.1.default",
                ["translations"] = {
                    ["EN"] = {
                        "What route are you travelling?",
                    },
                    ["TL"] = {
                        "Anong ruta ang tinatahak ninyo?",
                    },
                },
                ["variantID"] = "default",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["familyID"] = "trade.conversation.opening",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "Let's see what we can trade.",
                                ["id"] = "trade.opening",
                                ["templateID"] = "convo.trade.conversation.opening.say.1.trade.opening",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "Let's see what we can trade.",
                                    },
                                    ["TL"] = {
                                        "Tingnan natin kung ano ang maaari nating ipagpalit.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["namespace"] = "trade.conversation",
            ["textRoles"] = {
                {
                    ["fallback"] = "Let's see what we can trade.",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.trade.conversation.opening.say.1.trade.opening",
                    ["translations"] = {
                        ["EN"] = {
                            "Let's see what we can trade.",
                        },
                        ["TL"] = {
                            "Tingnan natin kung ano ang maaari nating ipagpalit.",
                        },
                    },
                    ["variantID"] = "trade.opening",
                },
            },
        },
        ["id"] = "trade.conversation.opening",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "opening",
            ["sourceId"] = "trade.conversation.opening",
            ["sourcePath"] = "adopters/dt/dialogue/trading/trade_conversation_opening.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "trade.conversation",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["metadata"] = {
                ["responseAct"] = "TRADE_OPENING",
                ["runtime"] = {
                    ["categoryID"] = "dynamic_trading:trade",
                    ["choiceID"] = "DT.trade",
                    ["openingKey"] = "opening.trade",
                    ["responseKey"] = "response.trade",
                },
                ["textRows"] = {
                    {
                        ["key"] = "category.trade",
                        ["text"] = {
                            ["EN"] = "Trade",
                            ["TL"] = "Kalakalan",
                        },
                    },
                    {
                        ["key"] = "choice.trade",
                        ["text"] = {
                            ["EN"] = "Open trading",
                            ["TL"] = "Buksan ang kalakalan",
                        },
                    },
                    {
                        ["key"] = "opening.trade",
                        ["text"] = {
                            ["EN"] = "What do you need?",
                            ["TL"] = "Ano ang kailangan mo?",
                        },
                    },
                    {
                        ["key"] = "response.trade",
                        ["text"] = {
                            ["EN"] = "Let's see what we can trade.",
                            ["TL"] = "Tingnan natin kung ano ang maaari nating ipagpalit.",
                        },
                    },
                },
                ["textTarget"] = "dynamic_trading/trade/opening",
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "trade.opening",
                                ["metadata"] = {
                                    ["templateID"] = "DTCommon.TradeOpening",
                                    ["textKey"] = "response.trade",
                                },
                                ["text"] = {
                                    ["EN"] = {
                                        "Let's see what we can trade.",
                                    },
                                    ["TL"] = {
                                        "Tingnan natin kung ano ang maaari nating ipagpalit.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = "TRADE_OPENING",
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "trade.conversation.opening",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "Let's see what we can trade.",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.trade.conversation.opening.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/trade_conversation_opening.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.person",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "Let's see what we can trade.",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.trade.conversation.opening.say.1.trade.opening",
                ["translations"] = {
                    ["EN"] = {
                        "Let's see what we can trade.",
                    },
                    ["TL"] = {
                        "Tingnan natin kung ano ang maaari nating ipagpalit.",
                    },
                },
                ["variantID"] = "trade.opening",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["exchangeFamily"] = {
            ["familyID"] = "trade.conversation.referral",
            ["initiatingSay"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["fallback"] = "I am just a mercenary. Our trader handles the deals.",
                                ["id"] = "trader.referral",
                                ["templateID"] = "convo.trade.conversation.referral.say.1.trader.referral",
                                ["textRole"] = "spoken_action",
                                ["translations"] = {
                                    ["EN"] = {
                                        "I am just a mercenary. Our trader handles the deals.",
                                    },
                                    ["TL"] = {
                                        "Mercenary lang ako. Ang trader namin ang namamahala sa mga kasunduan.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
            ["namespace"] = "trade.conversation",
            ["textRoles"] = {
                {
                    ["fallback"] = "I am just a mercenary. Our trader handles the deals.",
                    ["realizationKey"] = "1",
                    ["role"] = "spoken_action",
                    ["templateID"] = "convo.trade.conversation.referral.say.1.trader.referral",
                    ["translations"] = {
                        ["EN"] = {
                            "I am just a mercenary. Our trader handles the deals.",
                        },
                        ["TL"] = {
                            "Mercenary lang ako. Ang trader namin ang namamahala sa mga kasunduan.",
                        },
                    },
                    ["variantID"] = "trader.referral",
                },
            },
        },
        ["id"] = "trade.conversation.referral",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "referral",
            ["sourceId"] = "trade.conversation.referral",
            ["sourcePath"] = "adopters/dt/dialogue/trading/trade_conversation_referral.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "trade.conversation",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["metadata"] = {
                ["responseAct"] = "TRADER_REFERRAL",
                ["runtime"] = {
                    ["blockID"] = "dthoomans:caravan_referral",
                    ["categoryID"] = "dthoomans:caravan_referral",
                    ["choiceID"] = "trader_referral",
                    ["entryKey"] = "opening",
                    ["openingKey"] = "opening",
                    ["responseKey"] = "response.trader_referral",
                },
                ["textRows"] = {
                    {
                        ["key"] = "category.caravan_referral",
                        ["text"] = {
                            ["EN"] = "Caravan",
                            ["TL"] = "Karabana",
                        },
                    },
                    {
                        ["key"] = "choice.trader_referral",
                        ["text"] = {
                            ["EN"] = "Who handles the trading?",
                            ["TL"] = "Sino ang namamahala sa kalakalan?",
                        },
                    },
                    {
                        ["key"] = "opening",
                        ["text"] = {
                            ["EN"] = "I am only here to keep watch. What do you need?",
                            ["TL"] = "Narito lang ako para magbantay. Ano ang kailangan mo?",
                        },
                    },
                    {
                        ["key"] = "response.trader_referral",
                        ["text"] = {
                            ["EN"] = "I am just a mercenary. Our trader handles the deals.",
                            ["TL"] = "Mercenary lang ako. Ang trader namin ang namamahala sa mga kasunduan.",
                        },
                    },
                },
                ["textTarget"] = "dynamic_trading/caravan/referral/guard",
            },
            ["say"] = {
                ["keyOrder"] = {
                    "1",
                },
                ["mode"] = "single",
                ["realizations"] = {
                    ["1"] = {
                        ["key"] = "1",
                        ["shorthand"] = true,
                        ["variants"] = {
                            {
                                ["id"] = "trader.referral",
                                ["metadata"] = {
                                    ["templateID"] = "DTCommon.TraderReferral",
                                    ["textKey"] = "response.trader_referral",
                                },
                                ["text"] = {
                                    ["EN"] = {
                                        "I am just a mercenary. Our trader handles the deals.",
                                    },
                                    ["TL"] = {
                                        "Mercenary lang ako. Ang trader namin ang namamahala sa mga kasunduan.",
                                    },
                                },
                            },
                        },
                    },
                },
                ["textRole"] = "spoken_action",
            },
        },
        ["references"] = {
        },
        ["responsePlan"] = {
            ["dialogueAct"] = "TRADER_REFERRAL",
            ["kind"] = "dialogue_act_plan",
            ["responsePlanID"] = "trade.conversation.referral",
            ["schemaVersion"] = 1,
            ["turns"] = {
                {
                    ["continuation"] = "end",
                    ["id"] = "say_1",
                    ["offers"] = {
                    },
                    ["segments"] = {
                        {
                            ["args"] = {
                            },
                            ["fallback"] = "I am just a mercenary. Our trader handles the deals.",
                            ["kind"] = "translation",
                            ["templateID"] = "psdl.trade.conversation.referral.say_1",
                        },
                    },
                },
            },
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/trade_conversation_referral.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.person",
        },
        ["textRoles"] = {
            {
                ["fallback"] = "I am just a mercenary. Our trader handles the deals.",
                ["realizationKey"] = "1",
                ["role"] = "spoken_action",
                ["templateID"] = "convo.trade.conversation.referral.say.1.trader.referral",
                ["translations"] = {
                    ["EN"] = {
                        "I am just a mercenary. Our trader handles the deals.",
                    },
                    ["TL"] = {
                        "Mercenary lang ako. Ang trader namin ang namamahala sa mga kasunduan.",
                    },
                },
                ["variantID"] = "trader.referral",
            },
        },
        ["when"] = nil,
    },
    {
        ["domain"] = "trading",
        ["id"] = "trade.conversation.suggestions_recognition",
        ["kind"] = "dialogue",
        ["lineage"] = {
            ["localId"] = "suggestions_recognition",
            ["sourceId"] = "trade.conversation.suggestions_recognition",
            ["sourcePath"] = "adopters/dt/dialogue/trading/suggestions_recognition.json",
            ["sourceSchema"] = "psychopatz.convo-engine.v1",
        },
        ["module"] = "PNC/ConvoEngine/Dialogue/Trading",
        ["namespace"] = "trade.conversation",
        ["owner"] = "DTCommon",
        ["participants"] = {
            ["addressee"] = {
                "participant",
            },
            ["speaker"] = {
                "participant",
            },
        },
        ["payload"] = {
            ["recognition"] = {
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
                ["ownerModID"] = "DynamicTrading",
                ["packID"] = "pack.DT.trader_story",
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
        },
        ["references"] = {
        },
        ["slots"] = {
        },
        ["sourceShard"] = "adopters/dt/dialogue/trading/suggestions_recognition.json",
        ["target"] = {
            ["multiple"] = false,
            ["required"] = false,
            ["type"] = "entity.any",
        },
        ["when"] = nil,
    },
}
