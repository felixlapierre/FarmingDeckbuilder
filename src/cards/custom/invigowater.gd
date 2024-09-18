extends CardData
class_name Channeling

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.irrigated and (tile.state == Enums.TileState.Growing or tile.state == Enums.TileState.Mature):
				tile.add_yield(strength)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Channeling.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
