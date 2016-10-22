#import
from collections import deque
import numpy as np
import argparse
import imutils
import cv2

ballLower = (29, 86, 6)
ballUpper = (64, 255, 255)
cupLower = (101, 193.8, 114.75)
cupUpper = (120, 255, 255)

camera = cv2.VideoCapture(0)

# returns a list of tuples representing cups(x, y, width, height) and draws the ellipses
def getCups(frame, hsv):
	mask = cv2.inRange(hsv, cupLower, cupUpper)
	cv2.imshow("Frame2", mask)
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
				cv2.imshow("Frame", frame)
	return l

# Just like getcups, but with ML. IT WILL FAIL IF THE FILE IS INVALID, I DONT ERROR CHECK
# returns a list, not a deque
def getCups2(frame, filename):
	cascade = cv2.CascadeClassifier()
	cascade.load(filename)
	cups = cascade.detectMultiScale(frame)
	for (x, y, w, h) in cups:
		center = (x + 0.5*w, y + 0.5*h)
		cv2.ellipse(frame, ((x,y), (w,h), 90), (0,255,0),2)
	return cups


# returns a list of cup centers for ui use
def cupLocations():
	_, frame = camera.read()
	#frame = imutils.resize(frame, width=600)
	hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
	cups = getCups(frame, hsv)
	l = []
	for cup in cups:
		l.append(cup.x + 0.5 * cup.width, cup.y + 0.5 * cup.height)
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

def ballInCup(center, radius, cup):
	print center
	print cup
	x = cup[0][0]
	w = cup[1][0]
	y = cup[0][1]
	h = cup[1][1]
	print (center[0] - x)**2/w**2 + (center[1] - y)**2/h**2
	if (center[0] - x)**2/w**2 + (center[1] - y)**2/h**2 <= 1.2: 
		return True
	return False


def throwBall(numleft):
	framecount = 0
	
	pts = deque()
	rads = deque()

	cups = deque()
	while len(cups) != numleft:
		_, frame = camera.read()
		frame = imutils.resize(frame, width=600)
		hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
		cups = getCups(frame, hsv)
		#cups = getCups2(frame, "/memes/classifier/stage7.xml")

	while framecount < 5:
		_, frame = camera.read()
		#frame = imutils.resize(frame, width=600)
		hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
		getCups(frame, hsv)
		center, radius = getBall(frame, hsv)
		pts.appendleft(center)
		rads.appendleft(radius)

		if center is None:
			framecount = 0
		else:
			framecount += 1

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
		#frame = imutils.resize(frame, width=600)
		hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
		center, radius = getBall(frame, hsv)
		pts.appendleft(center)
		rads.appendleft(radius)

		if center is None:
			framecount += 1
		else:
			framecount = 0

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

	# getting list of last for frames. Will check to see if 2 are within a ellipse
	# in the list returned by getCups
	clist = [center]
	rlist = [radius]

	n = 2 #the last n frames to check
	while len(clist) < n:
		center = pts.popleft()
		if center is not None:
			clist.append(center)
			rlist.append(rads.popleft())
		else:
			rads.popleft()

	score = 0
	for i in range(n):
		for cup in cups:
			print cup
			if ballInCup(clist[i], rlist[i], cup):
				score += 1

	if score >= 1:
		return True
	return False

print throwBall(1)

camera.release()
cv2.destroyAllWindows()