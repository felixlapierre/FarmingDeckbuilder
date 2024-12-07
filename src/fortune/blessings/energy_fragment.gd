extends Fortune
class_name EnergyFragment

var icon = preload("res://assets/custom/EnergyFrag.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Energy Fragment", Fortune.FortuneType.GoodFortune, "Gain an extra energy at the start of the first week", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week == 1:
			args.turn_manager.energy += 1
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
