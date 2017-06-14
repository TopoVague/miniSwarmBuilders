#Nils Napp
#Histogram Data

import numpy as np
import matplotlib.pyplot as plt
import pickle
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.collections import PolyCollection
from matplotlib.colors import LinearSegmentedColormap


#make part 
partsize=380
clustersize=40

maxz=30
fnum= 670
fname= '670'
fig = plt.figure()
plt.rc('xtick', labelsize=8) 
ax = fig.add_subplot(111, projection='3d')

f=open('exportedFiles/bloblist670.pkf','r')
outname='exportedGraphs/histogram%d.pdf'%fnum

blobList=pickle.load(f)

#blobList=blobList[1]

colors = LinearSegmentedColormap('colormap', cm.jet._segmentdata.copy(), len(blobList))

solidColor=(0.861401557285873, 0.6, 0.706340378197998, 0.9)
#sosolidColor=(0.361401557285873, 1.0, grey, 1.0)
alpha = 0.8
verts = []
zr=np.array((0))
for blobs in blobList:
    z, edges = np.histogram(blobs, clustersize*3,(0,partsize*clustersize))
    #y = 0.5*(z[1:] + z[:-1])
    y = z
    y = np.hstack((zr,z,zr)) # add zero
    x = np.arange(len(y))
#    print blobs
#    print x
#    print y
#    print x[-1]
#    print edges
    verts.append(zip(x, y))

verts = np.array(verts)
n, p, d = verts.shape


poly = PolyCollection(verts, facecolors = [solidColor for i in range(n)])
poly.set_alpha(alpha)
poly.set_edgecolor('black')
poly.set_linewidth(.1)
ax.add_collection3d(poly, zs=np.arange(n), zdir='y')

ax.set_xlabel('ClusterSize')
ax.set_xlim3d(0, p)
ax.set_ylabel('Time (ms)')
ax.set_ylim3d(0,n)
ax.set_zlabel('Cluster Counts')
ax.set_zlim3d(0, 1.2*maxz)

ax.set_xticks(np.array(range(0,clustersize*3,3))+0.5)
ax.set_xticklabels(range(0,clustersize))

print edges
print ax.get_xticks()
print ax.get_xticklabels()
 
plt.savefig(outname)
plt.show()
#read in csv file
#csvfile=open('clsize.csv','rb')
#for line in csvfile

