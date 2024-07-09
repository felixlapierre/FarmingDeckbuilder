extends Fortune

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart
var weeds = preload("res://src/fortune/unique/weed.tres")
func _init() -> void:
	super("Weeds", FortuneType.BadFortune, "Start with weeds on your farm", 0)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	args.farm.use_card_random_tile(weeds, 4)
