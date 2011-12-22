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
    for ant in my_ants
      for dir in directions
        near_square = @ants.neighbor(ant.x, ant.y, dir)
        if @ants.passable(near_square.x, near_square.y) && @is_next_step_position_free(near_square.x, near_square.y)
          @ants.issue_order(ant.x, ant.y, dir)
          @occupie_next_step_position(near_square.x, near_square.y)
          break

  # Routine functions
  is_next_step_position_free: (x, y) =>
    !@positions[x + "," + y]?

  occupie_next_step_position: (x, y) =>
    @positions[x + "," + y] = true


(exports ? this).Bot = Bot
