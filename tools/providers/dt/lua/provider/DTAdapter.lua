-- Dynamic Trading's provider-local adapter.
--
-- The module has a provider-specific name so a composed worker can load
-- Project Hoomans and Dynamic Trading adapters together without Lua resolving
-- both providers' generic ``provider/Adapter`` modules to the first package
-- path on the search path.

local Adapter = {}

local function copyList(values)
    local result = {}
    for index, value in ipairs(type(values) == "table" and values or {}) do
        result[index] = value
    end
    return result
end

function Adapter.New(SemanticExecution, spec)
    if type(SemanticExecution) ~= "table"
        or type(SemanticExecution.new) ~= "function"
    then
        return nil, "core_execution_contract_required"
    end
    spec = type(spec) == "table" and spec or {}
    return SemanticExecution.new({
        providerID = spec.providerID,
        materializationMode = spec.materializationMode,
        capabilities = copyList(spec.capabilities),
        context = spec.context,
        callbacks = spec.callbacks,
    })
end

return Adapter
