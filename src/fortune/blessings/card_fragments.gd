extends Fortune
class_name CardFragment

var icon = preload("res://assets/custom/CardFragment.png")
var callback
var event_type = EventManager.EventType.AfterTurnStart

func _init() -> void:
	super("Card Fragment", Fortune.FortuneType.GoodFortune, "Draw an extra card at the start of the first week", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week == 1:
			args.cards.drawcard()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
