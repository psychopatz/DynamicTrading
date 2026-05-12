local context = require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad_Context"

require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad_Index"(context)
require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad_Load"(context)
require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad_Query"(context)
require "DT/Common/GeolocatorSystem/GeolocatorSystemLoad/DT_GeolocatorSystemLoad_RegionCache"(context)

return DT_GeolocatorSystem
