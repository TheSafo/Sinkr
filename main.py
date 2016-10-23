#from ballsandcups import *
import random
from firebase import firebase
from time import sleep

def main():
    fb = firebase.FirebaseApplication("https://sinkr-1dbdd.firebaseio.com/", None)
    gameId = random.randint(100000, 999999)
    cups = {x:True for x in range(0,6)}
    players = {x:'' for x in range(0,2)}
    fb.put('/games/' + str(gameId), 'cups', cups)
    fb.put('/games/' + str(gameId), 'players', players)
    fb.put('/games/' + str(gameId), 'turn', 0)
    print fb.get('/games/' + str(gameId) + '/players/', 0)
    while (fb.get('/games/' + str(gameId) + '/players/', 0) == "" or fb.get('/games/' + str(gameId) + '/players/', 1) == ""):
         sleep(1)

if __name__ == '__main__':
    main()
