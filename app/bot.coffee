CONFIG = require('./game').CONFIG

DIRECTIONS = ['N', 'E', 'S', 'W']

class Bot
  class LocationsCollection
    constructor: (locations=[]) ->
      @collection = {}
      @add_loc(loc) for loc in locations

    add_loc: (loc) ->
      @collection["#{loc.x};#{loc.y}"] = loc

    has_loc: (loc) ->
      if @collection[@key(loc)]?
        @collection[@key(loc)]
      else
        false

    remove_loc: (loc) ->
      if origin = @has_loc(loc)
        delete @collection[@key(loc)]

    key: (loc) ->
      "#{loc.x};#{loc.y}"

  constructor: (@ants) ->
    @find_path_cache = {}

  # You can setup stuff here, before the first turn starts:
  ready: ->

  # Here are the orders to the ants, executed each turn:
  do_turn: ->
    @find_path_cache = {}
    @init_collections()
    @search_food()
    @go_away_from_a_hill()

  move_ant: (ant, target) ->
    path = null
    
    if @ants.distance(ant, target) == 1
      path = [target]
    else
      path = @find_path(ant, target)

    if path != null
      directions = @ants.directions(ant, path[0])
      for direction in directions
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
      ant_targets = ant_targets.sort (a, b) => @distance(a.ant, a.target) - @distance(b.ant, b.target)
    else
      ant_targets = []

    for ant_target in ant_targets
      unless @targets.has_loc(ant_target.target) || @ants_with_orders.has_loc(ant_target.ant)
        @move_ant(ant_target.ant, ant_target.target)

  go_away_from_a_hill: ->
    my_hills = @ants.my_hills()
    my_ants = @ants.my_ants()
    for hill in my_hills
      for ant in my_ants
        if (hill.x == ant.x && hill.y == ant.y)
          for direction in DIRECTIONS
            @move_ant(ant, @ants.neighbor(ant.x, ant.y, direction))

  go_away_from_other_ants: ->
        
  #########################################################
  # Routine methods

  distance: (loc, dest) ->
    path = @find_path(loc, dest)
    if path != null
      path.length
    else
      Infinity

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
    if @find_path_cache["#{ant.x},#{ant.y}-#{dest.x},#{dest.y}"]?
      return @find_path_cache["#{ant.x},#{ant.y}-#{dest.x},#{dest.y}"]

    path = null

    my_hills = new LocationsCollection(@ants.my_hills())
    queue = [{ x: ant.x, y: ant.y, cost: 0 }]
    queue_collection = new LocationsCollection(queue)
    explored_tiles = new LocationsCollection()

    explored_tiles_by_cost = {}
    path_cost = null

    max_queue_length = 0
    while queue.length > 0
      max_queue_length = queue.length if max_queue_length < queue.length
      root_tile = queue.shift()
      explored_tiles.add_loc root_tile

      explored_tiles_by_cost[root_tile.cost] ?= []
      explored_tiles_by_cost[root_tile.cost].push root_tile

      unless root_tile.x == dest.x && root_tile.y == dest.y
        for direction in DIRECTIONS
          neighbor = @ants.neighbor(root_tile.x, root_tile.y, direction)
          neighbor = { x: neighbor.x, y: neighbor.y, cost: root_tile.cost + 1 }
          if (root_tile.cost < 10) and !explored_tiles.has_loc(neighbor) and !my_hills.has_loc(neighbor) and @ants.passable(neighbor)
            unless queue_collection.has_loc(neighbor)
              queue.push neighbor
              queue_collection.add_loc neighbor
      else
        path_cost = root_tile.cost
        break

    #console.log max_queue_length

    if path_cost == 0
      path = []
    else if path_cost == 1
      path = [dest]
    else if path_cost > 1
      path = [dest]
      current_tile = dest
      for cost in [path_cost-1..1]
        for tile in explored_tiles_by_cost[cost] when tile?
          if tile.cost == cost
            if @ants.distance(tile, current_tile) == 1
              path.push tile
              current_tile = tile
          
      path = path.reverse()

    @find_path_cache["#{ant.x},#{ant.y}-#{dest.x},#{dest.y}"] ?= path
    path


(exports ? this).Bot = Bot
