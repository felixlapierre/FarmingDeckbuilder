extends CardData
class_name CopperFlower

var tile: Tile

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		if args.specific.tile.is_watered():
			args.turn_manager.energy += strength
			args.user_interface.update()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = CopperFlower.new();
	new.assign(self)
	return new
