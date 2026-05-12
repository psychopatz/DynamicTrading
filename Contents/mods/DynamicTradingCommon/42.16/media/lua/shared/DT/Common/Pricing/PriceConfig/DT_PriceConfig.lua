DynamicTrading = DynamicTrading or {}
DynamicTrading.PriceConfig = DynamicTrading.PriceConfig or {}

DT_PriceConfigInternal = DT_PriceConfigInternal or {}

require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Shared"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Schema"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Discovery"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Sync"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Effective"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Presets"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Mutations"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig_Events"

return DynamicTrading.PriceConfig
