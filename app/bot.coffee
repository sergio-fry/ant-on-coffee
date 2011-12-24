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
    all_food = @ants.food()
    if all_food.length * my_ants.length > 0
      ant_targets = []
      ant_targets.push({ ant: ant, target: food }) for ant in my_ants for food in all_food
      #console.log (el) for el in ant_targets
      #console.log ("#{el.ant.x},#{el.ant.y} -> #{el.target.x},#{el.target.y}") for el in ant_targets
      ant_targets = ant_targets.sort (el) => @ants.distance(el.ant, el.target)
      ant_targets = ant_targets.concat({ ant: ant, target: ant } for ant in my_ants)
    else
      ant_targets = []

    #console.log "#{target.ant.x},#{target.ant.y} -> #{target.target.x},#{target.target.y} (dist: #{@ants.distance(target.ant, target.target)})" for target in ant_targets

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


(exports ? this).Bot = Bot
