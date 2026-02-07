DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}
DynamicTrading.Dialogue.Player = DynamicTrading.Dialogue.Player or {}
DynamicTrading.Dialogue.General = DynamicTrading.Dialogue.General or {}

-- Core Dialogue
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Sell_ask"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Sell_ask"

-- Player
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Intro"
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Buy"
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_BuyLast"
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_NoCash"
require "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Sell"

-- General
require "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Greetings"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Idle"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Buying"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/DT_General_Selling"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/Chat/DT_General_Chat_History"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/Chat/DT_General_Chat_World"
require "DT/Common/ArchetypeDefinitions/General/Dialogue/Chat/DT_General_Chat_Personal"

-- Archetypes - Sheriff
require "DT/Common/ArchetypeDefinitions/Sheriff/Dialogue/DT_Sheriff_Greetings"
require "DT/Common/ArchetypeDefinitions/Sheriff/Dialogue/DT_Sheriff_Buying"
require "DT/Common/ArchetypeDefinitions/Sheriff/Dialogue/DT_Sheriff_Selling"

-- Archetypes - Smuggler
require "DT/Common/ArchetypeDefinitions/Smuggler/Dialogue/DT_Smuggler_Greetings"
require "DT/Common/ArchetypeDefinitions/Smuggler/Dialogue/DT_Smuggler_Buying"
require "DT/Common/ArchetypeDefinitions/Smuggler/Dialogue/DT_Smuggler_Selling"

-- Archetypes - Doctor
require "DT/Common/ArchetypeDefinitions/Doctor/Dialogue/DT_Doctor_Greetings"
require "DT/Common/ArchetypeDefinitions/Doctor/Dialogue/DT_Doctor_Buying"
require "DT/Common/ArchetypeDefinitions/Doctor/Dialogue/DT_Doctor_Selling"

-- Archetypes - Butcher
require "DT/Common/ArchetypeDefinitions/Butcher/Dialogue/DT_Butcher_Greetings"
require "DT/Common/ArchetypeDefinitions/Butcher/Dialogue/DT_Butcher_Buying"
require "DT/Common/ArchetypeDefinitions/Butcher/Dialogue/DT_Butcher_Selling"
require "DT/Common/ArchetypeDefinitions/Butcher/Dialogue/DT_Butcher_Sell_ask"

-- Archetypes - Mechanic
require "DT/Common/ArchetypeDefinitions/Mechanic/Dialogue/DT_Mechanic_Greetings"
require "DT/Common/ArchetypeDefinitions/Mechanic/Dialogue/DT_Mechanic_Buying"
require "DT/Common/ArchetypeDefinitions/Mechanic/Dialogue/DT_Mechanic_Selling"
require "DT/Common/ArchetypeDefinitions/Mechanic/Dialogue/DT_Mechanic_Sell_ask"

-- Archetypes - Survivalist
require "DT/Common/ArchetypeDefinitions/Survivalist/Dialogue/DT_Survivalist_Greetings"
require "DT/Common/ArchetypeDefinitions/Survivalist/Dialogue/DT_Survivalist_Buying"
require "DT/Common/ArchetypeDefinitions/Survivalist/Dialogue/DT_Survivalist_Selling"
require "DT/Common/ArchetypeDefinitions/Survivalist/Dialogue/DT_Survivalist_Sell_ask"

-- Archetypes - Foreman
require "DT/Common/ArchetypeDefinitions/Foreman/Dialogue/DT_Foreman_Greetings"
require "DT/Common/ArchetypeDefinitions/Foreman/Dialogue/DT_Foreman_Buying"
require "DT/Common/ArchetypeDefinitions/Foreman/Dialogue/DT_Foreman_Selling"
require "DT/Common/ArchetypeDefinitions/Foreman/Dialogue/DT_Foreman_Sell_ask"

-- Archetypes - Scavenger
require "DT/Common/ArchetypeDefinitions/Scavenger/Dialogue/DT_Scavenger_Greetings"
require "DT/Common/ArchetypeDefinitions/Scavenger/Dialogue/DT_Scavenger_Buying"
require "DT/Common/ArchetypeDefinitions/Scavenger/Dialogue/DT_Scavenger_Selling"
require "DT/Common/ArchetypeDefinitions/Scavenger/Dialogue/DT_Scavenger_Sell_ask"

-- Archetypes - Tailor
require "DT/Common/ArchetypeDefinitions/Tailor/Dialogue/DT_Tailor_Greetings"
require "DT/Common/ArchetypeDefinitions/Tailor/Dialogue/DT_Tailor_Buying"
require "DT/Common/ArchetypeDefinitions/Tailor/Dialogue/DT_Tailor_Selling"
require "DT/Common/ArchetypeDefinitions/Tailor/Dialogue/DT_Tailor_Sell_ask"

