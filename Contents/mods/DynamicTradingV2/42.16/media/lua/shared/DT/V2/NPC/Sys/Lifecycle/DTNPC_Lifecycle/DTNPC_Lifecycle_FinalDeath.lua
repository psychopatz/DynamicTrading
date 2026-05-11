-- ==============================================================================
-- DTNPC_Lifecycle_FinalDeath.lua
-- Final death resolution and server-side dead/unregister flow.
-- ==============================================================================

require "Misc/DT_CorpseLootRuntime"

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

local internal = DTNPCLifecycle.Internal
local DEATH_MONEY_BUNDLE_VALUE = 100

local function isLifecycleDebugEnabled()
    if DynamicTrading and DynamicTrading.Debug == true then
        return true
    end
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and (sandbox.NPCDebug == true or sandbox.NPCProtectDebug == true) then
        return true
    end
    return DTNPCProtect
        and DTNPCProtect.CONFIG
        and (DTNPCProtect.CONFIG.DebugLogging == true or DTNPCProtect.CONFIG.CombatIssueLogging == true)
end

local function lifecycleDebugLog(npcData, event, message)
    if not isLifecycleDebugEnabled() or not DynamicTrading or not DynamicTrading.Log then
        return
    end
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "LifecycleDebug",
        tostring(event or "state")
            .. " npc=" .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
            .. " uuid=" .. tostring(npcData and npcData.uuid or nil)
            .. " " .. tostring(message or "")
    )
end

local function randomInt(minValue, maxValue)
    local minInt = math.floor(tonumber(minValue) or 0)
    local maxInt = math.floor(tonumber(maxValue) or minInt)
    if maxInt <= minInt then
        return minInt
    end
    if ZombRand then
        return minInt + ZombRand((maxInt - minInt) + 1)
    end
    return math.random(minInt, maxInt)
end

local function getFactionBudgetEstimate(npcData)
    local factionID = npcData and npcData.factionID or nil
    local faction = factionID and DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
    local config = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.TraderBudget or {
        BaseBudget = 500,
        MinBudget = 100,
        MaxBudget = 15000,
    }

    local eventMult = 1.0
    if DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.getTraderBudgetMultiplier and faction then
        eventMult = tonumber(DynamicTrading.Events.getTraderBudgetMultiplier(faction)) or 1.0
    end

    if faction and tostring(faction.factionType or "") == "independent" then
        return math.max(0, math.floor(((tonumber(config.BaseBudget) or 500) + randomInt(0, 1000)) * eventMult))
    end

    local colonyWealth = 0
    if faction then
        colonyWealth = tonumber(faction.ColonyWealth or faction.wealth) or 0
    else
        colonyWealth = tonumber(npcData and (npcData.ColonyWealth or npcData.colonyWealth or npcData.factionWealth)) or 0
    end
    if colonyWealth <= 0 then
        return 0
    end

    local budgetPercent = (SandboxVars and SandboxVars.DynamicTrading and tonumber(SandboxVars.DynamicTrading.TraderBudgetPercent) or 10.0) / 100
    local allocatedBudget = math.floor((colonyWealth * budgetPercent) * eventMult)
    allocatedBudget = math.max(tonumber(config.MinBudget) or 100, math.min(tonumber(config.MaxBudget) or 15000, allocatedBudget))
    if allocatedBudget > colonyWealth then
        allocatedBudget = colonyWealth
    end
    return math.max(0, math.floor(allocatedBudget))
end

