from firebase import firebase
fb = firebase.FirebaseApplication("https://sinkr-1dbdd.firebaseio.com/", None)
fb.delete('/', 'games')
fb.delete('/', 'leaderboard')
