import glob
import numpy as np
import cv2
counter = 0
for filename in glob.glob('memes/negative_images/*.JPG'):
	counter += 1
	im=cv2.imread(filename)
	hsv = cv2.cvtColor(im, cv2.COLOR_BGR2HSV)
	cv2.imwrite('hsv' + str(counter) +'.jpg', hsv)