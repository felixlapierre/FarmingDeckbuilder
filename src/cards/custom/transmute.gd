extends CardData
class_name Transmute

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed
var wildflower = load("res://src/fortune/unique/wildflower.tres")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		args.specific.tile.remove_seed()
		args.specific.tile.plant_seed(wildflower.copy())
		args.specific.tile.grow_one_week()
		args.specific.tile.play_effect_particles()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Transmute.new()
	new.assign(self)
	return new
