-- =============================================================================
-- FILE: media/lua/server/Misc/DT_BuildingScanner.lua
-- PURPOSE: Server-side building scanner with persistence
-- VERSION: 2.0 - Enhanced with County Support
-- =============================================================================

-- Ensure DTM global exists
DTM = DTM or {}

require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"

-- =============================================================================
-- SERVER STARTUP HANDLER
-- =============================================================================

local pendingBootstrap = false
local bootstrapRetryTicks = 0

local function attemptGeolocatorBootstrap(reason)
    DynamicTrading.Log("DTCommons", "Debug", "Scanner", "Initializing geolocator database (" .. tostring(reason or "startup") .. ")...")

    if DTM.EnsureBuildingsLoaded and DTM.EnsureBuildingsLoaded(true, true) then
        pendingBootstrap = false
        bootstrapRetryTicks = 0
        DynamicTrading.Log("DTCommons", "Debug", "Scanner", "Spatial database ready with " .. tostring(#(DTM.Buildings or {})) .. " cached locations.")
        return true
    end

    pendingBootstrap = true
    return false
end

local function onServerStart()
    attemptGeolocatorBootstrap("server-start")
end

Events.OnServerStarted.Add(onServerStart)

local function onServerTick()
    if not pendingBootstrap then
        return
    end

    bootstrapRetryTicks = bootstrapRetryTicks + 1
    if bootstrapRetryTicks < 300 then
        return
    end

    bootstrapRetryTicks = 0
    attemptGeolocatorBootstrap("deferred-retry")
end

Events.OnTick.Add(onServerTick)

-- =============================================================================
-- ADMIN COMMANDS (Optional)
-- =============================================================================

-- Command to rescan all buildings (admin only)
local function onRescanBuildings(module, command, player, args)
    if (module == "dtm" or module == "geolocator") and command == "rescan" then
        if player:getAccessLevel() == "admin" or player:getAccessLevel() == "moderator" then
            DynamicTrading.Log("DTCommons", "Debug", "Scanner", "Admin " .. player:getUsername() .. " initiated building rescan.")

            if not DTM.CanScanBuildings or not DTM.CanScanBuildings() then
                player:Say("[DTM] Rescan failed. World building data is not ready yet.")
                return
            end

            local scanned = DTM.ScanForBuildings and DTM.ScanForBuildings() or nil
            if DTM.ReplaceBuildings and DTM.ReplaceBuildings(scanned, true) then
                player:Say("[DTM] Rescan complete. Found " .. #DTM.Buildings .. " buildings.")
            else
                player:Say("[DTM] Rescan failed. Scan returned no valid locations.")
            end
        else
            player:Say("[DTM] You need admin privileges to use this command.")
        end
    end
end

Events.OnClientCommand.Add(onRescanBuildings)
