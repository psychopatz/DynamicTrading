-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion.lua
-- Travel companion job UI and order handlers.
-- ==============================================================================

pcall(require, "DC/UI/Colony/System/DC_System")
pcall(require, "DC/UI/Colony/SupplyWindow/DC_SupplyWindow")
pcall(require, "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Client")
pcall(require, "DT/V2/NPC/UI/DTNPC_CommandEmotes")

local MEDICAL_TEXTURE_CACHE = {}
local COMPANION_INVENTORY_PREWARM_TIMEOUT_MS = 1200
local COMPANION_INVENTORY_PREWARM = {
    pending = {},
    tickHookAdded = false,
}
local MEDICAL_PROVISION_FULL_TYPES = {
    ["Base.Bandage"] = true,
    ["Base.BandageBox"] = true,
    ["Base.AlcoholBandage"] = true,
    ["Base.RippedSheets"] = true,
    ["Base.AlcoholRippedSheets"] = true,
    ["Base.Bandaid"] = true,
    ["Base.CottonBalls"] = true,
    ["Base.CottonBallsBox"] = true,
    ["Base.AlcoholWipes"] = true,
    ["Base.AlcoholedCottonBalls"] = true,
    ["Base.Disinfectant"] = true,
}

local function debugCompanionUI(message)
    local text = "[DTV2 Companion UI] " .. tostring(message or "")
    print(text)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "CompanionUI", tostring(message or ""))
    end
end

