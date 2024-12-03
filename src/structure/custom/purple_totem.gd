extends Structure
class_name PurpleTotem

var callback: Callable

var event_type = EventManager.EventType.AfterYearStart
var event2 = EventManager.EventType.BeforeTurnStart

func _init():
	super()

func copy():
	var copy = PurpleTotem.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		args.turn_manager.flag_defer_excess = true
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event2, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.unregister_listener(event2, callback)
