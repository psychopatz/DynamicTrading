DTAbstract = DTAbstract or {}
DTAbstract.VERSION = 1
DTAbstract.MOD_ID = "DTAbstract"
DTAbstract.Enabled = true
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
