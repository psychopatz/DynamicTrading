local suggestions = dofile(
    "Contents/mods/DTCommon/common/media/lua/shared/DTCommon/ConvoEngine/UI/Dialogue/Trading.lua"
)
local packs = dofile(
    "Contents/mods/DTCommon/common/media/lua/shared/DTCommon/ConvoEngine/Packs/Dialogue/Trading.lua"
)

assert(type(packs) == "table" and #packs == 1, "ConvoEngine recognition projection changed pack count")
assert(packs[1].id == "pack.DT.trader_story", "ConvoEngine recognition lost trader pack identity")
assert(#packs[1].concepts == 11, "ConvoEngine recognition changed concept parity")
assert(#packs[1].speechActs == 7, "ConvoEngine recognition changed speech-act parity")
assert(#packs[1].patterns == 19, "ConvoEngine recognition changed pattern parity")
assert(packs[1].actionProviders[1].effectID == "DT.trade", "ConvoEngine recognition lost trade action provider")

local expected = {
    "question.trader",
    "question.destination",
    "question.origin",
    "question.settlement",
    "question.rumors",
    "question.whereabouts",
    "question.story",
    "action.trade",
}

assert(type(suggestions) == "table", "Core ConvoEngine UI projection did not return a table")
assert(#suggestions == #expected, "Core ConvoEngine UI projection changed suggestion count")
for index, expectedID in ipairs(expected) do
    local row = suggestions[index]
    assert(row.id == expectedID, "Core ConvoEngine UI projection reordered " .. expectedID)
    assert(row.patternID and row.patternID ~= "", "ConvoEngine offer lost its semantic pattern reference")
    assert(row.intent and row.speechAct, "ConvoEngine offer lost its semantic frame")
    assert(row.labelKey and row.utteranceKey, "Core did not generate UI translation keys")
    assert(row.display and row.display.EN, "ConvoEngine offer lost EN display text")
end

print("dt_convo_ui_projection_smoke: PASS")
