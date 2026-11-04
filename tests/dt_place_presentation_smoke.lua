local T = require "tests/support/test"
T.addPackagePaths()

DTCommon = {
    T = function(key, fallback)
        if key == "Place_named_translation" then
            return "Translated Market"
        end
        return fallback
    end,
}

local Places = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_PlacePresentation.lua"
)

T.truthy(Places.RegisterResolver(
    "low",
    function(id)
        if id == "community_alpha" then
            return "Low Priority Name"
        end
    end,
    10
), "low-priority resolver registration")
T.truthy(Places.RegisterResolver(
    "high",
    function(id)
        if id == "community_alpha" then
            return "High Priority Name"
        end
    end,
    90
), "high-priority resolver registration")

local name, reason = Places.Resolve("community_alpha")
T.equal(name, "High Priority Name",
    "highest-priority human resolver wins")
T.equal(reason, nil,
    "resolved place has no rejection reason")

T.truthy(Places.UnregisterResolver("high"),
    "resolver removal succeeds")
name = Places.Resolve("community_alpha")
T.equal(name, "Low Priority Name",
    "resolver removal exposes next candidate")

name = Places.Resolve("community_market", {
    worldKnowledge = {
        candidates = {
            {
                payload = {
                    communityID = "community_market",
                    marketName = "Riverside Exchange",
                },
            },
        },
    },
})
T.equal(name, "Riverside Exchange",
    "world knowledge can present canonical community ID")

name = Places.Resolve("named_translation")
T.equal(name, "Translated Market",
    "translation fallback remains available")

name, reason = Places.Resolve("actor:machine-only")
T.equal(name, nil,
    "machine actor ID must never leak to player-facing text")
T.equal(reason, "unpresentable_machine_id",
    "machine ID rejection reason")

name = Places.Resolve("West Point Outpost")
T.equal(name, "West Point Outpost",
    "human-authored place names pass through unchanged")

T.finish("dt_place_presentation_smoke")