local function getDeathMoneyPlan(npcData)
    if not npcData or not npcData.uuid then
        return 0, "no_uuid", nil, false
    end

    local stockData = nil
    if DynamicTrading_Stock and DynamicTrading_Stock.GetStock then
        local ok, result = pcall(DynamicTrading_Stock.GetStock, npcData.uuid)
        if ok then
            stockData = result
        end
    end

    local session = nil
    if DT_TraderSession and DT_TraderSession.GetSession then
        local ok, result = pcall(DT_TraderSession.GetSession, npcData.uuid)
        if ok then
            session = result
        end
    end
    local sessionBudget = math.max(0, math.floor(tonumber(session and session.budget) or 0))

    if stockData and stockData.tradeInteracted == true and session then
        return sessionBudget, "active_trader_budget", session, false
    end

    local budget = sessionBudget > 0 and sessionBudget or getFactionBudgetEstimate(npcData)
    if budget <= 0 then
        return 0, "no_budget", session, false
    end

    local minAmount = math.max(1, math.floor(budget * 0.25))
    local maxAmount = math.max(minAmount, math.floor(budget * 0.75))
    return randomInt(minAmount, maxAmount), "random_colony_budget", session, session == nil
end

local function addMoneyToContainer(container, amount)
    local safeAmount = math.max(0, math.floor(tonumber(amount) or 0))
    if not container or safeAmount <= 0 then
        return false
    end

    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    local bundles = math.floor(safeAmount / DEATH_MONEY_BUNDLE_VALUE)
    local loose = safeAmount % DEATH_MONEY_BUNDLE_VALUE

    local function addItem(fullType, count)
        if count <= 0 then
            return true
        end
        if helpers and helpers.AddItem then
            helpers.AddItem(container, fullType, count)
            return true
        end
        if container.AddItems then
            container:AddItems(fullType, count)
            return true
        end
        return false
    end

    if bundles > 0 then
        if not addItem("Base.MoneyBundle", bundles) then
            return false
        end
    end
    if loose > 0 then
        if not addItem("Base.Money", loose) then
            return false
        end
    end

    return true, bundles, loose
end

local function getCorpseOutfit(npcData)
    local outfit = type(npcData and npcData.outfit) == "table" and npcData.outfit or nil
    if outfit or not (DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed) then
        return outfit
    end

    return DT_NPC_Wardrobe.GetOutfitBySeed(
        npcData.archetypeID or "General",
        npcData.isFemale,
        npcData.identitySeed or 1
    )
end

