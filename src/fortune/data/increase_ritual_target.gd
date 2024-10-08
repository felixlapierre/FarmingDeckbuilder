extends Fortune

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var image = preload("res://assets/custom/YellowMana.png")

func _init() -> void:
	super("Ritual Disruption", FortuneType.BadFortune, "Increase ritual target by 10%", 0, image)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var increase = args.turn_manager.total_ritual * 0.1
		args.turn_manager.ritual_counter += increase
		args.turn_manager.total_ritual += increase
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
