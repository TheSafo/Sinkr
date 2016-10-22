#import
from collections import deque
import numpy as np
import argparse
import imutils
import cv2

ap = argparse.ArgumentParser()
ap.add_argument("-b", "--buffer", type=int, default=32,
	help="max buffer size")
args = vars(ap.parse_args())

ballLower = (29, 86, 6)
ballUpper = (64, 255, 255)
cupLower = (13, 5.1, 0)
cupUpper = (30, 26, 255)

pts = deque(maxlen = args["buffer"])

camera = cv2.VideoCapture(0)

def getCups(mainframe, frame):
	frame = imutils.resize(frame, width=600)
	cv2.GaussianBlur(frame, (11, 11), 0)
	hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
	mask = cv2.inRange(hsv, cupLower, cupUpper)
	cv2.imshow("Frame2", mask)
	mask = cv2.erode(mask, None, iterations=2)
	mask = cv2.dilate(mask, None, iterations=2)
	cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL,
		cv2.CHAIN_APPROX_SIMPLE)[-2]
	center = None

	if len(cnts) > 0:
		# get 10 highest contours for now, will eventually be a variable
		# representing number left
		numCups = 10
		if len(cnts) < 10: 
			numCups = len(cnts)
		c = sorted(cnts, key=cv2.contourArea)[-numCups:]

		for cupContour in c:
			if cv2.contourArea(cupContour) > 1000:
				ellipse = cv2.fitEllipse(cupContour)
				cv2.ellipse(frame,ellipse,(0,255,0),2)

while True:
	(grabbed, frame) = camera.read()
	cupframe = frame
	frame = imutils.resize(frame, width=600)
	hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
	mask = cv2.inRange(hsv, ballLower, ballUpper)
	mask = cv2.erode(mask, None, iterations=2)
	mask = cv2.dilate(mask, None, iterations=2)
	cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL,
		cv2.CHAIN_APPROX_SIMPLE)[-2]
	center = None

	if len(cnts) > 0:

		c = max(cnts, key=cv2.contourArea)
		((x, y), radius) = cv2.minEnclosingCircle(c)
		M = cv2.moments(c)
		center = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))

		if radius > 10:

			cv2.circle(frame, (int(x), int(y)), int(radius), (0, 255, 255), 2)
			cv2.circle(frame, center, 5, (0, 0, 255), -1)

	pts.appendleft(center)

	getCups(frame, cupframe)

	for i in xrange(1, len(pts)):
		if pts[i - 1] is None or pts[i] is None:
			continue

		thickness = int(np.sqrt(args["buffer"] / float(i + 1)) * 2.5)
		cv2.line(frame, pts[i - 1], pts[i], (0, 0, 255), thickness)

	cv2.imshow("Frame", frame)

	key = cv2.waitKey(1) & 0xFF

	if key == ord("q"):
		break

camera.release()
cv2.destroyAllWindows()