local function collectCorpseEquipmentLoot(npcData)
    local collected = {}
    local ordered = {}

    local function addSpec(fullType, condition)
        if not fullType or tostring(fullType) == "" then
            return
        end

        local itemType = tostring(fullType)
        local existing = collected[itemType]
        if existing then
            if existing.condition == nil and condition ~= nil then
                existing.condition = math.floor(tonumber(condition) or 0)
            end
            return
        end

        local spec = {
            fullType = itemType,
            condition = condition ~= nil and math.floor(tonumber(condition) or 0) or nil,
        }
        collected[itemType] = spec
        ordered[#ordered + 1] = spec
    end

    local outfit = getCorpseOutfit(npcData)
    for _, itemType in ipairs(outfit or {}) do
        addSpec(itemType, nil)
    end

    local loadout = type(npcData and npcData.loadout) == "table" and npcData.loadout or {}
    local bagType = loadout.bag
        or (DTNPCEquipmentVisuals and DTNPCEquipmentVisuals.GetDisplayBag and DTNPCEquipmentVisuals.GetDisplayBag(npcData))
        or npcData.displayBag
    addSpec(bagType, nil)
    addSpec(loadout.rangedWeapon, loadout.rangedCondition)
    addSpec(loadout.meleeWeapon, loadout.meleeCondition)

    return ordered
end

local function addCorpseEquipmentLoot(container, lootSpecs)
    if not container then
        return 0
    end

    local added = 0
    for index = 1, #(lootSpecs or {}) do
        local spec = lootSpecs[index]
        if spec and spec.fullType and not (DTCorpseLootRuntime and DTCorpseLootRuntime.ContainerHasItemType and DTCorpseLootRuntime.ContainerHasItemType(container, spec.fullType)) then
            local item = DTCorpseLootRuntime and DTCorpseLootRuntime.AddItemToContainer and DTCorpseLootRuntime.AddItemToContainer(container, spec.fullType, function(createdItem)
                if spec.condition ~= nil and createdItem and createdItem.getConditionMax and createdItem.setCondition then
                    local maxCondition = tonumber(createdItem:getConditionMax()) or 0
                    if maxCondition > 0 then
                        createdItem:setCondition(math.max(0, math.min(maxCondition, math.floor(tonumber(spec.condition) or maxCondition))))
                    end
                end
            end) or nil

            if item then
                added = added + 1
            end
        end
    end

    return added
end

local function deductDeathMoneyFromEconomy(npcData, amount, session, deductFactionDirectly)
    local safeAmount = math.max(0, math.floor(tonumber(amount) or 0))
    if safeAmount <= 0 then
        return
    end

    if session and session.closed ~= true then
        session.budget = math.max(0, math.floor(tonumber(session.budget) or 0) - safeAmount)
        if ModData and ModData.transmit then
            ModData.transmit("DynamicTrading_TraderSessions")
        end
        return
    end

    if deductFactionDirectly and npcData and npcData.factionID and DynamicTrading_Factions and DynamicTrading_Factions.AllocateTraderBudget then
        local faction = DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(npcData.factionID) or nil
        if faction and tostring(faction.factionType or "") == "independent" then
            return
        end
        DynamicTrading_Factions.AllocateTraderBudget(npcData.factionID, safeAmount)
    end
end

function DTNPCLifecycle.DropDeathMoney(zombie, npcData, removalContext)
    if isClient and isClient() and not (isServer and isServer()) then
        return false
    end
    if not zombie or not npcData then
        return false
    end
    if npcData.deathMoneyDropped == true and npcData.deathCorpseEquipmentDropped == true then
        return false
    end

    local amount, reason, session, deductFactionDirectly = getDeathMoneyPlan(npcData)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    local corpseEquipmentLoot = collectCorpseEquipmentLoot(npcData)
    if amount <= 0 and #corpseEquipmentLoot <= 0 then
        lifecycleDebugLog(npcData, "death_money_skip", "reason=" .. tostring(reason))
        return false
    end

    local x = math.floor(zombie:getX())
    local y = math.floor(zombie:getY())
    local z = math.floor(zombie:getZ())
    local uuid = tostring(npcData.uuid or "")

    if DTCorpseLootRuntime and DTCorpseLootRuntime.QueueCorpseMutation then
        local key = "dt_npc_death_money:" .. uuid .. ":" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)
        local queuedKey = DTCorpseLootRuntime.QueueCorpseMutation({
            key = key,
            label = "dt_npc_death_money",
            x = x,
            y = y,
            z = z,
            radius = 1,
            ttlTicks = 300,
            matcher = function(corpse, corpseModData, corpseX, corpseY, corpseZ)
                corpseModData = corpseModData or {}
                if corpseModData.IsDTNPC == true and tostring(corpseModData.DTNPC_UUID or "") == uuid then
                    return true
                end
                return corpseX == x and corpseY == y and corpseZ == z
            end,
            apply = function(corpse, container)
                local applied = false
                local bundles = 0
                local loose = 0

                if amount > 0 and npcData.deathMoneyDropped ~= true then
                    local moneyAdded = nil
                    moneyAdded, bundles, loose = addMoneyToContainer(container, amount)
                    if moneyAdded then
                        npcData.deathMoneyDropped = true
                        npcData.deathMoneyDropAmount = amount
                        npcData.deathMoneyDropReason = reason
                        deductDeathMoneyFromEconomy(npcData, amount, session, deductFactionDirectly)

                        if type(removalContext) == "table" then
                            removalContext.deathMoneyDropAmount = amount
                            removalContext.deathMoneyDropReason = reason
                        end

                        lifecycleDebugLog(
                            npcData,
                            "death_money_drop",
                            "amount=" .. tostring(amount)
                                .. " bundles=" .. tostring(bundles or 0)
                                .. " loose=" .. tostring(loose or 0)
                                .. " reason=" .. tostring(reason)
                        )
                        applied = true
                    end
                end

                if #corpseEquipmentLoot > 0 and npcData.deathCorpseEquipmentDropped ~= true then
                    local gearAdded = addCorpseEquipmentLoot(container, corpseEquipmentLoot)
                    npcData.deathCorpseEquipmentDropped = true
                    npcData.deathCorpseEquipmentCount = math.max(0, gearAdded)
                    if gearAdded > 0 then
                        lifecycleDebugLog(
                            npcData,
                            "death_equipment_drop",
                            "count=" .. tostring(gearAdded)
                        )
                        applied = true
                    end
                end

                return applied
            end,
            onExpired = function()
                lifecycleDebugLog(
                    npcData,
                    "death_corpse_loot_expired",
                    "amount=" .. tostring(amount)
                        .. " reason=" .. tostring(reason)
                        .. " corpse not resolved near " .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
                )
            end,
        })

        if queuedKey then
            return true
        end
    end

    local inv = zombie.getInventory and zombie:getInventory() or nil
    if not inv then
        lifecycleDebugLog(npcData, "death_money_skip", "no inventory container")
        return false
    end

    local applied = false
    local bundles = 0
    local loose = 0

    if amount > 0 and npcData.deathMoneyDropped ~= true then
        local added = nil
        added, bundles, loose = addMoneyToContainer(inv, amount)
        if not added then
            lifecycleDebugLog(npcData, "death_money_skip", "failed to add amount=" .. tostring(amount))
        else
            npcData.deathMoneyDropped = true
            npcData.deathMoneyDropAmount = amount
            npcData.deathMoneyDropReason = reason
            deductDeathMoneyFromEconomy(npcData, amount, session, deductFactionDirectly)

            if type(removalContext) == "table" then
                removalContext.deathMoneyDropAmount = amount
                removalContext.deathMoneyDropReason = reason
            end

            lifecycleDebugLog(
                npcData,
                "death_money_drop",
                "amount=" .. tostring(amount)
                    .. " bundles=" .. tostring(bundles or 0)
                    .. " loose=" .. tostring(loose or 0)
                    .. " reason=" .. tostring(reason)
            )
            applied = true
        end
    end

    if #corpseEquipmentLoot > 0 and npcData.deathCorpseEquipmentDropped ~= true then
        local gearAdded = addCorpseEquipmentLoot(inv, corpseEquipmentLoot)
        npcData.deathCorpseEquipmentDropped = true
        npcData.deathCorpseEquipmentCount = math.max(0, gearAdded)
        applied = gearAdded > 0 or applied
    end

    return applied
