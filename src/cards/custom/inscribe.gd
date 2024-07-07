extends CardData
class_name Inscribe

var callback_destroy: Callable
var callback_after_play: Callable
var event_type_destroy = EventManager.EventType.OnPlantDestroyed
var event_type_after_play = EventManager.EventType.AfterCardPlayed

var destroyed: int = 0

func copy():
	var new = Inscribe.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback_destroy = func(args: EventArgs):
		destroyed += 1
	callback_after_play = func(args: EventArgs):
		args.farm.on_card_draw.emit(destroyed, null)
	event_manager.register_listener(event_type_destroy, callback_destroy)
	event_manager.register_listener(event_type_after_play, callback_after_play)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type_destroy, callback_destroy)
	event_manager.unregister_listener(event_type_after_play, callback_after_play)
