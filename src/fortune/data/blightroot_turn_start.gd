extends Fortune

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var blightroot = preload("res://src/fortune/unique/blightroot.tres")
func _init() -> void:
	super("Infestation", FortuneType.MajorBadFortune, "Plant a spreading Blightroot on your farm at the start of each turn")

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	args.farm.use_card_random_tile(blightroot, 1)
