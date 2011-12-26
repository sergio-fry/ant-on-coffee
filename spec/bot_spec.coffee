Bot = require(__dirname + '/../app/bot').Bot
Game = require(__dirname + '/../app/game').Game

CONFIG =
  turntime : 0
  rows : 50
  cols : 50
  turn : 0

describe 'Bot', ->
  bot = null
  game = null

  beforeEach ->
    game = new Game()
    game.passable = -> true
    game.issue_order = -> true
    game.neighbor = (x, y, direction) ->
      switch direction
        when "N"
          if x-1 < 0 then { x: CONFIG.rows-1, y: y } else { x: x-1, y: y }
        when "S"
          if x+1 > CONFIG.rows-1 then { x: 0, y: y } else { x: x+1, y: y }
        when "E"
          if y+1 > CONFIG.cols-1 then { x: x, y: 0 } else { x: x, y: y+1 }
        when "W"
          if y-1 < 0 then { x: x, y: CONFIG.cols-1 } else { x: x, y: y-1 }

    bot = new Bot(game)
    bot.init_collections()

  describe '#is_order_allowed', ->
    it 'should allow to stay', ->
      game.my_ants = -> [{ x: 1, y: 1 }]
      bot.init_collections()
      expect(bot.is_order_allowed({ x: 1, y: 1 }, { x: 1, y: 1 })).toBeTruthy()

    it "should not allow to move over another ant", ->
      game.my_ants = -> [{ x: 1, y: 1 }, { x: 1, y: 2 }]
      bot.init_collections()
      expect(bot.is_order_allowed({ x: 1, y: 1 }, { x: 1, y: 2 })).toBeFalsy()


    it 'should allow to move', ->
      expect(bot.is_order_allowed({ x: 1, y: 1 }, { x: 1, y: 2 })).toBeTruthy()

    it 'should not allow to move to the same location twice', ->
      game.neighbor = -> { x: 1, y: 2 } # stub
      bot.move_ant({ x: 1, y: 1 }, { x: 1, y: 2 })
      game.neighbor = -> { x: 1, y: 2 } # stub
      expect(bot.is_order_allowed({ x: 2, y: 2 }, { x: 1, y: 2 })).toBeFalsy()

    it 'should not allow to move to the same ant twice', ->
      game.neighbor = -> { x: 1, y: 2 } # stub
      bot.move_ant({ x: 1, y: 1 }, { x: 1, y: 2 })
      game.neighbor = -> { x: 2, y: 1 } # stub
      expect(bot.is_order_allowed({ x: 1, y: 1 }, { x: 2, y: 1 })).toBeFalsy()

  describe "#do_turn", ->
    it "should issue order for each ant", ->
      game.my_ants = -> [{ x: 1, y: 1 }, { x: 10, y: 10 }]
      game.food = -> [{ x: 3, y: 1 }, { x: 12, y: 10 }]
      game.issue_order = jasmine.createSpy()
      bot.do_turn()
      expect(game.issue_order.callCount).toEqual(2)
  
  describe "#go_away_from_a_hill", ->
    it "should issue an order to go away for an ant on a hill", ->
      game.my_ants = -> [{ x: 1, y: 1 }]
      game.my_hills = -> [{ x: 1, y: 1 }]
      game.issue_order = jasmine.createSpy()
      bot.go_away_from_a_hill()
      expect(game.issue_order.callCount).toEqual(1)

    it "should issue an order to go away", ->
      game.my_ants = -> [{ x: 1, y: 1 }]
      game.my_hills = -> [{ x: 1, y: 2 }]
      game.issue_order = jasmine.createSpy()
      bot.go_away_from_a_hill()
      expect(game.issue_order.callCount).toEqual(0)

