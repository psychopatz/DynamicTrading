-- =============================================================================
-- FILE: media/lua/server/Misc/DT_BuildingScanner.lua
-- PURPOSE: Server-side building scanner with persistence
-- VERSION: 2.0 - Enhanced with County Support
-- =============================================================================

-- Ensure DTM global exists
DTM = DTM or {}

-- =============================================================================
-- SERVER STARTUP HANDLER
-- =============================================================================

local function onServerStart()
    print("[DTM Server] Initializing building database...")
    
    -- Try to load from ModData or Scan if first time
    if DTM.LoadBuildings() then
        local modData = ModData.getOrCreate("DT_Buildings")
        
        -- If this is the server and we have no locations in ModData yet, save them
        if not modData.locations or #modData.locations == 0 then
            print("[DTM Server] No cached building data found. Performing initial scan...")
            DTM.Buildings = DTM.ScanForBuildings()
            
            -- Save to ModData for persistence
            modData.locations = DTM.Buildings
            ModData.transmit("DT_Buildings")
            
            print("[DTM Server] Initial scan complete. Saved " .. #DTM.Buildings .. " buildings to ModData.")
        else
            print("[DTM Server] Loaded " .. #modData.locations .. " buildings from ModData cache.")
        end
    end
end

Events.OnServerStarted.Add(onServerStart)

-- =============================================================================
-- ADMIN COMMANDS (Optional)
-- =============================================================================

-- Command to rescan all buildings (admin only)
local function onRescanBuildings(module, command, player, args)
    if module == "dtm" and command == "rescan" then
        if player:getAccessLevel() == "admin" or player:getAccessLevel() == "moderator" then
            print("[DTM Server] Admin " .. player:getUsername() .. " initiated building rescan.")
            
            -- Perform new scan
            DTM.Buildings = DTM.ScanForBuildings()
            
            -- Rebuild lookup
            DTM.BuildingLookup = {}
            for _, b in ipairs(DTM.Buildings) do
                DTM.BuildingLookup[b.x .. "," .. b.y] = b
            end
            
            -- Save to ModData
            local modData = ModData.getOrCreate("DT_Buildings")
            modData.locations = DTM.Buildings
            ModData.transmit("DT_Buildings")
            
            player:Say("[DTM] Rescan complete. Found " .. #DTM.Buildings .. " buildings.")
        else
            player:Say("[DTM] You need admin privileges to use this command.")
        end
    end
end

Events.OnClientCommand.Add(onRescanBuildings)