CONFIG = require('./game').CONFIG

directions = ['N', 'E', 'S', 'W']

class Bot
  class LocationsCollection
    constructor: (@collection={}) ->

    add_loc: (loc) ->
      @collection["#{loc.x};#{loc.y}"] = true

    has_loc: (loc) ->
      @collection["#{loc.x};#{loc.y}"]?


  constructor: (@ants) ->

  # You can setup stuff here, before the first turn starts:
  ready: ->

  # Here are the orders to the ants, executed each turn:
  do_turn: ->
    @init_collections()

    my_ants = @ants.my_ants()
    all_food = @ants.food()
    if all_food.length * my_ants.length > 0
      ant_targets = []
      ant_targets.push({ ant: ant, target: food }) for ant in my_ants for food in all_food
      ant_targets = ant_targets.sort (el) => -@ants.distance(el.ant, el.target)
    else
      ant_targets = []

    for ant_target in ant_targets
      unless @targets.has_loc(ant_target.target) || @ants_with_orders.has_loc(ant_target.ant)
        @move_ant(ant_target.ant, ant_target.target)

  move_ant: (ant, target) ->
    directions = @ants.directions(ant, target)

    for direction in directions
      loc = @ants.neighbor(ant.x, ant.y, direction)

      if @ants.passable(loc) && @is_order_allowed(ant, loc)
        @ants.issue_order(ant.x, ant.y, direction)
        @moves.add_loc loc
        @ants_with_orders.add_loc ant
        @targets.add_loc target
        
  is_order_allowed: (ant, dest) ->
    not @moves.has_loc(dest) && not @ants_with_orders.has_loc(ant)

  init_collections: ->
    @moves = new LocationsCollection()
    @targets = new LocationsCollection()
    @ants_with_orders = new LocationsCollection()


(exports ? this).Bot = Bot
