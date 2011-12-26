CONFIG = require('./game').CONFIG

DIRECTIONS = ['N', 'E', 'S', 'W']

class Bot
  class LocationsCollection
    constructor: (locations=[]) ->
      @collection = {}
      @collection_array = []
      @add_loc(loc) for loc in locations

    add_loc: (loc) ->
      @collection_array.push loc
      @collection["#{loc.x};#{loc.y}"] = loc

    has_loc: (loc) ->
      if @collection[@key(loc)]?
        @collection[@key(loc)]
      else
        false

    remove_loc: (loc) ->
      if origin = @has_loc(loc)
        delete @collection_array[@collection_array.indexOf(origin)]
        delete @collection[@key(loc)]

    key: (loc) ->
      "#{loc.x};#{loc.y}"

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


  # http://xathis.com/posts/ai-challenge-2011-ants.html
  # http://www.csc.liv.ac.uk/~cs8js/4yp/BFS.html
  find_path: (ant, dest) ->
    path = null

    my_hills = new LocationsCollection(@ants.my_hills())
    queue = [{ x: ant.x, y: ant.y, cost: 0 }]
    explored_tiles = new LocationsCollection()

    explored_tiles_by_cost = { "0": [ant] }
    path_cost = null

    while queue.length > 0
      root_tile = queue.shift()
      explored_tiles.add_loc root_tile

      unless root_tile.x == dest.x && root_tile.y == dest.y
        for direction in DIRECTIONS
          neighbor = @ants.neighbor(root_tile.x, root_tile.y, direction)
          neighbor = { x: neighbor.x, y: neighbor.y, cost: root_tile.cost + 1 }
          if (root_tile.cost < 10) and !explored_tiles.has_loc(neighbor) and !my_hills.has_loc(neighbor) and @ants.passable(neighbor)
            queue.push neighbor
      else
        path_cost = root_tile.cost
        break

    if path_cost == 0
      path = []
    else if path_cost == 1
      path = [dest]
    else if path_cost > 1
      path = [dest]
      current_tile = dest
      for cost in [path_cost-1..1]
        for tile in explored_tiles.collection_array when tile?
          if tile.cost == cost
            if @ants.distance(tile, current_tile) == 1
              path.push tile
              current_tile = tile

            explored_tiles.remove_loc tile
          
      path = path.reverse()

    path


(exports ? this).Bot = Bot
