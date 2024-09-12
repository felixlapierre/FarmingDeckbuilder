extends MageAbility
class_name FireMageFortune

var icon = preload("res://assets/mage/fire_mage.png")

var event_type = EventManager.EventType.BeforeCardPlayed
var event_callable: Callable

func _init() -> void:
	super("Pyromancer", Fortune.FortuneType.GoodFortune, "All cards are Burned when played", 2, icon)

func register_fortune(event_manager: EventManager):
	var burn_effect = load("res://src/effect/data/obliviate.tres")
	event_callable = func(args: EventArgs):
		if true:#Global.selected_card.type == "SEED":
			Global.selected_card.effects.append(burn_effect)
			args.specific.play_args.card.effects.append(burn_effect)
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)