local function buildNavigationBlock(footerAction, overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildNavigationBlock then
        return DT_ConversationUI.BuildNavigationBlock(footerAction, overrides)
    end

    local block = {
        explicitFooter = true,
        footerAction = footerAction,
        defaultFooterAction = footerAction,
    }
    for key, value in pairs(overrides or {}) do
        block[key] = value
    end
    return block
end

local function buildLeaveFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildLeaveFooterAction then
        return DT_ConversationUI.BuildLeaveFooterAction(overrides)
    end

    local action = {
        kind = "leave",
        title = "Leave",
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

local function buildExitFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildExitFooterAction then
        return DT_ConversationUI.BuildExitFooterAction(overrides)
    end

    local action = buildLeaveFooterAction(overrides)
    if not overrides or overrides.title == nil then
        action.title = "Exit"
    end
    return action
end

local function buildBackFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildBackFooterAction then
        return DT_ConversationUI.BuildBackFooterAction(overrides)
    end

    local action = {
        kind = "back",
        title = "Back",
        closeAfter = false,
        exitAfter = false,
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

local function attachNavigationBlock(options, footerAction, overrides)
    options = type(options) == "table" and options or {}
    local navBlock = buildNavigationBlock(footerAction, overrides)
    options._dtFooterAction = footerAction
    options._dtNavigationBlock = navBlock
    return options, navBlock
end

local function nowMs()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    return math.floor((os.time() or 0) * 1000)
end

local function getNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end

local function normalizeText(value)
    value = value and tostring(value) or ""
    return value ~= "" and value or nil
end

local function getAuthorityUsername(player)
    if not player then
        return nil
    end

    local username = normalizeText(player.getUsername and player:getUsername() or nil)
    if DynamicTrading_Factions and DynamicTrading_Factions.GetPlayerFaction and username then
        local faction = DynamicTrading_Factions.GetPlayerFaction(username)
        local leader = normalizeText(faction and faction.leaderUsername or nil)
        if leader then
            return leader
        end
    end

    return username
end

local function getLocalUsername(player)
    return normalizeText(player and player.getUsername and player:getUsername() or nil)
end

local function getCommanderUsername(npcData, worker)
    local companionData = type(worker and worker.companion) == "table" and worker.companion or {}
    return normalizeText(
        npcData and npcData.dcCommanderUsername
            or companionData.commanderUsername
            or worker and worker.companionCommanderUsername
            or nil
    )
end

local function isLocalCommander(player, npcData, worker)
    local username = getLocalUsername(player)
    local commander = getCommanderUsername(npcData, worker)
    return username ~= nil and commander ~= nil and username == commander
end

local function getDistanceToNPC(player, npc)
    if not player or not npc then
        return 999999, 999999
    end
    local dx = (tonumber(player:getX()) or 0) - (tonumber(npc:getX()) or 0)
    local dy = (tonumber(player:getY()) or 0) - (tonumber(npc:getY()) or 0)
    local dz = math.abs((tonumber(player:getZ()) or 0) - (tonumber(npc:getZ()) or 0))
    return math.sqrt((dx * dx) + (dy * dy)), dz
end

local function canClaimCommand(player, npc)
    local distance, dz = getDistanceToNPC(player, npc)
    return distance <= 6 and dz <= 1
end

local function sendClaimCommand(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end
    return DC_System.SendCommand("ClaimCompanionCommand", {
        workerID = worker.workerID
    }) == true
end

local function sendTransferCommand(worker, username)
    if not worker or not worker.workerID or not username or not DC_System or not DC_System.SendCommand then
        return false
    end
    return DC_System.SendCommand("TransferCompanionCommand", {
        workerID = worker.workerID,
        username = username
    }) == true
end

local function collectTransferCandidates(player, worker)
    local currentUsername = getLocalUsername(player)
    local seen = {}
    local candidates = {}

    local function add(username)
        username = normalizeText(username)
        if not username or username == currentUsername or seen[username] then
            return
        end
        seen[username] = true
        candidates[#candidates + 1] = username
    end

    local status = DC_MainWindow and DC_MainWindow.cachedOwnedFactionStatus
        or DC_System and DC_System.ownedFactionStatusCache
        or nil
    local faction = status and status.faction or nil
    add(faction and faction.leaderUsername)
    for _, username in ipairs(status and status.memberUsernames or faction and faction.memberUsernames or {}) do
        add(username)
    end

    local ownerUsername = normalizeText(worker and worker.ownerUsername)
    if ownerUsername and ownerUsername ~= currentUsername then
        add(ownerUsername)
    end

    table.sort(candidates)
    return candidates
end

local function refreshCompanionWorker(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return
    end
    DC_System.SendCommand("RequestCompanionCommandStatus", {
        workerID = worker.workerID
    })
end

local function isValidTexture(texture)
    return texture ~= nil and texture ~= false
end

local function tryTexture(textureName)
    if not textureName or textureName == "" or not getTexture then
        return nil
    end

    local texture = getTexture(textureName)
    return isValidTexture(texture) and texture or nil
end

local function getTextureForFullType(fullType)
    fullType = normalizeText(fullType)
    if not fullType then
        return nil
    end
    if MEDICAL_TEXTURE_CACHE[fullType] ~= nil then
        return MEDICAL_TEXTURE_CACHE[fullType] ~= false and MEDICAL_TEXTURE_CACHE[fullType] or nil
    end

    local texture = nil
    if DC_SupplyWindow and DC_SupplyWindow.Internal and DC_SupplyWindow.Internal.getTextureForFullType then
        texture = DC_SupplyWindow.Internal.getTextureForFullType(fullType)
    end

    local script = getScriptManager and getScriptManager():getItem(fullType) or nil
    if not isValidTexture(texture) and script and script.getIcon then
        local iconName = script:getIcon()
        if iconName and iconName ~= "" then
            texture = tryTexture("Item_" .. tostring(iconName))
                or tryTexture("media/textures/Item_" .. tostring(iconName) .. ".png")
        end
    end

    if not isValidTexture(texture) and InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item and item.getTex then
            texture = item:getTex()
        end
    end

    MEDICAL_TEXTURE_CACHE[fullType] = isValidTexture(texture) and texture or false
    return MEDICAL_TEXTURE_CACHE[fullType] ~= false and MEDICAL_TEXTURE_CACHE[fullType] or nil
end

local function getDisplayNameForFullType(fullType)
    local script = fullType and getScriptManager and getScriptManager():getItem(fullType) or nil
    if script and script.getDisplayName then
        local name = normalizeText(script:getDisplayName())
        if name then
            return name
        end
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem and fullType then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item and item.getDisplayName then
            local name = normalizeText(item:getDisplayName())
            if name then
                return name
            end
        end
    end

    return tostring(fullType or "Medical Supply")
end

local function addMedicalSupplySummary(supplies, byFullType, entry)
    if type(entry) ~= "table" then
        return
    end

    local fullType = normalizeText(entry.fullType)
    if not fullType then
        return
    end

    local useKind = tostring(entry.medicalUse or "")
    local provisionType = tostring(entry.provisionType or "")
    local units = math.max(0, math.floor((tonumber(entry.treatmentUnitsRemaining) or 0) + 0.5))
    local knownMedical = MEDICAL_PROVISION_FULL_TYPES[fullType] == true
    if units <= 0 or (provisionType ~= "medical" and not knownMedical) or (useKind ~= "" and useKind ~= "bandage") then
        return
    end

    local supply = byFullType[fullType]
    if not supply then
        supply = {
            fullType = fullType,
            displayName = normalizeText(entry.displayName) or getDisplayNameForFullType(fullType),
            units = 0,
            texture = getTextureForFullType(fullType),
        }
        byFullType[fullType] = supply
        supplies[#supplies + 1] = supply
    end
    supply.units = supply.units + units
end

local function collectMedicalSupplies(worker)
    local supplies = {}
    local byFullType = {}

    for _, entry in ipairs(worker and worker.companionMedicalSupplies or {}) do
        addMedicalSupplySummary(supplies, byFullType, entry)
    end

    for _, entry in ipairs(worker and worker.nutritionLedger or {}) do
        addMedicalSupplySummary(supplies, byFullType, entry)
    end

    table.sort(supplies, function(a, b)
        return tostring(a.displayName or a.fullType or "") < tostring(b.displayName or b.fullType or "")
    end)

    local total = 0
    for _, supply in ipairs(supplies) do
        total = total + math.max(0, tonumber(supply.units) or 0)
    end

    return supplies, total
end

local function getPatchUpLabel(worker)
    if not worker then
        return "Patch Up", 1
    end

    local _, total = collectMedicalSupplies(worker)
    if total <= 0 then
        return "Patch Up (No medicine)", total
    end
    return "Patch Up (" .. tostring(total) .. " medical)", total
end

local function buildWorkerLookupUI(ui, npc, npcData)
    if ui then
        return ui
    end

    return {
        interactionObj = npc,
        target = {
            id = npcData and npcData.uuid or nil,
            name = npcData and npcData.name or nil,
            factionID = npcData and npcData.factionID or nil,
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    }
end

local function resolveCompanionWorkerByID(workerID)
    if not workerID then
        return nil
    end

    local cache = DC_MainWindow and DC_MainWindow.cachedDetails or nil
    if type(cache) == "table" and type(cache[workerID]) == "table" then
        return cache[workerID]
    end

    local internal = DC_SupplyWindow and DC_SupplyWindow.Internal or nil
    if internal and internal.resolveWorkerDetail then
        local detail = internal.resolveWorkerDetail(workerID)
        if detail then
            return detail
        end
    end

    local registry = DC_Colony and DC_Colony.Registry or nil
    if registry and registry.GetWorker then
        local worker = registry.GetWorker(workerID)
        if worker then
            return worker
        end
    end

    if registry and registry.GetWorkerRaw then
        return registry.GetWorkerRaw(workerID)
    end

    return nil
end

local function isWorkerDetailWarm(worker)
    if type(worker) ~= "table" then
        return false
    end

    return worker.nutritionLedger ~= nil
        or worker.toolLedger ~= nil
        or worker.outputLedger ~= nil
        or worker.haulLedger ~= nil
        or worker.skills ~= nil
        or worker.warehouse ~= nil
end

local function requestCompanionInventorySummary(workerID)
    if not workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    local detailVersions = DC_MainWindow and DC_MainWindow.cachedDetailVersions or nil
    local knownWorkerVersion = detailVersions and detailVersions[workerID] or nil
    local warehouseVersion = DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance.warehouseVersion or nil

    DC_System.SendCommand("RequestWorkerDetails", {
        workerID = workerID,
        knownVersion = knownWorkerVersion,
        includeWorkerLedgers = false
    })
    DC_System.SendCommand("RequestWarehouse", {
        knownVersion = warehouseVersion,
        includeLedgers = false
    })
    return true
end

local function openPendingCompanionInventory(entry)
    local workerToOpen = resolveCompanionWorkerByID(entry.workerID) or entry.worker
    if not workerToOpen or not workerToOpen.workerID or not DC_SupplyWindow or not DC_SupplyWindow.Open then
        return false
    end

    DC_SupplyWindow.Open(workerToOpen, entry.viewMode or "inventory")
    if DC_SupplyWindow.instance and DC_SupplyWindow.instance.updateStatus then
        DC_SupplyWindow.instance:updateStatus("Loading full inventory details...")
    end

    if DynamicTrading and DynamicTrading.DebugPerformance == true then
        debugCompanionUI(
            "companion inventory opened workerID=" .. tostring(entry.workerID)
                .. " latencyMs=" .. tostring(nowMs() - (entry.startedAt or nowMs()))
        )
    end
    return true
end

local function processPendingCompanionInventoryOpens()
    local stillPending = false
    local currentTime = nowMs()
    local hasPending = false

    for _ in pairs(COMPANION_INVENTORY_PREWARM.pending) do
        hasPending = true
        break
    end

    if hasPending
        and DC_SupplyWindow
        and DC_SupplyWindow.Preload
        and not DC_SupplyWindow.instance then
        pcall(DC_SupplyWindow.Preload)
    end

    for workerID, entry in pairs(COMPANION_INVENTORY_PREWARM.pending) do
        local warmedWorker = resolveCompanionWorkerByID(workerID)
        local isReady = isWorkerDetailWarm(warmedWorker)
        local expired = (currentTime - (entry.startedAt or currentTime)) >= COMPANION_INVENTORY_PREWARM_TIMEOUT_MS

        if isReady or expired then
            if openPendingCompanionInventory(entry) then
                COMPANION_INVENTORY_PREWARM.pending[workerID] = nil
            else
                stillPending = true
            end
        else
            stillPending = true
        end
    end

    if not stillPending and COMPANION_INVENTORY_PREWARM.tickHookAdded then
        Events.OnTick.Remove(processPendingCompanionInventoryOpens)
        COMPANION_INVENTORY_PREWARM.tickHookAdded = false
    end
end

local function queueCompanionInventoryOpen(worker)
    if not worker or not worker.workerID then
        return false
    end

    COMPANION_INVENTORY_PREWARM.pending[worker.workerID] = {
        workerID = worker.workerID,
        worker = worker,
        viewMode = "inventory",
        startedAt = nowMs(),
    }

    requestCompanionInventorySummary(worker.workerID)

    if not COMPANION_INVENTORY_PREWARM.tickHookAdded then
        Events.OnTick.Add(processPendingCompanionInventoryOpens)
        COMPANION_INVENTORY_PREWARM.tickHookAdded = true
    end

    return true
end

local function getCompanionWorker(ui, npc, npcData)
    local lookupUI = buildWorkerLookupUI(ui, npc, npcData)
    if DC_System and DC_System.GetConversationCompanionWorker then
        local ok, worker = pcall(DC_System.GetConversationCompanionWorker, lookupUI)
        if ok and worker then
            return worker
        end
    end

    local target = lookupUI and lookupUI.target or nil
    local linkedWorkerID = (npcData and npcData.linkedWorkerID)
        or (target and target.linkedWorkerID)
        or nil
    if linkedWorkerID then
        local worker = resolveCompanionWorkerByID(linkedWorkerID)
        if worker then
            return worker
        end
    end

    return nil
end

local function isLegacyTravelCompanion(player, npcData)
    if not player or not npcData then
        return false
    end

    if tostring(npcData.dcCompanionJob or "") ~= "TravelCompanion" then
        return false
    end

    if npcData.dcCompanionActive ~= true then
        return false
    end

    local authority = normalizeText(getAuthorityUsername(player))
    local owner = normalizeText(npcData.dcCompanionOwner or npcData.ownerUsername or npcData.master or nil)
    return authority ~= nil and owner == authority
end

local function attachNPCData(npc, npcData)
    if npc and npcData and DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
end

local function sendCompanionOrder(player, npc, args)
    local npcData = getNPCData(npc)
    if not player or not npcData or not npcData.uuid then
        return false, npcData
    end

    args = type(args) == "table" and args or {}
    args.uuid = npcData.uuid
    sendClientCommand(player, "DTNPC", "Order", args)
    return true, npcData
end

local function updateCompanionState(player, npc, state, extraArgs)
    local sent, npcData = sendCompanionOrder(player, npc, extraArgs and extraArgs or { state = state })
    if not sent or not npcData then
        return false
    end

    if state ~= "PatchUp" then
        if DTNPCHealth and DTNPCHealth.CancelPendingSelfBandage then
            DTNPCHealth.CancelPendingSelfBandage(npc, npcData, state, {
                manualInterrupt = true,
                retryDelayMs = DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS,
                sync = false,
            })
        end
        npcData.state = state or npcData.state
    end

    if extraArgs and extraArgs.combatOrder then
        npcData.combatOrder = extraArgs.combatOrder
    elseif state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.combatOrder = state
    elseif state ~= "PatchUp" then
        npcData.combatOrder = nil
    end

    if extraArgs and extraArgs.guardCombatOrder then
        npcData.guardCombatOrder = extraArgs.guardCombatOrder
        npcData.guardAttackMode = extraArgs.guardCombatOrder
    elseif extraArgs and extraArgs.guardAttackMode then
        npcData.guardAttackMode = extraArgs.guardAttackMode
        npcData.guardCombatOrder = extraArgs.guardAttackMode
    elseif state == "Stay" and extraArgs and extraArgs.clearGuardMode == true then
        npcData.guardCombatOrder = nil
        npcData.guardAttackMode = nil
    elseif state == "PatchUp" then
        -- Preserve guard settings through temporary self-care orders.
    elseif state ~= "Guard" then
        npcData.guardCombatOrder = npcData.guardCombatOrder
        npcData.guardAttackMode = npcData.guardAttackMode
    end

    if state == "Follow" or state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.master = player and player.getUsername and player:getUsername() or npcData.master
        npcData.masterID = player and player.getOnlineID and player:getOnlineID() or npcData.masterID
    end

    if state == "Guard" and npc then
        npcData.stationaryPostX = npc:getX()
        npcData.stationaryPostY = npc:getY()
        npcData.stationaryPostZ = npc:getZ()
        npcData.stationaryPostState = "Guard"
        npcData.anchorX = npc:getX()
        npcData.anchorY = npc:getY()
        npcData.anchorZ = npc:getZ()
        npcData.guardReturningToPost = nil
    end

    if state == "Stay" then
        npcData.guardReturningToPost = nil
    end

    npcData.tasks = {}
    attachNPCData(npc, npcData)
    return true
end

local function playCompanionCommandCue(player, cueKey)
    if DTNPC_CommandEmotes and DTNPC_CommandEmotes.Play then
        DTNPC_CommandEmotes.Play(player, cueKey)
    end
end

local function resolveCompanionCommandCue(state, extraArgs)
    local explicitCue = normalizeText(extraArgs and extraArgs.commandCue or nil)
    if explicitCue then
        return explicitCue
    end

    local combatOrder = normalizeText(extraArgs and extraArgs.combatOrder or nil)
    if combatOrder then
        return combatOrder
    end

    local guardOrder = normalizeText(extraArgs and (extraArgs.guardCombatOrder or extraArgs.guardAttackMode) or nil)
    if guardOrder then
        return guardOrder
    end

    return normalizeText(state)
end

local function issueCompanionStateOrder(player, npc, state, extraArgs)
    local sent = updateCompanionState(player, npc, state, extraArgs)
    if sent then
        playCompanionCommandCue(player, resolveCompanionCommandCue(state, extraArgs))
    end
    return sent
end

local function getAttackTypeLabel(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder ~= "ProtectAuto" and combatOrder ~= "ProtectRanged" and combatOrder ~= "ProtectMelee" then
        local state = npcData and npcData.state or nil
        if state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
            combatOrder = state
        end
    end
    if combatOrder == "ProtectAuto" then
        return "Auto"
    end
    if combatOrder == "ProtectRanged" then
        return "Ranged"
    end
    if combatOrder == "ProtectMelee" then
        return "Melee"
    end
    return "Balanced"
end

local function getAttackTypeMode(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder == "ProtectAuto" or combatOrder == "ProtectRanged" or combatOrder == "ProtectMelee" then
        return combatOrder
    end

    local state = npcData and npcData.state or nil
    if state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        return state
    end

    return nil
end

local function getGuardAttackTypeLabel(npcData)
    local guardOrder = npcData and (npcData.guardCombatOrder or npcData.guardAttackMode) or nil
    if guardOrder == "GuardAuto" then
        return "Auto"
    end
    if guardOrder == "GuardRanged" then
        return "Ranged"
    end
    if guardOrder == "GuardMelee" then
        return "Melee"
    end
    return "Auto"
end

local function getGuardAttackTypeMode(npcData)
    local guardOrder = npcData and (npcData.guardCombatOrder or npcData.guardAttackMode) or nil
    if guardOrder == "GuardAuto" or guardOrder == "GuardRanged" or guardOrder == "GuardMelee" then
        return guardOrder
    end
    return nil
end

local function getLootCombatOrder(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder == "ProtectAuto" or combatOrder == "ProtectRanged" or combatOrder == "ProtectMelee" then
        return combatOrder
    end
    return "ProtectAuto"
end

local function getRangedAmmoSnapshot(npcData)
    local loadout = npcData and type(npcData.loadout) == "table" and npcData.loadout or nil
    local rangedWeapon = normalizeText(loadout and loadout.rangedWeapon or nil)
    if not rangedWeapon then
        return {
            hasRangedWeapon = false,
            ammoCount = 0,
        }
    end

    return {
        hasRangedWeapon = true,
        ammoCount = math.max(0, math.floor(tonumber(loadout and loadout.ammoCount) or 0)),
    }
end

local function buildModeOptionLabel(baseLabel, isActive, includeAmmo, ammoCount)
    local label = tostring(baseLabel or "")
    if not isActive then
        return label
    end

    label = label .. " [ACTIVE]"
    if includeAmmo then
        label = label .. " (Ammo: " .. tostring(math.max(0, tonumber(ammoCount) or 0)) .. ")"
    end
    return label
end

local function buildModeOptionStyle(isActive, modeKey)
    if not isActive then
        return nil
    end

    if modeKey == "auto" then
        return {
            bgColor = { 0.16, 0.24, 0.36, 1.0 },
            borderColor = { 0.48, 0.70, 0.98, 1.0 },
            textColor = { 0.90, 0.96, 1.0, 1.0 },
        }
    end
    if modeKey == "ranged" then
        return {
            bgColor = { 0.17, 0.31, 0.20, 1.0 },
            borderColor = { 0.48, 0.86, 0.50, 1.0 },
            textColor = { 0.90, 1.0, 0.90, 1.0 },
        }
    end

    return {
        bgColor = { 0.36, 0.20, 0.18, 1.0 },
        borderColor = { 0.95, 0.50, 0.44, 1.0 },
        textColor = { 1.0, 0.92, 0.90, 1.0 },
    }
end

local function openCompanionInventory(ui, worker, npc, npcData)
    if not DC_SupplyWindow or not DC_SupplyWindow.Open then
        debugCompanionUI("openCompanionInventory missing DC_SupplyWindow.Open")
        return false
    end

    local resolvedWorker = nil
    local liveNPCData = npcData or getNPCData(npc)

    if worker and worker.workerID then
        resolvedWorker = {
            workerID = worker.workerID,
            name = worker.name or worker.workerID,
            ownerUsername = worker.ownerUsername,
        }
    end

    if (not resolvedWorker or not resolvedWorker.workerID) and (liveNPCData and liveNPCData.linkedWorkerID) then
        resolvedWorker = {
            workerID = liveNPCData.linkedWorkerID,
            name = liveNPCData.name or liveNPCData.linkedWorkerID,
            ownerUsername = liveNPCData.ownerUsername,
        }
    end

    if not resolvedWorker or not resolvedWorker.workerID then
        debugCompanionUI(
            "openCompanionInventory failed to resolve worker linkedWorkerID="
                .. tostring(liveNPCData and liveNPCData.linkedWorkerID or nil)
        )
        return false
    end

    debugCompanionUI(
        "openCompanionInventory workerID=" .. tostring(resolvedWorker.workerID)
            .. " name=" .. tostring(resolvedWorker.name or resolvedWorker.workerID)
    )

    if ui and ui.close then
        ui:close()
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if player and player.setHaloNote then
        player:setHaloNote("Loading companion inventory...", 170, 210, 255, 180)
    end

    if isWorkerDetailWarm(resolvedWorker) then
        requestCompanionInventorySummary(resolvedWorker.workerID)
        DC_SupplyWindow.Open(resolvedWorker, "inventory")
        if DC_SupplyWindow.instance and DC_SupplyWindow.instance.updateStatus then
            DC_SupplyWindow.instance:updateStatus("Refreshing inventory details...")
        end
        return true
    end

    return queueCompanionInventoryOpen(resolvedWorker)
end

local function sendCompanionHome(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    return DC_System.SendCommand("SetWorkerJobEnabled", {
        workerID = worker.workerID,
        enabled = false,
    }) == true
end

local function orderCompanionReturnHome(player, npc)
    local sent, npcData = sendCompanionOrder(player, npc, {
        state = "Idle",
        returnStatus = "Resting",
        startDeparture = true,
    })
    if not sent or not npcData then
        return false
    end

    npcData.state = "Departure"
    npcData.status = "Away"
    npcData.returnStatus = "Resting"
    npcData.requestedReturnStatus = "Resting"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatOrder = nil
    attachNPCData(npc, npcData)
    return true
end

local function openCompanionDialogue(npc, player)
    if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
        DTNPC_TraderDialogue_Hub.Init(nil, npc, player)
        return true
    end
    return false
end

local function openLootSearchWindow(player, npcData)
    if not player or not npcData or not npcData.uuid or not DTNPCLootSearchClient then
        return false
    end

    DTNPCLootSearchClient.OpenForNPC(player:getPlayerNum(), npcData)
    DTNPCLootSearchClient.RequestSync(player, npcData)
    return true
end

local function addCompanionContextAction(menu, label, callback)
    menu:addOption(label, nil, callback)
end

local function addDisabledContextAction(menu, label)
    local option = menu:addOption(label, nil, nil)
    if option then
        option.notAvailable = true
    end
end

local function addAttackTypeContextMenu(parentMenu, npc, player)
    local option = parentMenu:addOption("Attack Type")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    local liveData = getNPCData(npc)
    local currentMode = getAttackTypeMode(liveData)
    local ammoSnapshot = getRangedAmmoSnapshot(liveData)
    local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "ProtectAuto" or currentMode == "ProtectRanged")

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Auto", currentMode == "ProtectAuto", showAmmo and currentMode == "ProtectAuto", ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "ProtectAuto", {
            state = "ProtectAuto",
            combatOrder = "ProtectAuto",
            returnStatus = "Resting",
        })
        end
    )

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Ranged", currentMode == "ProtectRanged", showAmmo and currentMode == "ProtectRanged", ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "ProtectRanged", {
            state = "ProtectRanged",
            combatOrder = "ProtectRanged",
            returnStatus = "Resting",
        })
        end
    )

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Melee", currentMode == "ProtectMelee", false, ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "ProtectMelee", {
            state = "ProtectMelee",
            combatOrder = "ProtectMelee",
            returnStatus = "Resting",
        })
        end
    )
end

local function addGuardAttackTypeContextMenu(parentMenu, npc, player)
    local option = parentMenu:addOption("Guard Attack Type")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    local liveData = getNPCData(npc)
    local currentMode = getGuardAttackTypeMode(liveData)
    local ammoSnapshot = getRangedAmmoSnapshot(liveData)
    local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "GuardAuto" or currentMode == "GuardRanged")

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Auto", currentMode == "GuardAuto", showAmmo and currentMode == "GuardAuto", ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "Guard", {
            state = "Guard",
            guardCombatOrder = "GuardAuto",
            returnStatus = "Resting",
        })
        end
    )

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Ranged", currentMode == "GuardRanged", showAmmo and currentMode == "GuardRanged", ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "Guard", {
            state = "Guard",
            guardCombatOrder = "GuardRanged",
            returnStatus = "Resting",
        })
        end
    )

    addCompanionContextAction(
        subMenu,
        buildModeOptionLabel("Melee", currentMode == "GuardMelee", false, ammoSnapshot.ammoCount),
        function()
        issueCompanionStateOrder(player, npc, "Guard", {
            state = "Guard",
            guardCombatOrder = "GuardMelee",
            returnStatus = "Resting",
        })
        end
    )