end

function DTNPCLifecycle.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or internal.isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return false, false
    end

    local currentTime = internal.nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    if DTNPCLifecycle.ShouldIgnoreFriendlyFire(zombie, npcData, combatHealth, attacker, context) then
        return true, false
    end

    local healthInternal = DTNPCHealth and DTNPCHealth.Internal or nil
    if healthInternal and healthInternal.capturePlayerAttacker then
        healthInternal.capturePlayerAttacker(npcData, attacker)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Lifecycle",
        "HandleIncapacitatedDamage name=" .. tostring(npcData.name or npcData.uuid or "Unknown")
            .. " uuid=" .. tostring(npcData.uuid)
            .. " source=" .. tostring(context and context.source or "unknown")
            .. " amount=" .. tostring(amount)
            .. " attackerType=" .. tostring(internal.getAttackerType(attacker))
            .. " attackerID=" .. tostring(internal.getAttackerID(attacker))
            .. " currentTime=" .. tostring(currentTime)
            .. " graceUntil=" .. tostring(graceUntil)
    )

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
        combatHealth.lastAttackerType = internal.getAttackerType(attacker)
        combatHealth.lastAttackerID = internal.getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        if healthInternal and healthInternal.syncAndPersistHealth then
            healthInternal.syncAndPersistHealth(zombie, npcData, false, true)
        end
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.incapGraceUntil = 0
    combatHealth.incapFinalKillRequestedAt = currentTime
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = internal.getAttackerType(attacker)
    combatHealth.lastAttackerID = internal.getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = 0
    npcData.lastHealth = 0
    combatHealth.lastEngineHealth = 0
    zombie:setHealth(0)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
        DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
        return true, true
    end

    return false, false
