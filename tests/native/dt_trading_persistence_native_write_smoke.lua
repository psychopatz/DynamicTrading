local TRADER_ID = "dt_native_persistence"

PZHarnessNativeTest = function()
    local service = DTCommon.TraderService
    local traderID, record = service.Create({
        traderID = TRADER_ID,
        displayName = "Native Persistence Trader",
        budget = 321,
        abstractAccessEnabled = true,
    })
    PZHarness.assertEqual(traderID, TRADER_ID,
        "native trader creation returned the wrong ID")
    PZHarness.assertTrue(type(record) == "table" and type(record.i) == "table",
        "native trader stock was not serialized")
    local store = DTCommon.Storage.LoadInventory(record)
    local iterator = store and store:iterate()
    local itemRecord = iterator and iterator()
    local count = 0
    while itemRecord do
        count = count + 1
        itemRecord = iterator()
    end
    PZHarness.assertTrue(count > 0 and count <= 8,
        "native created trader did not persist bounded stock")
end
