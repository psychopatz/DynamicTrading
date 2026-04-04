-- ==============================================================================
-- DTNPC_ClientSync_VanillaPatches.lua
-- Compatibility guards for vanilla client handlers that assume IsoPlayer callers.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}

local ClientSync = DTNPC_ClientSync or {}
DTNPC_ClientSync = ClientSync

if ClientSync.VanillaPatchesLoaded then
    return
end

ClientSync.VanillaPatchesLoaded = true

local function isIsoPlayer(character)
    return character ~= nil and instanceof ~= nil and instanceof(character, "IsoPlayer")
end

local function patchFishingHandler()
    if ClientSync.FishingHandlerPatched then
        return
    end

    local ok = pcall(require, "Fishing/FishingHandler")
    if not ok or not Fishing or not Fishing.Handler then
        return
    end

    if type(Fishing.Handler.handleFishing) == "function" and not ClientSync._originalFishingHandleFishing then
        ClientSync._originalFishingHandleFishing = Fishing.Handler.handleFishing
        Fishing.Handler.handleFishing = function(player, primaryHandItem)
            if not isIsoPlayer(player) then
                return
            end

            return ClientSync._originalFishingHandleFishing(player, primaryHandItem)
        end
    end

    if type(Fishing.Handler.onEquipPrimary) == "function"
        and Events
        and Events.OnEquipPrimary
        and not ClientSync._originalFishingOnEquipPrimary then
        ClientSync._originalFishingOnEquipPrimary = Fishing.Handler.onEquipPrimary
        Fishing.Handler.onEquipPrimary = function(player, inventoryItem)
            if not isIsoPlayer(player) then
                return
            end

            return ClientSync._originalFishingOnEquipPrimary(player, inventoryItem)
        end

        Events.OnEquipPrimary.Remove(ClientSync._originalFishingOnEquipPrimary)
        Events.OnEquipPrimary.Add(Fishing.Handler.onEquipPrimary)
    end

    ClientSync.FishingHandlerPatched = true
end

patchFishingHandler()
