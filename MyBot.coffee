bot = require('./app/bot').Bot
game = require('./app/game').Game

ants = new game()
ants.run new bot(ants)
