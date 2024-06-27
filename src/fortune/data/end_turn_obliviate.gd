extends Fortune

var callable

func _init() -> void:
	super("Thoughtless", FortuneType.TargetGrowingPlants, "Obliviate rightmost card in hand at the end of the turn")

func register_fortune(event_manager: EventManager):
	callable = func(args: EventArgs):
		args.cards.obliviate_rightmost()
	event_manager.register_listener(EventManager.EventType.BeforeGrow, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeGrow, callable)
