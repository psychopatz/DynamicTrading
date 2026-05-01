-- ==============================================================================
-- DTNPC_Bandits_Server_Debug.lua
-- Forecast and debug command routing for bandit raid systems.
-- ==============================================================================

if isClient() and not isServer() then return end

local Bandits = DTNPCBandits
Bandits.Internal = Bandits.Internal or {}
local Internal = Bandits.Internal
Internal.Constants = Internal.Constants or {}
Internal.Shared = Internal.Shared or {}
Internal.Faction = Internal.Faction or {}
Internal.Raid = Internal.Raid or {}

Internal.Debug = Internal.Debug or {}

local Debug = Internal.Debug

local function getShared()
    local currentInternal = DTNPCBandits and DTNPCBandits.Internal or nil
    return currentInternal and currentInternal.Shared or {}
end

local function getFaction()
    local currentInternal = DTNPCBandits and DTNPCBandits.Internal or nil
    return currentInternal and currentInternal.Faction or {}
end

local function getFactionDisplayName(factionID)
    local shared = getShared()
    if shared and type(shared.getFactionDisplayName) == "function" then
        return shared.getFactionDisplayName(factionID)
    end

    local faction = getFaction()
    if faction and type(faction.getFactionDisplayName) == "function" then
        return faction.getFactionDisplayName(factionID)
    end

    return tostring(factionID or "Unknown")
end

local function getRaid()
    local currentInternal = DTNPCBandits and DTNPCBandits.Internal or nil
    return currentInternal and currentInternal.Raid or {}
end

local function getConstants()
    local currentInternal = DTNPCBandits and DTNPCBandits.Internal or nil
    return currentInternal and currentInternal.Constants or {}
end

local function canUseDebugCommand(player)
    if isDebugEnabled and isDebugEnabled() then return true end
    if not player or not player.getAccessLevel then return false end
    local access = tostring(player:getAccessLevel() or "")
    return access ~= "" and access ~= "None"
end

