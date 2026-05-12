local Internal = DT_TraderContacts.Internal

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
        return "Status unknown"
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
            return "Status: Deceased (" .. deathFlavorText .. ")"
        end
        return "Status: Deceased"
    end
    if status == "Unavailable" or current.missingFromRoster == true then
        return "Status: Deceased"
    end

    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Resting" then
        return "Status: Returning home"
    end
    if (status == "Unknown" or status == "") and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown)
        end
        return "Status: Moving toward your area"
    end
    if (status == "Unknown" or status == "") and visitMode == "Departure" then
        return "Status: Returning home"
    end

    if visitActive and arrivalCountdown and (status == "Away" or status == "Trading") then
        return string.format("Status: Moving toward your area (ETA %s)", arrivalCountdown)
    end

    if status == "Resting" then
        return "Resting at base"
    end
    if status == "Trading" and visitActive and (visitMode == "Follow" or state == "Follow") then
        return "Called in and following"
    end
    if status == "Trading" and visitActive and (visitMode == "Trading" or state == "Trading") then
        return "Called in and trading"
    end
    if status == "Trading" then
        return "Trading in the field"
    end
    if status == "Away" and visitActive and returnStatus == "Trading" then
        if arrivalCountdown then
            return string.format("Moving toward your area (ETA %s)", arrivalCountdown)
        end
        return "Moving toward your area"
    end
    if status == "Away" and returnStatus == "Trading" then
        return "En route to trade"
    end
    if status == "Away" and returnStatus == "Resting" then
        return "Returning home"
    end
    if state ~= "" then
        return "Status: " .. state
    end

    return "Status: " .. status
end
