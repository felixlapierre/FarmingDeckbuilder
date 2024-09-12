extends MageAbility
class_name BlightMageFortune

var icon = preload("res://assets/custom/Blight.png")
static var MAGE_NAME = "Blight Druid"
var event_type = EventManager.EventType.BeforeCardPlayed
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with 2 blight damage and 1 copy of 'Corruption' in your deck.", 4, icon)
	modify_deck_callback = func(deck):
		deck.append(load("res://src/cards/data/unique/corruption.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	event_manager.turn_manager.blight_damage = 2

func unregister_fortune(event_manager: EventManager):
	pass