end

function DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, context)
    local uuid = (npcData and npcData.uuid) or internal.getUUIDFromZombie(zombie)
    local liveData = internal.getLiveNPCData(uuid, npcData)
    if not uuid or not liveData then
        return false
    end
    if liveData.incapState ~= "Active" then
        return false
    end

    local removalContext = internal.copyContext(context)
    local killerContext = internal.buildKillerContext(attacker, liveData)
    if killerContext then
        for key, value in pairs(killerContext) do
            removalContext[key] = value
        end
    end

    if removalContext and removalContext.killerUsername and liveData.factionID and liveData.factionID ~= "Independent" then
        if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(liveData.factionID, DynamicTrading.GameplayEvents.MEMBER_KILLED_BY_PLAYER, {removalContext.killerUsername, liveData.name or "A member"})
        end
    end

    DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "Incapacitated NPC killed for good: " .. (liveData.name or uuid))
    DTNPCLifecycle.DropDeathMoney(zombie, liveData, removalContext)
    local finalKillContext = DTNPCLifecycle.WithFinalKillContext(zombie, removalContext)
    local manualCorpseCreated = false
    if finalKillContext.forcedLiveBodyRemoval == true then
        manualCorpseCreated = DTNPCLifecycle.CreateCorpseFromZombie(zombie, liveData, "incapacitated_final_kill") == true
        finalKillContext.manualCorpseCreated = manualCorpseCreated
    end
    DTNPCManager.RemoveData(uuid, "Dead", nil, nil, finalKillContext)

    if finalKillContext.forcedLiveBodyRemoval == true and zombie and not (zombie.isDead and zombie:isDead()) then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Engine Kill did not convert incapacitated body to corpse; "
                .. (manualCorpseCreated and "manual corpse created, " or "manual corpse failed, ")
                .. "removing live body for " .. tostring(liveData.name or uuid)
        )
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end
    return true
end

function DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext)
    if not zombie or not uuid or not npcData or npcData.incapState == "Active" then
        return false
    end
    if not DTNPCHealth or not DTNPCHealth.EnsureDefaults then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    local customCurrent = tonumber(combatHealth and combatHealth.current) or 0
    if not combatHealth or combatHealth.enabled ~= true or customCurrent <= (tonumber(DTNPCHealth.MIN_DAMAGE) or 0.01) then
        return false
    end

    local corpseX = math.floor(zombie:getX())
    local corpseY = math.floor(zombie:getY())
    local corpseZ = math.floor(zombie:getZ())

    npcData.lastX = corpseX
    npcData.lastY = corpseY
    npcData.lastZ = corpseZ
    npcData.health = math.max(1, tonumber(combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
    npcData.lastHealth = npcData.health
    combatHealth.engineProtected = true
    combatHealth.eventDrivenOnly = false
    combatHealth.lastEngineHealth = npcData.health

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Warn",
        "Recovered premature engine death while custom HP remained for "
            .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " customCurrent=" .. tostring(customCurrent)
            .. " customMax=" .. tostring(combatHealth.max)
            .. " engineHealth=" .. tostring(zombie:getHealth())
    )

    internal.saveSoulIfAvailable(uuid, npcData)
    DTNPCManager.RemoveData(uuid, nil, nil, nil, DTNPCLifecycle.WithStaleBodyCleanupContext(removalContext, corpseX, corpseY, corpseZ))

    local newZombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, uuid) or nil
    if newZombie then
        DTNPCLifecycle.CleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death")
        DTNPCLifecycle.ScheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, "premature_custom_health_death_delayed")
        return true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Error",
        "Failed to recover premature custom health death; falling back to normal death path: " .. tostring(uuid)
    )
    return false
