DTAbstract = DTAbstract or {}
DTAbstract.VERSION = 1
DTAbstract.MOD_ID = "DTAbstract"

local Activation = DTCommon and DTCommon.ModActivationPolicy
    or require "DTCommon/DTCommon_ModActivationPolicy"
local enabled = Activation.Apply(DTAbstract, DTAbstract.MOD_ID)
if enabled ~= true then
    return DTAbstract
end

DTAbstract.RequireRadio = true
-- Development-only preview. Default false: no UI entry or changes to trading.
DTAbstract.EnableRadioOSPreview = DTAbstract.EnableRadioOSPreview == true
require "DTAbstract/DTAbstract_CoreProvider"

if DTCommon and DTCommon.TraderProviders
    and type(DTCommon.TraderProviders.Register) == "function"
then
    DTCommon.TraderProviders.Register("DTAbstract", {
        kind = "abstract",
        priority = 100,
    })
end

return DTAbstract
