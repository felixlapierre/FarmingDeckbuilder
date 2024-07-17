extends Structure
class_name TemporalRift

var callback: Callable

var event_type = EventManager.EventType.OnPlantHarvest

func _init():
	super()

func copy():
	var copy = TemporalRift.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		if Helper.is_nearby(tile.grid_location, args.specific.tile.grid_location):
			args.specific.harvest_args.delay = true
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
