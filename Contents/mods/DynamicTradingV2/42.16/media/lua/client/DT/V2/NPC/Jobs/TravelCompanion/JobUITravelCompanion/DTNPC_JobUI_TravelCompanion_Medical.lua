-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Medical.lua
-- Companion medical supply and texture helpers.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}
local Constants = CompanionUI.Constants or {}
local State = CompanionUI.State or {}

CompanionUI.Modules = modules
CompanionUI.Constants = Constants
CompanionUI.State = State

if modules.Medical then
    return
end

modules.Medical = true

function CompanionUI.IsValidTexture(texture)
    return texture ~= nil and texture ~= false
end

function CompanionUI.TryTexture(textureName)
    if not textureName or textureName == "" or not getTexture then
        return nil
    end

    local texture = getTexture(textureName)
    return CompanionUI.IsValidTexture(texture) and texture or nil
end

function CompanionUI.GetTextureForFullType(fullType)
    fullType = CompanionUI.NormalizeText(fullType)
    if not fullType then
        return nil
    end

    local cache = State.medicalTextureCache or {}
    State.medicalTextureCache = cache
    if cache[fullType] ~= nil then
        return cache[fullType] ~= false and cache[fullType] or nil
    end

    local texture = nil
    if DC_SupplyWindow and DC_SupplyWindow.Internal and DC_SupplyWindow.Internal.getTextureForFullType then
        texture = DC_SupplyWindow.Internal.getTextureForFullType(fullType)
    end

    local script = getScriptManager and getScriptManager():getItem(fullType) or nil
    if not CompanionUI.IsValidTexture(texture) and script and script.getIcon then
        local iconName = script:getIcon()
        if iconName and iconName ~= "" then
            texture = CompanionUI.TryTexture("Item_" .. tostring(iconName))
                or CompanionUI.TryTexture("media/textures/Item_" .. tostring(iconName) .. ".png")
        end
    end

    if not CompanionUI.IsValidTexture(texture) and InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item and item.getTex then
            texture = item:getTex()
        end
    end

    cache[fullType] = CompanionUI.IsValidTexture(texture) and texture or false
    return cache[fullType] ~= false and cache[fullType] or nil
end

function CompanionUI.GetDisplayNameForFullType(fullType)
    local script = fullType and getScriptManager and getScriptManager():getItem(fullType) or nil
    if script and script.getDisplayName then
        local name = CompanionUI.NormalizeText(script:getDisplayName())
        if name then
            return name
        end
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem and fullType then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item and item.getDisplayName then
            local name = CompanionUI.NormalizeText(item:getDisplayName())
            if name then
                return name
            end
        end
    end

    return tostring(fullType or CompanionUI.T("DTNPC_UI_UseMedicalSupply", nil, "Medical Supply"))
end

function CompanionUI.AddMedicalSupplySummary(supplies, byFullType, entry)
    if type(entry) ~= "table" then
        return
    end

    local fullType = CompanionUI.NormalizeText(entry.fullType)
    if not fullType then
        return
    end

    local useKind = tostring(entry.medicalUse or "")
    local provisionType = tostring(entry.provisionType or "")
    local units = math.max(0, math.floor((tonumber(entry.treatmentUnitsRemaining) or 0) + 0.5))
    local knownMedical = Constants.MEDICAL_PROVISION_FULL_TYPES[fullType] == true
    if units <= 0 or (provisionType ~= "medical" and not knownMedical) or (useKind ~= "" and useKind ~= "bandage") then
        return
    end

    local supply = byFullType[fullType]
    if not supply then
        supply = {
            fullType = fullType,
            displayName = CompanionUI.NormalizeText(entry.displayName) or CompanionUI.GetDisplayNameForFullType(fullType),
            units = 0,
            texture = CompanionUI.GetTextureForFullType(fullType),
        }
        byFullType[fullType] = supply
        supplies[#supplies + 1] = supply
    end
    supply.units = supply.units + units
end

function CompanionUI.CollectMedicalSupplies(worker)
    local supplies = {}
    local byFullType = {}

    for _, entry in ipairs(worker and worker.companionMedicalSupplies or {}) do
        CompanionUI.AddMedicalSupplySummary(supplies, byFullType, entry)
    end

    for _, entry in ipairs(worker and worker.nutritionLedger or {}) do
        CompanionUI.AddMedicalSupplySummary(supplies, byFullType, entry)
    end

    table.sort(supplies, function(left, right)
        return tostring(left.displayName or left.fullType or "") < tostring(right.displayName or right.fullType or "")
    end)

    local total = 0
    for _, supply in ipairs(supplies) do
        total = total + math.max(0, tonumber(supply.units) or 0)
    end

    return supplies, total
end

function CompanionUI.GetPatchUpLabel(worker)
    if not worker then
        return CompanionUI.T("DTNPC_UI_PatchUp", nil, "Patch Up"), 1
    end

    local _, total = CompanionUI.CollectMedicalSupplies(worker)
    if total <= 0 then
        return CompanionUI.T("DTNPC_UI_PatchUpNoMedicine", nil, "Patch Up (No medicine)"), total
    end
    return CompanionUI.T("DTNPC_UI_PatchUpMedicalCount", {
        count = tostring(total),
    }, "Patch Up ({count} medical)"), total
end
