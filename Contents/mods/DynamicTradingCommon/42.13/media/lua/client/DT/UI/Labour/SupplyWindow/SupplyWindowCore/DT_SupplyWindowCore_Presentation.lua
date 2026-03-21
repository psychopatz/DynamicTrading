DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function Internal.getOutputTabLabel(worker)
    if not worker or not worker.jobType then
        return "Merchandise"
    end

    local config = Internal.Config or {}
    local jobTypes = config.JobTypes or {}
    local normalizedJob = config.NormalizeJobType and config.NormalizeJobType(worker and worker.jobType) or tostring(worker and worker.jobType or "")

    if normalizedJob == jobTypes.Farm then
        return "Yield"
    end
    if normalizedJob == jobTypes.Fish then
        return "Catch"
    end
    if normalizedJob == jobTypes.Scavenge then
        return "Haul"
    end

    return "Merchandise"
end

function Internal.getActiveWorkerTabLabel(window)
    local activeTab = window and window.activeTab or Internal.Tabs.Provisions
    if activeTab == Internal.Tabs.Equipment then
        return "Equipment"
    end
    if activeTab == Internal.Tabs.Output then
        return Internal.getOutputTabLabel(window and window.workerData)
    end
    return "Provisions"
end

function Internal.getRequiredToolSummary(worker)
    local config = Internal.Config or {}
    local profile = config.GetJobProfile and config.GetJobProfile(worker and worker.jobType) or {}
    local requiredTags = profile and profile.requiredToolTags or {}
    if not requiredTags or #requiredTags <= 0 then
        return "Any labour tool"
    end
    return table.concat(requiredTags, ", ")
end

function Internal.getWorkerSupplyTotals(entries)
    local totals = {
        count = 0,
        calories = 0,
        hydration = 0,
    }

    for _, entry in ipairs(entries or {}) do
        totals.count = totals.count + 1
        totals.calories = totals.calories + math.max(0, tonumber(entry.calories) or 0)
        totals.hydration = totals.hydration + math.max(0, tonumber(entry.hydration) or 0)
    end

    return totals
end

function Internal.getWorkerTabSummary(window, entries)
    local activeTab = window and window.activeTab or Internal.Tabs.Provisions

    if activeTab == Internal.Tabs.Equipment then
        return tostring(#(entries or {})) .. " equipped"
    end

    if activeTab == Internal.Tabs.Output then
        local stacks = 0
        local totalQty = 0
        for _, entry in ipairs(entries or {}) do
            stacks = stacks + 1
            totalQty = totalQty + math.max(1, tonumber(entry.qty) or 1)
        end
        return tostring(stacks) .. " stacks | " .. tostring(totalQty) .. " total"
    end

    local totals = Internal.getWorkerSupplyTotals(entries)
    return tostring(totals.count) .. " entries | "
        .. string.format("%.0f cal", totals.calories) .. " | "
        .. string.format("%.0f hyd", totals.hydration)
end

function Internal.shouldShowPlayerEntry(entry, activeTab)
    if not entry then
        return false
    end

    if activeTab == Internal.Tabs.Equipment then
        return true
    end

    if activeTab == Internal.Tabs.Output then
        return false
    end

    return entry.canDeposit == true
end

function Internal.shouldShowWorkerEntry(entry, activeTab)
    if not entry then
        return false
    end

    if activeTab == Internal.Tabs.Equipment or activeTab == Internal.Tabs.Output then
        return true
    end

    return (tonumber(entry.calories) or 0) > 0 or (tonumber(entry.hydration) or 0) > 0
end

function Internal.getPlayerEntryPresentation(entry, activeTab, worker)
    if activeTab == Internal.Tabs.Equipment then
        if entry.canAssignTool then
            return {
                statText = Internal.getRequiredToolSummary(worker),
                badgeText = "Tool",
                dimmed = false,
            }
        end
        return {
            statText = "Not a labour tool",
            badgeText = "Preview",
            dimmed = true,
        }
    end

    if activeTab == Internal.Tabs.Output then
        return {
            statText = "Worker storage tab",
            badgeText = "Read Only",
            dimmed = true,
        }
    end

    if entry.canDeposit then
        return {
            statText = string.format("+%.0f cal | +%.0f hyd", entry.calories or 0, entry.hydration or 0),
            badgeText = "Ready",
            dimmed = false,
        }
    end

    return {
        statText = "No calories or hydration",
        badgeText = "Preview",
        dimmed = true,
    }
end

function Internal.getWorkerEntryPresentation(entry, activeTab)
    if activeTab == Internal.Tabs.Equipment then
        local tags = entry.tags or {}
        local tagText = (#tags > 0) and table.concat(tags, ", ") or "Assigned labour tool"
        return {
            statText = tagText,
            badgeText = "",
        }
    end

    if activeTab == Internal.Tabs.Output then
        return {
            statText = "Qty " .. tostring(entry.qty or 1),
            badgeText = "",
        }
    end

    return {
        statText = string.format("%.0f cal left | %.0f hyd left", entry.calories or 0, entry.hydration or 0),
        badgeText = "",
    }
end

