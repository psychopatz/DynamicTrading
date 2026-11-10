-- DTHoomans adapter: the same Core execution contract with physical
-- materialization delegated to the adopter's body-capability callbacks.

local Adapter = require "provider/Adapter"

local Provider = {
    providerID = "DTHoomans",
    materializationMode = "physical",
    capabilities = {
        "semantic.conversation",
        "semantic.identity",
        "semantic.interaction",
        "trading.conversation",
        "trading.interaction",
        "trading.physical",
    },
}

function Provider.New(SemanticExecution, context, callbacks)
    return Adapter.New(SemanticExecution, {
        providerID = Provider.providerID,
        materializationMode = Provider.materializationMode,
        capabilities = Provider.capabilities,
        context = context,
        callbacks = callbacks,
    })
end

return Provider
