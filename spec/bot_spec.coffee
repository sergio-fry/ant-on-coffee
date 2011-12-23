bot = require(__dirname + '/../app/bot').Bot

describe 'Bot', () ->
  describe '#next_step_position', () ->
    it 'should be true for a new step', () ->
      b = new bot()
      b.positions = {}
      expect(b.is_next_step_position_free(1, 1)).toBeTruthy()

    it 'should be false if already occupied', () ->
      b = new bot()
      b.positions = {}
      b.occupie_next_step_position(1, 1)
      expect(b.is_next_step_position_free(1, 1)).toBeFalsy()

  describe '#nearest_food_for_ant', () ->
    it 'should return the nearest food', () ->
      game = {}
      game.my_ants = () -> [{ x: 1, y: 1 }]
      game.food = () -> [{ x: 5, y: 5 }, { x: 10, y: 10 }]
      game.distance = (loc1, loc2) ->
        console.log loc2.x
        if loc2.x == 10 then 5 else 3

      b = new bot(game)

      expect(b.nearest_food_for_ant(1, 1)).toEqual([5, 5])


