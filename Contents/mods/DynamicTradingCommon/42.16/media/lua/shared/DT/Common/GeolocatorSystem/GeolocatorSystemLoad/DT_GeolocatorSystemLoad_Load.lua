return function(context)
    function DT_GeolocatorSystem.HasBuildingsLoaded()
        return type(DT_GeolocatorSystem.Buildings) == "table" and #DT_GeolocatorSystem.Buildings > 0
    end

    function DT_GeolocatorSystem.GetLoadState()
        return DT_GeolocatorSystem.LoadState
    end

    function DT_GeolocatorSystem.CanScanBuildings()
        local world = getWorld and getWorld() or nil
        local metaGrid = world and world:getMetaGrid() or nil
        if not metaGrid then
            return false
        end

        local buildings = metaGrid:getBuildings()
        return buildings ~= nil and buildings:size() > 0
    end

    function DT_GeolocatorSystem.PersistBuildings()
        if not DT_GeolocatorSystem.HasBuildingsLoaded or not DT_GeolocatorSystem.HasBuildingsLoaded() then
            return false
        end

        local modData = context.getBuildingModData()
        modData.locations = DT_GeolocatorSystem.Buildings
        modData.indexSchemaVersion = context.INDEX_SCHEMA_VERSION
        ModData.transmit(DT_GeolocatorSystem.MOD_DATA_KEY or "DT_Buildings")
        return true
    end

    function DT_GeolocatorSystem.ReplaceBuildings(buildings, persistToModData)
        if type(buildings) ~= "table" or #buildings == 0 then
            return false
        end

        context.setBuildings(buildings)
        if persistToModData then
            DT_GeolocatorSystem.PersistBuildings()
        end
        return true
    end

    function DT_GeolocatorSystem.EnsureBuildingsLoaded(allowScan, persistToModData)
        if DT_GeolocatorSystem.InitCache then
            DT_GeolocatorSystem.InitCache()
        end

        local loadState = DT_GeolocatorSystem.LoadState or {}
        if DT_GeolocatorSystem.HasBuildingsLoaded and DT_GeolocatorSystem.HasBuildingsLoaded() then
            if not context.hasAnyEntries(DT_GeolocatorSystem.BuildingLookup)
                or DT_GeolocatorSystem.IndexVersion ~= DT_GeolocatorSystem.BuildVersion then
                context.rebuildBuildingLookup()
            end
            loadState.status = "ready"
            loadState.lastBuildingCount = #(DT_GeolocatorSystem.Buildings or {})
            return true
        end

        if loadState.status == "loading" then
            return false
        end

        local startedAtMs = context.getClockMs()
        loadState.status = "loading"
        loadState.source = nil
        loadState.startedAtMs = startedAtMs

        local modData = context.getBuildingModData()
        if modData and type(modData.locations) == "table" and #modData.locations > 0 then
            context.setBuildings(modData.locations)
            loadState.status = "ready"
            loadState.source = "moddata"
            loadState.lastBuildingCount = #DT_GeolocatorSystem.Buildings
            if startedAtMs then
                loadState.lastDurationMs = math.max(0, (context.getClockMs() or startedAtMs) - startedAtMs)
            end
            DynamicTrading.Log("DTCommons", "Mapping", "Init", "Loaded " .. #DT_GeolocatorSystem.Buildings .. " buildings from ModData.")
            return true
        end

        if not allowScan then
            loadState.status = "idle"
            return false
        end

        if not DT_GeolocatorSystem.CanScanBuildings or not DT_GeolocatorSystem.CanScanBuildings() then
            loadState.status = "idle"
            DynamicTrading.Log("DTCommons", "Mapping", "Warn", "Building scan requested before world building data was ready.")
            return false
        end

        local scanned = DT_GeolocatorSystem.ScanForBuildings and DT_GeolocatorSystem.ScanForBuildings() or nil
        if type(scanned) ~= "table" or #scanned == 0 then
            loadState.status = "idle"
            DynamicTrading.Log("DTCommons", "Mapping", "Warn", "Building scan returned no results; cache remains uninitialized.")
            return false
        end

        context.setBuildings(scanned)
        loadState.status = "ready"
        loadState.source = "scan"
        loadState.lastBuildingCount = #DT_GeolocatorSystem.Buildings
        if startedAtMs then
            loadState.lastDurationMs = math.max(0, (context.getClockMs() or startedAtMs) - startedAtMs)
        end
        if persistToModData then
            DT_GeolocatorSystem.PersistBuildings()
        end
        DynamicTrading.Log(
            "DTCommons",
            "Mapping",
            "Init",
            "Geolocator ready via " .. tostring(loadState.source) .. " with " .. tostring(loadState.lastBuildingCount)
                .. " buildings in " .. tostring(loadState.lastDurationMs or "?") .. " ms."
        )
        return true
    end

    function DT_GeolocatorSystem.LoadBuildings()
        return DT_GeolocatorSystem.EnsureBuildingsLoaded(true, false)
    end
end
