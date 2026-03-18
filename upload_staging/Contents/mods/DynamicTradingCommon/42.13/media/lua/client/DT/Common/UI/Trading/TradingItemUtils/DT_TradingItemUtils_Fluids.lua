if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

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

    return fType
end

--- Internal helper to get a readable fluid name in B42.
function DT_TradingItemUtils.Internal.getFluidName(fluidContainer, typeStr)
    local fType = typeStr or DT_TradingItemUtils.Internal.getFluidTypeID(fluidContainer)

    if not fType or fType == "" then
        if fluidContainer and fluidContainer.getPrimaryFluid then
            local pf = fluidContainer:getPrimaryFluid()
            if pf and pf.getDisplayName then return pf:getDisplayName() end
        end
        return ""
    end

    if type(fType) == "string" then
        local scriptFluid = getScriptManager():getFluid(fType)
        if scriptFluid then
            return scriptFluid:getDisplayName()
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
    if not fluidType or not DynamicTrading.Fluids then return nil end

    local fTypeStr = tostring(fluidType)
    local fData = DynamicTrading.Fluids[fTypeStr] or DynamicTrading.Fluids["Base." .. fTypeStr]
    if fData and fData.tags and fData.tags[1] then
        return fData.tags[1]
    end

    return nil
end
