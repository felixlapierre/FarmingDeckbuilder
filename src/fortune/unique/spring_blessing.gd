extends Fortune
class_name SpringBlessing

var icon = preload("res://assets/enhance/springbound.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Spring's Blessing", Fortune.FortuneType.GoodFortune, "Draw +1 card per turn in Spring", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week < Global.SUMMER_WEEK:
			args.cards.drawcard()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
