extends Structure
class_name PetrifiedTree

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart

func _init():
	super()

func copy():
	var copy = PetrifiedTree.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		for i in range(0, Constants.FARM_DIMENSIONS.y):
			var target_tile = args.farm.tiles[i][tile.grid_location.y]
			if target_tile.grid_location.x != tile.grid_location.x and !target_tile.is_destroyed()\
				and target_tile.state != Enums.TileState.Inactive:
				target_tile.destroy()
		args.turn_manager.energy += 1
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
