extends Fortune
class_name SummerBlessing

var icon = preload("res://assets/custom/Energy.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Summer's Blessing", Fortune.FortuneType.GoodFortune, "+1 energy per turn in Summer", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week >= Global.SUMMER_WEEK and args.turn_manager.week < Global.FALL_WEEK:
			args.turn_manager.energy += 1
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
