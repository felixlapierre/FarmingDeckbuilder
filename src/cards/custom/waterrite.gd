extends CardData
class_name WaterRite

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed
var puffshroom = preload("res://src/cards/data/unique/puffshroom.tres")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.irrigated and tile.state == Enums.TileState.Empty:
				tile.plant_seed_animate(puffshroom.copy())
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = WaterRite.new()
	new.assign(self)
	return new
