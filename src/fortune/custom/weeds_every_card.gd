extends Fortune
class_name WeedsEveryCard

var callback_card_played: Callable
var event_type_card_played = EventManager.EventType.AfterCardPlayed

var weeds = preload("res://src/fortune/unique/weed.tres")
var texture_display = load("res://assets/fortune/weed_card_fortune.png")

func _init(strength: float = 1.0) -> void:
	super("Overgrowth", FortuneType.BadFortune, "Plant {STRENGTH} weed(s) whenever you play a card", -1, texture_display, strength)

func register_fortune(event_manager: EventManager):
	callback_card_played = plant_weeds
	
	event_manager.register_listener(event_type_card_played, callback_card_played)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_card_played, callback_card_played)

func plant_weeds(args: EventArgs):
	args.farm.use_card_unprotected_tile(weeds, strength)
