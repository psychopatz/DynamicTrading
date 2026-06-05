-- ==============================================================================
-- DTNPC_ContextMenu_Providers.lua
-- Provider registry for production NPC context menu extensions.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}
DTNPCContextMenu.Internal = DTNPCContextMenu.Internal or {}
DTNPCContextMenu.Providers = DTNPCContextMenu.Providers or {}

local Internal = DTNPCContextMenu.Internal
local Providers = DTNPCContextMenu.Providers

if Internal.ProvidersLoaded then
    return
end

Internal.ProvidersLoaded = true

function DTNPCContextMenu.RegisterProvider(provider)
    if type(provider) ~= "table" or not provider.id or type(provider.addOptions) ~= "function" then
        return false
    end

    Providers[tostring(provider.id)] = provider
    return true
end

local function getOrderedProviders()
    local ordered = {}
    for _, provider in pairs(Providers) do
        ordered[#ordered + 1] = provider
    end

    table.sort(ordered, function(left, right)
        local leftPriority = tonumber(left and left.priority) or 0
        local rightPriority = tonumber(right and right.priority) or 0
        if leftPriority == rightPriority then
            return tostring(left and left.id or "") < tostring(right and right.id or "")
        end
        return leftPriority > rightPriority
    end)

    return ordered
end

function DTNPCContextMenu.AddProviderOptions(context, ui, npc, player, npcData)
    local ordered = getOrderedProviders()
    for index = 1, #ordered do
        local provider = ordered[index]
        if provider and provider.addOptions then
            provider.addOptions(context, ui, npc, player, npcData)
        end
    end
end
