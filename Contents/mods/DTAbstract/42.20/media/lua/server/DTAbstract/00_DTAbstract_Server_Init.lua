-- Server-side initialization for DTAbstract.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

require "DTAbstract/DTAbstract_SurvivorWorldRuntime"
require "DTAbstract/DTAbstract_TraderWorldProvider"
require "DTAbstract/DTAbstract_Server"
