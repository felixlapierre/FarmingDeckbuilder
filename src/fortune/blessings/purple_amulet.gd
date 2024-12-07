extends Fortune
class_name PurpleTrinket

var icon = preload("res://assets/custom/PurpleMana16.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Purple Trinket", Fortune.FortuneType.GoodFortune, "[img]res://assets/custom/PurpleMana16.png[/img] is not lost at the end of the 1st and 2nd week", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week == 1 or args.turn_manager.week == 2:
			args.turn_manager.flag_defer_excess = true
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
