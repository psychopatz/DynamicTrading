-- Server-side initialization for DTAbstract.

if DTAbstract and DTAbstract.Enabled == false then return end

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

require "DTAbstract/DTAbstract_SurvivorWorldRuntime"
require "DTAbstract/DTAbstract_TraderWorldProvider"
require "DTAbstract/DTAbstract_Server"
