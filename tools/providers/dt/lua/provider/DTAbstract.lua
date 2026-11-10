-- DTAbstract adapter: the same Core execution contract, permanently abstract.

local Adapter = require "provider/DTAdapter"

local Provider = {
    providerID = "DTAbstract",
    materializationMode = "abstract",
    capabilities = {
        "semantic.conversation",
        "semantic.identity",
        "semantic.interaction",
        "trading.conversation",
        "trading.interaction",
        "trading.remote",
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
