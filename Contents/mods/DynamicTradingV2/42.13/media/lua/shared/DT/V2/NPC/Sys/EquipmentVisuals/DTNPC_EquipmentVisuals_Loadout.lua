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

function Internal.chooseRequestedProtectWeapon(npcData, hasRanged, hasMelee)
    if not DTNPCProtect or not DTNPCProtect.GetRequestedProtectState then
        return nil
    end

    local requested = DTNPCProtect.GetRequestedProtectState(npcData)
    if requested == "ProtectRanged" then
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
    elseif requested == "ProtectMelee" then
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
    elseif requested == "ProtectAuto" then
        local resolved = DTNPCProtect and DTNPCProtect.GetAutoProtectState and DTNPCProtect.GetAutoProtectState(npcData) or nil
        if resolved == "ProtectMelee" and hasMelee then
            return npcData.loadout.meleeWeapon
        end
        if resolved == "ProtectRanged" and hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasRanged then
            return npcData.loadout.rangedWeapon
        end
        if hasMelee then
            return npcData.loadout.meleeWeapon
        end
    end

    return nil
end

function Internal.chooseActiveWeapon(npcData)
    if not npcData then
        return nil
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local loadout = npcData.loadout or {}
    local hasRanged = DTNPCProtect and DTNPCProtect.HasUsableRangedLoadout and DTNPCProtect.HasUsableRangedLoadout(npcData) or false
    local hasMelee = DTNPCProtect and DTNPCProtect.HasUsableMeleeLoadout and DTNPCProtect.HasUsableMeleeLoadout(npcData) or false
    local state = npcData.autoProtectActiveState or npcData.state or ""

    if state == "Attack" or state == "AttackRange" then
        local resolved = DTNPCProtect
            and DTNPCProtect.ResolveHostileCombatState
            and DTNPCProtect.ResolveHostileCombatState(npcData, state, npcData.combatTargetDistance)
            or state
        if resolved == "AttackRange" then
            if hasRanged then
                return loadout.rangedWeapon
            end
            if hasMelee then
                return loadout.meleeWeapon
            end
        else
            if hasMelee then
                return loadout.meleeWeapon
            end
            if hasRanged then
                return loadout.rangedWeapon
            end
        end
    end

    if state == "TradingDefenseRanged" or state == "ProtectRanged" then
        if hasRanged then
            return loadout.rangedWeapon
        end
        if hasMelee then
            return loadout.meleeWeapon
        end
    end

    if state == "TradingDefenseMelee" or state == "ProtectMelee" then
        if hasMelee then
            return loadout.meleeWeapon
        end
        if hasRanged then
            return loadout.rangedWeapon
        end
    end

    return Internal.chooseRequestedProtectWeapon(npcData, hasRanged, hasMelee)
end

function Internal.buildAttachmentMap(npcData, activeWeapon)
    local attachments = {}
    local loadout = npcData and npcData.loadout or {}
    local allowRanged = DTNPCProtect and DTNPCProtect.HasUsableRangedLoadout and DTNPCProtect.HasUsableRangedLoadout(npcData) or false
    local allowMelee = DTNPCProtect and DTNPCProtect.HasUsableMeleeLoadout and DTNPCProtect.HasUsableMeleeLoadout(npcData) or false

    local function addWeapon(itemType)
        if not itemType or itemType == "" or itemType == activeWeapon then
            return
        end

        local item = Helpers.createDisplayItem(itemType, Helpers.getStoredWeaponCondition(npcData, itemType))
        local slot = Helpers.resolveAttachmentSlot(item)
        if slot and not attachments[slot] then
            attachments[slot] = itemType
        end
    end

    if allowRanged then
        addWeapon(loadout.rangedWeapon)
    end
    if allowMelee then
        addWeapon(loadout.meleeWeapon)
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
        parts[#parts + 1] = tostring(slot) .. "=" .. tostring(attachments[slot] or "")
    end

    return table.concat(parts, "|")
end
