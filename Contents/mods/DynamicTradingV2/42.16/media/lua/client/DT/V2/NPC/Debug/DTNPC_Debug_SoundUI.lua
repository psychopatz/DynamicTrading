-- ==============================================================================
-- DTNPC_Debug_SoundUI.lua
-- UI for testing NPC vocalizations with customizable identity and gender.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISComboBox"

DTNPC_Debug_SoundUI = ISCollapsableWindow:derive("DTNPC_Debug_SoundUI")
DTNPC_Debug_SoundUI.instance = nil

function DTNPC_Debug_SoundUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Vocal System UI")
    self:setResizable(false)
end

function DTNPC_Debug_SoundUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local y = th + pad

    -- Seed
    local lblSeed = ISLabel:new(pad, y, 20, "Identity Seed (Number):", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblSeed)
    
    self.entrySeed = ISTextEntryBox:new("123", pad + 150, y, 100, 20)
    self.entrySeed:initialise()
    self.entrySeed:instantiate()
    self.entrySeed:setOnlyNumbers(true)
    self:addChild(self.entrySeed)

    local btnRand = ISButton:new(pad + 260, y, 60, 20, "Rand", self, function(self)
        self.entrySeed:setText(tostring(ZombRand(1000)))
    end)
    btnRand:initialise()
    self:addChild(btnRand)

    y = y + 30

    -- Gender
    local lblGender = ISLabel:new(pad, y, 20, "Gender:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblGender)

    self.comboGender = ISComboBox:new(pad + 150, y, 100, 20, self, nil)
    self.comboGender:initialise()
    self.comboGender:addOption("Male")
    self.comboGender:addOption("Female")
    self:addChild(self.comboGender)

    y = y + 40

    local btnWidth = 310
    local btnHeight = 24

    local function constructNpcData()
        local seedStr = self.entrySeed:getText() or ""
        local seed = tonumber(seedStr) or 0
        local isFemale = self.comboGender.selected == 2
        return {
            identitySeed = seed,
            isFemale = isFemale,
            name = "Test UI NPC"
        }
    end

    local function getEmitter()
        return getSpecificPlayer(0)
    end

    local function ensureHostility()
        return DTNPCHostility ~= nil
    end

    local function getVoiceSetDesc()
        local seedStr = self.entrySeed:getText() or "0"
        local seed = tonumber(seedStr) or 0
        local voiceSet = "V" .. (1 + (seed % 4))
        return voiceSet
    end

    local function addTestBtn(label, func)
        local btn = ISButton:new(pad, y, btnWidth, btnHeight, label, self, function(self)
            if not ensureHostility() then return end
            local npcData = constructNpcData()
            local n = getEmitter()
            func(n, npcData)
            if n and n.setHaloNote then
                local genderStr = npcData.isFemale and "(Female)" or "(Male)"
                n:setHaloNote("UI SFX: " .. getVoiceSetDesc() .. " " .. genderStr, 255, 255, 255, 300)
            end
        end)
        btn:initialise()
        self:addChild(btn)
        
        y = y + btnHeight + 5
        return btn
    end

    local lblHurt = ISLabel:new(pad, y, 20, "--- Combat Sounds ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblHurt)
    y = y + 25

    addTestBtn("Test Hurt Sound", function(n, npcData)
        if DTNPCHostility.PlayHurtSound then DTNPCHostility.PlayHurtSound(n, npcData, "Hurt") end
    end)
    addTestBtn("Test Incap Sound", function(n, npcData)
        if DTNPCHostility.PlayHurtSound then DTNPCHostility.PlayHurtSound(n, npcData, "Incap") end
    end)
    addTestBtn("Test Death Sound", function(n, npcData)
        if DTNPCHostility.PlayHurtSound then DTNPCHostility.PlayHurtSound(n, npcData, "Death") end
    end)
    addTestBtn("Test Effort Sound", function(n, npcData)
        if DTNPCHostility.PlayHurtSound then DTNPCHostility.PlayHurtSound(n, npcData, "Effort") end
    end)
    addTestBtn("Test Bandage", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Bandage") end
    end)

    y = y + 10
    local lblAmbient = ISLabel:new(pad, y, 20, "--- Ambient & Chat ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblAmbient)
    y = y + 25

    addTestBtn("Test Hey (Chat + Text)", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Chat") end
    end)
    addTestBtn("Test Sigh", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Sigh") end
    end)
    addTestBtn("Test Sneeze (Ambient)", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Ambient") end
    end)
    addTestBtn("Test State (Jump/Sleep/Smoke)", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "State") end
    end)
    addTestBtn("Test Alone (Ambient)", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Ambient") end
    end)
    addTestBtn("Test Angry (Chat Pool)", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Chat_Angry") end
    end)
    addTestBtn("Test Specific: Angry", function(n, npcData)
        if DTNPCHostility.PlayVocal then DTNPCHostility.PlayVocal(n, npcData, "Chat_Angry") end
    end)

    y = y + 10
    local lblUtils = ISLabel:new(pad, y, 20, "--- Utilities ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblUtils)
    y = y + 25

    local btnDump = ISButton:new(pad, y, btnWidth, btnHeight, "Dump All Audio Keys to file", self, function(self)
        local allSounds = getScriptManager():getAllGameSounds()
        local fileWriter = getFileWriter("DT_Audio_Dump.txt", true, false)
        if fileWriter then
            fileWriter:write("========== DT AUDIO DUMP ==========\n")
            fileWriter:write("Found " .. tostring(allSounds:size()) .. " sound events.\n\n")
            for i = 0, allSounds:size() - 1 do
                local sound = allSounds:get(i)
                fileWriter:write(tostring(sound:getName()) .. "\n")
            end
            fileWriter:close()
            local p = getSpecificPlayer(0)
            if p and p.setHaloNote then
                p:setHaloNote("Saved to Zomboid/Lua/DT_Audio_Dump.txt", 100, 255, 100, 300)
            end
        end
    end)
    btnDump:initialise()
    btnDump.backgroundColor = {r=0, g=0.3, b=0, a=1}
    self:addChild(btnDump)
    y = y + btnHeight + 5

    self:setHeight(y + 20)
end

function DTNPC_Debug_SoundUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DTNPC_Debug_SoundUI.instance = nil
end

function DTNPC_Debug_SoundUI.ToggleWindow()
    if DTNPC_Debug_SoundUI.instance then
        DTNPC_Debug_SoundUI.instance:close()
        return
    end

    local width = 340
    local height = 500
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local ui = DTNPC_Debug_SoundUI:new(x, y, width, height)
    ui:initialise()
    ui:addToUIManager()
    DTNPC_Debug_SoundUI.instance = ui
end

function DTNPC_Debug_SoundUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end
