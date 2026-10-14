-- Native seed smoke: the one-time trader creation seed must be sourced from
-- the real MarketSense catalog and remain compact on the real server.

PZHarnessNativeTest = function()
    local store = DTCommon.TraderStock.New()
    local inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
    local iterator = store and store:iterate()
    local record = iterator and iterator()
    local count = 0
    while record do
        count = count + 1
        local fullType = inventory.getItemFullType(record[1])
        PZHarness.assertTrue(
            type(fullType) == "string" and fullType ~= ""
                and tonumber(record[2]) >= 1,
            "native seed record is not a valid compact item record"
        )
        record = iterator()
    end
    PZHarness.assertTrue(count > 0 and count <= 8,
        "native MarketSense seed was empty or exceeded its bound")
end
