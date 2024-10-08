extends Structure
class_name Harvester

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart

func _init():
	super()

func copy():
	var copy = Harvester.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		for target_tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(target_tile.grid_location, tile.grid_location)\
				and target_tile.state == Enums.TileState.Mature:
				var effects = target_tile.harvest(false)
				args.farm.effect_queue.append_array(effects)
		args.farm.process_effect_queue()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
