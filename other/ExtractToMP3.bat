@echo off

setlocal enabledelayedexpansion


REM Set the folder path where the .fsb files are located

set "fsb_folder=C:\Users\Gebruiker\Downloads\Bloodborne Game of the Year Edition v1.09\CUSA03173\dvdroot_ps4\sound"


REM Set the path to the vgmstream-cli.exe file

set "vgmstream_cli=C:\Users\Gebruiker\Desktop\fsbext-master\other\vgmstream-cli.exe"


REM Set the path to the lame.exe file (assuming it's in the same folder as vgmstream_cli)

set "lame_exe=C:\Users\Gebruiker\Desktop\fsbext-master\other\lame.exe"


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