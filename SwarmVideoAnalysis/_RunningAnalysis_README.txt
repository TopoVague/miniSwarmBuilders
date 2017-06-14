VIDEO ANALYSIS README: 
Instructions for extracting data from videos using Open Source Computer Vision (Various imaging outputs/ Snapshots/ Histograms)

Requirements: 
-WinPython-32bit-2.7.10.3, 
-Numpy,MatplotLib
-OpenCV
Included Scripts for running the analysis
01_cropVideo.py
02_analyze_o.py
02_analyze_trace.py
03_histogram.py
imgSetup.py
testBlob.py
Steps to Run the scripts
/00-install all necessary libraries////////////////////////////////////////////////////////////////////////////////////////
> Install WinPython 32 (2.7.x),  Open CV (file name: opencv) , NumPy and MatplotLib
> Run IDLE (Python GUI) from WinPython-32bit-2.7.10.3 installation folder (wherever that is in your computer)
>Open:  00_importTest.py 
> Run the script by entering F5 to ensure you have everything setUP
/01-record videos and store them in one folder/////////////////////////////////////////////////////////////////////////////////////////
> Record Videos using webcam (adjust thresholds to allow for good reading of color values in simulation) > Save videos in inputVideos folders
02-crop Videos/////////////////////////////////////////////////////////////////////////////////////////

> Open '01.cropVideo.py' file from within Python and set the name of the video file you would like to be processed 
> Run the script by entering F5 
> Crop the frame by clicking on one point (i.e.upper left cropping frame corner), then another (lower right cropping frame corner). >Press Enter; this will give you coordinate values.
>These values get registered in the 'Python Shell' file. Repeat the same for Threshold value* 
IMPORTANT : The values of the coordinates used to crop the video frame need to be even numbers, so these values should be rounded accordingly in the script. 
/03A-Analyze Video/////////////////////////////////////////////////////////////////////////////////////////
> Copy/Paste values from the PythonShell into the analyze script  (cropPts=Ê VALUES; partThresh= VALUE)
> Run Script: This gives you a cropped version of the video with highlighted clusters in different colors.

> Wait for the Video to run til the end, 
/03B-Analyze Video/////////////////////////////////////////////////////////////////////////////////////////
>Open and Run the script analyzeTrace.py
>
**There is a way to visualize the path of each agent in the output file. I will update instructions to include this.
/04-Plot the results /////////////////////////////////////////////////////////////////////////////////////////
>then Run the 'histogram' script...Ê
> Deactivate Frame mask and Run script > it will crash, then run it again after reactivating
>a graph will be saved in the exprotedGraphs folder showing the occupancy over time
The above process will yield various analysis outputs. It will provide videos which provide different kinds of imaging, such as color coding of agent aggregation (clusters); snapshots from the video recording or histogram charts indicating size cluster relative to time lapse.



