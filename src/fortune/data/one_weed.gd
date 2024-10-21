extends Fortune

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var weeds = preload("res://src/fortune/unique/weed.tres")
var weeds_texture = preload("res://assets/fortune/weed_fortune.png")

var strength = 1

func _init() -> void:
	super("Weeds", FortuneType.BadFortune, "Plant a Weed on your farm", 0, weeds_texture)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	args.farm.use_card_unprotected_tile(weeds, strength)
