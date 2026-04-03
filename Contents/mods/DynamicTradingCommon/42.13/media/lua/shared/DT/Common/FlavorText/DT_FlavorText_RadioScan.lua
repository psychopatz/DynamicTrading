require "DT/Common/FlavorText/DT_FlavorText"

-- Mirror the RadioScan translate data in shared Lua so the tables are always
-- registered, even when nested Translate files are not evaluated by the loader.
DynamicTrading.FlavorText.RegisterTable("RadioScan", "Responses", "EN", {
    Unknown = "Unknown",
    UnknownTrader = "Unknown Trader",
    Connected = "Connected: %1",
    SignalAcquired = "Signal Acquired: %1",
    NetworkExhausted = "Network Exhausted. Try again tomorrow.",
    AirwavesDead = "The airwaves are dead... no more traders today.",
    PublicSignalAcquired = "Signal Acquired by %1: %2",
    RadarSyncing = "Syncing radar frequencies... try again.",
    RadarNoFrequencies = "Static... no frequencies found.",
    RadarLockAcquired = "Found something! Frequency locked.",
    RadarNothingButStatic = "Nothing but static...",
})

DynamicTrading.FlavorText.RegisterTable("RadioScan", "FailLines", "EN", {
    "Anyone trading out there? Come in.",
    "This is a survivor looking to trade. Copy?",
    "Calling any merchants on this frequency.",
    "Hello? Anyone running a market today?",
    "Any traders alive out there?",
    "Trying to reach a trading post. Respond.",
    "If anyone's selling, I'm listening.",
    "Merchant frequency check. Over.",
    "Looking for supplies. Any traders?",
    "Broadcasting for trade. Anyone home?",
    "This is an open call for merchants.",
    "Any caravans or traders nearby?",
    "Trying all channels... looking for trade.",
    "Anyone buying or selling out there?",
    "This is a survivor seeking commerce.",
    "Requesting trade contact. Over.",
    "Any safe zones or traders responding?",
    "Looking to barter. Respond if you can.",
    "Calling any active traders.",
    "If you can hear this, answer back.",
})

DynamicTrading.FlavorText.RegisterTable("RadioScan", "FailStates", "EN", {
    "Harsh static crackles through the speaker.",
    "The signal fades into white noise.",
    "A burst of interference drowns everything out.",
    "The radio hisses, then goes silent.",
    "Only distorted static replies.",
    "The channel collapses into noise.",
    "A low hum replaces the signal.",
    "The transmission cuts off abruptly.",
    "Heavy interference blocks the channel.",
    "The radio pops and crackles erratically.",
    "Nothing but dead air.",
    "The signal drops mid-transmission.",
    "A wall of static answers back.",
    "The frequency is completely jammed.",
    "The radio squeals, then quiets.",
    "Broken noise pulses through the speaker.",
    "The channel is overwhelmed by interference.",
    "A weak hiss lingers, then fades.",
    "The signal fails to connect.",
    "Silence. No reply.",
})
