# TLab-Photometry

******************************
DISCLAIMER: 
******************************
This analysis pipeline may still contain some bugs
The convertH5_FP function works on H5 files acquired using wavesurfer
The processParams file does NOT include "default" values. Please edit it to cater to your experimental needs.
******************************
FOR LAB: 
******************************
Please add this package to your computers through MATLAB and GIT and make sure the package is in the path.

HOW TO RUN:

1. Run the convertH5_FP function to convert H5 files acquired from wavesurfer into .MAT files
2. Edit the processParams file in the Parameter Files folder to desired analysis methods and save it as a new file
3. Run the analyzeFP function

OPTIONALLY:
- You can use the files in the "Helper Functions" folder to write your own analysis scripts
