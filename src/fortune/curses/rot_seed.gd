extends Fortune
class_name RotSeed

var icon = preload("res://assets/custom/Temp.png")
var callback
var event_type = EventManager.EventType.BeforeYearStart

func _init() -> void:
	super("Rot Seed", Fortune.FortuneType.GoodFortune, "Increase blight attack strength by 15%", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		for i in range(args.turn_manager.blight_pattern.size()):
			args.turn_manager.blight_pattern[i] *= 1.15
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
