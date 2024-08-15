extends Fortune

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart
var weeds = preload("res://src/fortune/unique/weed.tres")
func _init() -> void:
	super("Overgrown", FortuneType.BadFortune, "Entire farm is full of weeds", 1)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	for tile in args.farm.get_all_tiles():
		tile.plant_seed(weeds.copy())
