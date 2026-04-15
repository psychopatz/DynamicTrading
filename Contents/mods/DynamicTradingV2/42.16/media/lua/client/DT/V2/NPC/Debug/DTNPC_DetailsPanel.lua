-- ==============================================================================
-- DTNPC_DetailsPanel.lua
-- Decoupled component for viewing NPC npcData data and zombie methods.
-- ==============================================================================

DTNPC_DetailsPanel = ISPanel:derive("DTNPC_DetailsPanel")

function DTNPC_DetailsPanel:initialise()
    ISPanel.initialise(self)
end

function DTNPC_DetailsPanel:createChildren()
    self.propertyList = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.propertyList:initialise()
    self.propertyList:instantiate()
    self.propertyList.drawBorder = true
    self.propertyList.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.propertyList)
end

function DTNPC_DetailsPanel:setData(item)
    self.propertyList:clear()
    if not item then return end
    
    local npcData = item.npcData
    local id = item.id
    local zombie = item.zombie
    
    local function addProp(label, value, color)
        local c = color or {r=1, g=1, b=1, a=1}
        self.propertyList:addItem(tostring(label) .. ": " .. tostring(value), nil)
        local itm = self.propertyList.items[#self.propertyList.items]
        itm.color = c
    end

    local function addHeader(label, color)
        local c = color or {r=1, g=0.7, b=0, a=1}
        self.propertyList:addItem("--- " .. string.upper(label) .. " ---", nil)
        local itm = self.propertyList.items[#self.propertyList.items]
        itm.color = c
    end

    -- 1. IDENTIFICATION
    addHeader("IDENTIFICATION", {r=0, g=0.8, b=1, a=1})
    addProp("Name", npcData.name, {r=1, g=1, b=1, a=1})
    addProp("Body Instance ID", id, {r=0.6, g=0.6, b=0.6, a=1})
    addProp("Data ID", npcData.uuid or "N/A", {r=0.4, g=0.9, b=0.4, a=1})
    
    -- 2. STATE
    addHeader("STATE & POSITION", {r=1, g=0.9, b=0, a=1})
    addProp("State", npcData.state, {r=1, g=0.8, b=0.2, a=1})
    addProp("Combat Order", npcData.combatOrder or "None", {r=1, g=0.8, b=0.2, a=1})
    addProp("Guard Mode", npcData.guardCombatOrder or npcData.guardAttackMode or "None", {r=1, g=0.8, b=0.2, a=1})
    addProp("Hostile", npcData.isHostile, npcData.isHostile and {r=1, g=0.2, b=0.2, a=1} or {r=0.2, g=1, b=0.2, a=1})
    addProp("Master", npcData.master or "None", {r=0.8, g=0.8, b=1, a=1})
    addProp("Last Pos", (npcData.lastX or "?") .. "," .. (npcData.lastY or "?") .. "," .. (npcData.lastZ or "?"), {r=0, g=1, b=1, a=1})

    -- 3. ZOMBIE DATA (LIVE)
    if zombie then
        addHeader("LIVE ENGINE DATA", {r=1, g=0.3, b=0.3, a=1})
        addProp("Engine Health", string.format("%.2f", zombie:getHealth()), {r=1, g=0.4, b=0.4, a=1})
        addProp("Engine State", zombie:getRealState(), {r=1, g=0.6, b=0.3, a=1})
        addProp("Moving", zombie:isMoving(), zombie:isMoving() and {r=0.3, g=1, b=0.3, a=1} or {r=0.7, g=0.7, b=0.7, a=1})
        addProp("Useless", zombie:isUseless(), zombie:isUseless() and {r=1, g=0.2, b=0.2, a=1} or {r=0.7, g=0.7, b=0.7, a=1})
        
        local target = zombie:getTarget()
        if target then
            addProp("Target", target:getObjectName() or "Object", {r=1, g=0.5, b=0.5, a=1})
        end
    end

    if npcData.combatHealth then
        addHeader("CUSTOM HEALTH", {r=0.5, g=1, b=0.5, a=1})
        addProp("Enabled", npcData.combatHealth.enabled, npcData.combatHealth.enabled and {r=0.2, g=1, b=0.2, a=1} or {r=1, g=0.6, b=0.2, a=1})
        addProp("Current", npcData.combatHealth.current or "N/A", {r=0.6, g=1, b=0.6, a=1})
        addProp("Max", npcData.combatHealth.max or "N/A", {r=0.6, g=1, b=0.6, a=1})
        addProp("Base Max", npcData.combatHealth.baseMax or "N/A", {r=0.8, g=1, b=0.8, a=1})
        addProp("Skill Bonus", npcData.combatHealth.skillBonus or "N/A", {r=0.8, g=1, b=0.8, a=1})
    end

    -- 4. OUTFIT / LOOKS
    local debugOutfit = npcData.outfit
    local mappedLookIndex = nil
    if (not debugOutfit or #debugOutfit == 0) and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed then
        debugOutfit, mappedLookIndex = DT_NPC_Wardrobe.GetOutfitBySeed(npcData.archetypeID or "General", npcData.isFemale, npcData.identitySeed or 1)
    end

    if npcData.identitySeed then
        addProp("Identity Seed", npcData.identitySeed, {r=0.7, g=0.9, b=1, a=1})
    end
    if mappedLookIndex then
        addProp("Look Index", mappedLookIndex, {r=0.7, g=0.9, b=1, a=1})
    end

    if debugOutfit and #debugOutfit > 0 then
        addHeader("OUTFIT", {r=0.7, g=0.7, b=1, a=1})
        for _, itm in ipairs(debugOutfit) do
            addProp("  Item", itm, {r=0.8, g=0.8, b=0.9, a=1})
        end
    end

    -- 5. TASKS
    if npcData.tasks and #npcData.tasks > 0 then
        addHeader("ACTIVE TASKS", {r=1, g=0.5, b=1, a=1})
        for i, t in ipairs(npcData.tasks) do
            addProp("  GoTo", (t.x or "?") .. "," .. (t.y or "?") .. "," .. (t.z or "?"), {r=0.9, g=0.7, b=1, a=1})
        end
    end

    -- 6. RAW DATA
    addHeader("RAW DATA DUMP", {r=0.5, g=0.5, b=0.5, a=1})
    local keys = {}
    for k in pairs(npcData) do table.insert(keys, k) end
    table.sort(keys)
    for _, k in ipairs(keys) do
        if type(npcData[k]) ~= "table" then
            addProp(k, npcData[k], {r=0.7, g=0.7, b=0.7, a=1})
        end
    end
end

function DTNPC_DetailsPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end
