DTCommon = DTCommon or {}
DTCommon.ModActivationPolicy = DTCommon.ModActivationPolicy or {}

local Policy = DTCommon.ModActivationPolicy

Policy.CONFLICTS = {
    DTAbstract = {
        "DTHoomans",
        "ProjectHoomans",
    },
    DTHoomans = {
        "DTAbstract",
    },
}

local function activatedMods()
    if type(getActivatedMods) ~= "function" then
        return nil
    end
    local ok, mods = pcall(getActivatedMods)
    return ok and mods or nil
end

function Policy.IsActive(modID)
    modID = tostring(modID or "")
    if modID == "" then return false end
    local mods = activatedMods()
    if not mods then return false end

    if type(mods.contains) == "function" then
        local ok, active = pcall(mods.contains, mods, modID)
        if ok then return active == true end
    end

    if type(mods.size) == "function"
        and type(mods.get) == "function"
    then
        local okSize, size = pcall(mods.size, mods)
        if okSize then
            for index = 0, (tonumber(size) or 0) - 1 do
                local okGet, value = pcall(mods.get, mods, index)
                if okGet and tostring(value) == modID then
                    return true
                end
            end
        end
    end

    if type(mods) == "table" then
        for key, value in pairs(mods) do
            if tostring(key) == modID and value == true then
                return true
            end
            if tostring(value) == modID then return true end
        end
    end
    return false
end

function Policy.Check(modID)
    modID = tostring(modID or "")
    for _, conflictID in ipairs(Policy.CONFLICTS[modID] or {}) do
        if Policy.IsActive(conflictID) then
            return false, "incompatible_mod_active:" .. conflictID,
                conflictID
        end
    end
    return true, "compatible"
end

function Policy.Apply(namespace, modID)
    namespace = type(namespace) == "table" and namespace or {}
    local enabled, reason, conflictID = Policy.Check(modID)
    namespace.Enabled = enabled == true
    namespace.ActivationReason = reason
    namespace.ConflictingModID = conflictID
    if not enabled then
        print("[DynamicTrading][WARN] mod_disabled id="
            .. tostring(modID)
            .. " reason=" .. tostring(reason))
    end
    return enabled, reason, conflictID
end

return Policy