end

function DTNPCLifecycle.HandleZombieDead(zombie)
    local uuid = internal.getUUIDFromZombie(zombie)
    local zombieRuntimeID = DTNPC_ZombieAggro and DTNPC_ZombieAggro._internal and DTNPC_ZombieAggro._internal.getZombieRuntimeID
        and DTNPC_ZombieAggro._internal.getZombieRuntimeID(zombie)
        or nil
    if zombieRuntimeID and DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnZombieInvalidated then
        DTNPC_ZombieAggro.OnZombieInvalidated(zombieRuntimeID)
    end

    local attacker = zombie and zombie:getAttackedBy() or nil
    local removalContext = internal.buildKillerContext(attacker)

    if uuid and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Lifecycle",
            "ZombieDead triggered for "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " engineHealth=" .. tostring(zombie and zombie:getHealth() or nil)
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " incapState=" .. tostring(npcData.incapState)
                .. " state=" .. tostring(npcData.state)
                .. " status=" .. tostring(npcData.status)
        )

        local activePlayers = DTNPCManager.GetActivePlayers and DTNPCManager.GetActivePlayers() or {}
        local isWorkerLinkedCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            and tostring(npcData.linkedWorkerID or "") ~= ""
        local isSuspiciousRestartDeath = isWorkerLinkedCompanion
            and #activePlayers <= 0
            and removalContext == nil
            and tostring(npcData.status or "") ~= "Dead"

        if isSuspiciousRestartDeath then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Lifecycle",
                "Ignoring suspicious restart death for worker-linked travel companion and clearing stale body only: "
                    .. tostring(npcData.name or uuid)
                    .. " uuid=" .. tostring(uuid)
            )
            DTNPCManager.RemoveData(
                uuid,
                nil,
                nil,
                nil,
                DTNPCLifecycle.WithStaleBodyCleanupContext({
                    reason = "restart_companion_stale_body",
                }, zombie:getX(), zombie:getY(), zombie:getZ())
            )
            return
        end

        if npcData.incapState == "Active" and DTNPCLifecycle.PreserveSuspiciousIncapacitatedDeath(zombie, uuid, npcData) then
            return
        end

        if not removalContext and npcData.lastPlayerAttackerUsername then
            local elapsed = npcData.lastPlayerAttackedAt and (getTimeInMillis() - npcData.lastPlayerAttackedAt) or nil
            if not elapsed or elapsed <= 15000 then
                removalContext = {
                    killerUsername = npcData.lastPlayerAttackerUsername,
                    killerOnlineID = npcData.lastPlayerAttackerOnlineID,
                }
            end
        end
        if npcData.incapState == "Active" then
            DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker, removalContext)
            return
        end

        if DTNPCLifecycle.RecoverPrematureCustomHealthDeath(zombie, uuid, npcData, removalContext) then
            return
        end

        if DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext) then
            return
        end

        if removalContext and removalContext.killerUsername and npcData.factionID and npcData.factionID ~= "Independent" then
            if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                DynamicTrading.GameplayLogs.AddFactionEvent(npcData.factionID, DynamicTrading.GameplayEvents.MEMBER_KILLED_BY_PLAYER, {removalContext.killerUsername, npcData.name or "A member"})
            end
        end

        DynamicTrading.Log("DTV2", "NPC", "Lifecycle", "NPC Died: " .. (npcData.name or uuid))
        DTNPCLifecycle.DropDeathMoney(zombie, npcData, removalContext)
        DTNPCManager.RemoveData(uuid, "Dead", nil, nil, removalContext)
    else
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unregister ignored zombie with no authoritative UUID; refusing outfit-ID fallback.")
    end
end
