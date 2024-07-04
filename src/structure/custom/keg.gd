extends Structure
class_name Keg

var callback_harvest: Callable
var callback_turn_end: Callable
var callback_turn_start: Callable

var event_type_harvest = EventManager.EventType.OnPlantHarvest
var event_type_turn_end = EventManager.EventType.OnTurnEnd
var event_type_turn_start = EventManager.EventType.BeforeTurnStart

var my_tile: Tile
var collecting = false
var full = false
var turns_full: int = 0

func _init():
	super()

func copy():
	return Keg.new()

func register_events(event_manager: EventManager, tile: Tile):
	my_tile = tile
	callback_harvest = func(args: EventArgs):
		if full == false and Helper.is_adjacent(tile.grid_location, args.specific.tile.grid_location):
			var n_yield = args.specific.harvest_args.yld
			my_tile.current_yield += n_yield
			args.specific.harvest_args.yld = 0.0
			collecting = true
			var n_harvest_args = EventArgs.HarvestArgs.new(n_yield, args.specific.harvest_args.purple, false)
			args.farm.blight_bubble_animation(args.specific.tile, n_harvest_args, my_tile.position + Constants.TILE_SIZE / 2)

	callback_turn_end = func(args: EventArgs):
		if collecting:
			full = true
			collecting = false
			my_tile.seed_grow_time = 2
			my_tile.current_grow_progress = 0
			#TODO Update sprite
	callback_turn_start = func(args: EventArgs):
		if full:
			turns_full += 1
			my_tile.current_grow_progress = turns_full
			if turns_full == 2:
				var harvest_args = EventArgs.HarvestArgs.new(my_tile.current_yield, my_tile.purple, false)
				harvest_args.yld *= 2
				args.farm.gain_yield(my_tile, harvest_args)
				full = false
				turns_full = 0
				my_tile.current_yield = 0.0
				my_tile.seed_grow_time = 0
				my_tile.current_grow_progress = 0
	event_manager.register_listener(event_type_harvest, callback_harvest)
	event_manager.register_listener(event_type_turn_end, callback_turn_end)
	event_manager.register_listener(event_type_turn_start, callback_turn_start)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type_harvest, callback_harvest)
	event_manager.unregister_listener(event_type_turn_end, callback_turn_end)
	event_manager.unregister_listener(event_type_turn_start, callback_turn_start)

func do_winter_clear():
	my_tile.current_grow_progress = 0
	my_tile.current_yield = 0.0
	my_tile.seed_grow_time = 0
	full = false
	turns_full = 0
	collecting = false
