extends Fortune

@export var count: int

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var blightroot = preload("res://src/fortune/unique/blightroot.tres")
var blightroot_texture = preload("res://assets/fortune/blightroot_fortune.png")
func _init() -> void:
	count = 0
	super("Blightroot", Fortune.FortuneType.BadFortune, "Add a Blightroot to your farm", 0, blightroot_texture)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	args.farm.use_card_unprotected_tile(blightroot, 1)
