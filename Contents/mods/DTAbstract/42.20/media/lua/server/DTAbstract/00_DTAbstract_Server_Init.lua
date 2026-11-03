-- Server-side initialization for DTAbstract.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

require "DTAbstract/DTAbstract_Lifecycle"
require "DTAbstract/DTAbstract_Server"
