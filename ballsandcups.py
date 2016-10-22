#import
from collections import deque
import numpy as np
import argparse
import imutils
import cv2

ballLower = (29, 86, 6)
ballUpper = (64, 255, 255)
cupLower = (11.5, 8, 0)
cupUpper = (42, 30, 200)

camera = cv2.VideoCapture(0)

# returns a deque of ellipses representing cup borders and draws the ellipses
def getCups(frame, hsv):
	mask = cv2.inRange(hsv, cupLower, cupUpper)
	mask = cv2.erode(mask, None, iterations=2)
	mask = cv2.dilate(mask, None, iterations=2)
	cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL,
		cv2.CHAIN_APPROX_SIMPLE)[-2]
	center = None
	l = deque()

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
				l.append(ellipse)
				cv2.ellipse(frame,ellipse,(0,255,0),2)
	return l

# returns the center, radius of the ball if it's in frame, None otherwise
# also draws ball circle
def getBall(frame, hsv):
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
			return (center, radius)
	return None, None

def throwBall():
	framecount = 0
	
	pts = deque()
	rads = deque()
	
	while framecount < 5:
		_, frame = camera.read()
		frame = imutils.resize(frame, width=600)
		hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

		center, radius = getBall(frame, hsv)
		pts.appendleft(center)
		rads.appendleft(radius)

		if center is None:
			framecount = 0
		else:
			framecount += 1

		getCups(frame, hsv)

		# traces ball movement
		maxtrace = len(pts)
		if maxtrace > 32:
			maxtrace = 32
		for i in xrange(1,maxtrace):
			if pts[i - 1] is None or pts[i] is None:
				continue

			thickness = int(np.sqrt(maxtrace / float(i + 1)) * 2.5)
			cv2.line(frame, pts[i - 1], pts[i], (0, 0, 255), thickness)

		cv2.imshow("Frame", frame)

		key = cv2.waitKey(1) & 0xFF

		if key == ord("q"):
			return None

	print "ball detected!"
	#reset framecount
	framecount = 0

	while framecount < 20:
		_, frame = camera.read()
		frame = imutils.resize(frame, width=600)
		hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

		center, radius = getBall(frame, hsv)
		pts.appendleft(center)
		rads.appendleft(radius)

		if center is None:
			framecount += 1
		else:
			framecount = 0

		getCups(frame, hsv)

		# traces ball movement
		maxtrace = len(pts)
		if maxtrace > 32:
			maxtrace = 32
		for i in xrange(1,maxtrace):
			if pts[i - 1] is None or pts[i] is None:
				continue

			thickness = int(np.sqrt(maxtrace / float(i + 1)) * 2.5)
			cv2.line(frame, pts[i - 1], pts[i], (0, 0, 255), thickness)

		cv2.imshow("Frame", frame)

		key = cv2.waitKey(1) & 0xFF

		if key == ord("q"):
			return None

	print "ball has left the frame!"
	center = None
	radius = None
	while center is None:
		center = pts.popleft()
		radius = rads.popleft()

throwBall()

camera.release()
cv2.destroyAllWindows()