end

local function sendPatchUpOrder(player, npc)
    return updateCompanionState(player, npc, "PatchUp", {
        state = "PatchUp",
    })
end

local function addPatchUpContextMenu(parentMenu, npc, player, worker)
    if not worker then
        addCompanionContextAction(parentMenu, "Patch Up", function()
            sendPatchUpOrder(player, npc)
        end)
        return
    end

    local supplies, total = collectMedicalSupplies(worker)
    local label = total > 0 and ("Patch Up (" .. tostring(total) .. " medical)") or "Patch Up (No medicine)"
    local option = parentMenu:addOption(label)
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    if total > 0 then
        for _, supply in ipairs(supplies) do
            local itemOption = subMenu:addOption(
                tostring(supply.displayName or supply.fullType or "Medical Supply") .. " x" .. tostring(supply.units or 0),
                nil,
                nil
            )
            if itemOption then
                itemOption.notAvailable = true
                itemOption.iconTexture = supply.texture
            end
        end
        addCompanionContextAction(subMenu, "Use Medical Supply", function()
            sendPatchUpOrder(player, npc)
        end)
        return
    end

    addDisabledContextAction(subMenu, "No bandages, rags, or first-aid supplies packed.")
    addCompanionContextAction(subMenu, "Ask Anyway", function()
        sendPatchUpOrder(player, npc)
    end)
