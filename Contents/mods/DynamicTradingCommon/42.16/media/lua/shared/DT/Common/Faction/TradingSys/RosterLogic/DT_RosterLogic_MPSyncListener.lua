local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if type(data) ~= "table" then return end
    if key == MOD_DATA_KEY then
        ModData.add(key, data)
    elseif string.find(key, "DTSOUL_") then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

Events.OnInitGlobalModData.Add(DynamicTrading_Roster.Init)
