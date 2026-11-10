local T = require "tests/support/test"

package.path = (os.getenv("PZ_TEST_REPOSITORY")
    or ".")
    .. "/tools/providers/dt/lua/?.lua;"
    .. (os.getenv("PZ_TEST_CORE_REPOSITORY") or "../psychopatzCore")
    .. "/tools/semantic_harness/lua/?.lua;"
    .. package.path

local SemanticExecution = require "worker/SemanticExecution"
local Abstract = require "provider/DTAbstract"
local Hoomans = require "provider/DTHoomans"

local function callbacks()
    return {
        buildContext = function(context)
            return { provider = context.provider }
        end,
        submitText = function(_, text)
            return { accepted = true, text = text }
        end,
        previewText = function(_, text)
            return { preview = text }
        end,
        submitFrame = function(_, frame)
            return { frame = frame }
        end,
        snapshot = function(context)
            return { provider = context.provider }
        end,
    }
end

local abstract, abstractReason = Abstract.New(
    SemanticExecution,
    { provider = "abstract" },
    callbacks()
)
T.truthy(abstract, abstractReason)
T.equal(abstract:describe().providerID, "DTAbstract",
    "DTAbstract adapter lost provider identity")
T.equal(abstract:describe().materializationMode, "abstract",
    "DTAbstract adapter is not abstract")
T.equal(abstract:submitText("hello").text, "hello",
    "DTAbstract adapter did not delegate Core text callback")

local physical, physicalReason = Hoomans.New(
    SemanticExecution,
    { provider = "physical" },
    callbacks()
)
T.truthy(physical, physicalReason)
T.equal(physical:describe().providerID, "DTHoomans",
    "DTHoomans adapter lost provider identity")
T.equal(physical:describe().materializationMode, "physical",
    "DTHoomans adapter is not physical")
T.equal(physical:submitFrame({ id = "choice-1" }).frame.id, "choice-1",
    "DTHoomans adapter did not delegate Core frame callback")

local missing, missingReason = Abstract.New(nil, {}, {})
T.equal(missing, nil, "adapter accepted missing Core execution contract")
T.equal(missingReason, "core_execution_contract_required",
    "adapter reported the wrong missing Core contract reason")

T.finish("dt_semantic_execution_adapter_smoke")
