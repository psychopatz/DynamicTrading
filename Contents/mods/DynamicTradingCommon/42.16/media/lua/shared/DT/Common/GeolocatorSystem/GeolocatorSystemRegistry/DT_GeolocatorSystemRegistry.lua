DT_GeolocatorSystem = DT_GeolocatorSystem or {}

require "DT/Common/GeolocatorSystem/GeolocatorSystemRegistry/DT_GeolocatorSystemRegistry_Core"
require "DT/Common/GeolocatorSystem/GeolocatorSystemRegistry/DT_GeolocatorSystemRegistry_Build"

if DT_GeolocatorSystem.EnsureRegionRegistryBuilt then
    DT_GeolocatorSystem.EnsureRegionRegistryBuilt()
end

return DT_GeolocatorSystem.Registry
