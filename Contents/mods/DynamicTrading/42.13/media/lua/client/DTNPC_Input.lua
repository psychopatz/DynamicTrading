-- ==============================================================================
-- DTNPC_Input.lua
-- Client-side Logic: Listens for key presses to trigger actions.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCInput = DTNPCInput or {}

function DTNPCInput.OnKeyPressed(key)
    if key == Keyboard.KEY_K then
        
        local player = getPlayer()
        if not player then return end

        local occupations = {
            "General", "Farmer", "Butcher", "Doctor", "Mechanic", "Survivalist", 
            "Gunrunner", "Foreman", "Scavenger", "Tailor", "Electrician", "Welder", 
            "Chef", "Herbalist", "Smuggler", "Librarian", "Angler", "Sheriff", 
            "Bartender", "Teacher", "Hunter", "Quartermaster", "Musician", "Janitor", 
            "Carpenter", "Pawnbroker", "Pyro", "Athlete", "Pharmacist", "Hiker", 
            "Burglar", "Blacksmith", "Tribal", "Painter", "RoadWarrior", "Designer", 
            "Office", "Geek", "Brewer", "Demo"
        }
        
        local randomOcc = occupations[ZombRand(#occupations) + 1]
        local randomWalk = 0.04 + (ZombRand(5) / 100) -- 0.04 to 0.08
        local randomRun = 0.06 + (ZombRand(8) / 100) -- 0.06 to 0.13
        
        player:Say("Signal Sent: Spawning " .. randomOcc .. " NPC...")

        local args = {
            occupation = randomOcc,
            walkSpeed = randomWalk,
            runSpeed = randomRun
        }

        sendClientCommand(player, "DTNPC", "Spawn", args)
    end
end

Events.OnKeyPressed.Add(DTNPCInput.OnKeyPressed)
