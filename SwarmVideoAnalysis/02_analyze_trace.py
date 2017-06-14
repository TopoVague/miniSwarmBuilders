#Script to analyze video input using OPEN CV and output videos and texts for analysis
#Created by Nills Napp, Spring 2016
#Extended and Edited by Evangelos Pantazis, Spring 2017



#import libraries
import cv2
import numpy as np
import blob
import pickle


#READ HERE PRIOR TO RUNNING
# if folders do not exist create a set of directories for saving the output in separate folders
# 01 dirname 'inputVideos' here is where you should place the videos you want to analyse
# 02 dirname 'exportedFiles' here is where the files for the analysis will be saved
# 03 dirname 'exportedVideos' here is where the processed videos will be saved
# 04 dirname 'exportedImages' here is where saved screenshots will be saved
# you can press key 'p' to sace a sreenshot


# change to the number of the video you are analyzing so that you save output files accordingly
fnum=667
fileNum='667'

oFileCount=open('exportedFiles/counts %d.dat'%fnum,'w')
oFileBlobs=open('exportedFiles/blobCounts %d.dat'%fnum,'w')
oFileMove=open('exportedFiles/motion %d.dat'%fnum,'w')
opkfile=open('exportedFiles/bloblist%d.pkf'%fnum,'w')

ovfile='exportedVideos/output%d.avi'%fnum
framePath='exportedImages/'
#cap = cv2.VideoCapture('20_hexPartsArrayed_%d.avi'%fnum)
cap = cv2.VideoCapture('inputVideos/GOPR0%d.avi'%fnum)


# coloring of parts
robLow=(0,0,50)
robHigh=(100,100,255)

#fading out of trace of bots
fadeTime= 0.09


#cut & paste from imgSetup.py
cropPts = [(312, 12), (846, 530)]
partThresh= 100

#interval for saving a screenshot
screenshotCnt=0
frameSkip=500
frameCount=0

frameMask=cv2.imread('cropFrame.jpg')
frameMask=cv2.inRange(frameMask,(1,1,1),(255,255,255))

#cv2.imshow('mask',frameMask)
#cv2.waitKey(0)

#initialize files to save counts of clusters
blobCounts=[]
blobList=[]


def nextFrame():
    
    global cropPts
    global cap,fnum
    global frameCount

    while frameCount < frameSkip:
        if frameCount == 0:
            print 'Skipping Frames=' , frameSkip
        frameCount=frameCount+1
        ret, frame = cap.read()
        if not ret:
            print 'Could not skip frames'

    #change number to skip frames   
    for i in range(2):
        frameCount=frameCount+1
        ret, frame = cap.read()
        if not ret:
            break
    #don't process if the frame does not
    #ret, frame = cap.read()

    if ret:
        frame=cv2.pyrDown(frame)
        return ret, frame[cropPts[0][1]:cropPts[1][1],cropPts[0][0]:cropPts[1][0],:]

#        return ret, frame

    else:
        
        if fnum == 17:
            fnum=18
            print 'Switched Frame'
            cap.release()
            cap = cv2.VideoCapture('Video 18.mp4')
            return nextFrame()
        else:
            return ret, frame
    
def accFrame(acc,frame,fade):
    acc=acc*(1-fade) + frame
    return acc




#adjustThreshold

#process

#ret, frame = cap.read()
ret, frame = nextFrame()
compsize   = cv2.pyrDown(frame).shape
#print compsize

#save a frame of the cropped section of the image
cv2.imwrite('cropFrame.jpg',frame)

#open ouput video file
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out    = cv2.VideoWriter(ovfile,fourcc, 20.0, (frame.shape[1],frame.shape[0]))


out1   = cv2.VideoWriter('exportedVideos/O1_originalVid'+ovfile,fourcc, 20.0, (frame.shape[1],frame.shape[0]))
out2    = cv2.VideoWriter('exportedVideos/O2_B&W'+ovfile,fourcc, 20.0, (frame.shape[1],frame.shape[0]))
out3   = cv2.VideoWriter('exportedVideos/O3_Blob1'+ovfile,fourcc, 20.0, (frame.shape[1],frame.shape[0]))
out4    = cv2.VideoWriter('exportedVideos/O4'+ovfile,fourcc, 20.0, (frame.shape[1],frame.shape[0]))


#cv2.namedWindow('thresh')
#cv2.namedWindow('orig')
#cv2.namedWindow('analyze')
#cv2.namedWindow('robot')

#start analysis script
imgComposit = np.zeros(frame.shape)
imgComposit = imgComposit.astype('uint8')

gray    = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
imgTold = cv2.inRange(gray,partThresh,0)

imgTbot = cv2.inRange(frame,robLow,robHigh)

imgAccPart  = np.zeros(imgTold.shape)
imgAccRobot = np.zeros(imgTold.shape)

#temporary image
imgTmp = imgAccPart
imgOnes= np.ones(imgTold.shape)*255


movesum=0
screenshotCnt=0


#while new frames are showing up
while(ret):

