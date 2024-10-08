# Bloodborne Sound Repacking

Guide and Tools for Repacking Sounds in Bloodborne and Other Games with FSB Files, Remember! if you do this with the game on shadPS4, INSTALLTHE PKG ON THE MAIN SHADPS4!

This process uses the following tools: lame.exe, fsbankcl.exe, and vgmstream-cli.exe.

Firstly, complete the bat file guide. Windows won't allow you to use files from the internet without proper certification.


## bat file guide:
### Step 1: Create RepackToFSB.bat

Copy the code below.
Create a .txt file, paste the copied code into it, and save it as RepackToFSB.bat.
Replace the existing empty file with this new one in your project.

```batch
@echo off
setlocal enabledelayedexpansion

:: Function to select the MP3 input folder
set "MP3inputPath="
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder containing the converted MP3 files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "MP3inputPath="<temp.txt
del temp.txt

echo Selected MP3 input folder: %MP3inputPath%
echo.

:: Set the FSB output folder with a dialog box
set "FSBoutputPath="
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the output folder for repacked files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "FSBoutputPath="<temp.txt
del temp.txt

echo Selected FSB output folder: %FSBoutputPath%
echo.

:: Set the FMod Bank Tool path to the current folder
set "FmodBankToolPath=%cd%\Fmod\fsbankcl.exe"
echo Using FMod Bank Tool path: %FmodBankToolPath%
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
        :: Build the command and execute it
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
        :: Print error message if input folder doesn't exist
        echo ERROR: The input folder "!inputFolder!" does not exist. Skipping...
    )
)

:: Delete Temporary Cache Folder
rmdir %DataCache%

echo[
echo Repacking Done!
echo[
echo You can now close this window...
echo[
pause
```










### step 2: Create ExtractToMP3.bat
Copy the new code below.
Create another .txt file, paste the copied code into it, and save it as ExtractToMP3.bat.
Replace the existing empty file with this new one in your project.









```batch
@echo off
setlocal enabledelayedexpansion

REM Function to select the folder containing .fsb files
set "fsb_folder="
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder containing .fsb files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "fsb_folder="<temp.txt
del temp.txt

echo Selected FSB folder: %fsb_folder%
echo.

REM Set the vgmstream-cli.exe path to the current folder
set "vgmstream_cli=%cd%\vgstream\vgmstream-cli.exe"
echo Using vgmstream-cli path: %vgmstream_cli%
echo.

REM Set the lame.exe path to the current folder
set "lame_exe=%cd%\lame\lame.exe"
echo Using lame path: %lame_exe%
echo.

REM Create a "converted" folder inside the fsb folder if it doesn't exist
if not exist "%fsb_folder%\converted" mkdir "%fsb_folder%\converted"

REM Loop through each .fsb file in the specified folder
for %%F in ("%fsb_folder%\*.fsb") do (
    REM Get the base name of the .fsb file (without extension)
    set "basename=%%~nF"
   
    REM Create a subfolder inside the "converted" folder with the base name
    if not exist "%fsb_folder%\converted\!basename!" mkdir "%fsb_folder%\converted\!basename!"

    REM Run the vgmstream-cli.exe command for the current .fsb file
    REM Output .wav files directly into the appropriate "converted" subfolder
    "%vgmstream_cli%" -D 2 -S 0 -o "%fsb_folder%\converted\!basename!\?05s?n.wav" "%%F"

    REM Loop through each .wav file that was generated in the current subfolder
    for %%M in ("%fsb_folder%\converted\!basename!\*.wav") do (
        REM Extract the first 5 characters of the .wav file name
        set "subfolder=%%~nM"
        set "subfolder=!subfolder:~0,5!"
       
        REM Create a subfolder inside the base folder under "converted" with the first 5 characters of the .wav name
        if not exist "%fsb_folder%\converted\!basename!\!subfolder!" mkdir "%fsb_folder%\converted\!basename!\!subfolder!"

        REM Move the .wav file to the subfolder and rename it
        set "newname=%%~nM"
        set "newname=!newname:~5!"
        move "%%M" "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav"

        REM Convert the .wav file to .mp3 using lame
        "%lame_exe%" -V 2 "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav" "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.mp3"

        REM Delete the original .wav file after conversion
        del "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav"
    )
)

echo Extraction Done!
echo[

echo You can now close this window...
echo[
pause
```

## sound-repacking guide:

Open ExtractToMP3.bat and choose the folder containing the .fsb files from Bloodborne. The path should look like this:
bloodborne\CUSA03173\dvdroot_ps4\sound.

If you don't know where the game is installed, open shadps4 and check the game path.

After obtaining the converted files(please note that this process may take some time) start RepackToFSB.bat and select the converted .fsb files from the directory, which should be like this:
bloodborne\CUSA03173\dvdroot_ps4\sound\converted.

Also, choose a folder for the repacked audio (the final .fsb files). This may be either:
"bloodborne\CUSA03173\dvdroot_ps4\sound" or
"bloodborne\CUSA03173\dvdroot_ps4\sound\repacked"
(if you want to keep a backup).
