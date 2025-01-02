extends Fortune
class_name IncreaseRitualTarget

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var image = preload("res://assets/custom/YellowMana.png")

func _init(strength: float = 10.0) -> void:
	super("Ritual Disruption", FortuneType.BadFortune, "Increase ritual target by {STRENGTH}", 0, image, strength)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var increase = strength
		args.turn_manager.ritual_counter += increase
		args.turn_manager.total_ritual += increase
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
