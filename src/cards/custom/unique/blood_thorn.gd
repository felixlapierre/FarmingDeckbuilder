extends CardData
class_name BloodThorn

var event_type = EventManager.EventType.BeforeCardPlayed
var callback: Callable

func copy():
	var new = BloodThorn.new()
	new.assign(self)
	return new

func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		args.turn_manager.target_blight += strength
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
