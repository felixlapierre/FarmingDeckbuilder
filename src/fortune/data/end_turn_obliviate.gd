extends Fortune

var callable

func _init() -> void:
	super("Thoughtless", FortuneType.TargetGrowingPlants, "Obliviate rightmost card in hand at the end of the turn")

func register_fortune(event_manager: EventManager):
	var callable = func(farm: Farm, turn_manager: TurnManager, cards: Cards):
		cards.obliviate_rightmost()
	event_manager.register_on_turn_end(callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_on_turn_end(callable)
