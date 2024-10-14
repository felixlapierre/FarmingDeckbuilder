extends CardData
class_name Downpour

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var inc = 0
		for tile in args.farm.get_all_tiles():
			if tile.irrigated:
				inc += strength
		args.specific.tile.add_yield(inc)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Downpour.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
