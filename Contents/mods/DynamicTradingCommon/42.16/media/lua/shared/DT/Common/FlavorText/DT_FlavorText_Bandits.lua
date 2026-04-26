require "DT/Common/FlavorText/DT_FlavorText"

DynamicTrading.FlavorText.RegisterTable("Bandits", "Approach", "EN", {
    "Stop right there. You're paying a road fee.",
    "That's close enough. Hands where we can see them.",
    "Easy now. This road has a toll.",
    "Don't make this ugly. We only want our cut.",
    "Nice and slow. Bags open.",
    "You wandered into the wrong stretch of road.",
    "Nobody passes here for free anymore.",
    "Keep your hands still and listen close.",
    "We have been watching you. Pay up and keep walking.",
    "You look stocked. That makes this simple.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Money", "EN", {
    "Let's keep this simple. Hand over %1.",
    "Your wallet. %1. Now.",
    "Road tax is %1. Pay it.",
    "You can spare %1, or you can bleed for it.",
    "Count out %1 and nobody needs to get brave.",
    "We are taking %1. Don't reach for anything else.",
    "Drop %1 on the ground and back away.",
    "Price of staying alive today is %1.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Item", "EN", {
    "That %1. Hand it over.",
    "We want the %1. No arguments.",
    "The %1 comes with us.",
    "Put the %1 down nice and slow.",
    "That %1 looks useful. It belongs to us now.",
    "Toss over the %1 and you walk.",
    "We will take the %1. You keep your teeth.",
    "Don't get attached to the %1.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Tribute", "EN", {
    "%1 sent us. Offer a gift and maybe we leave this alone.",
    "You're in bad standing with %1. Make an offering before this gets worse.",
    "%1 has a grievance. Bring a gift and we might walk.",
    "We came on behalf of %1. Show respect with a gift.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Accept", "EN", {
    "Smart choice.",
    "See? Nobody had to be stupid.",
    "Good. Keep walking.",
    "That will do.",
    "You made the right call.",
    "Pleasure doing business. Keep moving.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "GiftAccepted", "EN", {
    "That will buy you a little peace.",
    "We'll take it and step back for now.",
    "A sensible offering. We're done here.",
    "This settles today.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "GiftAcceptedHigh", "EN", {
    "A proper gift. We'll remember it.",
    "That buys more than distance. We'll cool things off a little.",
    "Generous. Maybe %1 points of goodwill finds its way back to you.",
    "That's enough to ease tempers, for now.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Refuse", "EN", {
    "Wrong answer.",
    "Then we do this the hard way.",
    "You should have paid.",
    "Bad time to grow a spine.",
    "Enough talking.",
    "Your choice.",
    "Take them.",
    "Fine. We take everything.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Empty", "EN", {
    "You've got nothing worth the trouble. Get out of here.",
    "Empty pockets. Waste of our time.",
    "Not even worth the swing. Move.",
    "You are poorer than you look. Leave.",
    "Nothing to take. Lucky day.",
    "We are done here. Run along.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Waiting", "EN", {
    "Waiting for demand...",
    "They are looking through your pack...",
    "The bandits are deciding what to take...",
    "Keep still...",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Hostile", "EN", {
    "That's it. Get them.",
    "Enough. Take them down.",
    "Should have listened.",
    "No more warnings.",
    "Make it hurt.",
})

DynamicTrading.FlavorText.RegisterTable("Bandits", "Forecast", "EN", {
    WindowTitle = "Raid Forecast",
    WindowHeading = "Next Raid Window",
    DisabledNoCurrency = "CurrencyExpanded is not active. Bandit raids are disabled.",
    SystemEnabled = "System: enabled",
    SystemDisabled = "System: disabled by sandbox",
    ChancePerCheck = "Chance per eligible check: %1%",
    CooldownHours = "Cooldown: %1 hours",
    DemandWindow = "Demand window: %1 real-time minutes",
    NextEligibleHours = "Next eligible: in %1 hours",
    MaxPartySize = "Max party size: %1 | Resting roster share: %2%",
    HostileHeading = "Angry factions ready to raid:",
    HostileNone = "- None with resting members right now.",
    HostileEntry = "- %1: %2 raiders from %3 resting members",
})
