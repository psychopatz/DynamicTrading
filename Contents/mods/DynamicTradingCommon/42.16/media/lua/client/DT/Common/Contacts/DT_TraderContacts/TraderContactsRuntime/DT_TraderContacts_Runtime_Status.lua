local Internal = DT_TraderContacts.Internal

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_TraderContacts.GetVisitArrivalTime(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local startedAt

    if not current or current.contactVisitActive ~= true then
        return nil
    end

    startedAt = tonumber(current.contactVisitStartedAt)
    if not startedAt then
        return nil
    end

    return startedAt + Internal.GetVisitWalkHours()
end

function DT_TraderContacts.GetArrivalCountdownText(contact)
    local arrivalTime = DT_TraderContacts.GetVisitArrivalTime(contact)
    local remainingHours

    if not arrivalTime then
        return nil
    end

    remainingHours = arrivalTime - Internal.GetWorldAgeHours()
    if remainingHours <= 0 then
        return nil
    end

    return Internal.FormatCountdownFromHours(remainingHours)
end

function DT_TraderContacts.GetStatusText(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local status
    local state
    local returnStatus
    local visitMode
    local visitActive
    local arrivalCountdown
    local deathFlavorText

    if not current then
        return T("DTCommon_Status_Unknown", nil, "Status unknown")
    end

    status = tostring(current.status or "Unknown")
    state = tostring(current.state or "")
    returnStatus = tostring(current.returnStatus or "")
    visitMode = tostring(current.contactVisitMode or "")
    visitActive = current.contactVisitActive == true
    arrivalCountdown = DT_TraderContacts.GetArrivalCountdownText(current)

    if status == "Dead" then
        deathFlavorText = tostring(current.deathFlavorText or "")
        if deathFlavorText ~= "" then
            return T("DTCommon_Status_DeceasedFlavor", { flavor = deathFlavorText }, "Status: Deceased (" .. deathFlavorText .. ")")
        end
        return T("DTCommon_Status_Deceased", nil, "Status: Deceased")
    end
    if status == "Unavailable" or current.missingFromRoster == true then
        return T("DTCommon_Status_Deceased", nil, "Status: Deceased")
    end

    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Resting" then
        return T("DTCommon_Status_ReturningHome", nil, "Status: Returning home")
    end
    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return T("DTCommon_Status_MovingTowardAreaEta", { eta = arrivalCountdown }, string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown))
        end
        return T("DTCommon_Status_MovingTowardArea", nil, "Status: Moving toward your area")
    end
    if (status == "Unknown" or status == "") and visitMode == "Departure" then
        return T("DTCommon_Status_ReturningHome", nil, "Status: Returning home")
    end

    if visitActive and arrivalCountdown and (status == "Away" or status == "Trading") then
        return T("DTCommon_Status_MovingTowardAreaEta", { eta = arrivalCountdown }, string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown))
    end

    if status == "Resting" then
        return T("DTCommon_Status_RestingAtBase", nil, "Resting at base")
    end
    if status == "Trading" and visitActive and (visitMode == "Follow" or state == "Follow") then
        return T("DTCommon_Status_CalledFollowing", nil, "Called in and following")
    end
    if status == "Trading" and visitActive and (visitMode == "Trading" or state == "Trading") then
        return T("DTCommon_Status_CalledTrading", nil, "Called in and trading")
    end
    if status == "Trading" then
        return T("DTCommon_Status_TradingInField", nil, "Trading in the field")
    end
    if status == "Away" and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return T("DTCommon_Status_MovingTowardAreaEta", { eta = arrivalCountdown }, "Moving toward your area (ETA " .. tostring(arrivalCountdown) .. ")")
        end
        return T("DTCommon_Status_MovingTowardArea", nil, "Moving toward your area")
    end
    if status == "Away" and returnStatus == "Trading" then
        return T("DTCommon_Status_EnRouteTrade", nil, "En route to trade")
    end
    if status == "Away" and returnStatus == "Resting" then
        return T("DTCommon_Status_ReturningHome", nil, "Returning home")
    end
    if state ~= "" then
        return T("DTCommon_Status_Value", { value = state }, "Status: " .. state)
    end

    return T("DTCommon_Status_Value", { value = status }, "Status: " .. status)
end
