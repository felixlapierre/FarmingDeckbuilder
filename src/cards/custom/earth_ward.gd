extends CardData
class_name EarthWard

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Empty:
				var harvest_args = EventArgs.HarvestArgs.new(1, true, false)
				args.farm.gain_yield(tile, harvest_args)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = EarthWard.new()
	new.assign(self)
	return new
