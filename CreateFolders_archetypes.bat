@echo off
setlocal enabledelayedexpansion

:: =========================================================
:: CONFIGURATION
:: =========================================================
set "InputFile=archetypes.txt"

:: Updated Relative Path to point deep into the mod structure
set "BaseDir=Contents\mods\DynamicTrading\42.13\media\textures\Portraits"

echo.
echo =======================================================
echo  DYNAMIC TRADING - AUTO FOLDER GENERATOR
echo  Reading IDs from: %InputFile%
echo  Target Directory: .\%BaseDir%\
echo =======================================================
echo.

:: 1. Check if input file exists
if not exist "%InputFile%" (
    echo [ERROR] Could not find "%InputFile%" in this folder.
    echo Please make sure the file exists and try again.
    pause
    exit /b
)

:: 2. Loop through every line in the text file
for /f "usebackq tokens=*" %%A in ("%InputFile%") do (
    set "Line=%%A"
    
    :: --- FILTERING LOGIC ---
    :: We use a flag to determine if we should process this line
    set "IsValid=1"

    :: Skip the Header lines
    if "!Line!"=="Extracted Archetype IDs:" set "IsValid=0"
    if "!Line!"=="========================" set "IsValid=0"
    
    :: Skip the Column Title
    if "!Line!"=="UniqueID" set "IsValid=0"
    
    :: Skip empty lines (just in case)
    if "!Line!"=="" set "IsValid=0"

    :: --- EXECUTION ---
    if "!IsValid!"=="1" (
        call :Make "!Line!"
    )
)

echo.
echo =======================================================
echo  DONE! All folders created.
echo =======================================================
pause
exit

:: =========================================================
:: FUNCTION: CREATE FOLDERS
:: =========================================================
:Make
set "ID=%~1"

:: Trim spaces just in case
set "ID=%ID: =%"

if "%ID%"=="" goto :eof

:: Create Main Archetype folder
if not exist "%BaseDir%\%ID%" mkdir "%BaseDir%\%ID%"

:: Create Gender Subfolders
if not exist "%BaseDir%\%ID%\Male" mkdir "%BaseDir%\%ID%\Male"
if not exist "%BaseDir%\%ID%\Female" mkdir "%BaseDir%\%ID%\Female"

echo [OK] Created: %ID%
goto :eof