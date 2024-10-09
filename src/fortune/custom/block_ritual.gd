extends Fortune

var callback_harvest: Callable
var event_type_harvest = EventManager.EventType.OnPlantHarvest
var event_type_preview = EventManager.EventType.OnYieldPreview
var texture_display = load("res://assets/fortune/BlockRitual.png")

func _init() -> void:
	super("Block", FortuneType.BadFortune, "Prevent gaining " + Helper.mana_icon() + " this turn.", -1, texture_display)

func register_fortune(event_manager: EventManager):
	callback_harvest = func(args: EventArgs):
		if !args.specific.harvest_args.purple:
			args.specific.harvest_args.yld = 0.0
	
	event_manager.register_listener(event_type_harvest, callback_harvest)
	event_manager.register_listener(event_type_preview, callback_harvest)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_harvest, callback_harvest)
	event_manager.unregister_listener(event_type_preview, callback_harvest)
