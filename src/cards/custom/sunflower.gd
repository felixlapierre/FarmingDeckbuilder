extends CardData
class_name Sunflower

var tile: Tile

var callback: Callable
var event_type = EventManager.EventType.AfterGrow

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(p_tile.grid_location, tile.grid_location):
				tile.protected = true
	event_manager.register_listener(event_type, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Sunflower.new();
	new.assign(self)
	return new
