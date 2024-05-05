import numpy as np
import cv2
#import struct
i=0
j=0
image = cv2.imread("./image.jpg",cv2.IMREAD_GRAYSCALE)

def text_save(filename, data):#filename為dat寫入路徑，data為寫入的數據列表.
  file = open(filename,'a')
  for i in range(len(data)):
    s = str(data[i]).replace('[','').replace(']','').replace(" ",'\n').replace(" ",'')+'\n'#去除[]，有空白換行
    s = s.replace(" ",'').replace(',','') +'\n'  #去單引號，逗號，換行
    file.write(s)
  file.close()


img = cv2.resize(image, (32, 31), interpolation=cv2.INTER_AREA)
img_list=list(img)

img_a=[]
for i in range(1,16,1):#去偶數行
    del img_list[i]
print( img_list)
while ' ' in img_list:
    img_list.remove(' ')
print(img_list)

text_save('main_img.dat',img_list)
text_save('main_img.txt',img_list)



for i in range(0,15):
    up_row=img_list[i]
    down_row=img_list[i+1]
    middle_row=[]
    j=0
    middle_row.append((up_row[0]+down_row[0])>>1)
    while j <30:
            if up_row[j]>=down_row[j+2]:
                
                d1=up_row[j]-down_row[j+2]
            else:
                d1=down_row[j+2]-up_row[j]
            if(up_row[j+1]>=down_row[j+1]):
                d2=up_row[j+1]-down_row[j+1]
            else:
                d2=down_row[j+1] - up_row[j+1]
            if up_row[j+2]>=down_row[j]:
                d3=up_row[j+2]-down_row[j]
            else:
                d3=down_row[j] - up_row[j+2]

            if(j <30):
                if(d1<=d3):
                    dd=(up_row[j]+down_row[j+2])>>1
                    d13=d1
                else:
                    dd=(up_row[j+1]+down_row[j+1])>>1
                    d13=d3
                if(d2<=d13):
                    d=(up_row[j+2]+down_row[j])>>1
                else:
                    d=dd
            else:
                break
            middle_row.append(d)
            j=j+1
    middle_row.append((up_row[31]+down_row[31])>>1) 
    img_a.insert(i,middle_row)
for i in range(0,15):
    img_list.insert(i*2+1,img_a[i])

text_save('main_golden.dat',img_list)
text_save('main_golden.txt',img_list)

frame=tuple(img_list)
image=np.uint8(frame)
img = cv2.resize(image, (320, 310), interpolation=cv2.INTER_AREA) 
cv2.imshow('frame',img)
cv2.waitKey(0)
cv2.destroyAllWindows()    




