-- Shared human-facing place-name resolver.
--
-- Conversation authority belongs to ProjectHoomans. This utility remains in
-- DTCommon because market/world-knowledge systems also need to turn canonical
-- place identifiers into player-facing names.

DTCommon = DTCommon or {}
DTCommon.PlacePresentation = DTCommon.PlacePresentation or {}

local PlacePresentation = DTCommon.PlacePresentation

PlacePresentation.Resolvers = PlacePresentation.Resolvers or {}

function PlacePresentation.RegisterResolver(id, resolverFn, priority)
    if not id or type(resolverFn) ~= "function" then return false end
    PlacePresentation.Resolvers[id] = {
        fn = resolverFn,
        priority = tonumber(priority) or 50,
    }
    return true
end

function PlacePresentation.UnregisterResolver(id)
    if not id then return false end
    PlacePresentation.Resolvers[id] = nil
    return true
end

function PlacePresentation.IsMachineIdentifier(id)
    if type(id) ~= "string" or id == "" then return true end
    if string.find(id, "^community_")
        or string.find(id, "^settlement_[%d_]+")
        or string.find(id, "^loc_[%d_]+")
        or string.find(id, "^actor:")
        or string.find(id, "^id_[%d_]+")
    then
        return true
    end
    return false
end

function PlacePresentation.Resolve(placeID, context)
    if not placeID or placeID == "" then return nil end
    local str = tostring(placeID)

    local list = {}
    for id, entry in pairs(PlacePresentation.Resolvers) do
        list[#list + 1] = {
            id = id,
            fn = entry.fn,
            priority = entry.priority,
        }
    end
    table.sort(list, function(left, right)
        return left.priority > right.priority
    end)

    for _, entry in ipairs(list) do
        local ok, name = pcall(entry.fn, str, context)
        if ok
            and type(name) == "string"
            and name ~= ""
            and name ~= str
            and not PlacePresentation.IsMachineIdentifier(name)
        then
            return name
        end
    end

    if context
        and context.worldKnowledge
        and type(context.worldKnowledge.candidates) == "table"
    then
        for _, candidate in ipairs(
            context.worldKnowledge.candidates
        ) do
            local payload = candidate.payload
            if payload and (
                payload.marketID == str
                or payload.scopeID == str
                or payload.communityID == str
            ) then
                if payload.marketName
                    and not PlacePresentation.IsMachineIdentifier(
                        payload.marketName
                    )
                then
                    return payload.marketName
                end
                if payload.name
                    and not PlacePresentation.IsMachineIdentifier(
                        payload.name
                    )
                then
                    return payload.name
                end
            end
        end
    end

    if DTCommon and type(DTCommon.T) == "function" then
        local key = "Place_" .. str
        local translated = DTCommon.T(key, nil)
        if translated
            and translated ~= ""
            and translated ~= key
        then
            return translated
        end
    end

    if PlacePresentation.IsMachineIdentifier(str) then
        return nil, "unpresentable_machine_id"
    end

    return str
end

return PlacePresentation
