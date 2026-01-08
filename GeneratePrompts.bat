@echo off
setlocal enabledelayedexpansion

:: =========================================================
:: CONFIGURATION
:: =========================================================
set "OutputFile=Trading_Prompts_ID_Style.txt"

:: Updated Base Style: ID Photo, Neck Up Only, No Body
set "BaseStyle=, Project Zomboid art style, digital painting, semi-realistic, gritty survivalist aesthetic, zombie apocalypse survivors, distinct facial features, ID photo composition, close-up face portrait, headshot only, from the neck up, passport style, front facing, looking straight at camera, isolated on white background, no background, no body, no torso, no hands, high quality, 8k, square aspect ratio --ar 1:1"

:: Clear previous file
if exist "%OutputFile%" del "%OutputFile%"

echo Generatng Prompts...
echo ------------------------------------------------------- >> "%OutputFile%"
echo  DYNAMIC TRADING MOD - ID PORTRAIT PROMPTS
echo  Features: ID Style, Face Only, White Background
echo  Generated: %date% %time%
echo ------------------------------------------------------- >> "%OutputFile%"

:: =========================================================
:: ARCHETYPE CALLS
:: Format: call :Gen "ID" "Description"
:: Note: Descriptions edited to focus on head/neck details only.
:: =========================================================

:: --- GROUP A: ESSENTIALS ---
call :Gen "General" "regular survivors, everyday clothing collars, dirty t-shirts, tired expressions, disheveled hair, nervous looks"
call :Gen "Farmer" "farmers, wearing plaid shirt collars, straw hats or trucker caps, sun-weathered skin, dirt on faces, rural look"
call :Gen "Butcher" "butchers, heavy set build, thick necks, intense expressions, blood splatters on face and neck"
call :Gen "Doctor" "medical doctors, white lab coat collars, stethoscopes around necks, surgical masks pulled down to chin, exhausted eyes, clean glasses"
call :Gen "Mechanic" "mechanics, blue jumpsuit collars, grease smudges on faces, backwards caps, rugged look"

:: --- GROUP B: SURVIVORS ---
call :Gen "Survivalist" "hardcore preppers, camo gear collars, gas masks hanging loose around neck, scars, rugged beards or tied back hair, intense stare"
call :Gen "Gunrunner" "arms dealers, high trench coat collars, dark sunglasses, slicked back hair, intimidating aura"
call :Gen "Foreman" "construction foremen, yellow hard hats, high-visibility vest collars, safety goggles on forehead, commanding expressions"
call :Gen "Scavenger" "wasteland scavengers, layers of mismatched hoodies, goggles on forehead, bandana around neck, dirty and rugged"

:: --- GROUP C: SPECIALISTS ---
call :Gen "Tailor" "tailors and clothiers, measuring tapes draped around neck, pins in collar, glasses, precise look"
call :Gen "Electrician" "electricians, safety glasses on forehead, work shirt collars, technical look"
call :Gen "Welder" "metalworkers, welding goggles lifted onto forehead, soot marks on face, bandana around neck"
call :Gen "Chef" "professional chefs, white chef coat collars, tall chef hats or toques, sweat on brow, food smudges on face"
call :Gen "Herbalist" "nature experts, earth-toned poncho collars, dried flowers in hair or stuck in hats, gentle expressions"

:: --- GROUP D: ODDBALLS ---
call :Gen "Smuggler" "shady smugglers, hoodie hoods up, faces partially obscured by shadows or scarves, shifty eyes, distrustful look"
call :Gen "Librarian" "librarians, reading glasses on chains around neck, hair in buns, older age range, timid but intelligent expressions"
call :Gen "Angler" "fishermen, bucket hats with fishing hooks attached, waterproof rain coat collars, weather-beaten faces, beards"
call :Gen "Sheriff" "police sheriffs, beige uniform collars, stetson cowboy hats, aviator sunglasses, stern authority"
call :Gen "Bartender" "barkeeps, bowtie untied around neck, vest collars, weary but welcoming smiles"
call :Gen "Teacher" "school teachers, sweater vest or blouse collars, lanyards visible at neck, kind but stressed expressions"

:: --- GROUP E: EXTENDED ---
call :Gen "Hunter" "wilderness hunters, fur trapper hats, camo collars, face paint or mud on cheeks, determined expressions"
call :Gen "Quartermaster" "military supply officers, fatigue uniform collars, berets, strict and orderly appearance, clean shaven or tight buns"
call :Gen "Musician" "rockers and musicians, leather jacket collars, bandanas, piercings, dyed hair, makeup"
call :Gen "Janitor" "custodians, blue maintenance uniform collars, caps, tired working class look"
call :Gen "Carpenter" "carpenters, flannel shirt collars, pencils tucked behind ears, sawdust in hair, strong jawlines"
call :Gen "Pawnbroker" "pawn shop owners, cheap suit collars, gold chains around neck, greedy expressions, jeweler loupe over one eye"
call :Gen "Pyro" "arsonists, slight burn scars on face, soot stains, manic expressions, singed hair"
call :Gen "Athlete" "sports coaches and athletes, tracksuit collars, headbands, sweatbands, whistles around neck"
call :Gen "Pharmacist" "pharmacists, clean white coat collars, reading glasses on nose, clinical professional look"
call :Gen "Hiker" "backpackers, windbreaker collars, beanies, tanned skin, adventurous look"
call :Gen "Burglar" "cat burglars, black beanies, black masks pulled up to reveal mouth, sneaky expressions"
call :Gen "Blacksmith" "blacksmiths, muscular necks, heavy soot on face, sweat dripping, intense focus"
call :Gen "Tribal" "primitive survivors, bone necklaces, tribal face paint, wild hair, intense primal look"
call :Gen "Painter" "house painters, white overalls straps, paint splatters on face and hair, painter caps"
call :Gen "RoadWarrior" "post-apocalyptic drivers, motorcycle helmets or goggles on forehead, mohawks, dirt, Mad Max aesthetic"
call :Gen "Designer" "interior designers, trendy glasses, colorful scarves around neck, sharp haircuts, judgemental or stylish expressions"
call :Gen "Office" "corporate office workers, suit collars with loosened ties, disheveled hair, stressed corporate look"
call :Gen "Geek" "tech geeks and gamers, graphic t-shirt necklines, thick rimmed glasses, large headphones around neck, pale skin"
call :Gen "Brewer" "moonshiners, suspender straps visible, flushed red cheeks, rustic look"
call :Gen "Demo" "demolition experts, thick protective neck guards, protective visors on forehead, ear protection, grime and dust"

:: =========================================================
:: END OF SCRIPT
:: =========================================================
echo Done! Opening file...
start notepad "%OutputFile%"
exit

:: =========================================================
:: FUNCTION: GENERATE
:: =========================================================
:Gen
set "ID=%~1"
set "Desc=%~2"

echo. >> "%OutputFile%"
echo ======================================================= >> "%OutputFile%"
echo  %ID% >> "%OutputFile%"
echo ======================================================= >> "%OutputFile%"
echo. >> "%OutputFile%"
echo Character sheet, grid layout, 5 distinct ID-style face portraits of MALE %Desc%%BaseStyle% >> "%OutputFile%"
echo. >> "%OutputFile%"
echo Character sheet, grid layout, 5 distinct ID-style face portraits of FEMALE %Desc%%BaseStyle% >> "%OutputFile%"
echo. >> "%OutputFile%"

goto :eof