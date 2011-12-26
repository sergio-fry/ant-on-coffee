CONFIG = require('./game').CONFIG

DIRECTIONS = ['N', 'E', 'S', 'W']

class Bot
  class LocationsCollection
    constructor: (locations=[]) ->
      @collection = {}
      @add_loc(loc) for loc in locations

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
    @search_food()
    @go_away_from_a_hill()

  move_ant: (ant, target) ->
    for direction in @ants.directions(ant, target)
      loc = @ants.neighbor(ant.x, ant.y, direction)

      if @ants.passable(loc) && @is_order_allowed(ant, loc)
        @ants.issue_order(ant.x, ant.y, direction)
        @moves.add_loc loc
        @ants_with_orders.add_loc ant
        @targets.add_loc target

  #########################################################
  # Moving stratagies
  search_food: ->
    my_ants = @ants.my_ants()
    all_food = @ants.food()
    if all_food.length * my_ants.length > 0
      ant_targets = []
      ant_targets.push({ ant: ant, target: food }) for ant in my_ants for food in all_food
      ant_targets = ant_targets.sort (a, b) => @ants.distance(a.ant, a.target) - @ants.distance(b.ant, b.target)
    else
      ant_targets = []

    for ant_target in ant_targets
      unless @targets.has_loc(ant_target.target) || @ants_with_orders.has_loc(ant_target.ant)
        @move_ant(ant_target.ant, ant_target.target)

  go_away_from_a_hill: ->
    for hill in @ants.my_hills()
      console.log "hill found"
      for ant in @ants.my_ants()
        if (hill.x == ant.x && hill.y == ant.y)
          for direction in DIRECTIONS
            @move_ant(ant, @ants.neighbor(ant.x, ant.y, direction))
        
  #########################################################
  # Routine methods
  is_order_allowed: (ant, dest) ->
    not @moves.has_loc(dest) && not @ants_with_orders.has_loc(ant) && (not @my_ants.has_loc(dest) || (ant.x == dest.x && ant.y == dest.y))

  init_collections: ->
    @moves = new LocationsCollection()
    @targets = new LocationsCollection()
    @ants_with_orders = new LocationsCollection()
    @my_ants = new LocationsCollection(@ants.my_ants())


(exports ? this).Bot = Bot
