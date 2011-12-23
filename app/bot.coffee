CONFIG = require('./game').CONFIG

directions = ['N', 'E', 'S', 'W']

class Bot
  constructor: (@ants) ->

  # You can setup stuff here, before the first turn starts:
  ready: ->

  # Here are the orders to the ants, executed each turn:
  do_turn: ->
    @moves = {}

    my_ants = @ants.my_ants()
    ant_targets = ( { ant: ant, target: @nearest_food_for_ant(ant) } for ant in my_ants when @nearest_food_for_ant(ant)?).sort (el) => -@ants.distance(el.ant, el.target)
    ant_targets = ant_targets.concat({ ant: ant, target: ant } for ant in my_ants)
    console.log ant_targets

    targets = {}
    ants_with_orders = {}
    for ant_target in ant_targets
      unless targets[ant_target]? || ants_with_orders[ant_target.ant]?
        @move_ant(ant_target.ant, ant_target.target)
        targets[ant_target] = true
        ants_with_orders[ant_target.ant] = true

  move_ant: (ant, dest) ->
    for dir in @ants.direction(ant, dest)
      near_square = @ants.neighbor(ant.x, ant.y, dir)
      if @ants.passable(near_square) && !@moves[near_square]?
        @ants.issue_order(ant.x, ant.y, dir)
        @moves[near_square] = true


  # Routine functions
  nearest_food_for_ant: (ant) ->
    if @ants.food().length > 0
      food = ([food, @ants.distance(ant, food)] for food in @ants.food())
      food.sort((el) -> -el[1])[0][0] # first food in array sorted by distance

(exports ? this).Bot = Bot
