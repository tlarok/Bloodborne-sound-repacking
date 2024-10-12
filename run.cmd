@echo off

REM Paths to converter programs
set LAME_DIR="lame/lame.exe"
set VGMSTREAM_DIR="vgstream/vgmstream-cli.exe"
set FMOD_DIR="Fmod/fsbankcl.exe"


REM Limit of thread count during processing. 0 means we 'll use as many threads as CPU core count
set THREADS=0
REM Function to select the folder containing .fsb files
set "INPUT_DIR="
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder containing .fsb files'; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }" > temp.txt
set /p "INPUT_DIR="<temp.txt
del temp.txt

echo Selected FSB folder: %INPUT_DIR%
call "python" main.py --input_dir %INPUT_DIR% --vgmstream %VGMSTREAM_DIR% --lame %LAME_DIR% --fmod %FMOD_DIR% --threads %THREADS%

echo You can now close this window...
pause