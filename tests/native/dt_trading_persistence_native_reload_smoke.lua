local TRADER_ID = "dt_native_persistence"

PZHarnessNativeTest = function()
    local service = DTCommon.TraderService
    local record = service.GetRecord(TRADER_ID)
    PZHarness.assertTrue(type(record) == "table",
        "native trader record did not survive server restart")
    PZHarness.assertEqual(record.b, 321,
        "native trader budget did not survive server restart")
    local store = DTCommon.Storage.LoadInventory(record)
    local iterator = store and store:iterate()
    local itemRecord = iterator and iterator()
    local count = 0
    while itemRecord do
        count = count + 1
        itemRecord = iterator()
    end
    PZHarness.assertTrue(count > 0 and count <= 8,
        "native trader stock did not survive server restart")
    local snapshot = service.Snapshot(TRADER_ID)
    PZHarness.assertTrue(snapshot and #(snapshot.items or {}) > 0,
        "reloaded trader did not expose its MarketSense-valued stock")
end
