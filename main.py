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
    cups = {x:y for x in range(0, 6) for y in cupLocations(cupsleft)}
    players = {x:'' for x in range(0,2)}

    # initial db setup
    fb.put('/games/' + str(gameId), 'cups', cups)
    fb.put('/games/' + str(gameId), 'players', players)
    fb.put('/games/' + str(gameId), 'turn', turn)

    # wait for players to connect
    while (fb.get('/games/' + str(gameId) + '/players/', 0) == "" or fb.get('/games/' + str(gameId) + '/players/', 1) == ""):
        sleep(1)

    # main loop
   # while (len(cups) > 0):


if __name__ == '__main__':
    main()
