extends Fortune

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart

func _init() -> void:
	super("Slow Ritual", FortuneType.BadFortune, "Increase ritual target by 10%", 0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		args.turn_manager.ritual_counter *= 1.1
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
