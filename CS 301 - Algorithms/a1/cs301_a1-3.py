from datetime import datetime
import numpy as np
xarr=[]
yarr=[]

f = open('/Users/gorkemyar/PythonProjects/CS301/random dna.txt','r')
allLines=f.readlines()
for line in allLines:
    line=line.strip('\n').lower()
    if len(line)>0 and ord('z')>=ord(line[0])>=ord('a'):
        if len(xarr)<30:
            xarr.append(line)
        elif len(yarr)<30:
            yarr.append(line)
        else:
            break
print(xarr)
print(yarr)
alltime=[]
num=0
for i in range(30):
    X = xarr[i]
    Y = yarr[i]
    lX = len(X)
    lY = len(Y)

    start_time = datetime.now()
    def lcs(X,Y,i,j):
        if (i == 0 or j == 0):
            return 0
        elif X[i-1] == Y[j-1]:
            return 1 + lcs(X,Y,i-1,j-1)
        else:
            return max(lcs(X,Y,i,j-1),lcs(X,Y,i-1,j))

    num=lcs(X,Y,lX,lY)
    end_time = datetime.now()
    alltime.append((end_time - start_time).total_seconds())

nparr=np.array(alltime)

print(nparr.mean())
print(nparr.std())