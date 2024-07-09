extends Fortune
class_name Wildflowers

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart
var wildflower = preload("res://src/fortune/unique/wildflower.tres")
func _init() -> void:
	super("Wildflowers", FortuneType.GoodFortune, "Start with wildflowers on your farm", 0)

func register_fortune(event_manager: EventManager):
	callback = plant_wildflowers
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_wildflowers(args: EventArgs):
	args.farm.use_card_random_tile(wildflower, 2)
