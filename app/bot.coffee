CONFIG = require('./game').CONFIG

directions = ['N', 'E', 'S', 'W']

class Bot
  constructor: (@ants) ->

  # You can setup stuff here, before the first turn starts:
  ready: ->

  # Here are the orders to the ants, executed each turn:
  do_turn: ->
    # track all moves, prevent collisions
    @positions = {}

    my_ants = @ants.my_ants()
    ant_targets = ( { ant: ant, target: @nearest_food_for_ant(ant) } for ant in my_ants when @nearest_food_for_ant(ant)?).sort (el) => -@ants.distance(el.ant, el.target)

    targets = {}
    for ant_target in ant_targets
      unless targets[ant_target]
        @move_ant(ant_target.ant, ant_target.target)
        targets[ant_target] = true

  move_ant: (ant, dest) ->
    for dir in @ants.direction(ant, dest)
      near_square = @ants.neighbor(ant.x, ant.y, dir)
      if @ants.passable(near_square.x, near_square.y) && @is_next_step_position_free(near_square.x, near_square.y)
        @ants.issue_order(ant.x, ant.y, dir)
        @occupie_next_step_position(near_square.x, near_square.y)


  # Routine functions
  nearest_food_for_ant: (ant) ->
    if @ants.food().length > 0
      food = ([food, @ants.distance(ant, food)] for food in @ants.food())
      food.sort((el) -> -el[1])[0][0] # first food in array sorted by distance

  is_next_step_position_free: (x, y) =>
    !@positions[x + "," + y]?

  occupie_next_step_position: (x, y) =>
    @positions[x + "," + y] = true



(exports ? this).Bot = Bot
