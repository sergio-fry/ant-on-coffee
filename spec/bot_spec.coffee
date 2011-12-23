bot = require(__dirname + '/../app/bot').Bot

describe 'Bot', ->

  describe '#nearest_food_for_ant', ->
    it 'should return the nearest food', ->
      ant = { x: 1, y: 1 }
      game = {}
      game.my_ants = -> [ant]
      game.food = -> [{ x: 5, y: 5 }, { x: 10, y: 10 }]
      game.distance = (loc1, loc2) ->
        if loc2.x == 10 then 5 else 3

      b = new bot(game)

      expect(b.nearest_food_for_ant(ant)).toEqual({ x: 5, y: 5 })


