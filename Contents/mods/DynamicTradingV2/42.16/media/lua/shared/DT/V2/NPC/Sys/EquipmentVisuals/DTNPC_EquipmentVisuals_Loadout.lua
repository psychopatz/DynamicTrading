-- ==============================================================================
-- DTNPC_EquipmentVisuals_Loadout.lua
-- Active weapon, attachment, and signature resolution.
-- ==============================================================================

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}
EquipmentVisuals.Internal = EquipmentVisuals.Internal or {}

local Helpers = EquipmentVisuals.Helpers
local Internal = EquipmentVisuals.Internal

local function isMeleeDisplayType(displayType)
    return displayType == "onehanded"
        or displayType == "twohanded"
        or displayType == "spear"
        or displayType == "chainsaw"
        or displayType == "throwing"
        or displayType == "item"
end

local function getEquipSlot(item, scriptItem)
    if item and item.canBeEquipped then
        local slot = item:canBeEquipped()
        if slot and slot ~= "" then
            return tostring(slot)
        end
    end

    if scriptItem and scriptItem.canBeEquipped then
        local slot = scriptItem:canBeEquipped()
        if slot and slot ~= "" then
            return tostring(slot)
        end
    end

    return nil
end

local function scoreBagCandidate(itemType, equipSlot)
    local loweredType = Helpers.lower(itemType)
    local loweredSlot = Helpers.lower(equipSlot)

    if loweredSlot == "back" or loweredSlot:find("back", 1, true) then
        return 420
    end
    if loweredSlot:find("satchel", 1, true) then
        return 380
    end
    if loweredSlot:find("webbing", 1, true) or loweredSlot:find("ammostrap", 1, true) then
        return 340
    end
    if loweredSlot:find("fannypack", 1, true) then
        return 300
    end

    if loweredType:find("bag_", 1, true)
        or loweredType:find("backpack", 1, true)
        or loweredType:find("duffel", 1, true)
        or loweredType:find("satchel", 1, true)
        or loweredType:find("schoolbag", 1, true)
        or loweredType:find("slingbag", 1, true)
        or loweredType:find("fanny", 1, true)
        or loweredType:find("webbing", 1, true) then
        return 260
    end

    return 0
end

