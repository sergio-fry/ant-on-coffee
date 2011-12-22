bot = require(__dirname + '/../MyBot').Game

describe 'MyBot', () ->
  describe '#direction_occupied', () ->
    it 'should be true for a new step', () ->
      b = new bot()
      expect(b.direction_occupied?).toEqual(true)
