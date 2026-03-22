require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Sim = DT_Labour.Sim
local Presentation = DT_Labour.Presentation
local Network = DT_Labour.Network
local Internal = Network.Internal or {}

Network.Internal = Internal
Network.Handlers = Network.Handlers or {}

local function getCurrentDay()
    return math.floor((Config.GetCurrentHour() or 0) / Config.HOURS_PER_DAY)
end

local function resolveRecruitSourceUUID(args)
    if type(args) ~= "table" then
        return nil
    end

    if args.traderUUID and tostring(args.traderUUID) ~= "" then
        return tostring(args.traderUUID)
    end
    if args.sourceNPCID and tostring(args.sourceNPCID) ~= "" then
        return tostring(args.sourceNPCID)
    end
    return nil
end

local function detachRecruitedSourceNPC(args)
    local traderUUID = resolveRecruitSourceUUID(args)
    if not traderUUID then
        return nil
    end

    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(traderUUID) or nil
    local factionID = soul and soul.factionID or (args and args.factionID) or nil
    local removed = false

    if DTNPCManager and DTNPCManager.SetNPCStatus then
        DTNPCManager.SetNPCStatus(traderUUID, "Away", nil, nil)
    end

    if DynamicTrading_Stock and DynamicTrading_Stock.ClearStock then
        DynamicTrading_Stock.ClearStock(traderUUID)
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.RemoveSpecificSoul and DynamicTrading_Roster.RemoveSpecificSoul(traderUUID) then
        removed = true
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.RemoveTrader and DynamicTrading_Roster.RemoveTrader(traderUUID) then
        removed = true
    end

    if removed and factionID and DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction and not faction.playerOwned then
            faction.memberCount = math.max(0, (tonumber(faction.memberCount) or 0) - 1)
        end
    end

    if removed then
        ModData.transmit("DynamicTrading_Roster")
        ModData.transmit("DynamicTrading_Stock")
        if factionID then
            ModData.transmit("DynamicTrading_Factions")
        end
    end

    return traderUUID
end

local function createWorkerFromRecruitArgs(owner, args)
    local archetypeID = Config.NormalizeArchetypeID(args.archetypeID or args.profession)
    local worker = Registry.CreateWorker(owner, {
        jobType = args.jobType or Config.GetDefaultJobForArchetype(archetypeID),
        profession = args.jobType or Config.GetDefaultJobForArchetype(archetypeID),
        archetypeID = archetypeID,
        name = args.name,
        isFemale = args.isFemale,
        identitySeed = args.identitySeed,
        homeX = args.homeX or args.spawnX or args.x,
        homeY = args.homeY or args.spawnY or args.y,
        homeZ = args.homeZ or args.spawnZ or args.z or 0,
        presenceState = Config.PresenceStates.Home,
        state = Config.States.Idle,
        jobEnabled = false,
        sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil,
        sourceNPCType = args.sourceNPCType or "ConversationUI"
    })

    if args.x and args.y then
        Sites.AssignSiteForWorker(worker, args.x, args.y, args.z or 0, args.radius)
    end

    return worker
end

Internal.createWorkerFromRecruitArgs = createWorkerFromRecruitArgs

Network.Handlers.AttemptRecruitWorker = function(player, args)
    if not player then return end
    args = args or {}

    local owner = Config.GetOwnerUsername(player)
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    if not sourceNPCID then
        Internal.syncRecruitAttemptResult(player, {
            success = false,
            reasonCode = "missing_target",
            message = "I can't sort out who you're trying to recruit right now."
        })
        return
    end

    local existingWorker = Registry.FindWorkerBySourceID(owner, sourceNPCID)
    if existingWorker then
        Internal.syncRecruitAttemptResult(player, {
            success = false,
            alreadyRecruited = true,
            sourceNPCID = sourceNPCID,
            workerID = existingWorker.workerID,
            reasonCode = "already_recruited",
            message = "I'm already part of your labour roster."
        })
        Internal.syncWorkerDetail(player, existingWorker.workerID)
        Internal.syncWorkerList(player)
        return
    end

    local reputation = Internal.getEffectiveRecruitReputation(player, args.traderUUID or sourceNPCID, args.factionID)
    if reputation < Config.RECRUIT_REQUIRED_REPUTATION then
        Internal.syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "low_reputation",
            reputation = reputation,
            requiredReputation = Config.RECRUIT_REQUIRED_REPUTATION,
            message = "We aren't close enough for that yet. Earn more trust first."
        })
        return
    end

    local currentDay = getCurrentDay()
    local attemptState = Registry.GetRecruitAttempt(owner, sourceNPCID)
    if attemptState and tonumber(attemptState.lastAttemptDay) == currentDay then
        Internal.syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "cooldown",
            reputation = reputation,
            currentDay = currentDay,
            nextAttemptDay = currentDay + 1,
            message = "I've already given you my answer for today. Ask me again tomorrow."
        })
        return
    end

    local chance = math.max(0, math.min(100, tonumber(Config.RECRUIT_DAILY_CHANCE) or 0))
    local roll = ZombRand(100)
    local succeeded = roll < chance

    Registry.SetRecruitAttempt(owner, sourceNPCID, {
        lastAttemptDay = currentDay,
        lastRoll = roll,
        lastChance = chance,
        lastSuccess = succeeded
    })

    if not succeeded then
        Registry.Save()
        Internal.syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "rolled_failed",
            reputation = reputation,
            chance = chance,
            roll = roll,
            currentDay = currentDay,
            nextAttemptDay = currentDay + 1,
            message = "Not today. Give me until tomorrow and ask again."
        })
        return
    end

    detachRecruitedSourceNPC(args)

    local worker = createWorkerFromRecruitArgs(owner, args)
    if DynamicTrading_Factions and DynamicTrading_Factions.OnLabourWorkerCreated then
        DynamicTrading_Factions.OnLabourWorkerCreated(owner, worker)
    end
    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncRecruitAttemptResult(player, {
        success = true,
        sourceNPCID = sourceNPCID,
        workerID = worker.workerID,
        reasonCode = "recruited",
        reputation = reputation,
        chance = chance,
        roll = roll,
        currentDay = currentDay,
        message = "Alright. I'll join your labour roster."
    })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
    Internal.syncOwnedFactionStatus(player)
end

return Network
