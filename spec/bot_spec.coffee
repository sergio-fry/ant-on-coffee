bot = require(__dirname + '/../app/bot').Bot

describe 'Bot', () ->
  describe '#direction_occupied', () ->
    it 'should be true for a new step', () ->
      b = new bot()
      expect(b.direction_occupied()).toBeTruthy()
