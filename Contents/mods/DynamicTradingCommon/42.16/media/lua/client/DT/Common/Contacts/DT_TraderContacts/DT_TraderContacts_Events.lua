local Internal = DT_TraderContacts.Internal

local function onCreatePlayer()
    DT_TraderContacts.EnsureLoaded()
end

local function onGameStart()
    DT_TraderContacts.EnsureLoaded()
end

if not Internal.EventsRegistered then
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.OnGameStart.Add(onGameStart)
    Internal.EventsRegistered = true
end