local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    return {
        Public = Public,
        Internal = Internal,
        Utils = Utils,
        DYNAMIC_COLONIES_REQUIRED = "Dynamic Colonies is required for player-made colony factions.",
        getFactionData = Utils.getFactionData,
        getOwnerUsername = Utils.getOwnerUsername,
        getOnlinePlayerByUsername = Utils.getOnlinePlayerByUsername,
        getCharacterName = Utils.getCharacterName,
        isAuthority = Utils.isAuthority,
        findWorkerByID = Utils.findWorkerByID,
        isWorkerLiving = Utils.isWorkerLiving,
        removeValue = Utils.removeValue,
        containsValue = Utils.containsValue,
        copyArray = Utils.copyArray,
        ensureUniqueUsernames = Utils.ensureUniqueUsernames,
        getFactionRole = Utils.getFactionRole,
        trimName = Utils.trimName,
        sanitizeID = Utils.sanitizeID,
        getWorkersForOwner = Utils.getWorkersForOwner,
        buildFactionHome = Utils.buildFactionHome,
        appendUnique = Utils.appendUnique,
        getWorkerSummary = Utils.getWorkerSummary,
        getOwnerBuildingsSummary = Utils.getOwnerBuildingsSummary,
        getSummaryBuildingCount = Utils.getSummaryBuildingCount,
        hasCompletedHeadquarters = Utils.hasCompletedHeadquarters,
        isWorkerRegistryAvailable = Utils.isWorkerRegistryAvailable,
        isDynamicColoniesActive = Utils.isDynamicColoniesActive,
        isAdminReview = Utils.isAdminReview,
        getColonyRegistry = Utils.getColonyRegistry
    }
end
