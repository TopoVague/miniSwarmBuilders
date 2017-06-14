#Nils Napp

import cv2
import numpy as np

countColor=30
markColor=25

minBlobSize=60

mask=()
imgL=()
imgLC=()
imgColor=()
blobs=()

colorIdx=0
blobColors=[
(30,43,200),
(30,223,200),
(130,43,50),
(50,223,100),
(50,123,100)
]

testFill=()

def size2color(px):
    pct=1.0*px/350
    if pct < 1.5:
        return (200,10,10)
    elif pct < 2.5:
        return (10,200,10)
    elif pct < 3.5:
        return (10,10,200)
    elif pct < 4.5:
        return (200,10,200)
    elif pct < 5.5:
        return (10,200,200)
    else:
        return (200,200,20)


def slowBlob(img):
    initBlob(img)

    f,pt=findUnmaked()

    while(f):
        markBlob(pt)    
        f,pt=findUnmaked()
    
    return blobs

#set up mask and colors, etc
def initBlob(img):
    global mask
    global imgL,imgLC
    global blobs
    blobs=[]
    mask=np.zeros( (img.shape[0]+2, img.shape[1]+2) )
    mask=mask.astype('uint8')
    imgL=img.copy()
    
    imgL=cv2.cvtColor(imgL,cv2.COLOR_GRAY2RGB)

    imgLC=img.copy()

    imgColor=img.copy()

    imgLC=cv2.erode(imgLC,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(1,1)))

def markBlob(pt):
    global testFill
    global blobColors,colorIdx

    fill=cv2.floodFill(imgL,mask,pt,blobColors[colorIdx])
    colorIdx=(colorIdx+1)%len(blobColors)

#    fill=cv2.floodFill(imgL,mask,pt,np.round(100 + np.random.rand(3)*140).astype('uint8'))

#  fill=cv2.floodFill(imgL,mask,pt,size2color(fill[0]))

    rect=fill[3]
    imgLC[rect[1]:(rect[1]+rect[3]),rect[0]:(rect[0]+rect[2])]=np.minimum(cv2.cvtColor(imgL[rect[1]:(rect[1]+rect[3]),rect[0]:(rect[0]+rect[2])],cv2.COLOR_RGB2GRAY),imgLC[rect[1]:(rect[1]+rect[3]),rect[0]:(rect[0]+rect[2])])

#    cv2.imshow('Hi',imgL)
#    cv2.imshow('HiC',imgLC)    
#    cv2.imshow('maks',fill[2])
#    pt=cv2.moments(mask)
#    print pt
    
#    cv2.waitKey(0)
#    cv2.destroyAllWindows()
    if fill[0] >= minBlobSize:
        blobs.append(fill[0])
#    print fill[0]     
    testFill=fill

def findUnmaked():
    global imgLC
    pt=np.unravel_index(imgLC.argmax(),imgLC.shape)
    if imgLC[pt] == 255:
        return True,(pt[1],pt[0])
    else:
        return False,()

def loadThresh(fname):
    imgorig=cv2.imread(fname)
    imT=cv2.cvtColor(imgorig,cv2.COLOR_RGB2GRAY)
    imT=cv2.inRange(imT,110,255)
    return imT 