local function mergeSlotOptions(target, source)
    local merged = {}
    local seen = {}

    for i = 1, #(target or {}) do
        local slot = target[i]
        if slot and not seen[slot] then
            seen[slot] = true
            merged[#merged + 1] = slot
        end
    end
    for i = 1, #(source or {}) do
        local slot = source[i]
        if slot and not seen[slot] then
            seen[slot] = true
            merged[#merged + 1] = slot
        end
    end

    return merged
end

local function buildCandidate(itemType, npcData, sourceScore, role, liveItem)
    if not itemType or itemType == "" then
        return nil
    end

    local condition = liveItem and Helpers.getItemCondition(liveItem) or Helpers.getStoredWeaponCondition(npcData, itemType)
    local item = liveItem or Helpers.createDisplayItem(itemType, condition)
    local scriptItem = Helpers.getScriptItemDefinition(itemType)
    local attachmentType = item and item.getAttachmentType and item:getAttachmentType() or nil
    if (not attachmentType or attachmentType == "") and scriptItem and scriptItem.getAttachmentType then
        attachmentType = scriptItem:getAttachmentType()
    end

    local slotOptions = attachmentType and Helpers.getAttachmentSlotsByType(attachmentType) or {}
    local displayType = Helpers.getWeaponDisplayType(item) or ""
    local isRanged = displayType == "handgun" or displayType == "rifle"
    local isWeapon = (item and item.IsWeapon and item:IsWeapon()) or isRanged or isMeleeDisplayType(displayType)
    local isMelee = (isWeapon and not isRanged and displayType ~= "barehand") or role == "melee"
    local equipSlot = getEquipSlot(item, scriptItem)
    local bagScore = scoreBagCandidate(itemType, equipSlot)

    if role == "bag" then
        bagScore = bagScore + 260
    elseif role == "ranged" then
        isRanged = true
        isWeapon = true
    elseif role == "melee" then
        isMelee = true
        isWeapon = true
    end

    return {
        itemType = itemType,
        condition = condition,
        sourceScore = math.max(0, tonumber(sourceScore) or 0),
        fromInventory = liveItem ~= nil,
        attachmentType = attachmentType,
        slotOptions = slotOptions,
        displayType = displayType,
        isWeapon = isWeapon == true,
        isRanged = isRanged == true,
        isMelee = isMelee == true,
        equipSlot = equipSlot,
        bagScore = bagScore,
    }
end

local function registerCandidate(map, candidate)
    if not candidate or not candidate.itemType or candidate.itemType == "" then
        return
    end

    local existing = map[candidate.itemType]
    if not existing then
        map[candidate.itemType] = candidate
        return
    end

    existing.sourceScore = math.max(existing.sourceScore or 0, candidate.sourceScore or 0)
    existing.bagScore = math.max(existing.bagScore or 0, candidate.bagScore or 0)
    existing.fromInventory = existing.fromInventory or candidate.fromInventory
    existing.attachmentType = existing.attachmentType or candidate.attachmentType
    existing.equipSlot = existing.equipSlot or candidate.equipSlot
    existing.displayType = ((existing.displayType and existing.displayType ~= "") and existing.displayType) or candidate.displayType
    existing.isWeapon = existing.isWeapon or candidate.isWeapon
    existing.isRanged = existing.isRanged or candidate.isRanged
    existing.isMelee = existing.isMelee or candidate.isMelee
    existing.slotOptions = mergeSlotOptions(existing.slotOptions, candidate.slotOptions)

    if candidate.fromInventory and candidate.condition ~= nil then
        existing.condition = candidate.condition
    elseif existing.condition == nil then
        existing.condition = candidate.condition
    end
end

local function addLoadoutCandidates(map, npcData)
    local loadout = type(npcData and npcData.loadout) == "table" and npcData.loadout or {}

    registerCandidate(map, buildCandidate(loadout.rangedWeapon, npcData, 720, "ranged"))
    registerCandidate(map, buildCandidate(loadout.meleeWeapon, npcData, 700, "melee"))
    registerCandidate(map, buildCandidate(loadout.bag, npcData, 680, "bag"))
end

local function scanInventoryCandidates(map, container, npcData, depth)
    if not container or depth > (EquipmentVisuals.Constants.MAX_INVENTORY_SCAN_DEPTH or 3) then
        return
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return
    end

    local loadout = type(npcData and npcData.loadout) == "table" and npcData.loadout or {}

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local itemType = Helpers.getItemFullType(item)
        if itemType and itemType ~= "" then
            local score = 200
            local role = nil

            if loadout.rangedWeapon == itemType then
                score = score + 360
                role = "ranged"
            elseif loadout.meleeWeapon == itemType then
                score = score + 340
                role = "melee"
            elseif loadout.bag == itemType then
                score = score + 320
                role = "bag"
            end

            local candidate = buildCandidate(itemType, npcData, score, role, item)
            if candidate and (candidate.bagScore > 0 or candidate.isWeapon or #candidate.slotOptions > 0) then
                registerCandidate(map, candidate)
            end
        end

        if item and item.getInventory then
            local nested = item:getInventory()
            if nested then
                scanInventoryCandidates(map, nested, npcData, depth + 1)
            end
        end
    end
end

local function collectOrderedCandidates(map)
    local candidates = {}
    for _, candidate in pairs(map or {}) do
        candidates[#candidates + 1] = candidate
    end

    table.sort(candidates, function(left, right)
        local leftRank = (left.sourceScore or 0) + (left.bagScore or 0)
        local rightRank = (right.sourceScore or 0) + (right.bagScore or 0)
        if leftRank ~= rightRank then
            return leftRank > rightRank
        end
        if left.isWeapon ~= right.isWeapon then
            return left.isWeapon
        end
        return tostring(left.itemType) < tostring(right.itemType)
    end)

    return candidates
end

local function chooseBagCandidate(candidates)
    local best = nil
    local bestScore = nil

    for i = 1, #candidates do
        local candidate = candidates[i]
        if candidate.bagScore and candidate.bagScore > 0 then
            local score = candidate.bagScore + (candidate.sourceScore or 0)
            if not bestScore or score > bestScore then
                best = candidate
                bestScore = score
            end
        end
    end

    return best
end

local function chooseWeaponCandidate(candidates, wantRanged)
    local best = nil
    local bestScore = nil

    for i = 1, #candidates do
        local candidate = candidates[i]
        local matches = wantRanged and candidate.isRanged or (not wantRanged and candidate.isMelee)
        if matches then
            local score = candidate.sourceScore or 0
            if wantRanged then
                score = score + (candidate.displayType == "rifle" and 120 or 100)
            elseif candidate.displayType == "spear" then
                score = score + 120
            elseif candidate.displayType == "twohanded" then
                score = score + 100
            elseif candidate.displayType == "onehanded" then
                score = score + 80
            else
                score = score + 60
            end

            if not bestScore or score > bestScore then
                best = candidate
                bestScore = score
            end
        end
    end

    return best
end

local function getDisplayLoadoutSignature(npcData)
    local loadout = type(npcData and npcData.loadout) == "table" and npcData.loadout or {}
    return table.concat({
        tostring(loadout.rangedWeapon or ""),
        tostring(loadout.rangedCondition or ""),
        tostring(loadout.rangedAmmoType or ""),
        tostring(loadout.ammoCount or ""),
        tostring(loadout.meleeWeapon or ""),
        tostring(loadout.meleeCondition or ""),
        tostring(loadout.bag or ""),
        tostring(npcData and npcData.displayBag or ""),
    }, "|")
end

function Internal.resolveDisplayState(zombie, npcData, options)
    options = options or {}

    if not zombie or not npcData then
        return {
            bagItem = EquipmentVisuals.GetDisplayBag(npcData),
            rangedWeapon = npcData and npcData.loadout and npcData.loadout.rangedWeapon or nil,
            meleeWeapon = npcData and npcData.loadout and npcData.loadout.meleeWeapon or nil,
            conditions = {},
            candidatesByType = {},
            extraCandidates = {},
            inventorySignature = "",
        }
    end

    local modData = zombie:getModData()
    local now = Helpers.getNowMillis()
    local interval = EquipmentVisuals.Constants.DYNAMIC_SCAN_INTERVAL_MS or 750
    local loadoutSignature = getDisplayLoadoutSignature(npcData)

    if not options.force
        and modData
        and modData.DTNPCDynamicDisplayState
        and modData.DTNPCDynamicDisplayLoadoutSignature == loadoutSignature
        and (now - (tonumber(modData.DTNPCDynamicDisplayScanAt) or 0)) < interval then
        return modData.DTNPCDynamicDisplayState
    end

    local candidatesByType = {}
    addLoadoutCandidates(candidatesByType, npcData)

    local inventory = zombie.getInventory and zombie:getInventory() or nil
    if inventory then
        scanInventoryCandidates(candidatesByType, inventory, npcData, 0)
    end

    local orderedCandidates = collectOrderedCandidates(candidatesByType)
    local bagCandidate = chooseBagCandidate(orderedCandidates)
    local rangedCandidate = chooseWeaponCandidate(orderedCandidates, true)
    local meleeCandidate = chooseWeaponCandidate(orderedCandidates, false)
    local usedTypes = {}

    if bagCandidate then
        usedTypes[bagCandidate.itemType] = true
    end
    if rangedCandidate then
        usedTypes[rangedCandidate.itemType] = true
    end
    if meleeCandidate then
        usedTypes[meleeCandidate.itemType] = true
    end

    local extraCandidates = {}
    local signatureParts = {}
    for i = 1, #orderedCandidates do
        local candidate = orderedCandidates[i]
        if candidate and candidate.itemType then
            signatureParts[#signatureParts + 1] = table.concat({
                candidate.itemType,
                tostring(candidate.condition or ""),
                tostring(candidate.attachmentType or ""),
                tostring(candidate.equipSlot or ""),
            }, "#")

            if not usedTypes[candidate.itemType] and #candidate.slotOptions > 0 then
                local attachPriority = candidate.sourceScore or 0
                if candidate.isWeapon then
                    attachPriority = attachPriority + 280
                else
                    attachPriority = attachPriority + 120
                end
                if candidate.displayType == "spear" then
                    attachPriority = attachPriority + 80
                elseif candidate.displayType == "rifle" or candidate.displayType == "handgun" then
                    attachPriority = attachPriority + 60
                end

                candidate.attachPriority = attachPriority
                extraCandidates[#extraCandidates + 1] = candidate
            end
        end
    end

    table.sort(extraCandidates, function(left, right)
        if left.attachPriority ~= right.attachPriority then
            return left.attachPriority > right.attachPriority
        end
        return tostring(left.itemType) < tostring(right.itemType)
    end)

    local state = {
        bagItem = bagCandidate and bagCandidate.itemType or EquipmentVisuals.GetDisplayBag(npcData),
        rangedWeapon = rangedCandidate and rangedCandidate.itemType or nil,
        meleeWeapon = meleeCandidate and meleeCandidate.itemType or nil,
        conditions = {},
        candidatesByType = candidatesByType,
        extraCandidates = extraCandidates,
        inventorySignature = table.concat(signatureParts, "|"),
    }

    if bagCandidate and bagCandidate.condition ~= nil then
        state.conditions[bagCandidate.itemType] = bagCandidate.condition
    end
    if rangedCandidate and rangedCandidate.condition ~= nil then
        state.conditions[rangedCandidate.itemType] = rangedCandidate.condition
    end
    if meleeCandidate and meleeCandidate.condition ~= nil then
        state.conditions[meleeCandidate.itemType] = meleeCandidate.condition
    end

    if modData then
        modData.DTNPCDynamicDisplayState = state
        modData.DTNPCDynamicDisplayScanAt = now
        modData.DTNPCDynamicDisplayLoadoutSignature = loadoutSignature
    end

    return state
end

function Internal.chooseRequestedProtectWeapon(npcData, resolvedState, hasRanged, hasMelee)
    if not DTNPCProtect or not DTNPCProtect.GetRequestedProtectState then
        return nil
    end

    local requested = DTNPCProtect.GetRequestedProtectState(npcData)
    local rangedWeapon = resolvedState and resolvedState.rangedWeapon or nil
    local meleeWeapon = resolvedState and resolvedState.meleeWeapon or nil

    if requested == "ProtectRanged" then
        if hasRanged then
            return rangedWeapon
        end
        if hasMelee then
            return meleeWeapon
        end
    elseif requested == "ProtectMelee" then
        if hasMelee then
            return meleeWeapon
        end
        if hasRanged then
            return rangedWeapon
        end
    elseif requested == "ProtectAuto" then
        local resolved = DTNPCProtect and DTNPCProtect.GetAutoProtectState and DTNPCProtect.GetAutoProtectState(npcData) or nil
        if resolved == "ProtectMelee" and hasMelee then
            return meleeWeapon
        end
        if resolved == "ProtectRanged" and hasRanged then
            return rangedWeapon
        end
        if hasRanged then
            return rangedWeapon
        end
        if hasMelee then
            return meleeWeapon
        end
    end

    return nil
end

function Internal.chooseActiveWeapon(npcData, resolvedState)
    if not npcData then
        return nil
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local rangedWeapon = resolvedState and resolvedState.rangedWeapon or nil
    local meleeWeapon = resolvedState and resolvedState.meleeWeapon or nil
    local hasRanged = rangedWeapon ~= nil and rangedWeapon ~= ""
    local hasMelee = meleeWeapon ~= nil and meleeWeapon ~= ""
    local state = npcData.autoProtectActiveState or npcData.state or ""

    if state == "Attack" or state == "AttackRange" then
        local resolved = DTNPCProtect
            and DTNPCProtect.ResolveHostileCombatState
            and DTNPCProtect.ResolveHostileCombatState(npcData, state, npcData.combatTargetDistance)
            or state
        if resolved == "AttackRange" then
            if hasRanged then
                return rangedWeapon
            end
            if hasMelee then
                return meleeWeapon
            end
        else
            if hasMelee then
                return meleeWeapon
            end
            if hasRanged then
                return rangedWeapon
            end
        end
    end

    if state == "TradingDefenseRanged" or state == "ProtectRanged" then
        if hasRanged then
            return rangedWeapon
        end
        if hasMelee then
            return meleeWeapon
        end
    end

    if state == "TradingDefenseMelee" or state == "ProtectMelee" then
        if hasMelee then
            return meleeWeapon
        end
        if hasRanged then
            return rangedWeapon
        end
    end

    return Internal.chooseRequestedProtectWeapon(npcData, resolvedState, hasRanged, hasMelee)
end

function Internal.buildAttachmentMap(npcData, resolvedState, activeWeapon)
    local attachments = {}
    local usedSlots = {}
    local queued = {}
    local candidatesByType = resolvedState and resolvedState.candidatesByType or {}

    local function queueCandidate(itemType, priority)
        if not itemType or itemType == "" or itemType == activeWeapon then
            return
        end

        local candidate = candidatesByType[itemType]
        if not candidate or #candidate.slotOptions <= 0 then
            return
        end

        queued[#queued + 1] = {
            itemType = candidate.itemType,
            condition = candidate.condition,
            slotOptions = candidate.slotOptions,
            priority = priority or candidate.attachPriority or 0,
        }
    end

    if resolvedState then
        queueCandidate(resolvedState.rangedWeapon, 1000)
        queueCandidate(resolvedState.meleeWeapon, 950)

        for i = 1, #(resolvedState.extraCandidates or {}) do
            local candidate = resolvedState.extraCandidates[i]
            queueCandidate(candidate.itemType, candidate.attachPriority or 0)
        end
    end

    table.sort(queued, function(left, right)
        if left.priority ~= right.priority then
            return left.priority > right.priority
        end
        return tostring(left.itemType) < tostring(right.itemType)
    end)

    for i = 1, #queued do
        local candidate = queued[i]
        for slotIndex = 1, #candidate.slotOptions do
            local slot = candidate.slotOptions[slotIndex]
            if slot and not usedSlots[slot] then
                usedSlots[slot] = true
                attachments[slot] = {
                    itemType = candidate.itemType,
                    condition = candidate.condition,
                }
                break
            end
        end
    end

    return attachments
end

function Internal.buildSignature(activeWeapon, primaryType, attachments, bagItem)
    local parts = {
        "active=" .. tostring(activeWeapon or ""),
        "type=" .. tostring(primaryType or ""),
        "bag=" .. tostring(bagItem or ""),
    }

    local slots = {}
    for slot in pairs(attachments) do
        slots[#slots + 1] = slot
    end
    table.sort(slots, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for i = 1, #slots do
        local slot = slots[i]
        local entry = attachments[slot]
        local itemType = type(entry) == "table" and entry.itemType or entry
        local condition = type(entry) == "table" and entry.condition or nil
        parts[#parts + 1] = tostring(slot) .. "=" .. tostring(itemType or "") .. ":" .. tostring(condition or "")
    end

    return table.concat(parts, "|")
end
