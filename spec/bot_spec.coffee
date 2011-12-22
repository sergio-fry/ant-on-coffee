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