-- Archetypes - Electrician
require "DT/Common/ArchetypeDefinitions/Electrician/Dialogue/DT_Electrician_Greetings"
require "DT/Common/ArchetypeDefinitions/Electrician/Dialogue/DT_Electrician_Buying"
require "DT/Common/ArchetypeDefinitions/Electrician/Dialogue/DT_Electrician_Selling"
require "DT/Common/ArchetypeDefinitions/Electrician/Dialogue/DT_Electrician_Sell_ask"

-- Archetypes - Welder
require "DT/Common/ArchetypeDefinitions/Welder/Dialogue/DT_Welder_Greetings"
require "DT/Common/ArchetypeDefinitions/Welder/Dialogue/DT_Welder_Buying"
require "DT/Common/ArchetypeDefinitions/Welder/Dialogue/DT_Welder_Selling"
require "DT/Common/ArchetypeDefinitions/Welder/Dialogue/DT_Welder_Sell_ask"

-- Archetypes - Chef
require "DT/Common/ArchetypeDefinitions/Chef/Dialogue/DT_Chef_Greetings"
require "DT/Common/ArchetypeDefinitions/Chef/Dialogue/DT_Chef_Buying"
require "DT/Common/ArchetypeDefinitions/Chef/Dialogue/DT_Chef_Selling"
require "DT/Common/ArchetypeDefinitions/Chef/Dialogue/DT_Chef_Sell_ask"

-- Archetypes - Herbalist
require "DT/Common/ArchetypeDefinitions/Herbalist/Dialogue/DT_Herbalist_Greetings"
require "DT/Common/ArchetypeDefinitions/Herbalist/Dialogue/DT_Herbalist_Buying"
require "DT/Common/ArchetypeDefinitions/Herbalist/Dialogue/DT_Herbalist_Selling"
require "DT/Common/ArchetypeDefinitions/Herbalist/Dialogue/DT_Herbalist_Sell_ask"

-- Archetypes - Librarian
require "DT/Common/ArchetypeDefinitions/Librarian/Dialogue/DT_Librarian_Greetings"
require "DT/Common/ArchetypeDefinitions/Librarian/Dialogue/DT_Librarian_Buying"
require "DT/Common/ArchetypeDefinitions/Librarian/Dialogue/DT_Librarian_Selling"
require "DT/Common/ArchetypeDefinitions/Librarian/Dialogue/DT_Librarian_Sell_ask"

-- Archetypes - Angler
require "DT/Common/ArchetypeDefinitions/Angler/Dialogue/DT_Angler_Greetings"
require "DT/Common/ArchetypeDefinitions/Angler/Dialogue/DT_Angler_Buying"
require "DT/Common/ArchetypeDefinitions/Angler/Dialogue/DT_Angler_Selling"
require "DT/Common/ArchetypeDefinitions/Angler/Dialogue/DT_Angler_Sell_ask"

-- Archetypes - Bartender
require "DT/Common/ArchetypeDefinitions/Bartender/Dialogue/DT_Bartender_Greetings"
require "DT/Common/ArchetypeDefinitions/Bartender/Dialogue/DT_Bartender_Buying"
require "DT/Common/ArchetypeDefinitions/Bartender/Dialogue/DT_Bartender_Selling"
require "DT/Common/ArchetypeDefinitions/Bartender/Dialogue/DT_Bartender_Sell_ask"

-- Archetypes - Teacher
require "DT/Common/ArchetypeDefinitions/Teacher/Dialogue/DT_Teacher_Greetings"
require "DT/Common/ArchetypeDefinitions/Teacher/Dialogue/DT_Teacher_Buying"
require "DT/Common/ArchetypeDefinitions/Teacher/Dialogue/DT_Teacher_Selling"
require "DT/Common/ArchetypeDefinitions/Teacher/Dialogue/DT_Teacher_Sell_ask"

-- Archetypes - Hunter
require "DT/Common/ArchetypeDefinitions/Hunter/Dialogue/DT_Hunter_Greetings"
require "DT/Common/ArchetypeDefinitions/Hunter/Dialogue/DT_Hunter_Buying"
require "DT/Common/ArchetypeDefinitions/Hunter/Dialogue/DT_Hunter_Selling"
require "DT/Common/ArchetypeDefinitions/Hunter/Dialogue/DT_Hunter_Sell_ask"

