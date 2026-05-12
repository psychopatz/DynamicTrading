require "Utils/ConfigManager/DT_ConfigManager"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {}

DynamicTrading.Manuals.AutoOpen = DynamicTrading.Manuals.AutoOpen or {
    checked = false,
    runtimeState = nil,
}

local AutoOpen = DynamicTrading.Manuals.AutoOpen

local STATE_SCHEMA_VERSION = 1
local STATE_KEY_PREFIX = "DT_ManualAutoOpenState_"

local function safeTrim(value)
    local text = tostring(value or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function safeCall(callback)
    if not callback then
        return nil
    end

    local ok, result = pcall(callback)
    if ok then
        return result
    end

    return nil
end

local function getCurrentMillis()
    if getTimeInMillis then
        return tonumber(getTimeInMillis()) or 0
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end

    return os and os.time and (os.time() * 1000) or 0
end

local function getLocalPlayer()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function getLocalPlayerUsername()
    local player = getLocalPlayer()

    if player and player.getUsername then
        local username = safeTrim(player:getUsername())
        if username ~= "" then
            return username
        end
    end

    return "local"
end

local function getStateKey()
    return STATE_KEY_PREFIX .. getLocalPlayerUsername()
end

local function normalizeState(state)
    state = type(state) == "table" and state or {}

    state.schemaVersion = STATE_SCHEMA_VERSION
    state.seen = type(state.seen) == "table" and state.seen or {}
    state.disabled = type(state.disabled) == "table" and state.disabled or {}

    return state
end

local function ensureModDataState()
    if not ModData or not ModData.get or not ModData.add then
        AutoOpen.runtimeState = normalizeState(AutoOpen.runtimeState)
        return AutoOpen.runtimeState, nil
    end

    local key = getStateKey()

    if ModData.exists and not ModData.exists(key) then
        ModData.add(key, normalizeState({}))
    elseif not ModData.exists then
        local existing = ModData.get(key)
        if type(existing) ~= "table" then
            ModData.add(key, normalizeState({}))
        end
    end

    local state = ModData.get(key)
    if type(state) ~= "table" then
        if ModData.remove then
            ModData.remove(key)
        end
        ModData.add(key, normalizeState({}))
        state = ModData.get(key)
    end

    state = normalizeState(state)
    return state, key
end

local function loadState()
    if DT_ConfigManager and DT_ConfigManager.getManualAutoOpenState then
        local state = safeCall(function()
            return DT_ConfigManager.getManualAutoOpenState()
        end)

        if type(state) == "table" then
            return normalizeState(state), nil
        end
    end

    return ensureModDataState()
end

local function saveState(state, modDataKey)
    state = normalizeState(state)

    if DT_ConfigManager and DT_ConfigManager.setManualAutoOpenState then
        local saved = safeCall(function()
            DT_ConfigManager.setManualAutoOpenState(state)
            return true
        end)

        if saved == true then
            return
        end
    end

    if modDataKey and ModData and ModData.transmit then
        safeCall(function()
            ModData.transmit(modDataKey)
        end)
    end

    if GlobalModData and GlobalModData.save then
        safeCall(function()
            GlobalModData.save()
        end)
    end
end

local function getPlayerManualModData()
    if DT_ConfigManager and DT_ConfigManager.getManualModData then
        return DT_ConfigManager.getManualModData()
    end

    local player = getLocalPlayer()
    if not player then
        return nil
    end

    local modData = player:getModData()
    if type(modData.DT_ManualState) ~= "table" then
        modData.DT_ManualState = {}
    end

    return modData.DT_ManualState
end

local function transmitPlayerManualModData()
    local player = getLocalPlayer()
    if player and player.transmitModData then
        player:transmitModData()
    end
end

local function getWhatsNewState()
    local manualState = getPlayerManualModData()
    if not manualState then
        return nil
    end

    if type(manualState.whatsNew) ~= "table" then
        manualState.whatsNew = {}
    end

    local state = manualState.whatsNew
    state.acknowledgedCount = tonumber(state.acknowledgedCount or 0) or 0
    state.lastOpenedCount = tonumber(state.lastOpenedCount or 0) or 0

    return state
end

local function getManualID(manual)
    return safeTrim(manual and manual.id or "")
end

local function getManualType(manual)
    local manualType = string.lower(safeTrim(manual and manual.manualType or ""))

    if manualType ~= "" then
        return manualType
    end

    if DynamicTrading.Manuals
        and DynamicTrading.Manuals.IsUpdateManual
        and DynamicTrading.Manuals.IsUpdateManual(manual) then
        return "whats_new"
    end

    return "manual"
end

local function isUpdateManual(manual)
    if DynamicTrading.Manuals
        and DynamicTrading.Manuals.IsUpdateManual
        and DynamicTrading.Manuals.IsUpdateManual(manual) then
        return true
    end

    return getManualType(manual) == "whats_new"
end

local function getManualPageAndBlockCount(manual)
    if type(manual) == "table" and manual.contentPageCount ~= nil and manual.contentBlockCount ~= nil then
        return tonumber(manual.contentPageCount) or 0, tonumber(manual.contentBlockCount) or 0
    end

    local pageCount = 0
    local blockCount = 0

    for _, page in ipairs(type(manual and manual.pages) == "table" and manual.pages or {}) do
        pageCount = pageCount + 1
        blockCount = blockCount + #(page.blocks or {})
    end

    return pageCount, blockCount
end

function AutoOpen.GetManualAutoOpenKey(manual)
    if not manual then
        return ""
    end

    local key = safeTrim(manual.popupVersion)
    if key ~= "" then
        return key
    end

    key = safeTrim(manual.releaseVersion)
    if key ~= "" then
        return key
    end

    key = safeTrim(manual.contentRevision)
    if key ~= "" then
        return key
    end

    key = safeTrim(manual.autoOpenRevision)
    if key ~= "" then
        return key
    end

    local pageCount, blockCount = getManualPageAndBlockCount(manual)
    return "content:" .. tostring(pageCount) .. ":" .. tostring(blockCount)
end

function AutoOpen.GetCurrentWhatsNewCount()
    if not DynamicTrading
        or not DynamicTrading.Manuals
        or not DynamicTrading.Manuals.GetOrderedUpdateManuals then
        return 0
    end

    local updates = DynamicTrading.Manuals.GetOrderedUpdateManuals()
    return updates and #updates or 0
end

function AutoOpen.GetAcknowledgedWhatsNewCount()
    local state = getWhatsNewState()
    return state and (tonumber(state.acknowledgedCount) or 0) or 0
end

function AutoOpen.GetLastOpenedWhatsNewCount()
    local state = getWhatsNewState()
    return state and (tonumber(state.lastOpenedCount) or 0) or 0
end

function AutoOpen.SetAcknowledgedWhatsNewCount(count)
    local state = getWhatsNewState()
    if not state then
        return false
    end

    state.acknowledgedCount = tonumber(count or 0) or 0
    transmitPlayerManualModData()
    return true
end

function AutoOpen.MarkWhatsNewAcknowledged()
    local state = getWhatsNewState()
    if not state then
        return false
    end

    state.acknowledgedCount = AutoOpen.GetCurrentWhatsNewCount()
    transmitPlayerManualModData()
    return true
end

function AutoOpen.MarkWhatsNewOpened()
    local state = getWhatsNewState()
    if not state then
        return false
    end

    state.lastOpenedCount = AutoOpen.GetCurrentWhatsNewCount()
    transmitPlayerManualModData()
    return true
end

function AutoOpen.ShouldWhatsNewAutoOpen()
    local currentVisibleCount = AutoOpen.GetCurrentWhatsNewCount()
    if currentVisibleCount <= 0 then
        return false
    end

    return AutoOpen.GetAcknowledgedWhatsNewCount() ~= currentVisibleCount
end

local function getDisabledStateKey(manualID, autoOpenKey)
    return tostring(manualID or "") .. "::" .. tostring(autoOpenKey or "")
end

local function getSeenEntry(state, manualID)
    return state and state.seen and state.seen[manualID] or nil
end

function AutoOpen.HasManualBeenSeen(manual, autoOpenKey)
    local manualID = getManualID(manual)
    local key = safeTrim(autoOpenKey or AutoOpen.GetManualAutoOpenKey(manual))

    if manualID == "" or key == "" then
        return true
    end

    local state = loadState()
    local seenEntry = getSeenEntry(state, manualID)

    if type(seenEntry) == "table" then
        return safeTrim(seenEntry.seenKey) == key
    end

    if type(seenEntry) == "string" then
        return safeTrim(seenEntry) == key
    end

    return false
end

function AutoOpen.HasManualEverBeenSeen(manual)
    local manualID = getManualID(manual)

    if manualID == "" then
        return true
    end

    local state = loadState()
    return state.seen[manualID] ~= nil
end

function AutoOpen.IsManualDisabled(manual, autoOpenKey)
    local manualID = getManualID(manual)
    local key = safeTrim(autoOpenKey or AutoOpen.GetManualAutoOpenKey(manual))

    if manualID == "" or key == "" then
        return false
    end

    local state = loadState()
    local disabledKey = getDisabledStateKey(manualID, key)

    if state.disabled[disabledKey] == true then
        return true
    end

    if isUpdateManual(manual)
        and DT_ConfigManager
        and DT_ConfigManager.getDisabledAutoOpenReleaseVersion then
        local legacyDisabledVersion = safeTrim(DT_ConfigManager.getDisabledAutoOpenReleaseVersion())
        if legacyDisabledVersion ~= "" and legacyDisabledVersion == key then
            return true
        end
    end

    return false
end

function AutoOpen.SetManualDisabled(manual, autoOpenKey, disabled)
    local manualID = getManualID(manual)
    local key = safeTrim(autoOpenKey or AutoOpen.GetManualAutoOpenKey(manual))

    if manualID == "" or key == "" then
        return false
    end

    local state, modDataKey = loadState()
    local disabledKey = getDisabledStateKey(manualID, key)

    if disabled == true then
        state.disabled[disabledKey] = true
    else
        state.disabled[disabledKey] = nil
    end

    saveState(state, modDataKey)

    if isUpdateManual(manual)
        and DT_ConfigManager
        and DT_ConfigManager.setDisabledAutoOpenReleaseVersion then
        if disabled == true then
            DT_ConfigManager.setDisabledAutoOpenReleaseVersion(key)
        else
            local legacyDisabledVersion = DT_ConfigManager.getDisabledAutoOpenReleaseVersion
                and safeTrim(DT_ConfigManager.getDisabledAutoOpenReleaseVersion())
                or ""

            if legacyDisabledVersion == key then
                DT_ConfigManager.setDisabledAutoOpenReleaseVersion("")
            end
        end
    end

    return true
end

function AutoOpen.MarkManualSeen(manual, autoOpenKey)
    local manualID = getManualID(manual)
    local key = safeTrim(autoOpenKey or AutoOpen.GetManualAutoOpenKey(manual))

    if manualID == "" or key == "" then
        return false
    end

    local state, modDataKey = loadState()

    state.seen[manualID] = {
        seenKey = key,
        seenAt = getCurrentMillis(),
        manualType = getManualType(manual),
    }

    saveState(state, modDataKey)

    if isUpdateManual(manual) and DT_ConfigManager then
        if DT_ConfigManager.setLastSeenReleaseVersion then
            DT_ConfigManager.setLastSeenReleaseVersion(key)
        end

        if DT_ConfigManager.setLastSeenWhatsNewCount and DynamicTrading.Manuals.GetOrderedUpdateManuals then
            local updates = DynamicTrading.Manuals.GetOrderedUpdateManuals()
            DT_ConfigManager.setLastSeenWhatsNewCount(updates and #updates or 0)
        end
    end

    return true
end

local function getAutoOpenMode(manual)
    return string.lower(safeTrim(manual and manual.autoOpenMode or ""))
end

local function autoOpenOnUpdate(manual)
    if not manual then
        return false
    end

    if manual.autoOpenOnUpdate ~= nil then
        return manual.autoOpenOnUpdate == true
    end

    if isUpdateManual(manual) then
        return true
    end

    return false
end

local function autoOpenOnFirstSeen(manual)
    if not manual then
        return false
    end

    if manual.autoOpenOnFirstSeen ~= nil then
        return manual.autoOpenOnFirstSeen == true
    end

    return false
end

function AutoOpen.IsManualAutoOpenEligible(manual)
    if not manual then
        return false
    end

    if manual.hidden == true then
        return false
    end

    local mode = getAutoOpenMode(manual)
    if mode == "never" or mode == "disabled" or mode == "off" then
        return false
    end

    if autoOpenOnUpdate(manual) then
        return true
    end

    if autoOpenOnFirstSeen(manual) then
        return true
    end

    return false
end

function AutoOpen.CanManualShowDisableControl(manual)
    if isUpdateManual(manual) then
        return true
    end

    return AutoOpen.IsManualAutoOpenEligible(manual)
end

function AutoOpen.ShouldManualAutoOpenNow(manual)
    if isUpdateManual(manual) then
        return AutoOpen.ShouldWhatsNewAutoOpen()
    end

    if not AutoOpen.IsManualAutoOpenEligible(manual) then
        return false
    end

    local key = AutoOpen.GetManualAutoOpenKey(manual)
    if key == "" then
        return false
    end

    if AutoOpen.IsManualDisabled(manual, key) then
        return false
    end

    local manualID = getManualID(manual)
    if manualID == "" then
        return false
    end

    local state = loadState()
    local seenEntry = getSeenEntry(state, manualID)

    if not seenEntry then
        return autoOpenOnFirstSeen(manual) or autoOpenOnUpdate(manual)
    end

    local seenKey = ""
    if type(seenEntry) == "table" then
        seenKey = safeTrim(seenEntry.seenKey)
    elseif type(seenEntry) == "string" then
        seenKey = safeTrim(seenEntry)
    end

    if seenKey ~= key and autoOpenOnUpdate(manual) then
        return true
    end

    return false
end

local function getManualTypePriority(manual)
    local manualType = getManualType(manual)

    if manualType == "whats_new" then
        return 1000
    end

    if manualType == "manual" then
        return 500
    end

    if manualType == "support" then
        return 100
    end

    if manualType == "donators" then
        return 50
    end

    return 250
end

local function getManualPriority(manual)
    local explicit = tonumber(manual and manual.autoOpenPriority)
    if explicit ~= nil then
        return explicit
    end

    return getManualTypePriority(manual)
end

local function compareVersions(left, right)
    if DynamicTrading.Manuals and DynamicTrading.Manuals.CompareReleaseVersions then
        return DynamicTrading.Manuals.CompareReleaseVersions(left, right)
    end

    left = tostring(left or "")
    right = tostring(right or "")

    if left < right then return -1 end
    if left > right then return 1 end
    return 0
end

local function sortCandidates(left, right)
    local leftPriority = getManualPriority(left.manual)
    local rightPriority = getManualPriority(right.manual)

    if leftPriority ~= rightPriority then
        return leftPriority > rightPriority
    end

    local versionCompare = compareVersions(left.autoOpenKey, right.autoOpenKey)
    if versionCompare ~= 0 then
        return versionCompare > 0
    end

    local leftSort = tonumber(left.manual and left.manual.sortOrder) or 0
    local rightSort = tonumber(right.manual and right.manual.sortOrder) or 0

    if leftSort ~= rightSort then
        return leftSort < rightSort
    end

    return string.lower(tostring(left.manual and left.manual.title or "")) < string.lower(tostring(right.manual and right.manual.title or ""))
end

function AutoOpen.GetVisibleManuals()
    local manualsAPI = DynamicTrading and DynamicTrading.Manuals or nil

    if not manualsAPI then
        return {}
    end

    local active = manualsAPI.GetActiveAudienceState and manualsAPI.GetActiveAudienceState() or nil
    local registry = manualsAPI.Registry or {}
    local manuals = {}

    for _, manual in pairs(registry) do
        local visible = true

        if manualsAPI.IsManualVisible then
            visible = manualsAPI.IsManualVisible(manual, active)
        end

        if visible then
            table.insert(manuals, manual)
        end
    end

    return manuals
end

function AutoOpen.GetPendingCandidates()
    local candidates = {}

    for _, manual in ipairs(AutoOpen.GetVisibleManuals()) do
        if AutoOpen.ShouldManualAutoOpenNow(manual) then
            table.insert(candidates, {
                manual = manual,
                autoOpenKey = AutoOpen.GetManualAutoOpenKey(manual),
            })
        end
    end

    table.sort(candidates, sortCandidates)

    return candidates
end

function AutoOpen.GetBestPendingCandidate()
    local candidates = AutoOpen.GetPendingCandidates()
    return candidates[1]
end

function AutoOpen.OpenManual(manual, autoOpenKey)
    if not manual then
        return false
    end

    local manualID = getManualID(manual)
    if manualID == "" then
        return false
    end

    local pageID = manual.startPageId
    local args = {
        manualId = manualID,
        pageId = pageID,
        manualAutoOpened = true,
    }

    local opened = nil

    if isUpdateManual(manual) and DynamicTrading.Manuals.OpenUpdates then
        opened = DynamicTrading.Manuals.OpenUpdates(args)
    elseif DynamicTrading.Manuals.Open then
        args.viewMode = "manuals"
        opened = DynamicTrading.Manuals.Open(args)
    end

    if opened then
        if isUpdateManual(manual) then
            AutoOpen.MarkWhatsNewOpened()
        end
        AutoOpen.MarkManualSeen(manual, autoOpenKey)
        return true
    end

    return false
end

function AutoOpen.TryOpenPending()
    if AutoOpen.checked then
        return false
    end

    local player = getLocalPlayer()
    if not player then
        return false
    end

    if not DynamicTrading or not DynamicTrading.Manuals or not DynamicTrading.Manuals.Registry then
        return false
    end

    AutoOpen.checked = true

    if not AutoOpen.ShouldWhatsNewAutoOpen() then
        return false
    end

    local latest = DynamicTrading.Manuals.GetLatestWhatsNewManual
        and DynamicTrading.Manuals.GetLatestWhatsNewManual()
        or nil

    if not latest then
        return false
    end

    return AutoOpen.OpenManual(latest, AutoOpen.GetManualAutoOpenKey(latest))
end

function AutoOpen.ResetSessionCheck()
    AutoOpen.checked = false
end

Events.OnGameStart.Add(function()
    AutoOpen.ResetSessionCheck()
    AutoOpen.TryOpenPending()
end)

Events.OnCreatePlayer.Add(function(playerIndex)
    if playerIndex == 0 then
        AutoOpen.TryOpenPending()
    end
end)
