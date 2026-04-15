if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

local function getEconomyCommon()
    return DynamicTrading and DynamicTrading.Economy and DynamicTrading.Economy.Common or nil
end

function DT_TradingItemUtils.Internal.normalizeFluidTypeID(fluidType)
    local common = getEconomyCommon()
    if common and common.NormalizeFluidType then
        return common.NormalizeFluidType(fluidType)
    end

    local value = tostring(fluidType or "")
    local colonPos = string.find(value, ":", 1, true)
    if colonPos then
        value = string.sub(value, 1, colonPos - 1)
    end
    if value == "" or string.lower(value) == "true" then
        return nil
    end
    return value
end

--- Internal helper to get the strict Fluid ID string (e.g. "Base.Water") in B42.
function DT_TradingItemUtils.Internal.getFluidTypeID(fluidContainer)
    if not fluidContainer then return nil end
    local fType = nil

    -- Try B42 Primary Fluid logic
    if fluidContainer.getPrimaryFluid then
        local pFluid = fluidContainer:getPrimaryFluid()
        if pFluid then
            if pFluid.getFluidType then
                fType = pFluid:getFluidType()
            end
            if (not fType or fType == "") and pFluid.getFluid then
                local fluidObj = pFluid:getFluid()
                if fluidObj and fluidObj.getName then
                    fType = fluidObj:getName()
                end
            end
        end
    end

    -- Fallback to legacy/direct method
    if (not fType or fType == "") and fluidContainer.getFluidType then
        fType = fluidContainer:getFluidType()
    end

    return DT_TradingItemUtils.Internal.normalizeFluidTypeID(fType)
end

function DT_TradingItemUtils.Internal.getFluidData(fluidType)
    local common = getEconomyCommon()
    if common and common.GetFluidData then
        return common.GetFluidData(fluidType)
    end

    if not fluidType or not DynamicTrading.Fluids then return nil end
    local normalized = DT_TradingItemUtils.Internal.normalizeFluidTypeID(fluidType)
    if not normalized then return nil end
    return DynamicTrading.Fluids[normalized] or DynamicTrading.Fluids["Base." .. normalized]
end

--- Internal helper to get a readable fluid name in B42.
function DT_TradingItemUtils.Internal.getFluidName(fluidContainer, typeStr)
    local fType = DT_TradingItemUtils.Internal.normalizeFluidTypeID(typeStr or DT_TradingItemUtils.Internal.getFluidTypeID(fluidContainer))
    local fluidData = DT_TradingItemUtils.Internal.getFluidData(fType)

    if not fType or fType == "" then
        if fluidContainer and fluidContainer.getPrimaryFluid then
            local pf = fluidContainer:getPrimaryFluid()
            if pf and pf.getDisplayName then
                local ok, displayName = pcall(function() return pf:getDisplayName() end)
                if ok and displayName and displayName ~= "" then
                    return displayName
                end
            end
        end
        return ""
    end

    if type(fType) == "string" then
        if fluidData and fluidData.displayName and fluidData.displayName ~= "" then
            return fluidData.displayName
        end

        local scriptManager = getScriptManager and getScriptManager() or nil
        if scriptManager and scriptManager.getFluid then
            local ok, scriptFluid = pcall(function() return scriptManager:getFluid(fType) end)
            if ok and not scriptFluid and string.sub(fType, 1, 5) == "Base." then
                ok, scriptFluid = pcall(function() return scriptManager:getFluid(string.sub(fType, 6)) end)
            elseif ok and not scriptFluid then
                ok, scriptFluid = pcall(function() return scriptManager:getFluid("Base." .. fType) end)
            end

            if ok and scriptFluid then
                if scriptFluid.getDisplayName then
                    local displayOk, displayName = pcall(function() return scriptFluid:getDisplayName() end)
                    if displayOk and displayName and displayName ~= "" then
                        return displayName
                    end
                end
                if scriptFluid.getName then
                    local nameOk, fluidName = pcall(function() return scriptFluid:getName() end)
                    if nameOk and fluidName and fluidName ~= "" then
                        return fluidName
                    end
                end
            end
        end

        local shortName = fType:gsub("Base%.", "")
        local trans = getText("IGUI_Fluid_" .. shortName)
        if trans and trans ~= ("IGUI_Fluid_" .. shortName) then
            return trans
        end
        return shortName
    end

    if fType.getDisplayName then return fType:getDisplayName() end
    if fType.getName then return fType:getName() end

    return tostring(fType)
end

--- Resolves a category override from fluid contents when available.
function DT_TradingItemUtils.Internal.getFluidCategory(fluidType)
    local fData = DT_TradingItemUtils.Internal.getFluidData(fluidType)
    if fData and fData.tags and fData.tags[1] then
        return fData.tags[1]
    end

    return nil
end

function DT_TradingItemUtils.Internal.getFluidTags(fluidType)
    local fData = DT_TradingItemUtils.Internal.getFluidData(fluidType)
    return fData and fData.tags or nil
end
