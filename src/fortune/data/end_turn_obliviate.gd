extends Fortune

var callable

func _init() -> void:
	super("Thoughtless", FortuneType.BadFortune, "Obliviate rightmost card in hand at the end of the turn", 2)

func register_fortune(event_manager: EventManager):
	callable = func(args: EventArgs):
		args.cards.obliviate_rightmost()
	event_manager.register_listener(EventManager.EventType.BeforeGrow, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeGrow, callable)