#   Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    imgT = cv2.inRange(gray,partThresh,255)
    imgT = np.minimum(imgT,frameMask) 

    #merge close by clusters
    imgT=cv2.dilate(imgT,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(2,2)))

    imgTbot = cv2.inRange(frame,robLow,robHigh)
    imgTbot = np.minimum(imgTbot,frameMask) 
    imgTbot=cv2.erode(imgTbot,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(2,2)))
    imgTbot=cv2.dilate(imgTbot,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(2,2)))

    #show frame
    imgComposit[:compsize[0],:compsize[1],:]=cv2.pyrDown(frame)

    #show Parts 
    #imgComposit[compsize[0]:,:compsize[1],:]=cv2.cvtColor(cv2.pyrDown(imgTbot),cv2.COLOR_GRAY2RGB)

    #Display the resulting frame
    cv2.imshow('frame',cv2.pyrDown(gray))

    #show original
    cv2.imshow('orig',cv2.pyrDown(frame))
    #show threshold
    #cv2.imshow('frame',imgT)

    #out.write(cv2.cvtColor(imgT.astype('uint8'),cv2.COLOR_GRAY2RGB))

    #analyze image motion threshold
    imgTmp=np.absolute(imgT-imgTold)
    imgTmp=cv2.erode(imgTmp,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(1,1)))
    imgTmp=cv2.dilate(imgTmp,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(1,1)))

    

    #change fading speed for robots
    imgAccPart=accFrame(imgAccPart,imgTmp,fadeTime)
    imgAccRobot=accFrame(imgAccRobot,imgTbot,fadeTime)

    
    #imgAnalyze=imgTmp    
   
    cv2.imshow('analyzeMotion',cv2.cvtColor(np.round(imgAccPart.astype('uint8')),cv2.COLOR_GRAY2RGB))           
    
    #imgTmp=np.zeros(frame.shape)
    #show robots and parts
    imgTmp=cv2.cvtColor(imgT,cv2.COLOR_GRAY2RGB)
    imgComposit[compsize[0]:,compsize[1]:,:]=cv2.pyrDown(imgTmp)
    imgTmp[:,:,2]=imgTbot    
    imgComposit[:compsize[0],compsize[1]:,:]=cv2.pyrDown(imgTmp)


    out3.write(imgTmp)   
    imgT=cv2.dilate(imgT,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(2,2)))
    blobL=blob.slowBlob(imgT)

    imgTmp=blob.imgL
    #imgComposit[compsize[0]:,:compsize[1],:]=cv2.pyrDown(imgTmp)
    #imgTmp=np.zeros(frame.shape)
    imgTmp=cv2.cvtColor(imgT,cv2.COLOR_GRAY2RGB)    
    imgTmp[:,:,2]=np.minimum(imgAccRobot,imgOnes) 
    imgComposit[compsize[0]:,:compsize[1],:]=cv2.pyrDown(imgTmp)

    out4.write(imgTmp)
    #print 'Blob Count=', len(blobL)
    print 


    blobCounts.append(len(blobL))
    blobList.append(blobL)


    cv2.imshow('blobs',imgTmp)

    cv2.imshow('All_Analysis_robots',imgComposit)

    #output results    
    movesum =np.sum(np.sum(imgAccPart))/255
    print 'Frame=%s /'%frameCount, '   Movesum=%f /'%movesum , '  Blobcount=%d /'%len(blobL) , 'Blobsizes:%s /'%blobL

    oFileCount.write('%d\n'%len(blobL))
    bs=str(blobL)
    oFileBlobs.write(bs[1:-1] + '\n')
    oFileMove.write('%f\n'%movesum)

    #write frame
    out.write(imgTmp.astype('uint8'))
    #out.write(imgTmp)

    screenshotCnt=screenshotCnt+1
    #print frameCnt
    if screenshotCnt > frameSkip:
        
        cv2.imwrite(framePath + fileNum +'frameCapture%d.jpg'%screenshotCnt,imgTmp)
        #screenshotCnt=0
        print ('saved a frame')
        #screenshotCnt=screenshotCnt+1
        
    if (cv2.waitKey(1) & 0xFF) == ord('p'):
            cv2.imwrite(framePath +fileNum+ 'frameCapture%d.jpg'%screenshotCnt,imgTmp)
            screenshotCnt=screenshotCnt+1
    if (cv2.waitKey(1) & 0xFF) == ord('q'):
            break

    #set up for next loop
    imgTold=imgT
    out1.write(frame)
    out2.write(cv2.cvtColor(imgT,cv2.COLOR_GRAY2RGB))
    out.write(cv2.cvtColor(np.transpose(imgT),cv2.COLOR_GRAY2RGB))
  

    #set up for next loop
    imgTold=imgT

    #grab the next frame 
    ret, frame = nextFrame()     

# When everything done, release the capture
pickle.dump(blobList,opkfile)
opkfile.close()

cap.release()
out1.release()
out2.release()
out3.release()
out4.release()

oFileCount.close()
oFileBlobs.close()
oFileMove.close()
print (' made it to the end of the script' )
print ('videos saved at folder exportedVideos with ending%d'%fnum)
cv2.destroyAllWindows()
