Script main.py converts all the FSB sounds from given input folder to output. It works effeciently spawning as many processes as your system allows.
Full conversion on i9-9960X CPU using 32 threads takes less than 30 minutes

How to use script:
1. You need to download and install python. It was tested on python 3.12, you can get it here - https://www.python.org/downloads/
2. You need to get the encoders:
- vgmstream-cli.exe
- lame.exe
- fsbankcl.exe
Each one should pe placed in separate folder
3. When things are ready open run.cmd in any text editor and setup the following

set LAME_DIR="lame/lame.exe" 
set VGMSTREAM_DIR="vgstream/vgmstream-cli.exe"
set FMOD_DIR="Fmod/fsbankcl.exe"

LAME_DIR should contain path to lame encoder executable. Same applies to VGMSTREAM_DIR and FMOD_DIR, they should contain paths to lame and fsbankcl respectively

Then launch run.cmd command and select the directory with FSB sounds. Converted sounds will be placed in "converted" subfolder within it. 

Example output of script:
Output directory: converted
Available threads count: 32
Collecting *.fsb files in directory: sound
Found 504 files to process
Unpacking FSB files
Progress: [------------------->] 100%
Unpacked 70516 WAV files
Processing wav to mp3
Progress: [------------------->] 100%
Packing mp3 to FSB
Progress: [------------------->] 100%
Packing completed
Repacked files stored in sound\converted
Cleaning temp folders
Elapsed time: 00:29:34.715680