end

local function addTransferCommandContextMenu(parentMenu, worker, player)
    local candidates = collectTransferCandidates(player, worker)
    local option = parentMenu:addOption("Transfer Command")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    if #candidates == 0 then
        addDisabledContextAction(subMenu, "No faction members available")
        return
    end

    for _, username in ipairs(candidates) do
        addCompanionContextAction(subMenu, username, function()
            if sendTransferCommand(worker, username) then
                playCompanionCommandCue(player, "TransferCommand")
                refreshCompanionWorker(worker)
            end
        end)
    end
end

local function addCompanionContextMenu(context, ui, npc, player, npcData)
    if not context or not npc or not player then
        return false
    end

    local worker = getCompanionWorker(ui, npc, npcData or getNPCData(npc))
    local name = tostring((npcData and npcData.name) or (worker and worker.name) or "Companion")
    local liveData = npcData or getNPCData(npc)
    local commander = getCommanderUsername(liveData, worker)
    local isCommander = isLocalCommander(player, liveData, worker)
    local usesCommandAuthority = worker ~= nil and tostring(liveData and liveData.dcCompanionJob or "") == "TravelCompanion"

    local rootOption = context:addOption("Companion Orders: " .. name)
    local rootMenu = context:getNew(context)
    context:addSubMenu(rootOption, rootMenu)

    if usesCommandAuthority then
        addDisabledContextAction(rootMenu, "Commander: " .. tostring(commander or "No commander"))
    end

    addCompanionContextAction(rootMenu, "Talk", function()
        openCompanionDialogue(npc, player)
    end)

    if usesCommandAuthority and not isCommander then
        if worker and canClaimCommand(player, npc) then
            addCompanionContextAction(rootMenu, "Claim Command", function()
                if sendClaimCommand(worker) then
                    playCompanionCommandCue(player, "ClaimCommand")
                    refreshCompanionWorker(worker)
                end
            end)
        else
            addDisabledContextAction(rootMenu, "Move closer to claim command.")
        end
        return true
    end

    addCompanionContextAction(rootMenu, "Follow Me", function()
        issueCompanionStateOrder(player, npc, "Follow", {
            state = "Follow",
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(rootMenu, "Hold Position", function()
        issueCompanionStateOrder(player, npc, "Stay", {
            state = "Stay",
            clearGuardMode = true,
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(rootMenu, "Guard Position", function()
        issueCompanionStateOrder(player, npc, "Guard", {
            state = "Guard",
            guardCombatOrder = (liveData and (liveData.guardCombatOrder or liveData.guardAttackMode)) or "GuardAuto",
            returnStatus = "Resting",
        })
    end)

    local isLooting = liveData and liveData.state == "LootNearby"
    addCompanionContextAction(rootMenu, isLooting and "Stop Loot Search" or "Search Nearby Loot", function()
        local latestData = getNPCData(npc) or liveData
        if latestData and latestData.state == "LootNearby" then
            issueCompanionStateOrder(player, npc, "Stay", {
                state = "Stay",
                returnStatus = "Resting",
            })
            return
        end

        issueCompanionStateOrder(player, npc, "LootNearby", {
            state = "LootNearby",
            x = npc:getX(),
            y = npc:getY(),
            z = npc:getZ(),
            lootRadius = latestData and latestData.dcLootConfig and latestData.dcLootConfig.radius or nil,
            combatOrder = getLootCombatOrder(latestData),
            returnStatus = "Resting",
        })
        openLootSearchWindow(player, latestData)
    end)

    addPatchUpContextMenu(rootMenu, npc, player, worker)

    addAttackTypeContextMenu(rootMenu, npc, player)
    addGuardAttackTypeContextMenu(rootMenu, npc, player)
    if usesCommandAuthority and worker then
        addTransferCommandContextMenu(rootMenu, worker, player)
    end

    if worker or (npcData and npcData.linkedWorkerID) then
        addCompanionContextAction(rootMenu, "Manage Inventory", function()
            openCompanionInventory(ui, worker, npc, npcData)
        end)
    end

    if worker then
        addCompanionContextAction(rootMenu, "Go Home", function()
            local workerCommandSent = sendCompanionHome(worker)
            local returnOrderSent = orderCompanionReturnHome(player, npc)
            if workerCommandSent and returnOrderSent then
                playCompanionCommandCue(player, "GoHome")
            end
            return workerCommandSent and returnOrderSent
        end)
    end

    return true
end

local function generateRootOptions(ui, npc, player, worker)
    ui.isCompanionConversation = true
    if ui.refreshFactionInfo then
        ui:refreshFactionInfo()
    end

    local npcData = getNPCData(npc)
    local commander = getCommanderUsername(npcData, worker)
    local commanderText = "Commander: " .. tostring(commander or "No commander")
    local usesCommandAuthority = worker ~= nil and tostring(npcData and npcData.dcCompanionJob or "") == "TravelCompanion"
    if usesCommandAuthority and not isLocalCommander(player, npcData, worker) then
        local options = {
            {
                text = commanderText,
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak(commander and ("I'm taking orders from " .. commander .. ".") or "No one is commanding me right now.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            },
            {
                text = "Chat",
                message = "How are you holding up?",
                onSelect = function(innerUI)
                    innerUI:speak("I'm here, but command has to be claimed first.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        }

        if worker and canClaimCommand(player, npc) then
            options[#options + 1] = {
                text = "Claim Command",
                message = "I'm taking command. Follow my lead.",
                onSelect = function(innerUI)
                    if sendClaimCommand(worker) then
                        playCompanionCommandCue(player, "ClaimCommand")
                        local liveData = getNPCData(npc)
                        if liveData then
                            liveData.dcCommanderUsername = getLocalUsername(player)
                            liveData.master = getLocalUsername(player)
                            liveData.masterID = player and player.getOnlineID and player:getOnlineID() or liveData.masterID
                            attachNPCData(npc, liveData)
                        end
                        innerUI:speak("Command claimed. I'll follow you.")
                        refreshCompanionWorker(worker)
                    else
                        innerUI:speak("I couldn't claim command right now.")
                    end
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        else
            options[#options + 1] = {
                text = "Move closer to claim command.",
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak("Move within a few steps, then claim command.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        end

        local footerAction = buildLeaveFooterAction()
        local _, navBlock = attachNavigationBlock(options, footerAction, {
            resetHistory = true,
            debugLabel = "CompanionClaimRoot",
            requireExplicitNavigation = true,
        })
        ui:updateOptions(options, navBlock)
        return
    end

    local options = {}
    if usesCommandAuthority then
        options[#options + 1] = {
            text = commanderText,
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("You're my current commander.")
                generateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = "Chat",
        message = "How are you holding up?",
        onSelect = function(innerUI)
            innerUI:speak("I'm with you. Just say the word.")
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Follow Me",
        message = "Stay close and move with me.",
        onSelect = function(innerUI)
            if issueCompanionStateOrder(player, npc, "Follow", {
                state = "Follow",
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll stay close.")
            else
                innerUI:speak("I couldn't follow you right now.")
            end
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Hold Position",
        message = "Stay put until I tell you otherwise.",
        onSelect = function(innerUI)
            if issueCompanionStateOrder(player, npc, "Stay", {
                state = "Stay",
                clearGuardMode = true,
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll hold here.")
            else
                innerUI:speak("I couldn't hold position right now.")
            end
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Guard Position",
        message = "Hold this area and engage nearby threats.",
        onSelect = function(innerUI)
            local liveData = getNPCData(npc)
            if issueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = (liveData and (liveData.guardCombatOrder or liveData.guardAttackMode)) or "GuardAuto",
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll guard this position.")
            else
                innerUI:speak("I couldn't take up guard duty right now.")
            end
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = (npcData and npcData.state == "LootNearby") and "Stop Loot Search" or "Search Nearby Loot",
        message = "Search nearby sources, reveal their contents, then tell me what to collect.",
        onSelect = function(innerUI)
            local liveData = getNPCData(npc)
            if liveData and liveData.state == "LootNearby" then
                if issueCompanionStateOrder(player, npc, "Stay", {
                    state = "Stay",
                    returnStatus = "Resting",
                }) then
                    innerUI:speak("Looting paused.")
                else
                    innerUI:speak("I couldn't stop looting right now.")
                end
                generateRootOptions(innerUI, npc, player, worker)
                return
            end

            if issueCompanionStateOrder(player, npc, "LootNearby", {
                state = "LootNearby",
                x = npc:getX(),
                y = npc:getY(),
                z = npc:getZ(),
                lootRadius = liveData and liveData.dcLootConfig and liveData.dcLootConfig.radius or nil,
                combatOrder = getLootCombatOrder(liveData),
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll search nearby sources and wait for your pickup orders.")
                openLootSearchWindow(player, liveData)
            else
                innerUI:speak("I couldn't start looting right now.")
            end
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    local patchUpLabel, patchUpSupplyTotal = getPatchUpLabel(worker)
    options[#options + 1] = {
        text = patchUpLabel,
        message = "Take a moment to bandage yourself.",
        onSelect = function(innerUI)
            local sent = sendPatchUpOrder(player, npc)
            if sent then
                if patchUpSupplyTotal > 0 then
                    innerUI:speak("I'll patch myself up.")
                else
                    innerUI:speak("I don't have any bandages or rags packed.")
                end
            else
                innerUI:speak("I couldn't patch up right now.")
            end
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Attack Type",
        message = "Let's talk combat.",
        onSelect = function(innerUI)
            local liveData = getNPCData(npc)
            local currentLabel = getAttackTypeLabel(liveData)
            local currentMode = getAttackTypeMode(liveData)
            local ammoSnapshot = getRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "ProtectAuto" or currentMode == "ProtectRanged")
            innerUI:speak("Current attack type: " .. currentLabel .. ".")
            local attackOptions = {
                {
                    text = buildModeOptionLabel(
                        "Auto",
                        currentMode == "ProtectAuto",
                        showAmmo and currentMode == "ProtectAuto",
                        ammoSnapshot.ammoCount
                    ),
                    message = "Use whichever weapon fits the fight.",
                    style = buildModeOptionStyle(currentMode == "ProtectAuto", "auto"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "ProtectAuto", {
                            state = "ProtectAuto",
                            combatOrder = "ProtectAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll switch between range and melee as needed.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = buildModeOptionLabel(
                        "Ranged",
                        currentMode == "ProtectRanged",
                        showAmmo and currentMode == "ProtectRanged",
                        ammoSnapshot.ammoCount
                    ),
                    message = "Cover me from range.",
                    style = buildModeOptionStyle(currentMode == "ProtectRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "ProtectRanged", {
                            state = "ProtectRanged",
                            combatOrder = "ProtectRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll keep some distance and cover you.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = buildModeOptionLabel("Melee", currentMode == "ProtectMelee", false, ammoSnapshot.ammoCount),
                    message = "Stay close and fight up front.",
                    style = buildModeOptionStyle(currentMode == "ProtectMelee", "melee"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "ProtectMelee", {
                            state = "ProtectMelee",
                            combatOrder = "ProtectMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll stay close and handle threats up front.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
            }
            local footerAction = buildBackFooterAction({
                onSelect = function(backUI)
                    generateRootOptions(backUI, npc, player, worker)
                end
            })
            local _, navBlock = attachNavigationBlock(attackOptions, footerAction, {
                debugLabel = "CompanionAttackType",
                requireExplicitNavigation = true,
            })
            innerUI:updateOptions(attackOptions, navBlock)
        end
    }

    options[#options + 1] = {
        text = "Guard Attack Type",
        message = "How should you fight while guarding?",
        onSelect = function(innerUI)
            local liveData = getNPCData(npc)
            local currentLabel = getGuardAttackTypeLabel(liveData)
            local currentMode = getGuardAttackTypeMode(liveData)
            local ammoSnapshot = getRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "GuardAuto" or currentMode == "GuardRanged")
            innerUI:speak("Current guard attack type: " .. currentLabel .. ".")
            local guardOptions = {
                {
                    text = buildModeOptionLabel(
                        "Auto",
                        currentMode == "GuardAuto",
                        showAmmo and currentMode == "GuardAuto",
                        ammoSnapshot.ammoCount
                    ),
                    message = "Use whichever weapon fits the threat while guarding.",
                    style = buildModeOptionStyle(currentMode == "GuardAuto", "auto"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll guard this spot and adapt as needed.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = buildModeOptionLabel(
                        "Ranged",
                        currentMode == "GuardRanged",
                        showAmmo and currentMode == "GuardRanged",
                        ammoSnapshot.ammoCount
                    ),
                    message = "Guard from a distance.",
                    style = buildModeOptionStyle(currentMode == "GuardRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll hold this spot and engage from range.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = buildModeOptionLabel("Melee", currentMode == "GuardMelee", false, ammoSnapshot.ammoCount),
                    message = "Hold the line up close.",
                    style = buildModeOptionStyle(currentMode == "GuardMelee", "melee"),
                    onSelect = function(choiceUI)
                        if issueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll hold this spot and fight up close.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                },
            }
            local footerAction = buildBackFooterAction({
                onSelect = function(backUI)
                    generateRootOptions(backUI, npc, player, worker)
                end
            })
            local _, navBlock = attachNavigationBlock(guardOptions, footerAction, {
                debugLabel = "CompanionGuardAttackType",
                requireExplicitNavigation = true,
            })
            innerUI:updateOptions(guardOptions, navBlock)
        end
    }

    if usesCommandAuthority then
        options[#options + 1] = {
            text = "Transfer Command",
            message = "I'm assigning you to someone else.",
            onSelect = function(innerUI)
                local candidates = collectTransferCandidates(player, worker)
                if #candidates == 0 then
                    innerUI:speak("There isn't another faction member to transfer command to.")
                    generateRootOptions(innerUI, npc, player, worker)
                    return
                end

                local choices = {}
                for _, username in ipairs(candidates) do
                    choices[#choices + 1] = {
                        text = tostring(username),
                        message = "Report to " .. tostring(username) .. ".",
                        onSelect = function(choiceUI)
                            if sendTransferCommand(worker, username) then
                                playCompanionCommandCue(player, "TransferCommand")
                                choiceUI:speak("Command transferred to " .. tostring(username) .. ".")
                                refreshCompanionWorker(worker)
                            else
                                choiceUI:speak("I couldn't transfer command right now.")
                            end
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    }
                end
                local footerAction = buildBackFooterAction({
                    onSelect = function(backUI)
                        generateRootOptions(backUI, npc, player, worker)
                    end
                })
                local _, navBlock = attachNavigationBlock(choices, footerAction, {
                    debugLabel = "CompanionTransferCommand",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(choices, navBlock)
            end
        }
    end

    if worker then
        options[#options + 1] = {
            text = "Manage Inventory",
            message = "Let me check what you're carrying.",
            onSelect = function(innerUI)
                if openCompanionInventory(innerUI, worker, npc, getNPCData(npc)) then
                    return
                else
                    innerUI:speak("I couldn't open my inventory right now.")
                    debugCompanionUI(
                        "Manage Inventory failed workerID="
                            .. tostring(worker and worker.workerID or nil)
                            .. " linkedWorkerID="
                            .. tostring(getNPCData(npc) and getNPCData(npc).linkedWorkerID or nil)
                    )
                end
                generateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = "Go Home",
        message = "Head back home and stand down.",
        onSelect = function(innerUI)
            local workerCommandSent = worker and sendCompanionHome(worker) or true
            local returnOrderSent = orderCompanionReturnHome(player, npc)
            if workerCommandSent and returnOrderSent then
                playCompanionCommandCue(player, "GoHome")
                innerUI:speak("Understood. I'll head home.")
                local doneOptions = {}
                local footerAction = buildExitFooterAction()
                local _, navBlock = attachNavigationBlock(doneOptions, footerAction, {
                    resetHistory = true,
                    debugLabel = "CompanionGoHomeResolved",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(doneOptions, navBlock)
            else
                innerUI:speak("I couldn't head home right now.")
                generateRootOptions(innerUI, npc, player, worker)
            end
        end
    }

    local footerAction = buildLeaveFooterAction()
    local _, navBlock = attachNavigationBlock(options, footerAction, {
        resetHistory = true,
        debugLabel = "CompanionRoot",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, navBlock)
end

DTNPCJobUI.Register({
    id = "TravelCompanion",
    priority = 100,
    matches = function(ui, npc, player, npcData)
        npcData = npcData or getNPCData(npc)
        if not npcData then
            return false
        end

        if getCompanionWorker(ui, npc, npcData) then
            return true
        end

        return isLegacyTravelCompanion(player, npcData)
    end,
    getTalkLabel = function(ui, npc, player, npcData, defaultName)
        return "Talk to Companion " .. tostring(defaultName or (npcData and npcData.name) or "Survivor")
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        return {
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    end,
    generateOptions = function(ui, npc, player, npcData)
        local worker = getCompanionWorker(ui, npc, npcData or getNPCData(npc))
        generateRootOptions(ui, npc, player, worker)
        return true
    end,
    addContextMenuOptions = function(context, ui, npc, player, npcData)
        return addCompanionContextMenu(context, ui, npc, player, npcData or getNPCData(npc))
    end
})
