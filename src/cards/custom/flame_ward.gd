extends CardData
class_name FlameWard

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var harvest_args = EventArgs.HarvestArgs.new(self.strength * args.cards.cards_burned, true, false)
		args.farm.on_yield_gained.emit(harvest_args)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = FlameWard.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