local function computeRaidPartySize(factionID, maxCap, partyPercent)
    local Shared = getShared()
    local Raid = getRaid()
    local resting = Raid.getRestingFactionMembers(factionID)
    if #resting <= 0 then return 0, 0 end
    local count = math.ceil(#resting * (Shared.clampPercent(partyPercent, 50) / 100))
    count = math.max(1, math.min(#resting, Shared.clampDifficulty(maxCap), count))
    return count, #resting
end

local function collectHostileRaidSummaries(player, maxCap, partyPercent)
    local Shared = getShared()
    local Faction = getFaction()
    local summaries = {}
    for _, factionID in ipairs(Faction.getHostileFactionIDsForPlayer(player)) do
        local faction = Faction.getFactionData(factionID)
        local raidSize, resting = computeRaidPartySize(factionID, maxCap, partyPercent)
        if raidSize > 0 then
            summaries[#summaries + 1] = {
                factionID = factionID,
                name = getFactionDisplayName(factionID),
                raidSize = raidSize,
                resting = resting,
                isBandit = Shared.isBanditFactionID(factionID),
                systemFaction = Faction.isFactionExcludedFromPopulationPool(factionID, faction),
            }
        end
    end
    table.sort(summaries, function(left, right)
        return tostring(left.name) < tostring(right.name)
    end)
    return summaries
end

local function pickFactionToAnger(player)
    local Faction = getFaction()
    local Raid = getRaid()
    local factions = ModData.get("DynamicTrading_Factions")
    if type(factions) ~= "table" then return nil end

    local readyCandidates = {}
    local fallbackCandidates = {}
    for factionID, faction in pairs(factions) do
        if type(faction) == "table"
            and not Faction.isFactionExcludedFromPopulationPool(factionID, faction)
            and not Faction.isFactionHostileToPlayer(factionID, faction, player) then
            if #Raid.getRestingFactionMembers(factionID) > 0 then
                readyCandidates[#readyCandidates + 1] = factionID
            else
                fallbackCandidates[#fallbackCandidates + 1] = factionID
            end
        end
    end

    local candidates = #readyCandidates > 0 and readyCandidates or fallbackCandidates
    if #candidates <= 0 then return nil end
    return candidates[ZombRand(#candidates) + 1]
end

local function makeFactionAngryAtPlayer(player, factionID)
    local Shared = getShared()
    local Faction = getFaction()
    if not player then return nil end
    local factions = ModData.get("DynamicTrading_Factions")
    if type(factions) ~= "table" then return nil end

    factionID = factionID and tostring(factionID) or pickFactionToAnger(player)
    local faction = factionID and factions[factionID] or nil
    if not faction or Faction.isFactionExcludedFromPopulationPool(factionID, faction) then return nil end

    local username = Shared.getUsername(player)
    if not username then return nil end
    if Faction.ensurePlayerDispositionState then
        Faction.ensurePlayerDispositionState(faction)
    end
    faction.playerDisposition = type(faction.playerDisposition) == "table" and faction.playerDisposition or {}
    faction.playerDisposition[username] = -100
    if ModData.transmit then ModData.transmit("DynamicTrading_Factions") end

    if type(Shared.sendBanditCommand) == "function" then
        Shared.sendBanditCommand(player, "BanditRepSync", {
            factionID = factionID,
            mode = "set",
            value = -100,
            memberUUIDs = Faction.getAliveFactionMemberUUIDs and Faction.getAliveFactionMemberUUIDs(factionID) or {},
            source = "debug_make_angry",
        })
    end

    return factionID, faction
end

local function sendRaidForecast(player)
    local Shared = getShared()
    local Constants = getConstants()
    if type(Shared.getSandbox) ~= "function"
        or type(Shared.worldHours) ~= "function"
        or type(Shared.clampDifficulty) ~= "function"
        or type(Shared.clampPercent) ~= "function"
        or type(Shared.sendBanditCommand) ~= "function" then
        return
    end
    local sandbox = Shared.getSandbox()
    local currentHour = Shared.worldHours()
    local cooldown = tonumber(sandbox.BanditAmbushCooldownHours) or 72
    local nextEligible = math.max(currentHour, (Bandits.LastRandomAmbushHour or -99999) + cooldown)
    local difficulty = Shared.clampDifficulty(sandbox.BanditAmbushDifficulty)
    local partyPercent = Shared.clampPercent(sandbox.BanditRaidPartyPercent, 50)

    if Shared.isCurrencyExpandedActive() then
        Bandits.EnsureBanditFaction(false)
    end

    Shared.sendBanditCommand(player, "BanditRaidForecast", {
        currencyExpanded = Shared.isCurrencyExpandedActive(),
        enabled = sandbox.EnableBanditAmbushes ~= false,
        currentHour = currentHour,
        nextEligibleHour = nextEligible,
        cooldownRemainingHours = math.max(0, nextEligible - currentHour),
        checkIntervalHours = Constants.RANDOM_CHECK_INTERVAL_HOURS or 0.25,
        chance = tonumber(sandbox.BanditAmbushChance) or 3,
        cooldownHours = cooldown,
        demandWindowMinutes = (tonumber(Constants.DEMAND_TIMEOUT_MS) or 120000) / 60000,
        maxRaidSize = difficulty,
        partyPercent = partyPercent,
        hostileFactions = Shared.isCurrencyExpandedActive() and collectHostileRaidSummaries(player, difficulty, partyPercent) or {},
    })
end

function Debug.onClientCommand(module, command, player, args)
    local Shared = getShared()
    local Faction = getFaction()
    local Raid = getRaid()
    if module ~= "DTNPC" then return end

    if command == "BanditDemandStarted" then
        Bandits.StartDemand(player, args)
    elseif command == "BanditDemandPay" then
        Bandits.PayDemand(player, args)
    elseif command == "BanditDemandRefuse" then
        Bandits.RefuseDemand(player, args)
    elseif command == "SpawnBanditAmbush" then
        if canUseDebugCommand(player) then
            Bandits.EnsureBanditFaction(true)
            Bandits.SpawnAmbushForPlayer(player, {
                difficulty = args and args.difficulty or nil,
                partyPercent = args and args.partyPercent or nil,
                factionID = args and args.factionID or Bandits.FACTION_ID,
                debug = true,
            })
        end
    elseif command == "SpawnHostileFactionRaid" then
        if canUseDebugCommand(player) then
            if type(Shared.getSandbox) ~= "function"
                or type(Shared.clampDifficulty) ~= "function"
                or type(Shared.clampPercent) ~= "function"
                or type(Raid.pickHostileRaidFactionForPlayer) ~= "function" then
                if type(Shared.sendBanditCommand) == "function" then
                    Shared.sendBanditCommand(player, "BanditDebugNotice", {
                        message = "Bandit raid debug tools are not fully initialized yet.",
                    })
                end
                return
            end
            local sandbox = Shared.getSandbox()
            local difficulty = Shared.clampDifficulty(args and args.difficulty or sandbox.BanditAmbushDifficulty)
            local partyPercent = Shared.clampPercent(args and args.partyPercent or sandbox.BanditRaidPartyPercent, 50)
            local factionID = args and args.factionID or Raid.pickHostileRaidFactionForPlayer(player, difficulty, partyPercent, false)
            if factionID then
                local ok = Bandits.SpawnAmbushForPlayer(player, {
                    difficulty = difficulty,
                    partyPercent = partyPercent,
                    factionID = factionID,
                    debug = true,
                })
                if ok then
                    Shared.sendBanditCommand(player, "BanditDebugNotice", {
                        message = "Spawned angry faction raid: " .. tostring(getFactionDisplayName(factionID)),
                    })
                end
            else
                Shared.sendBanditCommand(player, "BanditDebugNotice", {
                    message = "No angry non-bandit faction with resting members is ready to raid you.",
                })
            end
        end
    elseif command == "BanditDebugMakeFactionAngry" then
        if canUseDebugCommand(player) then
            local factionID, faction = makeFactionAngryAtPlayer(player, args and args.factionID or nil)
            Shared.sendBanditCommand(player, "BanditDebugNotice", {
                message = factionID
                    and (tostring(faction.name or factionID) .. " is now at -100 reputation with you.")
                    or "No eligible faction could be made angry.",
            })
        end
    elseif command == "RequestBanditRaidForecast" then
        if canUseDebugCommand(player) then
            sendRaidForecast(player)
        end
    end
end
