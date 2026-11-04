local T = require "tests/support/test"
T.addPackagePaths()

local active = {}
getActivatedMods = function()
    return {
        contains = function(_, modID)
            return active[tostring(modID)] == true
        end,
    }
end

DTCommon = {}
local Policy = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_ModActivationPolicy.lua"
)

active = {}
local ok, reason = Policy.Check("DTAbstract")
T.truthy(ok, reason)

active.ProjectHoomans = true
ok, reason = Policy.Check("DTAbstract")
T.falsy(ok, "DTAbstract must reject ProjectHoomans")
T.equal(reason, "incompatible_mod_active:ProjectHoomans",
    "ProjectHoomans conflict reason")

active = { DTHoomans = true }
ok, reason = Policy.Check("DTAbstract")
T.falsy(ok, "DTAbstract must reject DTHoomans")
T.equal(reason, "incompatible_mod_active:DTHoomans",
    "DTHoomans conflict reason")

active = { DTAbstract = true }
ok, reason = Policy.Check("DTHoomans")
T.falsy(ok, "DTHoomans must reject DTAbstract")
T.equal(reason, "incompatible_mod_active:DTAbstract",
    "DTAbstract conflict reason")

local namespace = {}
local enabled, applyReason, conflictID =
    Policy.Apply(namespace, "DTHoomans")
T.falsy(enabled, "runtime guard must fail closed")
T.falsy(namespace.Enabled,
    "runtime guard marks conflicting provider disabled")
T.equal(conflictID, "DTAbstract",
    "runtime guard exposes conflicting mod ID")
T.equal(namespace.ActivationReason, applyReason,
    "runtime guard preserves activation reason")

T.finish("dt_mod_activation_exclusivity_smoke")
