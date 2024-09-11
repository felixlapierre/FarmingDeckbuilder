extends MageAbility
class_name BlightMageFortune

var icon = preload("res://assets/custom/Blight.png")

var event_type = EventManager.EventType.BeforeCardPlayed
var event_callable: Callable

func _init() -> void:
	super("Blight Druid", Fortune.FortuneType.GoodFortune, "Start with 2 blight damage", 3, icon)
	modify_deck_callback = func(deck):
		deck.append(load("res://src/cards/data/unique/dark_visions.tres"))

func register_fortune(event_manager: EventManager):
	event_manager.turn_manager.blight_damage = 2

func unregister_fortune(event_manager: EventManager):
	pass