-- Archetypes - Quartermaster
require "DT/Common/ArchetypeDefinitions/Quartermaster/Dialogue/DT_Quartermaster_Greetings"
require "DT/Common/ArchetypeDefinitions/Quartermaster/Dialogue/DT_Quartermaster_Buying"
require "DT/Common/ArchetypeDefinitions/Quartermaster/Dialogue/DT_Quartermaster_Selling"
require "DT/Common/ArchetypeDefinitions/Quartermaster/Dialogue/DT_Quartermaster_Sell_ask"

-- Archetypes - Musician
require "DT/Common/ArchetypeDefinitions/Musician/Dialogue/DT_Musician_Greetings"
require "DT/Common/ArchetypeDefinitions/Musician/Dialogue/DT_Musician_Buying"
require "DT/Common/ArchetypeDefinitions/Musician/Dialogue/DT_Musician_Selling"
require "DT/Common/ArchetypeDefinitions/Musician/Dialogue/DT_Musician_Sell_ask"

-- Archetypes - Janitor
require "DT/Common/ArchetypeDefinitions/Janitor/Dialogue/DT_Janitor_Greetings"
require "DT/Common/ArchetypeDefinitions/Janitor/Dialogue/DT_Janitor_Buying"
require "DT/Common/ArchetypeDefinitions/Janitor/Dialogue/DT_Janitor_Selling"
require "DT/Common/ArchetypeDefinitions/Janitor/Dialogue/DT_Janitor_Sell_ask"

-- Archetypes - Carpenter
require "DT/Common/ArchetypeDefinitions/Carpenter/Dialogue/DT_Carpenter_Greetings"
require "DT/Common/ArchetypeDefinitions/Carpenter/Dialogue/DT_Carpenter_Buying"
require "DT/Common/ArchetypeDefinitions/Carpenter/Dialogue/DT_Carpenter_Selling"
require "DT/Common/ArchetypeDefinitions/Carpenter/Dialogue/DT_Carpenter_Sell_ask"

-- Archetypes - Pawnbroker
require "DT/Common/ArchetypeDefinitions/Pawnbroker/Dialogue/DT_Pawnbroker_Greetings"
require "DT/Common/ArchetypeDefinitions/Pawnbroker/Dialogue/DT_Pawnbroker_Buying"
require "DT/Common/ArchetypeDefinitions/Pawnbroker/Dialogue/DT_Pawnbroker_Selling"
require "DT/Common/ArchetypeDefinitions/Pawnbroker/Dialogue/DT_Pawnbroker_Sell_ask"

-- Archetypes - Pyro
require "DT/Common/ArchetypeDefinitions/Pyro/Dialogue/DT_Pyro_Greetings"
require "DT/Common/ArchetypeDefinitions/Pyro/Dialogue/DT_Pyro_Buying"
require "DT/Common/ArchetypeDefinitions/Pyro/Dialogue/DT_Pyro_Selling"
require "DT/Common/ArchetypeDefinitions/Pyro/Dialogue/DT_Pyro_Sell_ask"

-- Archetypes - Athlete
require "DT/Common/ArchetypeDefinitions/Athlete/Dialogue/DT_Athlete_Greetings"
require "DT/Common/ArchetypeDefinitions/Athlete/Dialogue/DT_Athlete_Buying"
require "DT/Common/ArchetypeDefinitions/Athlete/Dialogue/DT_Athlete_Selling"
require "DT/Common/ArchetypeDefinitions/Athlete/Dialogue/DT_Athlete_Sell_ask"

-- Archetypes - Pharmacist
require "DT/Common/ArchetypeDefinitions/Pharmacist/Dialogue/DT_Pharmacist_Greetings"
require "DT/Common/ArchetypeDefinitions/Pharmacist/Dialogue/DT_Pharmacist_Buying"
require "DT/Common/ArchetypeDefinitions/Pharmacist/Dialogue/DT_Pharmacist_Selling"
require "DT/Common/ArchetypeDefinitions/Pharmacist/Dialogue/DT_Pharmacist_Sell_ask"

-- Archetypes - Hiker
require "DT/Common/ArchetypeDefinitions/Hiker/Dialogue/DT_Hiker_Greetings"
require "DT/Common/ArchetypeDefinitions/Hiker/Dialogue/DT_Hiker_Buying"
require "DT/Common/ArchetypeDefinitions/Hiker/Dialogue/DT_Hiker_Selling"
require "DT/Common/ArchetypeDefinitions/Hiker/Dialogue/DT_Hiker_Sell_ask"

-- Archetypes - Burglar
require "DT/Common/ArchetypeDefinitions/Burglar/Dialogue/DT_Burglar_Greetings"
require "DT/Common/ArchetypeDefinitions/Burglar/Dialogue/DT_Burglar_Buying"
require "DT/Common/ArchetypeDefinitions/Burglar/Dialogue/DT_Burglar_Selling"
require "DT/Common/ArchetypeDefinitions/Burglar/Dialogue/DT_Burglar_Sell_ask"

