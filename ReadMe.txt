How To Use:
---------------

First place bank files into the bank folder you want to extract. Once extracted, 
you will find the wav files in the wav folder with another folder with the same 
name as the bank file.

To build the bank files, you will need to replace the wav files with your own 
and if you want, you can edit the txt file to your new wav file names. After that 
click File->Build. You will now find the built bank files in the build folder.

When replacing the wav files they should be in this format - 

Type: WAV
Format: PCM
Bit Depth - 16 Bits
Sample Rate: Same as the extracted wavs, normally - 44khz or 48khz.

Version History:
--------------------

0.0.1.6 - Fixed a bug with the config file.
0.0.1.5 - Updated Qt5Core.dll to a newer version. Added console window to the program and added a build folder so it doesn't edit the original bank file. 
0.0.1.4 - Complete code overhaul and new Fmod api, Improved FSB Info and you can now play tracks when double clicking them. Should be no crashing now. 
0.0.1.3 - Fixed a problem loading large bank files.
0.0.1.2 - Added FMOD Bank Profile to Options and FSB Info.
0.0.1.1 - Fixed a crashing bug.
0.0.1.0 - Initial Release