-- Thin Dynamic Trading adapter around Core's semantic execution contract.
-- The execution engine and callback dispatch remain Core-owned.

local Adapter = {}

local function copyList(values)
    local result = {}
    for index, value in ipairs(type(values) == "table" and values or {}) do
        result[index] = value
    end
    return result
end

function Adapter.New(SemanticExecution, spec, defaults)
    if type(SemanticExecution) ~= "table"
        or type(SemanticExecution.new) ~= "function"
    then
        return nil, "core_execution_contract_required"
    end
    spec = type(spec) == "table" and spec or {}
    defaults = type(defaults) == "table" and defaults or {}
    local capabilities = spec.capabilities or defaults.capabilities
    return SemanticExecution.new({
        providerID = spec.providerID or defaults.providerID,
        materializationMode = spec.materializationMode
            or defaults.materializationMode,
        capabilities = copyList(capabilities),
        context = spec.context,
        callbacks = spec.callbacks,
    })
end

return Adapter
