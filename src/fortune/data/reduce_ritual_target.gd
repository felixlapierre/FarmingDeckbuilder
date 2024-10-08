extends Fortune
class_name ReduceRitualTarget

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart
var image = preload("res://assets/custom/YellowMana.png")

func _init() -> void:
	super("Ritual Attunement", FortuneType.GoodFortune, "Decrease ritual target by 10%", 0, image)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		args.turn_manager.ritual_counter *= 0.9
		args.turn_manager.total_ritual *= 0.9
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
