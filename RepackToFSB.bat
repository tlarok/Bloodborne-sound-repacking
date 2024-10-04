@echo off

setlocal enabledelayedexpansion

:: Function to select folder with a message in the dialog box
set "MP3inputPath="
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder containing converted MP3/OGG files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "MP3inputPath="<temp.txt
del temp.txt

echo Selected MP3 input folder: %MP3inputPath%
echo.

:: Check for the first subfolder and the 00001 subfolder inside it
set "firstSubfolder="
for /d %%F in ("%MP3inputPath%\*") do (
    set "firstSubfolder=%%F"
    goto :CheckNestedFolder
)

:CheckNestedFolder
if not defined firstSubfolder (
    echo ERROR: No subfolders found in the selected input folder.
    echo[
    echo Select the folder where the FSBs were converted.
    echo[
    echo Possibly: ..\CUSAXXXXX\dvdroot_ps4\sound\converted
    echo[
    echo Terminating the script, try again.
    pause
    exit /b
)

if not exist "!firstSubfolder!\00001" (
    echo ERROR: The subfolder "00001" does not exist inside the first folder.
    echo[
    echo You most likely selected the wrong folder.
    echo[
    echo Terminating the script, try again.
    pause
    exit /b
)

:: Check for .mp3 or .ogg files in the 00001 folder
set "foundFiles=0"
for %%G in ("!firstSubfolder!\00001\*.mp3" "!firstSubfolder!\00001\*.ogg") do (
    set "foundFiles=1"
)

if !foundFiles! equ 0 (
    echo ERROR: No .mp3 or .ogg files found inside the "00001" folder.
    echo[
    echo Please point to the "converted" folder which contains the right structured files/folders.
    echo[
    echo Terminating the script, try again.
    pause
    exit /b
)

:: Function to select output folder with a message in the dialog box
set "FSBoutputPath="
:SelectFSBOutput
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the output folder for repacked files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "FSBoutputPath="<temp.txt
del temp.txt

echo Selected FSB output folder: %FSBoutputPath%
echo.

:: Check if there are existing .fsb files in the selected output path
if exist "%FSBoutputPath%\*.fsb" (
    :: Display a pop-up message box to confirm overwrite
    set "overwrite=0"
    powershell -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('There are already .fsb files in the output folder. Do you want to overwrite them?', 'Overwrite Confirmation', [System.Windows.Forms.MessageBoxButtons]::YesNo)" > temp.txt
    set /p "overwrite="<temp.txt
    del temp.txt

    if /i "!overwrite!" NEQ "Yes" (
        echo[
        echo You chose not to overwrite the existing files.
        echo Selecting the FSB output folder again...
        echo[
        goto SelectFSBOutput
    )
)

:: Set path to the FMOD Bank Tool in the current folder \Fmod\fsbankcl.exe
set "FmodBankToolPath=%CD%\Fmod\fsbankcl.exe"

echo Selected FMod Bank Tool path: %FmodBankToolPath%
echo.

:: Check if the outputPath exists, create it if it doesn't
if not exist "%FSBoutputPath%" (
    echo[
    echo Output directory "%FSBoutputPath%" does not exist. Creating it...
    echo[
    mkdir "%FSBoutputPath%"
)

:: Create Temporary Data Cache Path (based on the output path)
set "DataCache=%FSBoutputPath%\cache"
mkdir "%DataCache%"

:: Loop through each folder in the base path
for /d %%F in ("%MP3inputPath%\*") do (
    set "folderName=%%~nxF"
    set "inputFolder=%%F"
    set "outputFile=%FSBoutputPath%\%%~nxF.fsb"

    :: Build the command and execute it
    if exist "!inputFolder!" (
        set "finalCommand="%FmodBankToolPath%" -o "!outputFile!" "!inputFolder!" -format mp3 -quality 25 -recursive -cache_dir "!DataCache!""

        echo Processing folder: !folderName!
        echo Input folder: !inputFolder!
        echo Output file: !outputFile!
        echo[
        echo Fmod Bank command:
        echo !finalCommand!
        echo[

        !finalCommand!

        :: Delete Temporary Cache Files
        del /s "%DataCache%\*.fobj" 1>nul
    ) else (
        echo ERROR: The input folder "!inputFolder!" does not exist. Skipping...
    )
)

:: Delete Temporary Cache Folder
rmdir %DataCache%

echo[
echo Done!
echo[
echo You can now close this window...
echo[
pause
