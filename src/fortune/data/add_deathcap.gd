extends Fortune
class_name AddDeathcap

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var deathcap = preload("res://src/fortune/unique/deathcap.tres")
var deathcap_texture = preload("res://assets/fortune/deathcap_fortune.png")
func _init(strength: float = 1.0) -> void:
	super("Death", FortuneType.BadFortune, "On turn start: Plant {STRENGTH} Deathcap on your farm", 2, deathcap_texture, strength)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	args.farm.use_card_unprotected_tile(deathcap, strength)
