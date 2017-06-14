#Set up for analysis
#Cropping finding histograms etc
import cv2
import numpy as np



#vfile='inputVideos/20_hexPartsArrayed_1.avi'
vfile='inputVideos/GOPR0667.avi'
cropPts=[]

imgThresh=100


def cropClick(event, x, y, flags, param):
    # grab references to the global variables
    global img , cropPts
         
    # if the left mouse button was clicked, record the starting
    # (x, y) coordinates and indicate that cropping is being
    # performed
    
    if event == cv2.EVENT_LBUTTONDOWN:
        cropPts.append((x,y))
        print (x,y)

    if event == cv2.EVENT_RBUTTONDOWN:
        print 'poly', cropPts
        cropPts=[]
        
#    if event == cv2.EVENT_RBUTTONDOWN:
#        if len(cropPts) >= 2:
#            cv2.rectangle(img,cropPts[0],cropPts[1],(0,255,0))
#            rect=img[min(refPt[1],pt2[1]):max(refPt[1],pt2[1]),min(refPt[0],pt2[0]):max(refPt[0],pt2[0]),:]
#            cv2.imshow('rect',rect)
#        else:
#            refPt = (x, y)
#            print refPt 

#    if event == cv2.EVENT_MOUSEMOVE:
#        print "."   



def getCrop(img):
    cv2.imshow('croppingWindow',img)
    cv2.setMouseCallback('croppingWindow',cropClick)
    cv2.waitKey(0)
    cv2.rectangle(img,cropPts[0],cropPts[1],(0,255,0),1)
    cv2.imshow('croppingWindow',cv2.pyrDown(img))

    imgC=img[cropPts[0][1]:cropPts[1][1],cropPts[0][0]:cropPts[1][0],:]
    cv2.imshow('croppedRegion',imgC)
    cv2.waitKey(0)
    
    return cropPts


def newThresh(t):
    global imgThresh
    imgThresh=t
    imt=cv2.inRange(imgC,t,255)  
    cv2.imshow("Thresh",imt)
    



vid=cv2.VideoCapture(vfile)
ret,frame=vid.read()
frame = cv2.pyrDown(frame)
cropPts=getCrop(frame)
print 'cropPts =', cropPts  #print out points used for cropping

imgC=frame[cropPts[0][1]:cropPts[1][1],cropPts[0][0]:cropPts[1][0],:]
imgC=cv2.cvtColor(imgC,cv2.COLOR_RGB2GRAY)

cv2.imshow('croppedRegion',imgC)
cv2.createTrackbar("Threshold","croppedRegion",imgThresh,250,newThresh)    

cv2.waitKey(0)
print 'partThresh=', imgThresh

cv2.destroyAllWindows() 

