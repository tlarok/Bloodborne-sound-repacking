@echo off

setlocal enabledelayedexpansion

:: Function to select the folder containing .fsb files
set "fsb_folder="

powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder containing .fsb files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "fsb_folder="<temp.txt
del temp.txt

echo Selected FSB folder: %fsb_folder%
echo.

:: Check for .fsb files in the selected folder
if not exist "%fsb_folder%\*.fsb" (
    echo No .fsb files found in the selected folder.
    echo Please select a folder that contains .fsb files.
    pause
    exit /b
)

:: Set paths for vgmstream-cli and lame executables in the current directory
set "vgmstream_cli=%~dp0vgstream\vgmstream-cli.exe"
set "lame_exe=%~dp0lame\lame.exe"

echo Selected vgmstream-cli path: %vgmstream_cli%
echo Selected lame path: %lame_exe%
echo.

:: Create a "converted" folder inside the fsb folder if it doesn't exist
if not exist "%fsb_folder%\converted" mkdir "%fsb_folder%\converted"

:: Loop through each .fsb file in the specified folder
for %%F in ("%fsb_folder%\*.fsb") do (
    :: Get the base name of the .fsb file (without extension)
    set "basename=%%~nF"

    :: Create a subfolder inside the "converted" folder with the base name
    if not exist "%fsb_folder%\converted\!basename!" mkdir "%fsb_folder%\converted\!basename!"

    :: Run the vgmstream-cli.exe command for the current .fsb file
    :: Output .wav files directly into the appropriate "converted" subfolder
    "%vgmstream_cli%" -D 2 -S 0 -o "%fsb_folder%\converted\!basename!\?05s?n.wav" "%%F"

    :: Loop through each .wav file that was generated in the current subfolder
    for %%M in ("%fsb_folder%\converted\!basename!\*.wav") do (
        :: Extract the first 5 characters of the .wav file name
        set "subfolder=%%~nM"
        set "subfolder=!subfolder:~0,5!"

        :: Create a subfolder inside the base folder under "converted" with the first 5 characters of the .wav name
        if not exist "%fsb_folder%\converted\!basename!\!subfolder!" mkdir "%fsb_folder%\converted\!basename!\!subfolder!"

        :: Move the .wav file to the subfolder and rename it
        set "newname=%%~nM"
        set "newname=!newname:~5!"
        move "%%M" "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav"

        :: Convert the .wav file to .mp3 using lame
        "%lame_exe%" -V 2 "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav" "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.mp3"

        :: Delete the original .wav file after conversion
        del "%fsb_folder%\converted\!basename!\!subfolder!\!newname!.wav"
    )
)

echo[
echo Extraction Done!
echo[
echo You can now close this window...
echo[
pause
