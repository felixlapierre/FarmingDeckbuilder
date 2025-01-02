extends Structure
class_name Sprinkler

var callback: Callable

var event_type = EventManager.EventType.BeforeYearStart
var event2 = EventManager.EventType.AfterGrow

func _init():
	super()

func copy():
	var copy = Sprinkler.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		for target_tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(target_tile.grid_location, tile.grid_location):
				target_tile.irrigate()
	event_manager.register_listener(event_type, callback)
	#event_manager.register_listener(event2, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	#event_manager.unregister_listener(event2, callback)
