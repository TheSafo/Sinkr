# import
from ballsandcups import *
import random
from firebase import firebase
from time import sleep

def main():

    # variables
    cupsleft = 6
    turn = 0
    fb = firebase.FirebaseApplication("https://sinkr-1dbdd.firebaseio.com/", None)
    gameId = random.randint(100000, 999999)

    # dicts for db
    cups = {i:{'x':x, 'y':y} for i in range(0, 6) for (x,y) in cupLocations(cupsleft)}
    players = {x:'' for x in range(0,2)}
    scores = {x:0 for x in range(0,2)}

    # initial db setup
    fb.put('/games/' + str(gameId), 'cups', cups)
    fb.put('/games/' + str(gameId), 'players', players)
    fb.put('/games/' + str(gameId), 'scores', scores)
    fb.put('/games/' + str(gameId), 'turn', turn)

    # wait for players to connect
    while (fb.get('/games/' + str(gameId) + '/players/', 0) == "" or fb.get('/games/' + str(gameId) + '/players/', 1) == ""):
        sleep(1)

    # main loop
    while (len(cups) > 0):
        if throwBall(cupsleft) != (None, None):
            cupsleft -= 1
            scores[turn] += 1
            fb.remove('/games/' + str(gameId), 'cups')
            cups = {i:{'x':x, 'y':y} for i in range(0, cupsleft) for (x,y) in cupLocations(cupsleft)}
            fb.put('/games/' + str(gameId), 'cups', cups)
            fb.put('/games/' + str(gameId), 'scores', scores)
        turn ^= 1
        fb.put('/games/' + str(gameId), 'turn', turn)


if __name__ == '__main__':
    main()
