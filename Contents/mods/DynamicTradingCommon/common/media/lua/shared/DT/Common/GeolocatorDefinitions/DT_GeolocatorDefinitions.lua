DT_GeolocatorSystem = DT_GeolocatorSystem or {}
DT_GeolocatorSystem.PendingRegionDefinitions = DT_GeolocatorSystem.PendingRegionDefinitions or {}

if not DT_GeolocatorSystem.RegisterRegionDefinition then
    function DT_GeolocatorSystem.RegisterRegionDefinition(definition)
        if type(definition) ~= "table" then
            return nil
        end

        local pending = DT_GeolocatorSystem.PendingRegionDefinitions
        pending[#pending + 1] = definition
        return definition
    end
end

if not DT_GeolocatorSystem.NormalizeGeolocatorRegistryKey then
    function DT_GeolocatorSystem.NormalizeGeolocatorRegistryKey(value)
        local text = tostring(value or "")
        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")
        text = text:gsub("%s+", " ")
        text = text:lower()
        text = text:gsub("[^%w]+", "_")
        text = text:gsub("^_+", "")
        text = text:gsub("_+$", "")
        return text
    end
end
