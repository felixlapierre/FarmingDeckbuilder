extends Fortune
class_name BlockRitual

var callback_harvest: Callable
var event_type_harvest = EventManager.EventType.OnPlantHarvest
var event_type_preview = EventManager.EventType.OnYieldPreview
var texture_display = load("res://assets/fortune/BlockRitual.png")

func _init(strength: float = 1.0) -> void:
	super("Block", FortuneType.BadFortune, "Gain {STR_PER} less " + Helper.mana_icon() + " this turn.", -1, texture_display, strength)

func register_fortune(event_manager: EventManager):
	callback_harvest = func(args: EventArgs):
		if !args.specific.harvest_args.purple:
			args.specific.harvest_args.yld *= (1.0 - strength)
	
	event_manager.register_listener(event_type_harvest, callback_harvest)
	event_manager.register_listener(event_type_preview, callback_harvest)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_harvest, callback_harvest)
	event_manager.unregister_listener(event_type_preview, callback_harvest)
