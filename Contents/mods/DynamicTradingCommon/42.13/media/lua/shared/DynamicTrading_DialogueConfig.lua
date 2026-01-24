DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Player = DynamicTrading.Dialogue.Player or {}
DynamicTrading.Dialogue.General = DynamicTrading.Dialogue.General or {}

-- Core Dialogue
require "Dialogue/Player/Sell_ask"
require "Dialogue/General/Sell_ask"

-- Player
require "Dialogue/Player/Intro"
require "Dialogue/Player/Buy"
require "Dialogue/Player/BuyLast"
require "Dialogue/Player/NoCash"
require "Dialogue/Player/Sell"

-- General
require "Dialogue/General/Greetings"
require "Dialogue/General/Idle"
require "Dialogue/General/Buying"
require "Dialogue/General/Selling"

-- Archetypes - Sheriff
require "Dialogue/Sheriff/Greetings"
require "Dialogue/Sheriff/Buying"
require "Dialogue/Sheriff/Selling"

-- Archetypes - Smuggler
require "Dialogue/Smuggler/Greetings"
require "Dialogue/Smuggler/Buying"
require "Dialogue/Smuggler/Selling"

-- Archetypes - Doctor
require "Dialogue/Doctor/Greetings"
require "Dialogue/Doctor/Buying"
require "Dialogue/Doctor/Selling"

-- Archetypes - Farmer
require "Dialogue/Farmer/Greetings"
require "Dialogue/Farmer/Buying"
require "Dialogue/Farmer/Selling"

-- Archetypes - Gunrunner
require "Dialogue/Gunrunner/Greetings"
require "Dialogue/Gunrunner/Buying"
require "Dialogue/Gunrunner/Selling"