-- ==============================================================================
-- DT_APIViePanel.lua
-- Generic component for viewing available Lua methods of an object.
-- ==============================================================================

DT_APIViePanel = ISPanel:derive("DT_APIViePanel")

-- Static cache to prevent lag by only scanning Java classes once per session
DT_APIViePanel.ClassCache = {}

function DT_APIViePanel:initialise()
    ISPanel.initialise(self)
end

function DT_APIViePanel:createChildren()
    local listHeight = self.height * 0.7
    
    -- 1. List area
    self.propertyList = ISScrollingListBox:new(0, 0, self.width, listHeight)
    self.propertyList:initialise()
    self.propertyList:instantiate()
    self.propertyList.itemheight = 30
    self.propertyList.font = UIFont.Medium
    self.propertyList.drawBorder = true
    self.propertyList.backgroundColor = {r=0, g=0, b=0, a=0.5}
    
    -- standard onmousedown callback for ISScrollingListBox
    -- it passes the 'item' field of the list item
    self.propertyList.onmousedown = function(target, item)
        target:onSelectMethod(item)
    end
    self.propertyList.target = self
    
    self.propertyList.doDrawItem = function(list, y, item, alt)
        if not item then return y end
        if list.selected == item.index then
            list:drawRect(0, y, list:getWidth(), item.height - 1, 0.3, 0.7, 0.3, 0.5)
        end
        list:drawRectBorder(0, y, list:getWidth(), item.height, 0.5, 0.5, 0.5, 0.3)
        
        local color = {r=1, g=1, b=1, a=1}
        if item.item and item.item.color then color = item.item.color end
        
        -- Center text vertically in the 30px height
        list:drawText(item.text, 10, y + (item.height - 18) / 2, color.r, color.g, color.b, color.a, UIFont.Medium)
        return y + item.height
    end
    
    self:addChild(self.propertyList)

    -- 2. Detail area (bottom)
    self.detailLabel = ISLabel:new(10, listHeight + 10, 20, "DETAILS", 1, 1, 1, 1, UIFont.Medium, true)
    self.detailLabel:initialise()
    self:addChild(self.detailLabel)
    
    self.detailTextPanel = ISPanel:new(10, listHeight + 35, self.width - 20, self.height - listHeight - 45)
    self.detailTextPanel:initialise()
    self.detailTextPanel:instantiate()
    self.detailTextPanel.backgroundColor = {r=0, g=0, b=0, a=0.7}
    self.detailTextPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.detailTextPanel.text = ""
    self.detailTextPanel.render = function(p)
        ISPanel.render(p)
        if p.text and p.text ~= "" then
            p:drawText(p.text, 10, 10, 1, 1, 1, 1, UIFont.Medium)
        end
    end
    self:addChild(self.detailTextPanel)
end

function DT_APIViePanel:onSelectMethod(itemData)
    if not itemData then return end
    
    local name = itemData.methodName or "Unknown"
    local help = itemData.helpText or "No additional help found."
    
    self.detailLabel:setName("DETAILS: " .. name)
    self.detailTextPanel.text = help
end

function DT_APIViePanel:setObject(obj, className)
    print("DT_APIViePanel:setObject() called for " .. tostring(className))
    self.propertyList:clear()
    
    local function addProp(label, value, color)
        local c = color or {r=1, g=1, b=1, a=1}
        self.propertyList:addItem(tostring(label) .. ": " .. tostring(value), { color = c })
    end

    local function addHeader(label)
        self.propertyList:addItem("--- " .. string.upper(label) .. " ---", { color = {r=1, g=0.8, b=0.4, a=1} })
    end

    if not obj then 
        addHeader("DIAGNOSTICS")
        addProp("Object", "NIL / Not Found", {r=1, g=0.3, b=0.3, a=1})
        return 
    end
    
    addHeader("DIAGNOSTICS")
    addProp("Lua Type", type(obj))
    
    local fullClassName = "Unknown"
    -- Safe way to get class name without calling getMethods()
    if obj.getClass then
        -- We wrapped this in a pcall just in case B42 restricted getClass() itself
        local success, res = pcall(function() return obj:getClass():getName() end)
        if success then fullClassName = res end
    end
    addProp("Java Class", fullClassName, {r=0.7, g=0.7, b=1, a=1})

    addHeader("METHODS FOUND")
    
    local methods = {}
    
    -- Helper to extract signature from tostring(...)
    local function getMethodSig(func, name)
        local str = tostring(func)
        local sig = name .. "()"
        local isJava = not string.find(str, "function: 0x")
        
        if isJava then
            -- Java proxies often look like: "public void zombie.characters.IsoZombie.setHealth(float)"
            -- We want to extract the part after the last dot if it contains parens
            if string.find(str, "%(") then
                local s = str:gsub(".-%.", "") -- strip package prefix
                if string.find(s, "%(") then sig = s end
            end
        end
        return sig, isJava, str
    end

    local function scan(t)
        if not t then return end
        if type(t) == "table" then
            for k, v in pairs(t) do
                if type(k) == "string" and not string.find(k, "__") then
                    if type(v) == "function" or type(v) == "userdata" then
                        methods[k] = v
                    end
                end
            end
        elseif type(t) == "userdata" then
            local mt = getmetatable(t)
            -- In B42, iterate the metatable's index if it's a table
            if mt and mt.__index and type(mt.__index) == "table" then
                for k, v in pairs(mt.__index) do
                    if type(k) == "string" and not string.find(k, "__") then
                        if type(v) == "function" or type(v) == "userdata" then
                            methods[k] = v
                        end
                    end
                end
            end
        end
    end

    -- 1. Scan the object itself
    scan(obj)
    
    -- 2. Scan the metatable chain
    local mt = getmetatable(obj)
    local depth = 0
    while mt and depth < 10 do
        if mt.__index then
            scan(mt.__index)
        end
        local nextMt = getmetatable(mt)
        if not nextMt or nextMt == mt then break end
        mt = nextMt
        depth = depth + 1
    end
    
    local sortedMethods = {}
    for k in pairs(methods) do table.insert(sortedMethods, k) end
    table.sort(sortedMethods)
    
    for _, k in ipairs(sortedMethods) do
        local func = methods[k]
        local displayName, isJava, fullStr = getMethodSig(func, k)
        
        local color = {r=0.6, g=0.6, b=1, a=1} -- Lua default
        if isJava then color = {r=0.4, g=0.8, b=1, a=1} end -- Java default
        
        local helpText = "Name: " .. k .. "\n"
        if isJava then
            helpText = helpText .. "Java Signature: " .. fullStr .. "\n"
        end
        
        -- Built-in PZ help checks
        if type(func) == "table" then
            if func.help then
                helpText = helpText .. "\nHELP: " .. tostring(func.help)
            elseif func.getHelp then
                helpText = helpText .. "\nHELP: " .. tostring(func:getHelp())
            end
        end
        
        self.propertyList:addItem(displayName, {methodName = k, methodObj = func, helpText = helpText, color = color})
    end
    
    if #sortedMethods == 0 then
        addProp("No methods found", "Verify if the object is accessible via metatable.")
    end
    
    print("DT_APIViePanel:setObject() finished! Items: " .. tostring(#self.propertyList.items))
end

function DT_APIViePanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end
