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

  #describe "#go_away_from_other_ants", ->
    #it "should order to ants to go away from each other", ->
      #game.my_ants = -> [{ x: 5, y: 5 }, { x: 5, y: 6 }]
      #game.issue_order = jasmine.createSpy()
      #bot.go_away_from_other_ants()
      #expect(game.issue_order.callCount).toEqual(2)

  describe "#freedom", ->
    it "should be gt father from ant", ->
      game.my_ants = -> [{ x: 5, y: 5 }]
      expect(bot.freedom({ x: 5, y: 6 })).toBeLessThan(bot.freedom({ x: 6, y: 6 }))

    it "should be gt father from ants", ->
      game.my_ants = -> [{ x: 5, y: 5 }, { x: 7, y: 5 }]
      expect(bot.freedom({ x: 6, y: 6 })).toBeLessThan(bot.freedom({ x: 8, y: 6 }))


  describe "#find_path", ->
    ######################################################
    # without unpassable tiles
    it "should find path of length 0", ->
      path = bot.find_path({ x: 1, y: 1 }, { x: 1, y: 1})
      expect(path.length).toEqual(0)

    it "should find path of length 1", ->
      path = bot.find_path({ x: 1, y: 1 }, { x: 1, y: 2})
      expect(path.length).toEqual(1)

    it "should find path of length 2", ->
      path = bot.find_path({ x: 1, y: 1 }, { x: 2, y: 2})
      expect(path.length).toEqual(2)

    ######################################################
    # with unpassable tiles
    it "should find path of length 4", ->
      game.passable = (loc) ->
        if loc.x == 1 and loc.y == 2
          false
        else
          true

      path = bot.find_path({ x: 1, y: 1 }, { x: 1, y: 3})
      expect(path.length).toEqual(4)

    it "should return null if no route", ->
      game.passable = (loc) -> false

      path = bot.find_path({ x: 1, y: 1 }, { x: 1, y: 3})
      expect(path).toEqual(null)

  describe "#distance", ->
    it "should return length of path", ->
      bot.find_path = -> [1..5]
      expect(bot.distance({ x: 1, y: 1 }, { x: 1, y: 4 })).toEqual(5)

    it "should return Infinity if there is no path", ->
      bot.find_path = -> null
      expect(bot.distance({ x: 1, y: 1 }, { x: 1, y: 4 })).toEqual(Infinity)