-- Archetypes - Blacksmith
require "DT/Common/ArchetypeDefinitions/Blacksmith/Dialogue/DT_Blacksmith_Greetings"
require "DT/Common/ArchetypeDefinitions/Blacksmith/Dialogue/DT_Blacksmith_Buying"
require "DT/Common/ArchetypeDefinitions/Blacksmith/Dialogue/DT_Blacksmith_Selling"
require "DT/Common/ArchetypeDefinitions/Blacksmith/Dialogue/DT_Blacksmith_Sell_ask"

-- Archetypes - Tribal
require "DT/Common/ArchetypeDefinitions/Tribal/Dialogue/DT_Tribal_Greetings"
require "DT/Common/ArchetypeDefinitions/Tribal/Dialogue/DT_Tribal_Buying"
require "DT/Common/ArchetypeDefinitions/Tribal/Dialogue/DT_Tribal_Selling"
require "DT/Common/ArchetypeDefinitions/Tribal/Dialogue/DT_Tribal_Sell_ask"

-- Archetypes - Painter
require "DT/Common/ArchetypeDefinitions/Painter/Dialogue/DT_Painter_Greetings"
require "DT/Common/ArchetypeDefinitions/Painter/Dialogue/DT_Painter_Buying"
require "DT/Common/ArchetypeDefinitions/Painter/Dialogue/DT_Painter_Selling"
require "DT/Common/ArchetypeDefinitions/Painter/Dialogue/DT_Painter_Sell_ask"

-- Archetypes - RoadWarrior
require "DT/Common/ArchetypeDefinitions/RoadWarrior/Dialogue/DT_RoadWarrior_Greetings"
require "DT/Common/ArchetypeDefinitions/RoadWarrior/Dialogue/DT_RoadWarrior_Buying"
require "DT/Common/ArchetypeDefinitions/RoadWarrior/Dialogue/DT_RoadWarrior_Selling"
require "DT/Common/ArchetypeDefinitions/RoadWarrior/Dialogue/DT_RoadWarrior_Sell_ask"

-- Archetypes - Designer
require "DT/Common/ArchetypeDefinitions/Designer/Dialogue/DT_Designer_Greetings"
require "DT/Common/ArchetypeDefinitions/Designer/Dialogue/DT_Designer_Buying"
require "DT/Common/ArchetypeDefinitions/Designer/Dialogue/DT_Designer_Selling"
require "DT/Common/ArchetypeDefinitions/Designer/Dialogue/DT_Designer_Sell_ask"

-- Archetypes - Office
require "DT/Common/ArchetypeDefinitions/Office/Dialogue/DT_Office_Greetings"
require "DT/Common/ArchetypeDefinitions/Office/Dialogue/DT_Office_Buying"
require "DT/Common/ArchetypeDefinitions/Office/Dialogue/DT_Office_Selling"
require "DT/Common/ArchetypeDefinitions/Office/Dialogue/DT_Office_Sell_ask"

-- Archetypes - Geek
require "DT/Common/ArchetypeDefinitions/Geek/Dialogue/DT_Geek_Greetings"
require "DT/Common/ArchetypeDefinitions/Geek/Dialogue/DT_Geek_Buying"
require "DT/Common/ArchetypeDefinitions/Geek/Dialogue/DT_Geek_Selling"
require "DT/Common/ArchetypeDefinitions/Geek/Dialogue/DT_Geek_Sell_ask"

-- Archetypes - Brewer
require "DT/Common/ArchetypeDefinitions/Brewer/Dialogue/DT_Brewer_Greetings"
require "DT/Common/ArchetypeDefinitions/Brewer/Dialogue/DT_Brewer_Buying"
require "DT/Common/ArchetypeDefinitions/Brewer/Dialogue/DT_Brewer_Selling"
require "DT/Common/ArchetypeDefinitions/Brewer/Dialogue/DT_Brewer_Sell_ask"

-- Archetypes - Demo
require "DT/Common/ArchetypeDefinitions/Demo/Dialogue/DT_Demo_Greetings"
require "DT/Common/ArchetypeDefinitions/Demo/Dialogue/DT_Demo_Buying"
require "DT/Common/ArchetypeDefinitions/Demo/Dialogue/DT_Demo_Selling"
require "DT/Common/ArchetypeDefinitions/Demo/Dialogue/DT_Demo_Sell_ask"

print("[DynamicTrading] Dialogue Registry Complete \n.")
